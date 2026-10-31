# P15D: fixed-locale rho-sensitivity validation

The eligible archived control is byte-identical **310/310**, covering 15,480 numeric fields at rho 0.4/0.6. New references cover **442/448** sampled designs. Six designs exceed the prescribed 200-cluster limit. Both required plants were detected **2/2**. Numerical and rounded-string disagreements below are retained as observed; completion of this lane does not imply every preregistered prediction passed.

## Reproducibility correction and scope

The root cause established in ../p15c/ROOT_CAUSE.md is locale-dependent factor-level ordering of clusters in robumeta 2.1. This changes the order of floating-point operations. rho_ref_v3.R fixes LC_COLLATE and LC_CTYPE to English_United States.utf8, prints and asserts both settings, and records Sys.getlocale() in every output file. **This is a reproducibility fix after the preregistration; the sample, thresholds and comparator are unchanged.** The corrected literal-formula sensitivity() call from p15b is retained. No production engine, pinned reference, corpus or preregistration was edited.

R 4.6.0, robumeta 2.1, clubSandwich 0.7.0 and jsonlite 2.0.0 are asserted and printed before fitting. The required R executable and library paths are used. The inherited C.UTF-8 startup warnings occur before the explicit successful locale settings. Shared package-build warnings (R 4.6.1) remain in the raw logs. These warnings do not prevent the exact archived control.

Only one R fitting job runs at a time. The prescribed bin/Rscript.exe launcher starts bin/x64/Rscript.exe; these are one launcher and one computing process, not two fitting jobs. Each completed JSON is atomically renamed from a temporary file. Designs above 200 clusters are skipped before any fit; memory snapshots for eligible designs with at least 100 clusters are in evidence/memory.jsonl.

## Coverage and exclusions

Control range 0001–0311: 310/311 generated (0001 excluded). Tail range 0312–0448: 132/137 generated. Overall fresh coverage: 442/448 designs and 884/896 planned new-rho fit records. Original sample indices and known-failure flags are retained in evidence/comparison_index.json; the compact comparator view contains only available references. Existing lane references cover all 448 designs and are also compared for the six excluded fresh-R designs.

| Index | Design | Clusters | Reason |
|---|---|---:|---|
| 0001 | clubSandwich::dropoutPrevention::studySample::duration | 317 | not computable by robumeta on a 16 GB machine |
| 0312 | dat.mccurdy2020::001::id::ni | 1,653 | not computable by robumeta on a 16 GB machine |
| 0333 | dat.moura2021::001::species.id::effect.size.id | 341 | not computable by robumeta on a 16 GB machine |
| 0334 | dat.moura2021::001::study.id::(intercept) | 457 | not computable by robumeta on a 16 GB machine |
| 0335 | dat.moura2021::001::species.id::(intercept) | 341 | not computable by robumeta on a 16 GB machine |
| 0336 | dat.moura2021::001::study.id::ni | 457 | not computable by robumeta on a 16 GB machine |

These exclusions implement the requested resource rule, not fresh observed allocation failures. For 0312, the 8*m^3 allocation alone is 36,133,376,616 bytes (about 36 GB decimal), exceeding the 16 GB host capacity.

Fresh sensitivity() tables are available for **441/448** designs; **1** eligible design returned an error. Errors are excluded from rounded-string denominators, never counted as passes:

- 0069, dat.besson2016::001::dam_ID::photoperiod, known failure=True: `{'error': "infinite or missing values in 'x'"}`

## Controls and unchanged comparator

audit.py:20 compares the complete serialized r04/r06 blocks, including every numeric token, against ../p15/rveup/rho_ref/. Result: **310/310 byte-identical**, zero exceptions, maximum absolute and relative difference **0**. Sensitivity output and new locale metadata are excluded from this numeric control. The excluded archived 0001 file is neither regenerated nor included in its denominator.

locale_regression.py:1 runs the same generator with both locale fixes disabled on designs 0135 and 0293. Fresh archived numeric-byte matches: **0/2 before, 2/2 after**. This negative control demonstrates that the check detects the original problem. Raw failed-control outputs remain in evidence/locale_disabled/. Maxima for the disabled controls:

| Index | Max absolute difference | Max relative-scaled difference |
|---|---:|---:|
| 0135 | 1.7051149825419998e-08 | 3.0524886078745681e-10 |
| 0293 | 1.6226238130911952e-09 | 1.0982617570938083e-10 |

audit.py:46 creates a lossless input view because robumeta sensitivity() has two identically named display columns. Raw rho_ref_v3 files remain untouched. Standard JSON decoding originally retains all eight columns in **0/2063** rows; unique transport keys restore **2063/2063**. Every displayed string is checked unchanged (**12378/12378**) and all numeric blocks retain identical bytes. No printed-value rounding is changed.

compare_rho.py is copied from ../p15/rveup/compare_rho.py with only its input/output root adapted. AST comparison confirms unchanged logic (1/1). It runs on all 442 available fresh references for all three groups; its complete output and failure list are compare_inputs/rho_results.json and compare_inputs/rho_failures.json, with raw stdout in evidence/compare_rho.log. finish_validation.py additionally invokes the exact same compare_fit/check function ASTs on all 448 designs for the existing-reference group; evidence/lane_all_results.json and evidence/lane_all_failures.json retain that complete coverage.

## Observed group results

| Group | Designs | No known failure: passes/checks | Known failure: passes/checks | Total | Failing designs (not known) |
|---|---:|---:|---:|---:|---:|
| new_refs_04_06 | 442 | 19,824/19,824 | 1,302/1,456 | 21,126/21,280 | 27 (0) |
| lane_refs_0_02_08_1 | 448 | 40,176/40,176 | 2,602/2,912 | 42,778/43,088 | 27 (0) |
| sensitivity_strings | 441 | 10,451/11,568 | 810/810 | 11,261/12,378 | 66 (66) |

Within the 442-design unchanged-comparator run, the existing-reference subtotal is 42,250/42,560. The main table uses the more complete 448-design result. Known failure means the original sample flag derived from strict-lane failures at rho 0.5 or 0.8; flags were not reassigned after observing these results.

Numeric comparisons use 1e-9 relative-scaled difference for tau2, estimate, SE, t, df and corresponding clubSandwich quantities; p-values and CI limits use absolute difference. Status is exact. Sensitivity uses the original printed-string tolerance 0.5*10^(-d)+1e-12. The original comparator is retained, including its treatment of scientific notation. Maxima below are over finite differences; null/nonfinite failures remain failures and do not inflate these maxima.

Predictions (a)/(b): no observed numeric failures outside the preregistered known-failure stratum, within the stated coverage. Prediction (c): fails under the unchanged comparator.

String-failure attribution reproduces the official failure list **1117/1117**. There are 1,117 failures among 2,155 scientific-notation checks and 0 among 10,223 ordinary-notation checks. The inherited decimal count includes the exponent text: for example, `-3.33e-01` produces d=6 and tolerance 0.000000500001, although half its displayed unit is 0.0005. This makes that gate stricter than the printed resolution. An exponent-aware diagnostic places 1,117 failed checks within half a displayed unit; 0 checks remain outside that diagnostic limit. **These diagnostics do not replace or relabel the preregistered results.** Full string values, tolerances and mappings are in evidence/sensitivity_checks.json and evidence/sensitivity_diagnostics.json.

### new_refs_04_06

| Quantity | No known failure: passes/checks | Max difference | Known failure: passes/checks | Max difference |
|---|---:|---:|---:|---:|
| ci_hi | 1,514/1,514 | 4.3213788103457773e-10 | 70/112 | 4.676747948906268e-07 |
| ci_lo | 1,514/1,514 | 7.8138562287222157e-10 | 74/112 | 4.0434485981677426e-07 |
| club_df | 1,514/1,514 | 5.811717448116269e-12 | 106/112 | 60.332493395532317 |
| club_estimate | 1,514/1,514 | 2.3644585535499648e-11 | 110/112 | 1.0438597800261439e-09 |
| club_p | 1,514/1,514 | 2.9937163859017346e-11 | 102/112 | 0.097463305183944193 |
| club_se | 1,514/1,514 | 6.1275682944418468e-11 | 108/112 | 1.7670670710295038e-09 |
| club_t | 1,514/1,514 | 8.2720253042456528e-11 | 92/112 | 0.57031515700520963 |
| df | 1,514/1,514 | 7.5540131483558225e-12 | 108/112 | 2.5111078901129179e-09 |
| estimate | 1,514/1,514 | 2.3644585535499648e-11 | 110/112 | 1.0438597800261439e-09 |
| p | 1,514/1,514 | 2.5391383440265258e-11 | 104/112 | 0.097463305183985383 |
| se | 1,514/1,514 | 4.9503707284419292e-11 | 112/112 | 7.3997668489536639e-10 |
| status | 828/828 | 0 | 56/56 | 0 |
| t | 1,514/1,514 | 7.0948349885350378e-11 | 94/112 | 0.57031515700520963 |
| tau2 | 828/828 | 1.0602629885170245e-14 | 56/56 | 7.6246949507034029e-11 |

### lane_refs_0_02_08_1

| Quantity | No known failure: passes/checks | Max difference | Known failure: passes/checks | Max difference |
|---|---:|---:|---:|---:|
| ci_hi | 3,068/3,068 | 4.3213788103457773e-10 | 143/224 | 5.8388377510709688e-07 |
| ci_lo | 3,068/3,068 | 7.8138562287222157e-10 | 144/224 | 7.7527056419057772e-07 |
| club_df | 3,068/3,068 | 4.6199589512061148e-12 | 212/224 | 60.63081998345838 |
| club_estimate | 3,068/3,068 | 2.9371007296629854e-11 | 220/224 | 1.0438597800261439e-09 |
| club_p | 3,068/3,068 | 2.9937163859017346e-11 | 204/224 | 0.097463305183944193 |
| club_se | 3,068/3,068 | 6.1275682944418468e-11 | 215/224 | 1.7670670710295038e-09 |
| club_t | 3,068/3,068 | 8.2720253042456528e-11 | 184/224 | 0.57031515700520963 |
| df | 3,068/3,068 | 9.3357574733564434e-12 | 216/224 | 2.5111078901129179e-09 |
| estimate | 3,068/3,068 | 2.9371007296629854e-11 | 220/224 | 1.0438597800261439e-09 |
| p | 3,068/3,068 | 2.5391383440265258e-11 | 208/224 | 0.097463305183985383 |
| se | 3,068/3,068 | 4.9503707284419292e-11 | 224/224 | 6.6374045200024976e-10 |
| status | 1,680/1,680 | 0 | 112/112 | 0 |
| t | 3,068/3,068 | 7.0948349885350378e-11 | 188/224 | 0.57031515700520963 |
| tau2 | 1,680/1,680 | 3.5107333706818622e-14 | 112/112 | 7.6247376633670076e-11 |

### sensitivity_strings

| Quantity | No known failure: passes/checks | Max difference | Known failure: passes/checks | Max difference |
|---|---:|---:|---:|---:|
| coefficient | 4,129/4,542 | 0.38070769597263165 | 324/324 | 4.9925625326352474e-05 |
| se | 4,128/4,542 | 0.048910282522207638 | 324/324 | 4.9752574938111138e-05 |
| tau2 | 2,194/2,484 | 4.868789634490895 | 162/162 | 4.9595959792730904e-05 |

## Planted defects

All plants use real generated data from `dat.anand1999::002::study::year` and rerun the unchanged full comparator. The unmodified selected-design baseline passes **186/186** checks.

- Engine estimate multiplied by 1+1e-8: -4.9641530890303329 → -4.9641531386718638; detected **1/1** (including the strict estimate check).
- Actual R sensitivity coefficient string, Rho = 0: `-4.96496` → `-4.96497`; only the last digit changed, by one unit. Difference 1.4894986640534569e-05, tolerance 5.0000010000000006e-06; detected **1/1**.

Full baseline/perturbed inputs, comparator outputs and raw logs are retained under plants/. evidence/plants.json records the exact failures. Both controls pass before the defect and fail after it; total detection is **2/2**.

## Changes, provenance and reproduction

- bootstrap.py:1 copies and hashes supplied inputs; rho_ref_v3.R:1 adds the explicit locale; rho_ref_v3.R:22 adds the cluster guard; rho_ref_v3.R:38 adds locale metadata and atomic checkpoints.
- memory_check.py:1 records physical memory; run_generation.py:1 launches one sequential R job; audit.py:1 checks archive bytes, transport and source integrity.
- locale_regression.py:1 supplies the failing-before/passing-after locale control; finish_validation.py:1 runs comparator coverage and both plants; sensitivity_diagnostics.py:1 maps retained string failures; inspect_strings.py:1 inventories display formats; build_report.py:1 renders observed results. complete_after_control.py:1 sequences the required checks and halts on failure.
- All supplied-source hashes and 1,792 pinned lane-reference hashes are verified unchanged in evidence/integrity.log and evidence/lane_integrity.log. Engine output is reused from the supplied rho_engine.jsonl with its recorded Node host and code hashes; this task does not rerun the JavaScript engine.
- The initial inline Python inventory command failed on PowerShell quote handling; snapshot_lane_refs.py replaces it. The raw error is retained in evidence/harness_failures.log. A CIM process-query attempt was denied; process paths were obtained through Get-Process. These diagnostics did not alter the generator or comparator.

From this lane, on a fresh output directory (existing reference checkpoints are preserved and existing generation logs are not overwritten):

```powershell
python bootstrap.py
python snapshot_lane_refs.py
python run_generation.py 1 311
python audit.py control
python locale_regression.py
python run_generation.py 312 448
python audit.py prepare
python finish_validation.py
python sensitivity_diagnostics.py
python inspect_strings.py
python audit.py integrity
python snapshot_lane_refs.py
python build_report.py
```

R environment: R_ENVIRON_USER=NUL; R_LIBS_USER=<HOST>/<RLIB-DIR>/Rlib_dta; R_LIBS=<HOST>/<RLIB-DIR>/Rlib_extra; executable C:/Program Files/R/R-4.6.0/bin/Rscript.exe. No network or Git write operation was used. No browser or production-code work was required. The six fresh-R exclusions and any sensitivity() error above are the remaining coverage limits.

## Paper sentence set (at most 80 words)

Under a fixed locale, robumeta 2.1 and clubSandwich 0.7.0 references covered 442/448 designs; six exceeded the cluster limit. All 310 eligible archived controls matched byte for byte. Strict numerical failures were confined to pre-identified designs. robumeta 2.1 supplies sensitivity(), which prints rounded strings; one call failed and scientific-notation comparator failures were retained. Equivalent rho refits can be composed in R in a few lines. Both planted defects were detected.

LANE DONE
