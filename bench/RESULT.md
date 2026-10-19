> **Historical report (17 Oct 2026, before the browser audit ran).** Its integrity line (16295/16301; 6 failing) predates the browser captures. After the 19 Oct browser audit, review_final.py reports 16301/16301 evidence-integrity checks passing; see results/browser/ and README.md.

# Job 17 resume result

**Non-browser audit completed; strict numerical failures and deferred browser validation remain blockers.** No tolerance waivers, regenerated datasets, commits or pushes. The source clone was not edited.

| Command | Exact result |
|---|---|
| `python run_references.py` | Exit 0; 16270/16270 reference files already present; 0 recomputed |
| `python reference_cache.py` | 16270/16270 existing reference byte hashes and source stamps verified; 0 fits recomputed |
| `node engine_full.cjs original --extend` | 16270/16270 captures; 5873 appended to existing 10397 |
| `python compare_engine.py original` | 511964/546655 pass; 34691 fail |
| `python compare.py original` | 16272/32542 pass; 16270 fail; 0/16270 browser captures |
| `node engine_full.cjs patched --extend` | 16270/16270 captures; 5881 appended to existing 10389 |
| `python compare_engine.py patched` | 543519/546941 pass; 3422 fail |
| `python compare.py patched` | 16272/32542 pass; 16270 fail; 0/16270 browser captures |
| `python verify_metadata.py` | 223/223 pass |
| `python dataset_ledger.py` | 118 included; 1 excluded datasets |
| `python diagnose_failures.py` | original: 34691 failed checks across 11921 cases; patched: 3422 failed checks across 1037 cases |
| `python review_final.py` | 16295/16301 integrity checks pass; 6 fail |
| `python report.py` | Exit 0; blocked-browser report generated in RESULTS.md and results.json |
| `python package_artifacts.py` | 17366 files in rve-validation.zip; SHA-256 manifest included |

The comparison scripts report failed checks in their JSON output even when their process exit code is 0. Final-review failures:

- original complete ordered page coverage
- original browser metadata
- original focused tests
- patched complete ordered page coverage
- patched browser metadata
- patched focused tests

Still unrun: the host Playwright command in BROWSER_TODO.md; all real browser parser, display, control and export tests. The browser comparison commands above executed against missing captures and do not count as browser execution. After the host supplies evidence, rerun the comparisons, review and report and refresh this summary/archive.

Strict numerical failures are diagnosed in STRICT_DIAGNOSIS.md and strict-diagnosis.json, with full unaltered failures in engine-failures-full-original.json and engine-failures-full-patched.json. Detailed scope, limitations and before/after tables are in RESULTS.md. Proposed app changes are in fix.patch.

| Item | Static or dynamic |
|---|---|
| Rho grid and strict tolerances | Static task requirements |
| Eligibility and diagnostic labels | Static disclosed audit rules |
| Counts, fit results and provenance hashes | Dynamic on-disk evidence and execution |
