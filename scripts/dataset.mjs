import { readFile } from 'node:fs/promises';

const DEFAULT_URL = 'https://nsis-dev.github.io/release-data/versions.json';

export async function loadDataset() {
  const file = process.env.NSIS_DATA_FILE;
  if (file) {
    return JSON.parse(await readFile(file, 'utf-8'));
  }
  const url = process.env.NSIS_DATA_URL || DEFAULT_URL;
  const res = await fetch(url);
  if (!res.ok) {
    throw new Error(`fetch ${url}: ${res.status} ${res.statusText}`);
  }
  return res.json();
}
