import { readFile } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

import test from 'ava';

import { loadDataset } from './dataset.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const BUCKET_DIR = path.join(ROOT, 'bucket');

const dataset = await loadDataset();

for (const entry of Object.values(dataset.versions)) {
  test(`bucket/nsis-${entry.version}.json matches dataset`, async (t) => {
    const file = path.join(BUCKET_DIR, `nsis-${entry.version}.json`);
    const manifest = JSON.parse(await readFile(file, 'utf-8'));

    t.is(manifest.version, entry.version);
    t.is(manifest.url, entry.artifacts.zip.url);
    t.deepEqual(
      manifest.hash.sort(),
      [
        `sha1:${entry.artifacts.zip.hashes.sha1}`,
        `sha256:${entry.artifacts.zip.hashes.sha256}`,
        `sha512:${entry.artifacts.zip.hashes.sha512}`,
      ].sort(),
    );
  });
}

for (const [aliasName, version] of [
  ['nsis.json', dataset.latest.stable.v3],
  ['nsis-2.json', dataset.latest.stable.v2],
]) {
  if (!version) continue;
  const entry = dataset.versions[version];
  if (!entry) continue;
  test(`bucket/${aliasName} points at latest ${entry.version}`, async (t) => {
    const file = path.join(BUCKET_DIR, aliasName);
    const manifest = JSON.parse(await readFile(file, 'utf-8'));
    t.is(manifest.version, entry.version);
    t.is(manifest.url, entry.artifacts.zip.url);
  });
}
