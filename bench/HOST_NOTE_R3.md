# Host note for round 3 (lane p10-11-15, 19 Oct 2026). Logistics only; TASK_R3.md rules are unchanged and binding.

- Host: BASEIMAGE. R: `C:\Program Files\R\R-4.6.0\bin\Rscript.exe` (system library has metafor 5.2.1, metadat 1.6.0,
  robumeta 2.1, clubSandwich 0.7.0, digest). jsonlite is pre-installed by the host in `./Rlib-r3` (your sandbox has no
  network); put it LAST in .libPaths as TASK_R3 says. Python: `py` (Python 3.13); `python` is not on PATH.
- BROWSER AUDIT: the host is already running it (started 11:18 local) with tests/playwright.r3host.config.cjs, which differs
  from playwright.r3.config.cjs only in using the installed Microsoft Edge 151 (channel msedge) because this host has no
  Playwright Chromium. Do NOT start Playwright, an http server, or anything on port 8088. The host writes
  app-original.jsonl, app-patched.jsonl, browser-*.json, ui-*.json, downloads-*/ and browser-host.log; browser-host.json
  gets "exit_code" when it finishes. Do not edit those files.
- Do all numerical R3 work now (Rule C, Rule K, Rule X, acceptance/refusal table, cross-app stats-qt regression, integrity
  hashes, RESULT_R3.md). If browser-host.json has an exit_code by the time you finish, also run the post-processing in
  TASK_R3 (compare.py original/patched, review_final.py, report.py, package_artifacts.py with `py`) and report the browser
  counts; otherwise write in RESULT_R3.md "browser audit: running on host, post-processing pending" and stop.
- multilevel-ma, webr-validator and bma-tau-priors source for the cross-app regression: use `allmeta/` in this folder only if
  present; otherwise use original/ (pre-patch) vs patched/ shared/stats-qt.js with their pages from original/. Record which.
- Never commit/push. Write progress to PROGRESS.md (append an "R3" section).
