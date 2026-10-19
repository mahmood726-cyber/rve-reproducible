// R3 browser audit on baseimage: identical to playwright.config.cjs except the web server uses the `py`
// launcher (this host has no `python` on PATH) and the browser is Playwright's bundled Chromium
// (PLAYWRIGHT_BROWSERS_PATH), because this host has no system Chrome. Test logic is unchanged.
module.exports={testDir:__dirname,testMatch:'audit.spec.cjs',timeout:14400000,workers:2,fullyParallel:true,use:{browserName:'chromium',channel:'chromium',headless:true},webServer:{command:'py -m http.server 8088 --bind 127.0.0.1 --directory ..',url:'http://127.0.0.1:8088',reuseExistingServer:false,timeout:30000},reporter:'line'};
