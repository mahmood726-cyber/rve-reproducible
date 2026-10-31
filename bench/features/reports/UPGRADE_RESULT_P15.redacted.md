# Paper 15: rve-meta upgrade evidence at 6740d2f

The centring and R-script comparisons reproduce the stored results exactly, including failures. **The full upgrade is not yet validated:** 137/448 rho reference files are missing, all 311 available sensitivity outputs are errors, and this environment cannot initialize Node, Rscript or Git. The requested fresh unit/browser passes and real sensitivity-string plant remain outstanding. No production code, pinned reference, preregistration, tolerance or configuration set was changed.

## Source identity and preregistrations

Branch ref: feat/rve-meta-usability-centring; full HEAD 6740d2f4684e4537667f85577e99fa1ad283c83e. Base 09e169150c23e1c6a35bbdf10a3a31cf1eea5023.

Git CLI commands failed with Windows initialization status 3221225794 (0xC0000142). As a read-only fallback, git_objects.py decoded the repository's pack/index and checked each decoded object's Git SHA-1. It recovered both trees and their unified diff in evidence/upgrade_diff_python.txt. All seven changed working files match HEAD after line-ending normalization; rve.js and stats-qt.js are unchanged between these commits. Evidence: evidence/git_verification.json. This is a verified object-tree diff, not a successful git diff CLI run.

All preregistration SHA-256 values match their sibling .sha256 files, 3/3:

| File | SHA-256 |
|---|---|
| rveup/PREREG_CENTRING.md | 16d0e9133819fd33c9fdfe124470d15c2c82e5171e6174cea9dc3c6c4446a898 |
| rveup/PREREG_RSCRIPT_SAMPLE.md | 3c543ee02fbe227b19028ca5efe8d39a90fc7f48c4feb1d86923556afd8056a2 |
| rveup/PREREG_RHO.md | f99ee8c15bac95724689a50d909068a22d5171354674d8103a1d221a6aeb745b |

The population configurations hash is 91b6f6fe0935e36650a0bcb13126937f7ed978ad2d9535b9ebdbded8db0f3b73. The conditioning CSV, fixed centring IDs and centred configurations also match their recorded hashes, 4/4 input hashes overall (evidence/provenance.json). All 448 sampled known-failure flags match the pinned conditioning CSV using failures at rho 0.5 or 0.8.

| Engine file | Committed/current LF SHA-256 | Recorded validation SHA-256 | Finding |
|---|---|---|---|
| shared/rve.js | ee2e2eb93663a65dcd6b525735481da4584ca9802a7c678706d3b4185150eb61 | c12a87ce03827a20c47ec97a4ec70dec72aeb1adcd66f8dd0294538aaf6b61ac | Recorded bytes are CRLF; converting current LF to CRLF reproduces the recorded hash exactly |
| shared/stats-qt.js | 67a1094959b4a2227f947c228068753be7d6cc825b1191047226bd2e6d1a2c65 | fb4110ba8e4b2e784193fde258ac37086713dc8d75a3295f84272d6fbdba8efb | Same CRLF/LF distinction |
| shared/rve-extras.js | e24c34ba4abdbcfcb9514523274824082b668a1220e82dfb3e994670db05518c | e24c34ba4abdbcfcb9514523274824082b668a1220e82dfb3e994670db05518c | Exact match to rho preregistration and rho engine metadata |

Against rveup/engine/, all three files have identical text after CRLF normalization. Against rveup/rve-extras.prereg.js (cbfa4153de181b4aa814b694d29804f8b2e676a9dfc3f35d3805f6ab1ec4ef4f), the only changes are:
- Added RHO_GRID, rhoSensitivity (shared/rve-extras.js:219), toRhoSensitivityCSV (:241), and their public exports (:487).
- Expanded reserved names in rColumnNames (:275), adding robu-internal names such as study, studynum, k, weights, pred, e, userweights, ImH and predictor_labels.
- No change to centreRows (:199), xtwx (:178) or kappaXtWX (:188), or their core numerical callees. Those changes are outside the centring-validation path; its engine step does not require rerunning.
- rColumnNames is on the toRScript (:301) path. The R-script preregistration itself does not pin an extras hash. Current-function replay in the functions V8 isolate verifies 353/353 sampled column mappings. Only u_132 and u_185 differ under the earlier prereg snapshot; both complete scripts regenerated with current code equal the stored scripts exactly (2/2), whereas the earlier implementation fails both comparisons (2/2 defects detected). Thus the stored R executions correspond to the current affected exports. This replay is explicitly not a fresh Node or R run. Reproduction: node verify_export_current.cjs; receipt: evidence/export_current_audit.json.

## Changes introduced since 09e169150

| File:line at HEAD | Change |
|---|---|
| shared/rve-extras.js:86 | Header-aware CSV/TSV/semicolon parsing, quoted fields, SE input and specific row/column errors |
| shared/rve-extras.js:178 | Fitted-weight condition number and arithmetic predictor centring |
| shared/rve-extras.js:219 | Six-point rho refits, sign/significance flags and sensitivity CSV |
| shared/rve-extras.js:254 | R string escaping, safe predictor names and executable R-script construction |
| shared/rve-extras.js:368 | Structured result, named coefficient/input CSV and reproducibility report |
| rve-meta/index.html:27 | Navigation clearance and responsive layout; table scrolling at :53 |
| rve-meta/index.html:93 | robumeta corrdat example, with small example retained |
| rve-meta/index.html:289 | Centring control; kappa warning/refit logic at :406 |
| rve-meta/index.html:302 | Live result status; semantic coefficient table and low-df warning (:427) |
| rve-meta/index.html:367 | Actionable engine refusals; predictor-name mismatch display at :399 |
| rve-meta/index.html:456 | Sensitivity display; export handlers at :492 |
| rve-meta/index.html:508 | Form submission refits; autosave restoration refits at :554 |
| tests/test_rve.py:1 | Updated numerical-engine tests/documentation |
| tests/test_rve_extras.py:36 | Parser, conditioning, centring and script tests; reserved-name regression at :134 |
| hub/shared/tests/rve-meta-usability.spec.mjs:1 | Usability and feature browser assertions |
| .github/workflows/rve-integrity.yml:1 | CI job for the two Node-backed pytest modules |
| rve-meta/README.md:1 | Updated feature and convention documentation |

## Rho sensitivity: observed evidence and gaps

Sample: 448 designs, 28 with a known strict-gate failure. The lane originally contained only 310 new-reference files. All 310 are byte-identical to the host originals. One additional existing host file (0311.json) was copied after verifying its design identity; provenance and SHA-256 are in evidence/rho_recovery.json. No existing reference was edited. Files 0312 through 0448 remain missing: 137 designs / 274 new rho fits.

The unchanged comparator, with its machine path adapted, stops at missing 0312.json (evidence/compare_rho.py.log). rho_audit.py adds availability guards in memory only; it preserves every sample and the comparator's quantities, scaling and tolerances, checks all four existing lane-rho references for all 448 designs, and the two new references for the 311 available designs. Missing and erroneous evidence is explicitly outside the numerical denominators.

All 311 available sens fields contain errors: 310 report “object of type 'symbol' is not subsettable”; one reports “infinite or missing values in 'x'”. There are **no rounded sensitivity strings to validate**. The old R wrapper's sensitivity() branch failed independently of its numeric fits. Rscript cannot initialize here, so these failures were not repaired or relabelled as passes.

| Group | Designs covered | No known failure: passes/checks | Known failure: passes/checks | Failing designs |
|---|---:|---:|---:|---:|
| new_refs_04_06 | 311 | 13928/13928 | 976/1092 | 21 |
| lane_refs_0_02_08_1 | 448 | 40176/40176 | 2602/2912 | 27 |
| sensitivity_strings | 0 | 0/0 | 0/0 | 0 |

The available new-reference total is 14,904/15,020; the complete existing-reference total is 42,778/43,088. Every numeric failure is in a pre-identified known-failure design (21 new-reference failing designs, 27 existing-reference failing designs). This supports the numeric prediction within the observed coverage; it does not establish it for the missing new references. The rounded-string prediction is untested; 0/0 is no evidence of agreement.

Per-quantity values below use relative-scaled |app-ref|/max(1,|ref|), except absolute p/CI differences; status uses exact equality. These are the original comparator's maxima over finite differences, so null/nonfinite failures do not inflate the displayed maximum. All quantities are reported, including known-failure quantities that passed.

### new_refs_04_06
| Quantity | No known failure: passes/checks | Max difference | Known failure: passes/checks | Max difference |
|---|---:|---:|---:|---:|
| ci_hi | 1064/1064 | 4.32137881035e-10 | 52/84 | 4.67674794891e-07 |
| ci_lo | 1064/1064 | 7.81385622872e-10 | 56/84 | 4.04344859817e-07 |
| club_df | 1064/1064 | 5.81171744812e-12 | 78/84 | 60.3324933955 |
| club_estimate | 1064/1064 | 2.36445855355e-11 | 82/84 | 1.04385978003e-09 |
| club_p | 1064/1064 | 2.9937163859e-11 | 76/84 | 0.0874104268522 |
| club_se | 1064/1064 | 6.12756829444e-11 | 82/84 | 1.19271615675e-09 |
| club_t | 1064/1064 | 8.27202530425e-11 | 72/84 | 0.570315157005 |
| df | 1064/1064 | 7.55401314836e-12 | 80/84 | 2.51110789011e-09 |
| estimate | 1064/1064 | 2.36445855355e-11 | 82/84 | 1.04385978003e-09 |
| p | 1064/1064 | 2.53913834403e-11 | 78/84 | 0.0802097383 |
| se | 1064/1064 | 4.95037072844e-11 | 84/84 | 7.39976684895e-10 |
| status | 580/580 | 0 | 42/42 | 0 |
| t | 1064/1064 | 7.09483498854e-11 | 70/84 | 0.570315157005 |
| tau2 | 580/580 | 1.06026298852e-14 | 42/42 | 7.6246949507e-11 |

### lane_refs_0_02_08_1
| Quantity | No known failure: passes/checks | Max difference | Known failure: passes/checks | Max difference |
|---|---:|---:|---:|---:|
| ci_hi | 3068/3068 | 4.32137881035e-10 | 143/224 | 5.83883775107e-07 |
| ci_lo | 3068/3068 | 7.81385622872e-10 | 144/224 | 7.75270564191e-07 |
| club_df | 3068/3068 | 4.61995895121e-12 | 212/224 | 60.6308199835 |
| club_estimate | 3068/3068 | 2.93710072966e-11 | 220/224 | 1.04385978003e-09 |
| club_p | 3068/3068 | 2.9937163859e-11 | 204/224 | 0.0974633051839 |
| club_se | 3068/3068 | 6.12756829444e-11 | 215/224 | 1.76706707103e-09 |
| club_t | 3068/3068 | 8.27202530425e-11 | 184/224 | 0.570315157005 |
| df | 3068/3068 | 9.33575747336e-12 | 216/224 | 2.51110789011e-09 |
| estimate | 3068/3068 | 2.93710072966e-11 | 220/224 | 1.04385978003e-09 |
| p | 3068/3068 | 2.53913834403e-11 | 208/224 | 0.097463305184 |
| se | 3068/3068 | 4.95037072844e-11 | 224/224 | 6.63740452e-10 |
| status | 1680/1680 | 0 | 112/112 | 0 |
| t | 3068/3068 | 7.09483498854e-11 | 188/224 | 0.570315157005 |
| tau2 | 1680/1680 | 3.51073337068e-14 | 112/112 | 7.62473766337e-11 |

sensitivity_strings: coefficient, SE and tau2 each have zero checks in both groups; maxima are not available.

Plant evidence (evidence/rho_plants.json): an engine coefficient multiplied by 1+1e-8 produces an additional strict comparison failure, **1/1 detected**. A separate synthetic string fixture changes only its final decimal digit and is detected by the original rounding comparator, **1/1 synthetic check**. The requested perturbation of an actual R sensitivity string is **blocked**, because none exists. The synthetic check is not substituted for that required validation. Both plants run in memory without editing source evidence.

## Centring

The comparator output, failure lists and kappa rows are JSON-object-identical to the inherited files, 3/3 artifact comparisons. All 1,705 centred engine/R statuses are ok; all 1,705 echoed input designs match exactly.

| Gate | Passes/checks | Failing configurations | Prediction assessment |
|---|---:|---:|---|
| P1 centred engine vs centred R | 56,265/56,265 | 0 | Predicted complete agreement observed |
| P2 invariant quantities vs uncentred R | 23,698/23,842 | 66 | Prediction that every check passes is false; preregistered conditioning caveat applies |
| P3 centred kappa | 1,705/1,705 | 0 | Predicted relative agreement at 1e-6 observed |
| P3 uncentred kappa <=9e8 | 800/800 | 0 | Predicted agreement observed |
| P3 uncentred kappa >9e8 | 858/903 | 45 | No agreement was predicted in this band |
| P3 total | 3,363/3,408 | 45 | Includes the unrestricted high-kappa band |

Two uncentred R refusals are separately excluded from P2 and uncentred P3. Both centred fits succeed. The following bands use R's uncentred fitted-weight kappa; thus their denominator is 1,703.

| Uncentred kappa band | Configurations | kappa*u range (u=2^-53) | P2 failed checks / configurations | P3 failed checks / configurations |
|---|---:|---:|---:|---:|
| <=9e8 | 800 | 1.02e-09–9.78e-08 | 0 / 0 | 0 / 0 |
| (9e8,1e10] | 75 | 1.61e-07–7.83e-07 | 0 / 0 | 0 / 0 |
| (1e10,1e12] | 413 | 1.15e-06–9.61e-05 | 0 / 0 | 0 / 0 |
| >1e12 | 415 | 0.000119–0.00181 | 144 / 66 | 45 / 45 |

All P2/P3 failures occur above kappa=1e12. That location is consistent with the pre-stated forward-error caveat; it does not prove which calculation is responsible. P2's maximum observed comparator discrepancy is approximately 6.59e-9. P3's maximum uncentred relative discrepancy is approximately 1.94e-6; centred agreement reaches approximately 5.94e-11.

**The prediction that every centred kappa is <=9e6 is false: 461/1,705 exceed it; only 1,244/1,705 satisfy it.** The maximum centred kappa is 266,701,347,402.04095. Centring improved the observed numerical comparison but did not make every design well conditioned. The prediction is not reinterpreted as merely improvement. Full per-quantity counts/maxima: rveup/centring_results.json and evidence/compare_centred.py.log.

## R-script export

These are fresh comparisons of existing R outputs, not fresh R executions. Recorded reference stack: R 4.6.0, robumeta 2.1, clubSandwich 0.7.0. Numeric conventions and 1e-9 tolerance are unchanged.

| Stratum | Scripts with successful stored R output | Exact input echoes | Passes/checks | Failing scripts |
|---|---:|---:|---:|---:|
| Uncentred | 300/300 | 300/300 | 7,561/7,572 | 2 |
| Centred | 50/50 | 50/50 | 1,350/1,350 | 0 |
| Fixtures | 3/3 | 3/3 | 129/129 | 0 |
| Total | 353/353 | 353/353 | 9,040/9,051 | 2 |

The 11 failures are not all null-reference checks. Six belong to the exact-fit u_015; five are finite discrepancies in ill-conditioned u_017. All are retained as failures.

| Script / coefficient | Quantity | Script value | Pinned reference | Comparator difference |
|---|---|---:|---:|---:|
| u_015 / intercept | t | -4.2659207618695758 | null | null |
| u_015 / intercept | prob | 0.00022502424570913782 | null | null |
| u_015 / intercept | club_tstat | -4.2659207618695678 | null | null |
| u_015 / intercept | club_p_Satt | 0.00022502424570917387 | null | null |
| u_015 / slope | t | 18365860067306596 | null | null |
| u_015 / slope | club_tstat | 18365860067306540 | null | null |
| u_017 / intercept | b.r | -6.766432466727565 | -6.766432457981864 | 1.2925128724120813e-09 |
| u_017 / intercept | SE | 32.661739892458471 | 32.661739853768303 | 1.1845715411198088e-09 |
| u_017 / intercept | CI.L | -77.886302071581483 | -77.886301977742121 | 9.3839361170466873e-08 |
| u_017 / intercept | CI.U | 64.353437138126353 | 64.353437061778394 | 7.6347959065969917e-08 |
| u_017 / intercept | club_beta | -6.766432466727565 | -6.766432457981864 | 1.2925128724120813e-09 |

u_015 is dat.bakdash2021::001::Author::es.z::rho=0.8, an exact-fit design with yi equal to the moderator. The ideal intercept is 0, slope 1 and residual-based SEs 0. In the pinned computation, intercept t is 0/0 (NaN), its p is undefined, and slope t is infinite; JSON serializes these nonfinite values as null (also in clubSandwich). A separate host fit leaves binary64 residuals around machine precision, producing intercept -1.11e-16, SE 2.60e-17, t -4.2659 and p 0.000225, and slope t about 1.836586e16. These finite residual ratios are not evidence of meaningful inferential accuracy for a degenerate exact fit.

The current app core, replayed in the functions V8 isolate, gives intercept 0, slope 1, both SEs 0, nonfinite t statistics, intercept p nonfinite and slope p 0. That is consistent with the exact-fit algebra and pinned reference convention. A finite t near 1.8e16 is not a uniquely correct target. No claim that the app is more accurate than R is warranted.

u_017 is dat.baker2009::001::studlab::year::rho=0.5; its five failing reference values are finite. The generated R script differs from the older pinned uncentred calculation at 1.18–1.29e-9 scaled estimate/SE differences and 7.63–9.38e-8 absolute CI differences. A hand-written same-host R diagnostic reproduces every checked numeric value of the generated script: 25/25 for u_015 and 25/25 for u_017 (evidence/host_numeric.json). This supports the exporter reproducing that host's R fit, not exact agreement across the strict pinned-reference gate. Label differences are excluded only from this additional numeric host comparison. No pinned comparison was changed. Input fidelity passes, so lost input precision is not the explanation; these artifacts support sensitivity of ill-conditioned floating-point fits, without identifying a particular BLAS or platform operation as the cause.

## Unit tests and CI

Requested command, from allmeta/: python -m pytest tests/test_rve.py tests/test_rve_extras.py -q.

Fresh outcome: **0/19 passed, 19 failed**, all at Node process initialization with return code 3221225794 and no Node output. The raw trace is evidence/pytest.log; this is an environment failure, not evidence of numerical regressions. The inherited rveup/pytest_final.log reports **19/19 passed in 9.60s**, but cannot replace a fresh run here. No separate rve-named standalone Node test suite was found; these pytest tests launch Node and the three browser specs also use Node.

.github/workflows/rve-integrity.yml:30 sets up Node 20 and Python 3.12, installs pytest and numpy, and runs precisely those two pytest files at :38. Push trigger is restricted to main; pull requests have no branch restriction. Both use explicit paths for the core, extras, stats, page, tests and workflow. It does what its comment says for engine/extras unit tests. It does not run the preregistered corpora, R scripts, browser usability/parity specs or planted defects. No CI execution was observed.

## Browser runs for the manager

Run from this lane:
```powershell
powershell -NoProfile -File .\run_browser.ps1
```

run_browser.ps1:1 starts a hidden Python server on 127.0.0.1:8797 and stops its own server in finally. serve_browser.py:1 serves the worktree and plants with shared assets; all 27 tested HTTP routes return exact expected bytes (27/27). It refuses an already occupied port. The PowerShell script sets PW_CHANNEL=msedge and uses <HOST>/p101115\P15\tests\node_modules\@playwright\test\cli.js with --workers=1.

The first run includes full usability, parity and CR2 parity specs on the real page. Each subsequent run selects its plant's assertion(s). One log per run goes to browser_logs/; summary lines have PLANT <id> failed=<n> passed=<n>, parsed from Playwright's reporter text, not the process exit. If no reporter counts exist, NA is written and the run is marked UNVALIDATED. A non-green real-page baseline prevents interpretation of plant failures as demonstrated defect detection.

build_browser.py:1 rebuilt the supplied 22 plants from the verified 6740d2f page. The inherited manifest and suite omit D3. To cover the requested D1–D18 list, an additional D3 page truncates input CSV and uses the existing composite D2 export assertion; it is explicitly not an inherited D3-labelled test. There are 23 pages total (18 numbered plus EX, CL, KA, RH, RS), with hashes in evidence/plants_build.json. Local spec copies in browser_specs/ change only package import/navigation plumbing to use the installed Playwright module and config baseURL; production spec assertions are retained. No claim of 23/23 detected browser plants is made.

Exactly one single-spec command was attempted here (evidence/browser_attempt.json). Node failed before any browser launch, so no browser reporter counts exist. There were no further browser attempts. PowerShell syntax/execution also remains untested because that executable cannot initialize. HTTP routing and asset identity are evidenced; browser behavior is not.

## Reproduction and outstanding work

Python commands from this lane:
```text
python inspect_lane.py
python git_objects.py
python verify_provenance.py
python rveup/compare_centred.py
python rveup/compare_rscripts.py
python rho_audit.py
python extra_analysis.py
python host_numeric.py
```

Set PYTHONUTF8=1 on Windows when running scripts that print Unicode. The three original comparators differ only in their LANE path (:7 or :10); archived references, configurations and preregistrations remain untouched. build_browser.py rebuilds assets, and verify_browser_assets.py applies baseURL navigation and verifies HTTP routes. verify_export_current.cjs reproduces the current-name/script checks when Node can run. Source-object extraction is read-only.

Before claiming completion of the upgrade validation:
1. Generate/obtain the missing 137 rho reference pairs with the prescribed R 4.6.0 / robumeta 2.1 / clubSandwich 0.7.0 environment. Diagnose the sensitivity-wrapper error and generate actual rounded sensitivity outputs in a new evidence directory; retain existing errors.
2. Run the complete strict rho comparator and the actual one-last-digit sensitivity-string plant. The current synthetic check is insufficient for that claim.
3. Run the requested pytest command and the manager browser runner in a working native-runtime environment. Use the actual printed counts, including failures.

No R process completed here; no browser passed here; no git changes were committed or pushed. Reports and runner preparation are complete, with the above validation gaps explicitly outstanding.

## Draft capabilities paragraph (118 words)

The upgraded rve-meta interface adds working-correlation sensitivity tables, predictor centring and reproducible R-script export. Its six-point rho grid reports coefficient estimates, robust standard errors, degrees of freedom, confidence intervals and p-values, with flags for sign or significance changes. robumeta 2.1 already provides sensitivity(), but presents its coefficient, standard-error and heterogeneity summaries as rounded strings. The interface also displays the fitted-design condition number and offers centring with one action; R users can perform the same centring by subtracting predictor means in a few lines. Exported scripts include the input data and calls to robumeta 2.1 and clubSandwich 0.7.0, making the corresponding R workflow explicit. These interface capabilities do not establish universal numerical agreement or guarantee that centring resolves ill-conditioning.
