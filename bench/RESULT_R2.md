# Round 2 strict engine result

Full fresh capture: **16,270/16,270 configurations**. Strict failures changed from **3,422 checks / 1,037 configurations** to **2,617 checks / 785 configurations**. The strict gate remains failed. No tolerances, reference records, comparison rules, or failing-case exclusions were changed.

| Category (exclusive diagnostic labels) | Before | After |
|---|---:|---:|
| inference mismatch despite fit quantities meeting tolerance | 590 | 492 |
| near-zero reference SE; t/p sensitive to residual rounding | 245 | 190 |
| fit/variance/df numerical mismatch; unresolved | 115 | 96 |
| refusal reason disagreement | 85 | 5 |
| acceptance/refusal disagreement | 2 | 2 |

| Failed quantity | Before | After |
|---|---:|---:|
| ci_hi | 664 | 538 |
| ci_lo | 656 | 540 |
| club_df | 70 | 60 |
| club_estimate | 43 | 39 |
| club_p | 277 | 210 |
| club_se | 81 | 63 |
| club_t | 576 | 441 |
| df | 40 | 30 |
| estimate | 43 | 39 |
| p | 265 | 195 |
| refusal_category | 85 | 5 |
| se | 65 | 25 |
| status | 2 | 2 |
| t | 545 | 420 |
| tau2 | 10 | 10 |

Resolved baseline configurations: 283. Newly failing configurations: 31. Retained failing configurations: 754. These are configuration-set transitions, not waivers.

## Root causes established before the corresponding fixes

Trace environment: R 4.6.0, robumeta 2.1 and clubSandwich 0.7.0 from the local Rlib, locale C; verified in `r2-environment.json`.

### 1. Fit, variance and df

Read the installed robumeta 2.1 function, exported as `r2-robu-source.txt`. The three smallest baseline fit failures are `dat.steurer2006::001::author::year` at rho 0, 0.2 and 0.5 (four rows each; the same design at three working correlations). `r2-trace.R` captures the actual R internals, and `r2-trace.cjs` instruments the engine without changing its delivered interface. Full step comparisons are in `r2-small-step-comparison.json`.

The model formulas agree: CORR weights, HTJ moments, rho term, zero truncation, CR2 cutoff and Satterthwaite expression are algebraically equivalent. The concrete differences are numerical operation order: Gauss-Jordan versus R LAPACK-style partial-pivot LU; rowwise versus clusterwise normal-equation reduction; factored moment products versus left-associated matrix products; and score-vector outer products versus left-associated sandwich products in R. With uncentered year predictors, cancellation amplifies these differences. The LU multiplier uses reciprocal scaling to match the relevant LAPACK operation. The patch now follows those operation orders; it does not insert reference outputs.

In all three traced cases, the final engine matches R normal equations, FE coefficients, bread, final coefficients, covariance and SE exactly. The tau2 denominator differs by at most 2.842170943040401e-14 and coefficient df by at most 4.6851411639181606e-14. Tau2 is zero and termB is zero, so rho handling is not the cause in these cases. Remaining corpus fit failures are still unresolved numerical discrepancies; tracing three cases does not prove every remaining case has one unique cause.

Source locations: `patched/shared/rve.js:81` (LU), `:216` (normal equations), `:259` (moments), `:320` (sandwich). Installed R counterparts: `r2-robu-source.txt:71`, `:99`, `:159`, `:245`.

### 2. Refusal categories and acceptance

Baseline: 80 rank-deficient designs hit the app cluster-count guard before the singular solve in R; five further reason mismatches involved the complex-eigenvalue error in R. The engine now attempts the initial solve before the cluster-count guard, matching rank-deficiency precedence. The audit comparator and R references are unchanged.

`r2-complex.R` reruns the relevant installed R implementation and records its actual eigensolver output. For `dat.lehmann2018::001::PRPublication::Year::rho=0.2`, a 44-row leverage block has asymmetry 1.1342645572787191e-12 and imaginary eigenvalue component up to 4.7997087018674754e-15. For the two `dat.moura2021::001::species.id::publication.year` status mismatches (rho 0.8 and 1), the 498-row block has asymmetry around 4e-17 and imaginary components around 2.5e-15. R dispatches to a nonsymmetric eigen routine and robu fails at `eigenval < 10^-10`; JavaScript uses symmetric Jacobi rotations. These are reference implementation path differences, not evidence of a genuinely complex statistical model. No dataset/rho-specific refusal or invented threshold was added. Remaining disagreement is a strict failure.

The full-pass review found five additional computational-singularity disagreements introduced by the initial LU replacement. Before correcting them, `r2-solve-default-source.txt` confirmed the R machine-epsilon tolerance and the reference records reported reciprocal condition number 6.80105e-19. The final LU guard uses the explicit inverse one-norm reciprocal condition number against Number.EPSILON. A design-solve preflight over all 16270 configurations changed acceptance only for those five cases (`r2-condition-preflight.json`). A fresh full recapture follows this correction; the earlier completed run is archived as `r2-precondition-*`.

### 3. Inference when fit quantities meet tolerance

The proposed t-quantile/incomplete-beta explanation was tested directly: `r2-probe.cjs` evaluates JavaScript inference using R coefficients, SE, t and df for all 590 baseline inference-category configurations (1180 coefficient rows). There are 0 isolated CI failures and 0 isolated p failures; maximum CI endpoint difference is 2.1100277081131935e-10. Thus the existing round-one Student-t implementation is adequate for those inputs. This category includes fit rounding that meets its own tolerance but is amplified by estimate/SE division or by CI construction (especially large intercepts / low df). R2 does not make an unsupported quantile change.

### 4. Near-zero SE

Reference SE <= 1e-12 remains a diagnostic label only. Near-exact fits amplify residual rounding in t = estimate/SE and in p. No floor, replacement t/p value, tolerance relaxation, or exclusion was introduced. Every failed check in this category remains in the failure files.

## Remaining blockers and reference cross-check

Independent source-record comparison finds 116 robumeta/clubSandwich coefficient checks differing by more than at least one individual tolerance, including **30 checks across 11 configurations with disjoint acceptance intervals**. The intervals use exactly 1e-9 absolute for p and 1e-9 times max(1, absolute(reference)) for other quantities. No single result can pass both references on those disjoint checks. `r2-reference-disagreements.json` contains values, coefficient indices and the interval proof; these checks were not waived.

The smallest traced case still differs from clubSandwich df by about 1.2e-9 relative despite matching robu df to about 5e-14 absolute. Other remaining failures require additional work on reference arithmetic, ordering and eigen behavior. In particular, the JS df calculation uses a cluster Gram matrix whereas robu forms the observation Gram matrix: algebraically identical traces, different floating-point summation. The engine also retains first-seen cluster ordering whereas robu sorts factor levels. No claim is made that all remaining fit discrepancies are fully isolated.

Every remaining configuration, category, quantity, app value and reference value is retained in `strict-diagnosis.json` and `engine-failures-full-patched.json`. Newly failing IDs are recorded in `r2-transitions.json`. No complete-parity or release-readiness claim is supported.

## Verification and deliverables

- `python patch_app.py`: reproducible edits to `patched/` and regenerated `fix.patch`; `r2-invert.js` is the local generator input for LU.
- `node engine_full.cjs patched`: fresh full capture from zero after final source changes; earlier partial attempt is archived under `r2-intermediate-*` and excluded.
- `python compare_engine.py patched` and `python diagnose_failures.py`: strict, complete comparisons and category regeneration.
- `node contract.cjs`: patched 12/12 API checks pass. `node edge.cjs`: patched 8/8 large-variance edge checks pass.
- `python r2-verify.py`: syntax, generator idempotence, clean patch application and normalized source equivalence pass.
- `r2-final-recapture-proof.json`: 16260 records are byte-identical between the two full passes. Five acceptance decisions now correctly refuse computational singularity; five already-refused records use a more precise singularity message, with unchanged comparator category. Every retained accepted fit record is byte-identical.
- Capture harness: three independent worker threads, ordered writes, same fixed engine hashes. `node r2-worker-test.cjs` proves serialized equality against serial execution on three traced fits and an explicit empty-input refusal fixture. Each full pass evaluates all configurations with fixed engine hashes. The final guarded pass starts from zero and reuses no prior-source captures.
- Source-level second pass: installed R source traces, raw R/club reference compatibility, source hashes and unchanged tolerance/comparator checks.
- No browser runs. Remaining parser/display/export validation is in `BROWSER_TODO.md`. No original-clone edits, commit, push or portfolio/submission-state change.

| Item | Static versus dynamic |
|---|---|
| 1e-9 tolerances; eigen cutoff 1e-10; SE diagnostic threshold 1e-12 | Static existing requirements, unchanged |
| Machine-epsilon condition guard | Static default taken from installed R solve.default; exercised over all designs |
| LU and matrix multiplication order | Static source-backed implementation, not fitted to identifiers or stored outputs |
| Counts, traces, coefficients, weights, variance, df, p and CI | Dynamic executed engine and installed-R outputs |
| Corpus inputs, IDs and source references | Existing source-backed records, not modified |
| API and large-variance fixtures | Explicit synthetic software tests, not research findings |
