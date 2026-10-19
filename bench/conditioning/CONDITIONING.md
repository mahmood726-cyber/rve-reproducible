# Paper 15: design conditioning and the strict-gate failures

Produced by `conditioning.py` then `summarise.py` (this folder; both read-only over `../codex17`). No new R or engine fits were run. Outputs: `conditioning.csv` (one row per configuration, 16,270 rows), `conditioning-summary.json`, `fig_conditioning.png`.

**Reproduction gate.** `conditioning.py` recomputes every comparison with the same rules as `codex17/compare_engine.py` and asserts that it reproduces the lane's failures exactly: 2,617 failed checks across 785 configurations (it does; the script stops if it does not).

## What κ is

κ = 2-norm condition number of XᵀWX, where W holds the CORR weights the engine actually used for the fit (`fit.weights` in `engine-full-patched.jsonl`). Two matrices that use only the inputs were computed as sensitivity checks: XᵀW₀X (CORR weights with τ² = 0, so no fit is needed) and XᵀX (unweighted). Every failing configuration lands in the same tier whichever of the three matrices is used (780/780 fitted). Across all configurations the tier agrees for 15,475 (W₀) and 15,455 (unweighted) of 15,688. u = 2⁻⁵³ ≈ 1.11×10⁻¹⁶.

## Failing configurations by lane category and κ

| Lane category | Tier | Configs | Failed checks | κ range | Median / max scaled difference | Max fit-quantity difference |
|---|---|---:|---:|---|---|---|
| inference mismatch, fit within tolerance | B | 492 | 914 | 9.5e10 – 1.6e13 | 1.5e-8 / 4.0e-6 | 9.9e-10 |
| fit/variance/df mismatch | B | 92 | 556 | 1.6e12 – 1.6e13 | 3.7e-7 / 1.3e-6 | 4.6e-9 |
| acceptance/refusal (R complex eigenvalues) | B | 2 | 2 | 7.8e10 | – | – |
| near-zero reference SE (exact-fit designs) | A | 190 | 1,120 | 3.4 – 4.4e5 | non-finite / non-finite | 1.1e-13 |
| fit/variance/df mismatch (besson2016; robumeta and clubSandwich disagree) | A | 4 | 20 | 3.9e5 – 5.0e5 | 60 / 61 | 61 (club df) |
| refusal reason (app m≤p; R complex eigenvalues) | no fit | 5 | 5 | – | – | – |
| **Total** | | **785** | **2,617** | | | |

"Scaled difference" uses the gate's own scaling: |app − R| / max(1, |R|) for estimate, SE, t, df and τ²; absolute for p and the CI endpoints.

## The relation (figure `fig_conditioning.png`)

| κ(XᵀWX) | Configurations | Failing |
|---|---:|---:|
| exactly 1 (intercept only) | 1,595 | 0 |
| (1, 10²] | 2,225 | 145 |
| (10², 10⁴] | 4,289 | 25 |
| (10⁴, 10⁶] | 4,651 | 24 |
| (10⁶, 9.0×10⁶] | 1,225 | 0 |
| (9.0×10⁶, 10¹⁰] | 875 | 0 |
| (10¹⁰, 10¹²] | 415 | 252 |
| (10¹², 10¹⁴] | 415 | 334 |
| refused by the app (no fit) | 580 | 5 |

The distribution splits in two. Below κ = 5.0×10⁵ the failures are the 190 exact-fit designs and the 4 besson2016 reference disagreements. Neither group is a conditioning effect: their fit quantities agree to 1.1×10⁻¹³, or the app matches robumeta and clubSandwich gives a different answer. No configuration fails between κ = 4.98×10⁵ and κ = 7.81×10¹⁰, and 2,100 configurations sit in (10⁶, 10¹⁰). Above 7.8×10¹⁰ most configurations fail (586 of 830 with κ > 10¹⁰). Among failing configurations in tier B (κ > 9.0×10⁶), 550 of 586 use the uncentred `year` moderator. Centring year with the same weights brings all 760 fitted year designs below the threshold (median κ 14, max 529). So the ill-conditioning comes from the parametrisation, not from the statistical problem.

In tier B, max scaled difference / (κ·u) ranges from 6.0×10⁻⁷ to 1.4×10⁻² (median 1.6×10⁻⁴). Every tier-B numerical failure therefore lies within the first-order forward-error bound, by a factor of at least 72. The fit quantities in tier B miss 1e-9 by at most a factor of 4.6 (max 4.6×10⁻⁹). The large tier-B differences are in CI endpoints (up to 4.0×10⁻⁶ absolute), which come from large intercepts on the year scale.

## Proposed tiering rule (option b): stated as post hoc

> **Tier A:** κ₂(XᵀWX) ≤ 10⁻⁹/u = 9.007×10⁶: the strict 10⁻⁹ gate, unchanged.
> **Tier B:** κ₂(XᵀWX) > 9.007×10⁶: each numerical check uses tolerance κ·u, with the strict gate's scaling.
> Status and refusal-category checks stay exact in both tiers.

Why this rule. It uses only the design matrix and the fitted weights, never an observed app–R difference. Its threshold is where the textbook forward-error bound of a backward-stable solve, κ·u, first exceeds the gate tolerance (Higham 2002). It has no tuned constant. **It was formulated after the lane's failures and their κ distribution had been seen.** The paper must therefore present it as a post hoc, conditioning-based classification, not as a pre-registered gate. The empty band (4.98×10⁵, 7.81×10¹⁰) means that any threshold in roughly 10⁶–10¹⁰ classifies the failures identically. That band would also make a data-driven threshold look convincing, so the real defence is the derivation from 10⁻⁹/u, not the fit to the data.

What it classifies:

| | Configurations | Strict failing configs | Tiered failing configs | Strict failed checks | Tiered failed checks |
|---|---:|---:|---:|---:|---:|
| Tier A | 13,985 | 194 | 194 | 1,140 | 1,140 |
| Tier B | 1,705 | 586 | 2 (status only) | 1,472 | 2 |
| Refused by app | 580 | 5 | 5 | 5 | 5 |
| **Total** | **16,270** | **785** | **201** | **2,617** | **1,147** |

Checks overall: strict 544,324/546,941 pass; tiered 545,794/546,941 pass (1,470 checks reclassified, all in tier B).

What it does **not** do:
- It cannot reach the 190 exact-fit designs. These are κ-benign; the moderator is an alias of the effect, for example `TE` in 110 of them, and the reference SE is ≤ 5.8×10⁻¹³. In 175 of the 190 the moderator is bit-identical to yi, and in all 190 yi is linear in X to a relative OLS residual of 5.4×10⁻¹¹ (`exactfit.py` → `exactfit.json`). Both programs return numerical noise for t and p. In 35 configurations every failing check has both values non-finite (both programs agree that t is undefined), and they fail only because the comparator requires finite numbers (210 such checks in all).
- It cannot reach the 4 besson2016 configurations, where robumeta and clubSandwich disagree substantively (Satterthwaite df 61.6 versus 1.0). The app matches robumeta. Across the corpus, 30 reference checks in 11 configurations have disjoint robumeta/clubSandwich acceptance intervals (`r2-reference-disagreements.json`). No implementation can pass those checks against both references.
- It cannot reach the 7 refusal disagreements (2 status, 5 reason). All involve R's nonsymmetric eigen routine returning tiny imaginary parts (`r2-complex-trace.json`).
- In tier B, κ·u reaches 1.8×10⁻³ at κ = 1.6×10¹³, so tier B would also accept a real error of that size. The observed differences use at most 1.4% of that allowance.

## A related observation (not a third option, but reviewers may raise it)

The strict gate compares CI endpoints in absolute terms (10⁻⁹) but coefficients relative to max(1,|R|). A CI endpoint inherits the coefficient's relative error, so an endpoint of magnitude 217 cannot meet 10⁻⁹ absolute unless the coefficient agrees to about 5×10⁻¹² relative. Of the 492 tier-B inference configurations, 487 fail only on CI endpoints, and 454 of those would pass if CIs were judged relative to |R| (`conditioning-summary.json`, `inference_category_ci_only*`). This is a property of the tolerance specification (TASK.md), fixed before the run. It is reported here only as information.
