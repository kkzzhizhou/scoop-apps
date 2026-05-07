import { readFileSync, writeFileSync, readdirSync, existsSync } from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

type Manifest = Record<string, unknown> & {
    portableProfile?: PortableProfile;
    post_install?: string | string[];
    pre_uninstall?: string | string[];
};

type PortableProfile = {
    mappings: PortableMapping[];
    options?: {
        module?: string;
        log?: boolean;
    };
};

type PortableMapping = {
    label?: string;
    source: string;
    target: string;
    strategy?: string;
    ensureTarget?: boolean;
    targetType?: "file" | "directory";
};

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, "..");
const srcDir = path.join(repoRoot, "src", "bucket");
const bucketDir = path.join(repoRoot, "bucket");
const defaultModulePath = path.join(repoRoot, "scripts", "portable.psm1");

const moduleCache = new Map<string, string[]>();

function main() {
    const args = process.argv.slice(2);
    const only = parseOnlyArgs(args);

    const entries = readdirSync(srcDir, { withFileTypes: true })
        .filter((entry) => entry.isFile())
        .filter((entry) => entry.name.endsWith(".json") || entry.name.endsWith(".jsonc"));

    const changed: string[] = [];

    for (const entry of entries) {
        const baseName = entry.name.replace(/\.(jsonc?|JSONC?)$/, "");
        if (only && !only.has(baseName)) {
            continue;
        }

        const srcPath = path.join(srcDir, entry.name);
        const outPath = path.join(bucketDir, `${baseName}.json`);
        const manifest = parseJsonc(srcPath);
        const previous = existsSync(outPath) ? readFileSync(outPath, "utf8") : undefined;
        const bucketManifest: Manifest | undefined = previous ? JSON.parse(previous) : undefined;

        // 使用 bucket 中的 version 与 architecture 作为最终结果的权威来源，
        // 并在发生差异时回写到 src，避免旧版本信息覆盖最新版本。
        const mergedManifest = mergeCanonicalFields(manifest, bucketManifest);

        if (bucketManifest && hasCanonicalDiff(manifest, mergedManifest)) {
            const srcSerialized = JSON.stringify(mergedManifest, null, 4) + "\n";
            writeFileSync(srcPath, srcSerialized, "utf8");
        }

        const output = transformManifest(mergedManifest, baseName);
        const serialized = JSON.stringify(output, null, 4) + "\n";

        if (previous !== serialized) {
            changed.push(baseName);
        }

        writeFileSync(outPath, serialized, "utf8");
    }

    const summary = changed.length
        ? `Updated manifests: ${changed.join(", ")}`
        : "No manifest changes";
    console.log(summary);
}

function parseOnlyArgs(args: string[]): Set<string> | undefined {
    const idx = args.findIndex((arg) => arg === "--only" || arg.startsWith("--only="));
    if (idx === -1) return undefined;

    let value: string | undefined;
    const arg = args[idx];
    if (arg.startsWith("--only=")) {
        value = arg.split("=", 2)[1]?.trim();
    } else {
        value = args[idx + 1];
    }

    if (!value) {
        throw new Error("--only 需要指定包名，多个包用逗号分隔");
    }

    return new Set(
        value
            .split(",")
            .map((name) => name.trim())
            .filter(Boolean)
    );
}

function parseJsonc(filePath: string): Manifest {
    const raw = readFileSync(filePath, "utf8");
    const stripped = stripJsonComments(raw);
    return JSON.parse(stripped);
}

function stripJsonComments(input: string): string {
    let output = "";
    let inString = false;
    let stringChar = "";
    for (let i = 0; i < input.length; i++) {
        const char = input[i];
        const next = input[i + 1];

        if (inString) {
            output += char;
            if (char === "\\" && stringChar === "\"") {
                i += 1;
                output += input[i] ?? "";
                continue;
            }

            if (char === stringChar) {
                inString = false;
            }
            continue;
        }

        if (char === "\"" || char === "\'") {
            inString = true;
            stringChar = char;
            output += char;
            continue;
        }

        if (char === "/" && next === "/") {
            i += 2;
            while (i < input.length) {
                const ch = input[i];
                if (ch === "\n" || ch === "\r") {
                    i -= 1;
                    break;
                }
                i += 1;
            }
            continue;
        }

        if (char === "/" && next === "*") {
            i += 2;
            while (i < input.length) {
                if (input[i] === "*" && input[i + 1] === "/") {
                    i += 1;
                    break;
                }
                i += 1;
            }
            continue;
        }

        output += char;
    }

    return output;
}

function transformManifest(manifest: Manifest, pkgName: string): Manifest {
    const cloned: Manifest = JSON.parse(JSON.stringify(manifest));
    const profile = cloned.portableProfile as PortableProfile | undefined;
    delete cloned.portableProfile;

    if (profile) {
        applyPortableProfile(cloned, profile, pkgName);
    }

    return cloned;
}

function applyPortableProfile(manifest: Manifest, profile: PortableProfile, pkgName: string) {
    if (!Array.isArray(profile.mappings) || profile.mappings.length === 0) {
        throw new Error(`portableProfile.mappings 不能为空: ${pkgName}`);
    }

    const templateModulePath = resolveModulePath(profile.options?.module ?? defaultModulePath);
    const templateLines = loadModuleLines(templateModulePath);
    const regionLines = ["#region scoop-portable-profile", ...templateLines, "#endregion"];
    const postInstall = normalizeScriptField(manifest.post_install);
    const preUninstall = normalizeScriptField(manifest.pre_uninstall);

    const installInvoke = buildInvokeBlock("Install", profile);
    const uninstallInvoke = buildInvokeBlock("Uninstall", profile);

    manifest.post_install = [...postInstall, ...regionLines, ...installInvoke];
    manifest.pre_uninstall = [...preUninstall, ...regionLines, ...uninstallInvoke];
}

function resolveModulePath(moduleValue: string): string {
    if (path.isAbsolute(moduleValue)) {
        return moduleValue;
    }
    return path.join(repoRoot, moduleValue);
}

function loadModuleLines(filePath: string): string[] {
    if (!existsSync(filePath)) {
        throw new Error(`找不到 portable 模板：${filePath}`);
    }

    if (moduleCache.has(filePath)) {
        return moduleCache.get(filePath)!;
    }

    const raw = readFileSync(filePath, "utf8");
    const normalized = raw.replace(/^\uFEFF/, "").split(/\r?\n/).map((line) => line.trimEnd()).filter((line) => line.length > 0);
    moduleCache.set(filePath, normalized);
    return normalized;
}

function normalizeScriptField(value: unknown): string[] {
    if (value === undefined) {
        return [];
    }
    if (Array.isArray(value)) {
        return value.map((line) => String(line));
    }
    if (typeof value === "string") {
        return [value];
    }
    throw new Error("post_install/pre_uninstall 字段必须是字符串或字符串数组");
}

function mergeCanonicalFields(src: Manifest, bucket: Manifest | undefined): Manifest {
    if (!bucket) {
        return src;
    }

    const merged: Manifest = JSON.parse(JSON.stringify(src));

    if ((bucket as any).version !== undefined) {
        (merged as any).version = (bucket as any).version;
    }

    if ((bucket as any).architecture !== undefined) {
        (merged as any).architecture = (bucket as any).architecture;
    }

    if ((bucket as any).extract_dir !== undefined) {
        (merged as any).extract_dir = (bucket as any).extract_dir;
    }

    if ((bucket as any).url !== undefined) {
        (merged as any).url = (bucket as any).url;
    }

    if ((bucket as any).hash !== undefined) {
        (merged as any).hash = (bucket as any).hash;
    }

    return merged;
}

function hasCanonicalDiff(src: Manifest, merged: Manifest): boolean {
    const srcVersion = (src as any).version;
    const mergedVersion = (merged as any).version;
    if (srcVersion !== mergedVersion) {
        return true;
    }

    const srcArch = (src as any).architecture;
    const mergedArch = (merged as any).architecture;

    const srcArchJson = srcArch === undefined ? "" : JSON.stringify(srcArch);
    const mergedArchJson = mergedArch === undefined ? "" : JSON.stringify(mergedArch);

    if (srcArchJson !== mergedArchJson) {
        return true;
    }

    const srcExtract = (src as any).extract_dir;
    const mergedExtract = (merged as any).extract_dir;
    const srcExtractJson = srcExtract === undefined ? "" : JSON.stringify(srcExtract);
    const mergedExtractJson = mergedExtract === undefined ? "" : JSON.stringify(mergedExtract);

    if (srcExtractJson !== mergedExtractJson) {
        return true;
    }

    const srcUrl = (src as any).url;
    const mergedUrl = (merged as any).url;
    const srcUrlJson = srcUrl === undefined ? "" : JSON.stringify(srcUrl);
    const mergedUrlJson = mergedUrl === undefined ? "" : JSON.stringify(mergedUrl);

    if (srcUrlJson !== mergedUrlJson) {
        return true;
    }

    const srcHash = (src as any).hash;
    const mergedHash = (merged as any).hash;
    const srcHashJson = srcHash === undefined ? "" : JSON.stringify(srcHash);
    const mergedHashJson = mergedHash === undefined ? "" : JSON.stringify(mergedHash);

    return srcHashJson !== mergedHashJson;
}

function buildInvokeBlock(action: "Install" | "Uninstall", profile: PortableProfile): string[] {
    const mappings = profile.mappings.map(renderMapping); 
    const logFlag = profile.options?.log === false ? "$false" : "$true";

    const lines: string[] = [
        `Invoke-PortableMappings -Action ${action} -Context @{ Dir = $dir; PersistDir = $persist_dir } -Mappings @(`,
        ...mappings.map((mapping, idx) => `    ${mapping}${idx < mappings.length - 1 ? "," : ""}`),
        `) -Log:${logFlag}`,
    ];

    return lines;
}

function renderMapping(mapping: PortableMapping): string {
    if (!mapping.source || !mapping.target) {
        throw new Error("portableProfile.mappings 中的 source 与 target 为必填字段");
    }

    const label = mapping.label ?? mapping.source;
    const strategy = mapping.strategy ?? "symlink";
    const ensure = mapping.ensureTarget !== false;
    const targetType = (mapping.targetType ?? "directory").toLowerCase();
    if (targetType !== "file" && targetType !== "directory") {
        throw new Error(`unsupported targetType '${mapping.targetType}'`);
    }

    return `@{ Label = ${toPsLiteral(label)}; Source = ${toPsLiteral(mapping.source)}; Target = ${toPsLiteral(mapping.target)}; Strategy = ${toPsLiteral(strategy)}; EnsureTarget = ${ensure ? "$true" : "$false"}; TargetType = ${toPsLiteral(targetType)} }`;
}

function toPsLiteral(value: string): string {
    if (value.includes("$")) {
        const escaped = value.replace(/"/g, "`\"");
        return `"${escaped}"`;
    }
    const escaped = value.replace(/'/g, "''");
    return `'${escaped}'`;
}

function normalizeStringArray(value: unknown): string[] {
    if (value === undefined || value === null) {
        return [];
    }

    if (Array.isArray(value)) {
        return value
            .map((item) => String(item).trim())
            .filter((item) => item.length > 0);
    }

    const str = String(value).trim();
    return str ? [str] : [];
}

if (import.meta.main) {
    main();
}
