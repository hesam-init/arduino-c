#!/usr/bin/env node
// Render a Wokwi diagram.json to a PNG wiring picture.
//
//   node render.mjs <diagram.json> <out.png>
//
// Uses the system Chrome; set CHROME=/path/to/chrome to use another browser.

import { readFile } from 'node:fs/promises';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { chromium } from 'playwright-core';

const [input, output] = process.argv.slice(2);
if (!input || !output) {
  console.error('usage: render.mjs <diagram.json> <out.png>');
  process.exit(2);
}

const diagram = JSON.parse(await readFile(input, 'utf8'));
const pageUrl = pathToFileURL(fileURLToPath(new URL('page.html', import.meta.url))).href;

const browser = await chromium.launch({
  executablePath: process.env.CHROME || '/usr/bin/google-chrome-stable',
});
try {
  const page = await browser.newPage({
    viewport: { width: 4000, height: 4000 },
    deviceScaleFactor: 2,
  });
  const errors = [];
  page.on('pageerror', (err) => errors.push(err.message));
  await page.goto(pageUrl);
  if (errors.length) throw new Error(errors.join('\n'));

  const size = await page.evaluate((d) => render(d), diagram);
  await page.setViewportSize(size);
  await page.screenshot({ path: output });
  console.log(`${input} -> ${output} (${size.width}x${size.height})`);
} catch (err) {
  console.error(`${input}: ${err.message.split('\n')[0].replace(/^page\.evaluate: (Error: )?/, '')}`);
  process.exitCode = 1;
} finally {
  await browser.close();
}
