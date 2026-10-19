// Host-run R3 browser audit on baseimage (lane p10-11-15, 19 Oct 2026). Identical to playwright.r3.config.cjs except the
// browser channel is the installed Microsoft Edge (Chromium) because this host has no Playwright Chromium download; test
// logic (audit.spec.cjs) is unchanged.
module.exports={testDir:__dirname,testMatch:'audit.spec.cjs',timeout:14400000,workers:2,fullyParallel:true,use:{browserName:'chromium',channel:'msedge',headless:true},webServer:{command:'py -m http.server 8088 --bind 127.0.0.1 --directory ..',url:'http://127.0.0.1:8088',reuseExistingServer:false,timeout:30000},reporter:'line'};
