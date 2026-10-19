# Strict failure diagnosis

All failures remain failures at the specified 1e-9 tolerances. Categories below describe observed evidence, not waivers or proof of a unique mathematical cause.

## original

34691 failed checks across 11921 configurations.

| Observed category | Configurations |
|---|---:|
| inference mismatch despite fit quantities meeting tolerance | 11259 |
| near-zero reference SE; t/p sensitive to residual rounding | 250 |
| fit/variance/df numerical mismatch; unresolved | 115 |
| acceptance/refusal disagreement | 288 |
| refusal reason disagreement | 9 |

Failed quantities: {"ci_hi": 10084, "ci_lo": 10087, "club_df": 70, "club_estimate": 43, "club_p": 6382, "club_se": 81, "club_t": 571, "df": 40, "estimate": 43, "p": 6378, "refusal_category": 9, "se": 65, "status": 288, "t": 540, "tau2": 10}

## patched

2617 failed checks across 785 configurations.

| Observed category | Configurations |
|---|---:|
| inference mismatch despite fit quantities meeting tolerance | 492 |
| near-zero reference SE; t/p sensitive to residual rounding | 190 |
| fit/variance/df numerical mismatch; unresolved | 96 |
| refusal reason disagreement | 5 |
| acceptance/refusal disagreement | 2 |

Failed quantities: {"ci_hi": 538, "ci_lo": 540, "club_df": 60, "club_estimate": 39, "club_p": 210, "club_se": 63, "club_t": 441, "df": 30, "estimate": 39, "p": 195, "refusal_category": 5, "se": 25, "status": 2, "t": 420, "tau2": 10}

## Interpretation and remaining work

R2 isolated the inference functions using R fit inputs for the 590 baseline inference-category configurations: no CI or p check exceeded tolerance (r2-inference-probe.json). Thus these failures cannot be attributed to the t implementation alone. R2 traces demonstrate arithmetic-order differences in LU inversion and sandwich multiplication on the three smallest fit cases; matching these orders reproduces their robumeta coefficients and SEs exactly. Near-zero SE remains a descriptive category only. The JSON companion retains every failing check. See RESULT_R2.md and r2-reference-disagreements.json for remaining reference conflicts; none are waived.

Acceptance/refusal differences and fit/variance/df mismatches remain unresolved blockers. No reference substitutions, excluded failing cases, or relaxed tolerances were used. Browser parser, display and export checks remain unrun by host instruction; direct-engine evidence cannot resolve them.

| Item | Static or dynamic |
|---|---|
| Acceptance tolerance | Static task requirement, unchanged |
| 1e-12 near-zero-SE diagnostic label | Static descriptive threshold only; does not affect pass/fail |
| Counts, statuses, SE, df and differences | Dynamic captured engine and R reference records |

## Refusal source diagnosis

reference.R calls robu before its audit m<=p and rank guards. The R2 engine attempts the initial normal-equation solve before its m<=p guard; the guard still precedes CR2 eigen calculations. Consequently, a design failing both conditions can yield a different first refusal. The observed pairs below remain strict failures; the audit does not reorder R errors or waive them.

| App refusal | R refusal | Cases |
|---|---|---:|
| RVE: m<=p; insufficient clusters for inference | invalid comparison with complex values | 5 |

Accepted-by-app / refused-by-R cases (unresolved):

- `dat.moura2021::001::species.id::publication.year::rho=0.8`: R reports `invalid comparison with complex values`.
- `dat.moura2021::001::species.id::publication.year::rho=1`: R reports `invalid comparison with complex values`.

The R2 trace (r2-complex-trace.json) shows that tiny asymmetries send R into its nonsymmetric eigensolver; tiny imaginary eigenvalues then cause robu to fail its real-valued cutoff comparison. The engine uses a symmetric eigensolver. Remaining cases are retained as failures, with no case-specific refusal heuristic.
