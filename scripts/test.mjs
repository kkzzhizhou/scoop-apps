// Dependencies
import { asyncForEach, getHash } from './shared.mjs';
import { stable, prerelease } from './versions.mjs';
import fs from 'fs/promises';
import isCI from 'is-ci';
import MFH from 'make-fetch-happen';
import path from 'path';
import test from 'ava';

const fetch = MFH.defaults({
  cacheManager: '.cache'
});

const __dirname = path.resolve(path.dirname(''));

const allVersions = [...stable.v2, ...prerelease.v3, ...stable.v3];

// TODO: test all versions
asyncForEach(allVersions, async version => {
  const major = version[0];
  const directory = (/\d(a|b|rc)\d*$/.test(version) === true) ? `NSIS%20${major}%20Pre-release` : `NSIS%20${major}`;
  const url = isCI
    ? `https://downloads.sourceforge.net/project/nsis/${directory}/${version}/nsis-${version}.zip`
    : `https://netcologne.dl.sourceforge.net/project/nsis/${directory}/${version}/nsis-${version}.zip`;

  await test(`NSIS v${version}`, async t => {
    let response = await fetch(url);
    
    if (!response.ok) {
      t.log(response.statusText);
      t.pass('Skipping Test');
    }
    
    const manifest = await fs.readFile(path.join(__dirname, 'bucket', `nsis-${version}.json`), 'utf8');
    const hashes = JSON.parse(manifest).hash;
    const sha512 = hashes.filter(item => item.startsWith('sha512:'))[0];

    const hash = (await getHash(await response.arrayBuffer())).filter(item => item.startsWith('sha512:'))[0];
    const [, actual] = hash.split(':');
    const [, expected] = sha512.split(':');

    t.is(actual, expected);
  });
});
