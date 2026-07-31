import { readFile, writeFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import { Eta } from 'eta';
import logSymbols from 'log-symbols';

import { loadDataset } from './dataset.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const BUCKET_DIR = path.join(ROOT, 'bucket');

const eta = new Eta({
  views: __dirname,
  useWith: true,
  autoEscape: false,
  cache: true,
});

function hashStrings(zip) {
  return [
    `sha1:${zip.hashes.sha1}`,
    `sha256:${zip.hashes.sha256}`,
    `sha512:${zip.hashes.sha512}`,
  ];
}

function renderManifest(entry) {
  const rendered = eta.render('manifest', {
    version: entry.version,
    url: entry.artifacts.zip.url,
    extractDir: `nsis-${entry.version}`,
    hashes: hashStrings(entry.artifacts.zip),
  });
  return JSON.stringify(JSON.parse(rendered), null, 4);
}

async function writeIfChanged(filePath, content) {
  let existing = null;
  try {
    existing = await readFile(filePath, 'utf-8');
  } catch (err) {
    if (err.code !== 'ENOENT') throw err;
  }
  if (existing === content) return 'unchanged';
  await writeFile(filePath, content);
  return existing === null ? 'created' : 'updated';
}

async function emit(outFile, content, stats) {
  const result = await writeIfChanged(outFile, content);
  stats[result] += 1;
  if (result !== 'unchanged') {
    console.log(logSymbols.success, `${result}: ${path.relative(ROOT, outFile)}`);
  }
}

async function main() {
  const dataset = await loadDataset();
  const stats = { created: 0, updated: 0, unchanged: 0 };

  for (const entry of Object.values(dataset.versions)) {
    const out = path.join(BUCKET_DIR, `nsis-${entry.version}.json`);
    await emit(out, renderManifest(entry), stats);
  }

  const aliases = [
    { name: 'nsis.json', version: dataset.latest.stable.v3 },
    { name: 'nsis-2.json', version: dataset.latest.stable.v2 },
  ];
  for (const { name, version } of aliases) {
    if (!version) continue;
    const entry = dataset.versions[version];
    if (!entry) continue;
    await emit(path.join(BUCKET_DIR, name), renderManifest(entry), stats);
  }

  console.log(
    logSymbols.info,
    `${stats.created} created, ${stats.updated} updated, ${stats.unchanged} unchanged`,
  );
}

main().catch((err) => {
  console.error(logSymbols.error, err);
  process.exit(1);
});
