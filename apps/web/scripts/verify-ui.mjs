import assert from 'node:assert/strict';
import { createRequire } from 'node:module';
import { mkdir } from 'node:fs/promises';
import { join } from 'node:path';
import { tmpdir } from 'node:os';

// Use an available Playwright installation; this does not add a runtime dependency.
const { chromium } = createRequire(import.meta.url)('playwright');
const baseURL = process.env.QA_BASE_URL || 'http://localhost:3002';
const output = process.env.QA_OUTPUT_DIR || join(tmpdir(), 'fitflow-visual-qa');
await mkdir(output, { recursive: true });
const browser = await chromium.launch({
  headless: true,
  ...(process.env.QA_BROWSER_PATH ? { executablePath: process.env.QA_BROWSER_PATH } : {}),
});
const results = [];
async function check(name, run) {
  if (process.env.QA_ONLY && !name.includes(process.env.QA_ONLY)) return;
  const context = await browser.newContext({ viewport: { width: 360, height: 800 }, reducedMotion: 'reduce' });
  const page = await context.newPage();
  page.setDefaultTimeout(8000);
  const errors = [];
  page.on('pageerror', (error) => errors.push(error.message));
  try {
    await run(page);
    assert.deepEqual(errors, [], 'No uncaught browser errors');
    results.push({ name, status: 'PASS' });
  } catch (error) {
    await page.screenshot({ path: join(output, `${name.replace(/\W+/g, '-')}-failure.png`) }).catch(() => {});
    results.push({ name, status: 'FAIL', error: error.message, browserErrors: errors });
  } finally {
    await context.close();
    console.log(JSON.stringify(results.at(-1)));
  }
}
async function openPlan(page) {
  await page.goto(baseURL, { waitUntil: 'networkidle' });
  await page.getByRole('button', { name: 'BUILD MY 7 DAYS' }).click();
  await page.locator('.plan-365-action').click();
}

try {
  await check('modal layers block mobile navigation without obscuring dialog actions', async (page) => {
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    await page.locator('.donate-button').click();
    const dialog = page.getByRole('dialog');
    await dialog.waitFor();
    const covered = await page.locator('.mobile-bottom-nav a').first().evaluate((node) => {
      const rect = node.getBoundingClientRect();
      return !node.contains(document.elementFromPoint(rect.x + rect.width / 2, rect.y + rect.height / 2));
    });
    assert.equal(covered, true, 'The backdrop must intercept taps on background navigation');
    await page.screenshot({ path: join(output, 'modal-layer.png') });
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('.donate-button').evaluate((node) => node === document.activeElement), true);
    const visibleMobileBars = await page.locator('.mobile-bottom-nav,.mobile-dock').evaluateAll((nodes) => nodes.filter((node) => node.getClientRects().length).length);
    assert.equal(visibleMobileBars, 1, 'Only one mobile navigation bar should be rendered');
    await page.locator('.mobile-bottom-nav a[href="#library"]').click();
    assert.equal(new URL(page.url()).hash, '#library');
  });

  await check('workout history follows its workout section instead of preceding the hero', async (page) => {
    for (const width of [320, 390, 768, 1024, 1440, 1920]) {
      await page.setViewportSize({ width, height: 900 });
      await page.goto(baseURL, { waitUntil: 'networkidle' });
      const positions = await page.evaluate(() => Object.fromEntries(['#top', '#workouts', '.workout-log-section', '#library']
        .map((selector) => [selector, document.querySelector(selector).getBoundingClientRect().top])));
      assert.ok(positions['.workout-log-section'] > positions['#workouts'], `${width}: history must follow workout actions`);
      assert.ok(positions['.workout-log-section'] < positions['#library'], `${width}: history stays next to workouts`);
    }
  });

  await check('tablet header retains single line labels and usable disclosure navigation', async (page) => {
    for (const width of [768, 1024, 1280]) {
      await page.setViewportSize({ width, height: 900 });
      await page.goto(baseURL, { waitUntil: 'networkidle' });
      const menu = page.getByRole('button', { name: 'Open navigation menu' });
      if (await menu.isVisible()) await menu.click();
      const wrapped = await page.locator('.main-nav a,.donate-button').evaluateAll((nodes) => nodes.filter((node) => {
        const range = document.createRange();
        range.selectNodeContents(node);
        const lines = new Set([...range.getClientRects()].filter((rect) => rect.width).map((rect) => Math.round(rect.top)));
        return lines.size > 1;
      }).map((node) => node.textContent));
      assert.deepEqual(wrapped, [], `${width}: navigation labels should not wrap`);
      await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'EXERCISES', exact: true }).click();
      assert.equal(new URL(page.url()).hash, '#library');
    }
  });

  await check('blocked storage does not prevent browsing or calculator use', async (page) => {
    await page.addInitScript(() => {
      Object.defineProperty(window, 'localStorage', { get() { throw new DOMException('Blocked', 'SecurityError'); } });
    });
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    await page.getByRole('button', { name: 'BUILD MY 7 DAYS' }).click();
    await page.locator('.plan-365-action').waitFor();
    assert.equal(await page.locator('.auth-nav-link').innerText(), 'SIGN IN');
  });

  await check('export error recovery and keyboard modal', async (page) => {
    await openPlan(page);
    const dialog = page.getByRole('dialog');
    await page.keyboard.press('Shift+Tab');
    assert.equal(await dialog.evaluate((node) => node.contains(document.activeElement)), true);
    await page.route('**/api/plan-export', (route) => route.fulfill({ status: 503, body: '{}' }));
    await dialog.getByRole('button', { name: 'DOWNLOAD EXCEL' }).click();
    await dialog.getByRole('alert').waitFor();
    await page.unroute('**/api/plan-export');
    const downloadPromise = page.waitForEvent('download');
    await dialog.getByRole('button', { name: 'DOWNLOAD EXCEL' }).click();
    const download = await downloadPromise;
    assert.equal(download.suggestedFilename(), 'FITFLOW_365_DAYS.xlsx');
    assert.equal(await download.failure(), null);
    await page.keyboard.press('Escape');
    await dialog.waitFor({ state: 'hidden' });
    assert.equal(await page.locator('.plan-365-action').evaluate((node) => node === document.activeElement), true);
  });

  await check('headlines retain white lead and black tail in both themes', async (page) => {
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    for (const theme of ['light', 'dark']) {
      if (theme === 'dark') await page.locator('.theme-toggle').click();
      const colors = await page.locator('.closing h2').evaluate((node) => {
        const tail = [...node.childNodes].find((child) => child.textContent.includes('COUNT.'));
        return { lead: getComputedStyle(node).color, tail: getComputedStyle(tail.nodeType === 1 ? tail : node).color };
      });
      assert.equal(colors.lead, 'rgb(255, 255, 255)', theme);
      assert.equal(colors.tail, 'rgb(21, 21, 21)', theme);
      await page.locator('.closing').screenshot({ path: join(output, `headline-${theme}.png`) });
    }
  });

  await check('primary CTA text contrast across themes and interaction states', async (page) => {
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    for (const theme of ['light', 'dark']) {
      if (theme === 'dark') await page.locator('.theme-toggle').click();
      const actions = page.locator('.red-action');
      for (let i = 0; i < await actions.count(); i += 1) {
        const action = actions.nth(i);
        for (const state of ['default', 'focus', 'hover']) {
          if (state === 'focus') await action.focus();
          if (state === 'hover') await action.hover();
          const ratio = await action.evaluate((node) => {
            const luminance = (rgb) => rgb.match(/[\d.]+/g).slice(0, 3).map(Number)
              .map((value) => value / 255).map((value) => value <= 0.04045 ? value / 12.92 : ((value + 0.055) / 1.055) ** 2.4)
              .reduce((sum, value, index) => sum + value * [0.2126, 0.7152, 0.0722][index], 0);
            const style = getComputedStyle(node);
            const values = [luminance(style.color), luminance(style.backgroundColor)].sort((a, b) => b - a);
            return (values[0] + 0.05) / (values[1] + 0.05);
          });
          assert.ok(ratio >= 4.5, `${theme} ${state}: ${await action.innerText()} contrast ${ratio.toFixed(2)}`);
        }
      }
    }
  });

  await check('catalog search empty retry and exercise details', async (page) => {
    await page.route('**/api/exercises?*', (route) => route.fulfill({ status: 503, body: '{}' }));
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    await page.locator('.catalog-error').waitFor();
    await page.unroute('**/api/exercises?*');
    await page.getByRole('button', { name: 'RETRY', exact: true }).click();
    await page.locator('.exercise-card').first().waitFor();
    await page.getByPlaceholder('Find an exercise').fill('no-such-movement-xyz');
    await page.locator('.empty-catalog').waitFor();
    await page.getByRole('button', { name: 'CLEAR FILTERS', exact: true }).first().click();
    await page.locator('.exercise-card').first().click();
    await page.getByRole('dialog').waitFor();
    assert.match(await page.getByRole('dialog').innerText(), /HOW TO DO IT/);
    await page.keyboard.press('Escape');
    await page.getByRole('dialog').waitFor({ state: 'hidden' });
  });

  await check('local registration profile persistence logout and orphan redirect', async (page) => {
    await page.goto(`${baseURL}/auth?mode=register`, { waitUntil: 'networkidle' });
    await page.getByLabel('NAME', { exact: true }).fill('QA Member');
    await page.getByLabel('EMAIL', { exact: true }).fill('qa@example.test');
    await page.getByLabel('PASSWORD').fill('Example1234');
    await page.getByRole('button', { name: 'CREATE ACCOUNT' }).click();
    await page.waitForURL('**/account');
    assert.equal(await page.getByLabel('NAME', { exact: true }).inputValue(), 'QA Member');
    await page.getByLabel('AGE', { exact: true }).fill('25');
    await page.getByLabel('HEIGHT / CM', { exact: true }).fill('170');
    await page.getByLabel('WEIGHT / KG', { exact: true }).fill('70');
    await page.getByRole('button', { name: 'SAVE PROFILE' }).click();
    await page.getByRole('status').waitFor();
    await page.reload({ waitUntil: 'networkidle' });
    assert.equal(await page.getByLabel('HEIGHT / CM', { exact: true }).inputValue(), '170');
    await page.getByRole('button', { name: 'LOG OUT', exact: true }).click();
    await page.getByRole('dialog').getByRole('button', { name: 'LOG OUT' }).click();
    await page.waitForURL('**/auth');
    await page.getByLabel('EMAIL', { exact: true }).fill('qa@example.test');
    await page.getByLabel('PASSWORD').fill('Example1234');
    await page.getByRole('button', { name: 'SIGN IN' }).click();
    await page.waitForURL('**/account');
    await page.evaluate(() => localStorage.removeItem('fitflow-auth-users'));
    await page.reload({ waitUntil: 'networkidle' });
    await page.waitForURL('**/auth?next=/account');
  });

  await check('profile forms accept decimals and preserve identity after saving', async (page) => {
    await page.goto(`${baseURL}/auth?mode=register`, { waitUntil: 'networkidle' });
    await page.getByLabel('NAME', { exact: true }).fill('Decimal member');
    await page.getByLabel('EMAIL', { exact: true }).fill('decimal@example.test');
    await page.getByLabel('PASSWORD').fill('Example1234');
    await page.getByRole('button', { name: 'CREATE ACCOUNT' }).click();
    await page.waitForURL('**/account');
    await page.getByLabel('HEIGHT / CM').fill('175.5');
    await page.getByLabel('WEIGHT / KG').fill('100.5');
    assert.equal(await page.getByLabel('HEIGHT / CM').evaluate((node) => node.checkValidity()), true);
    assert.deepEqual(await page.getByLabel('DAYS / WEEK').locator('option').evaluateAll((nodes) => nodes.map((node) => node.value)), ['2', '3', '4', '5', '6']);
    await page.getByRole('button', { name: 'SAVE PROFILE' }).click();
    await page.getByRole('status').waitFor();
    await page.reload({ waitUntil: 'networkidle' });
    assert.equal(await page.getByLabel('WEIGHT / KG').inputValue(), '100.5');
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    await page.locator('.auth-nav-link').click();
    const dialog = page.getByRole('dialog');
    await dialog.getByRole('button', { name: 'SAVE PROFILE' }).click();
    await dialog.getByRole('status').waitFor();
    assert.equal(await dialog.getByLabel('NAME', { exact: true }).inputValue(), 'Decimal member');
    await page.evaluate(() => { Storage.prototype.setItem = () => { throw new DOMException('Storage full', 'QuotaExceededError'); }; });
    await dialog.getByRole('button', { name: 'SAVE PROFILE' }).click();
    await dialog.getByRole('alert').waitFor();
    assert.equal(await dialog.getByLabel('NAME', { exact: true }).inputValue(), 'Decimal member');
    await dialog.screenshot({ path: join(output, 'profile-storage-error.png') });
  });

  await check('partly damaged workout logs cannot crash progress or erase valid records', async (page) => {
    await page.goto(`${baseURL}/auth?mode=register`, { waitUntil: 'networkidle' });
    await page.getByLabel('NAME', { exact: true }).fill('History member');
    await page.getByLabel('EMAIL', { exact: true }).fill('history@example.test');
    await page.getByLabel('PASSWORD').fill('Example1234');
    await page.getByRole('button', { name: 'CREATE ACCOUNT' }).click();
    await page.waitForURL('**/account');
    const history = [{ date: new Date().toISOString(), durationSeconds: 1800,
      workoutId: 'qa-session', logs: [null, { exerciseId: 'press', exerciseName: 'Press', weight: 10, sets: 3, reps: 12 }] }];
    await page.evaluate((value) => localStorage.setItem('fitflow-workout-history:history%40example.test', JSON.stringify(value)), history);
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    await page.locator('.exercise-card').first().waitFor();
    await page.getByRole('status').filter({ hasText: 'Some workout records' }).waitFor();
    assert.match(await page.locator('.progress-stat-grid strong').nth(1).innerText(), /^1\s*EXERCISES/);
    assert.equal(await page.locator('.workout-log-item').count(), 1);
    await page.locator('.workout-log-section').screenshot({ path: join(output, 'history-recovery.png') });
    assert.deepEqual(await page.evaluate(() => JSON.parse(localStorage.getItem('fitflow-workout-history:history%40example.test'))), history);
  });

  await check('exercise instructions recover after a failed detail request', async (page) => {
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    await page.route('**/api/exercises/*', (route) => route.fulfill({ status: 503, body: '{}' }));
    await page.locator('.exercise-card').first().click();
    const dialog = page.getByRole('dialog');
    await dialog.getByRole('alert').waitFor();
    await page.unroute('**/api/exercises/*');
    await dialog.getByRole('button', { name: 'RETRY INSTRUCTIONS' }).click();
    await dialog.locator('ol li').first().waitFor();
    assert.ok((await dialog.locator('ol li').first().innerText()).length > 15);
  });

  await check('responsive routes themes and lazy assets', async (page) => {
    const measurements = [];
    for (const width of [320, 360, 414, 768, 1280, 1920]) {
      await page.setViewportSize({ width, height: 900 });
      await page.goto(baseURL, { waitUntil: 'networkidle' });
      for (const theme of ['light', 'dark']) {
        if (theme === 'dark') await page.locator('.theme-toggle').click();
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, `${width} ${theme}`);
        await page.screenshot({ path: join(output, `home-${width}-${theme}.png`) });
      }
      measurements.push(await page.evaluate(() => ({
        width: innerWidth,
        resources: performance.getEntriesByType('resource').length,
        transferredBytes: performance.getEntriesByType('resource').reduce((sum, item) => sum + item.transferSize, 0),
        fullCatalogRequested: performance.getEntriesByType('resource').some((item) => /exercises\.json/.test(item.name)),
      })));
      assert.equal(measurements.at(-1).fullCatalogRequested, false);
    }
    for (const width of [360, 1280]) {
      await page.setViewportSize({ width, height: 900 });
      for (const route of ['about', 'nutrition', 'auth']) {
        await page.goto(`${baseURL}/${route}`, { waitUntil: 'networkidle' });
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true, `${route} ${width}`);
        await page.screenshot({ path: join(output, `${route}-${width}.png`) });
      }
    }
    console.log(JSON.stringify({ measurements }));
  });

  await check('compact header controls do not overlap or clip the wordmark', async (page) => {
    for (const width of [320, 360, 414]) {
      await page.setViewportSize({ width, height: 900 });
      await page.goto(baseURL, { waitUntil: 'networkidle' });
      const controls = await page.locator('.site-header > a,.site-header > button').evaluateAll((nodes) => nodes
        .filter((node) => node.getClientRects().length && getComputedStyle(node).display !== 'none')
        .map((node) => {
          const r = node.getBoundingClientRect();
          return { text: node.textContent, left: r.left, right: r.right, top: r.top, bottom: r.bottom, width: r.width, contentWidth: node.scrollWidth };
        }));
      for (let i = 0; i < controls.length; i += 1) {
        const a = controls[i];
        assert.ok(a.left >= 0 && a.right <= width, `${width}: ${a.text} outside viewport`);
        assert.ok(a.contentWidth <= a.width + 1, `${width}: ${a.text} clipped`);
        for (const b of controls.slice(i + 1)) {
          const overlap = Math.min(a.right, b.right) - Math.max(a.left, b.left) > 1 && Math.min(a.bottom, b.bottom) - Math.max(a.top, b.top) > 1;
          assert.equal(overlap, false, `${width}: ${a.text} overlaps ${b.text}`);
        }
      }
      await page.getByRole('button', { name: 'Open navigation menu' }).click();
      await page.getByRole('navigation', { name: 'Main navigation' }).getByRole('link', { name: 'EXERCISES', exact: true }).click();
      assert.equal(new URL(page.url()).hash, '#library');
      assert.equal(await page.getByRole('button', { name: 'Open navigation menu' }).getAttribute('aria-expanded'), 'false');
    }
  });

  await check('nutrition headline never breaks a word across lines', async (page) => {
    for (const width of [320, 360, 414]) {
      await page.setViewportSize({ width, height: 900 });
      await page.goto(`${baseURL}/nutrition`, { waitUntil: 'networkidle' });
      const lineCount = await page.locator('.menu-generator-heading h2').evaluate((node) => {
        const text = [...node.childNodes].find((child) => child.nodeType === 3 && child.textContent.includes('RANDOMIZE'));
        const start = text.textContent.indexOf('RANDOMIZE');
        const range = document.createRange();
        range.setStart(text, start);
        range.setEnd(text, start + 'RANDOMIZE'.length);
        return range.getClientRects().length;
      });
      assert.equal(lineCount, 1, `${width}: RANDOMIZE must remain a whole word`);
    }
  });

  await check('favicon is compact and mutable assets are revalidated', async (page) => {
    await page.goto(baseURL, { waitUntil: 'networkidle' });
    const iconURL = await page.locator('link[rel="icon"]').getAttribute('href');
    const icon = await page.request.get(new URL(iconURL, baseURL).href);
    assert.equal(icon.status(), 200);
    const bytes = (await icon.body()).length;
    console.log(JSON.stringify({ faviconBytes: bytes }));
    assert.ok(bytes < 20_000, `Favicon transfers ${bytes} bytes`);
    const food = await page.request.get(`${baseURL}/food/items/protein-1.png`);
    assert.equal(food.status(), 200);
    assert.doesNotMatch(food.headers()['cache-control'] || '', /immutable/);
  });
} finally {
  await browser.close();
}
console.log(JSON.stringify({ output, passed: results.filter((item) => item.status === 'PASS').length, total: results.length }));
if (results.some((item) => item.status === 'FAIL')) process.exitCode = 1;
