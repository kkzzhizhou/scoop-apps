// Lanzou webdisk -> local file downloader (for DiskGenius CN mirror).
// Requires playwright-core + local Edge. Must run NON-headless (headless
// fingerprint gets challenged by the file CDN).
// Usage: node lanzou-dl.cjs <shareCode> <outFile>
//   e.g. node lanzou-dl.cjs DG64 DG6201829_x64.zip
const { chromium } = require('playwright-core');

const EDGE = 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';

(async () => {
  const [share, out] = process.argv.slice(2);
  if (!share || !out) {
    console.error('usage: node lanzou-dl.cjs <shareCode> <outFile>');
    process.exit(2);
  }
  const browser = await chromium.launch({ executablePath: EDGE, headless: false });
  try {
    const ctx = await browser.newContext({
      userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0',
      extraHTTPHeaders: { Referer: 'https://www.diskgenius.cn/' },
    });
    const page = await ctx.newPage();
    await page.goto('https://eassos.lanzoue.com/' + share, { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForTimeout(3000);

    let frame = page.frames().find(f => f.url().includes('/fn?'));
    if (!frame) {
      await page.waitForTimeout(5000);
      frame = page.frames().find(f => f.url().includes('/fn?'));
    }
    if (!frame) throw new Error('fn iframe not found');

    const href = await frame.locator('a').first().getAttribute('href');
    if (!href) throw new Error('download href not found in iframe');

    const p2 = await ctx.newPage();
    const dlP = p2.waitForEvent('download', { timeout: 90000 }).catch(() => null);
    try {
      await p2.goto(href, { timeout: 30000 });
      throw new Error('page loaded instead of download (challenge?)');
    } catch (e) {
      const d = await dlP;
      if (!d) throw e;
      await d.saveAs(out);
      const size = require('fs').statSync(out).size;
      if (size < 1000000) throw new Error('downloaded file too small: ' + size);
      console.log('OK ' + out + ' ' + size);
    }
  } finally {
    await browser.close();
  }
})().catch(e => { console.error('FAIL: ' + e.message); process.exit(1); });
