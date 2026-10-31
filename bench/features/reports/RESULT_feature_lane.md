# P15 lane result

Reports: [UPGRADE_RESULT_P15.md](UPGRADE_RESULT_P15.md) and [CAPABILITIES_DRAFT_P15.md](CAPABILITIES_DRAFT_P15.md), a 118-word paragraph. The audit and handoff are finished; full upgrade validation remains blocked by the explicit gaps below. LANE DONE marks the handoff, not an all-pass validation.

## Changes and source

HEAD is 6740d2f4684e4537667f85577e99fa1ad283c83e. No production source, pinned reference, corpus, preregistration, tolerance or git state was modified. git_objects.py:1 verified packed Git object SHA-1s and derived the 09e169150..HEAD diff when Git could not start. The upgrade report provides production file:line details.

- rveup/compare_rho.py:6, compare_centred.py:10 and compare_rscripts.py:6: only the LANE path was adapted.
- rveup/rho_ref/0311.json: one additional host reference copied; existing 310 files were first matched byte-for-byte. Provenance: evidence/rho_recovery.json.
- rho_audit.py:1: available-reference audit and in-memory plants; original comparison functions and thresholds retained.
- extra_analysis.py:1 and host_numeric.py:1: kappa-band and R-script diagnostics.
- verify_export_current.cjs:1: current/prereg export comparison, with functions V8 replay receipt in evidence/export_current_audit.json.
- build_browser.py:1: 22 inherited plants plus D3 input-CSV truncation, tested by the existing composite D2 assertion because no inherited D3 test exists.
- browser_specs/:1, pw.manager.config.mjs:1, serve_browser.py:1 and run_browser.ps1:1: local browser handoff using config baseURL, per-run logs and reporter counts.
- UPGRADE_RESULT_P15.md:1 and CAPABILITIES_DRAFT_P15.md:1: findings and paper draft.

Progress was saved after steps. evidence/progress_history.md retains the earlier notes; this report corrects the early assumption that the rho comparison completed.

## Evidence

| Check | Result |
|---|---|
| Prereg hashes / fixed input hashes | 3/3; 4/4 |
| Rho known-failure flags | 448/448 |
| New rho reference coverage | 311/448; 137 missing |
| New rho comparisons, available refs only | 14,904/15,020 |
| Existing rho comparisons, complete sample | 42,778/43,088 |
| Real sensitivity strings | 0 usable; 311 errors, 137 missing |
| Engine 1e-8 plant | 1/1 detected |
| Synthetic last-digit check | 1/1; actual R-string plant blocked |
| Centring P1 | 56,265/56,265 |
| Centring P2 | 23,698/23,842; 66 failing configurations |
| Centring P3 | 3,363/3,408; 45 failing configurations |
| Centred kappa <=9e6 prediction | 1,244/1,705 satisfy; 461 violate |
| R exports uncentred / centred / fixtures | 7,561/7,572; 1,350/1,350; 129/129 |
| Input echoes / current column mappings | 353/353; 353/353 |
| Affected exports, current / prior | Current matches 2/2; prior mismatches 2/2 |
| Independent host numeric checks | 50/50 |
| Reproduced result/failure artifacts | 5/5 JSON-object equal |
| Fresh pytest | 0/19 passed; 19 Node initialization failures |
| Historical pytest log | 19/19; not fresh validation |
| Plant pages / HTTP byte checks | 23/23; 27/27 |
| Browser | One attempt; Node failed before browser launch |

Rho failures occur only in known-failure designs. The sensitivity errors are 310 “object of type 'symbol' is not subsettable” and one “infinite or missing values in 'x'”. The synthetic string check cannot replace the requested real-string plant.

All P2/P3 failures lie above uncentred kappa=1e12. P2's all-pass prediction is false, with its stated attribution caveat. P3's <=9e8 agreement prediction passes; high-kappa agreement was not predicted. The all-centred-kappa<=9e6 prediction is false.

u_015 has six null-reference failures from exact-fit nonfinite statistics. u_017 has five finite estimate/SE/CI differences, not null references. The upgrade report lists all 11 and their interpretation.

## Reproduction

From this lane, with PYTHONUTF8=1 for Unicode output:
```text
python inspect_lane.py
python git_objects.py
python verify_provenance.py
python rveup/compare_centred.py
python rveup/compare_rscripts.py
python rho_audit.py
python extra_analysis.py
python host_numeric.py
node verify_export_current.cjs
```

From allmeta/: python -m pytest tests/test_rve.py tests/test_rve_extras.py -q.

CI configures Node 20/Python 3.12, installs pytest/numpy and runs those two pytest files; push is main-only and PRs use path filtering. It does not run the corpus, R or browser gates. No CI execution was observed.

## Browser runs for the manager

```powershell
powershell -NoProfile -File .\run_browser.ps1
```

The runner serves the worktree and plants at 127.0.0.1:8797, uses the requested P15 Playwright CLI, PW_CHANNEL=msedge and --workers=1. It runs the full real-page usability/parity/CR2 suite and every plant. browser_logs/ contains one log per run; summary.log uses PLANT <id> failed=<n> passed=<n>, parsed from reporter output. Missing counts are NA. A failing real baseline prevents interpreting plant failures as defect detection.

The sole attempted command is recorded in evidence/browser_attempt.json. Node, Rscript, PowerShell and Git cannot initialize (0xC0000142); no further browser attempt was made. PowerShell execution remains unverified, while HTTP routing/bytes passed.

## Outstanding

Obtain the missing 137 rho pairs and usable sensitivity outputs for all 448 designs with the pinned R/package versions, preserving current errors. Diagnose the R sensitivity wrapper, run the complete strict comparator and actual last-digit plant, then rerun pytest and the browser handoff in a working native-runtime environment.

No R process completed, no browser behavior was demonstrated, no permission escalation was attempted, and no commit/push was made.

LANE DONE
