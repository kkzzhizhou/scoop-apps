import * as hash from 'hash-wasm';

// via https://codeburst.io/javascript-async-await-with-foreach-b6ba62bbf404
const asyncForEach = async (array, callback) => { 
    for (let index = 0; index < array.length; index++) {
        await callback(array[index], index, array);
    }
}

async function getHash(blob) {
    const data = new Uint8Array(blob)
    const sha1 = await hash.sha1(data);
    const sha256 = await hash.sha256(data);
    const sha512 = await hash.sha512(data);
  
    const hashes = [
      `sha1:${sha1}`,
      `sha256:${sha256}`,
      `sha512:${sha512}`
    ];
  
    return hashes;
  }

export {
   asyncForEach,
   getHash
};