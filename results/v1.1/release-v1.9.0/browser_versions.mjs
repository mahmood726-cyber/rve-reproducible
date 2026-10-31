// Print the exact browser builds used by the archive rerun (same Playwright install as the specs).
import { chromium, firefox, webkit } from '@playwright/test';
import { createRequire } from 'node:module';
const req = createRequire(import.meta.url);
console.log('playwright', req('@playwright/test/package.json').version, 'node', process.version);
for (const [name, type, opts] of [['msedge', chromium, { channel: 'msedge' }], ['chromium', chromium, {}], ['firefox', firefox, {}], ['webkit', webkit, {}]]) {
  const b = await type.launch(opts);
  console.log('browser', name, b.version());
  await b.close();
}
