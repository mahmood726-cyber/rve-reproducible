// Archive rerun on the allmeta v1.9.0 bytes (d38d3fd). Differs from playwright.config.mjs only in the project list
// (Edge, bundled Chromium, Firefox, WebKit) and reuseExistingServer: false.
import { defineConfig, devices } from '@playwright/test';
const rve = /rve-meta-.*\.spec\.mjs$/;
const render = /rve-meta-wasm-render\.spec\.mjs$/;
export default defineConfig({
  testDir: '.',
  testMatch: '*.spec.mjs',
  timeout: 30_000,
  workers: 1,
  use: { baseURL: 'http://localhost:8088' },
  projects: [
    { name: 'msedge', testMatch: rve, use: { ...devices['Desktop Edge'], channel: 'msedge' } },
    { name: 'chromium', testMatch: rve, use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', testMatch: render, use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', testMatch: render, use: { ...devices['Desktop Safari'] } },
  ],
  webServer: {
    command: 'python -m http.server 8088 --bind 127.0.0.1 --directory ../../../',
    port: 8088, cwd: '.', reuseExistingServer: false, stdout: 'ignore', stderr: 'ignore',
  },
});
