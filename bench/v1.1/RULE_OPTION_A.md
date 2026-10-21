# Option A: independently explained undefined quantities

Written before running either comparator. Numeric tolerance remains 1e-9:
absolute for p and CI endpoints, relative with denominator max(1, abs(R))
otherwise. Exact checks and refusal-category comparison remain unchanged.
One undefined side against a finite number always fails. Two undefined
(null or numeric nonfinite) values pass only when their independently
derived reason codes are identical. Non-numeric strings are invalid, not
undefined numeric values.

Reason derivation takes one side's record and coefficient only. For the R
robumeta comparison it uses that coefficient's SE and dfs; for clubSandwich
it uses that coefficient's SE and df_Satt, never robumeta's fields. The app
uses its own summary se and df. No dataset identities or opposite-side
values enter classification. A finite value has no undefined reason.

Ordered taxonomy:

1. REFUSED:<category> for a refused side, with the existing category
   normalization (insufficient clusters, rank deficiency, no rows, otherwise
   the side's lowercased refusal text). Existing refused-fit checks remain exact.
2. DF_NONPOSITIVE for undefined df, or undefined p/CI with that side's
   df nonfinite, null, or <= 0. This has priority for p/CI if SE is also zero.
3. SE_ZERO for undefined t or p when that side's SE is exactly zero.
   This includes underflow already represented as zero in that side's
   captured SE; no epsilon or cross-side inference is used. A tiny positive
   SE is not relabeled zero. Zero SE does not itself make a df, estimate,
   SE, tau2, or confidence endpoint undefined.
4. OTHER_NONFINITE for every other undefined numeric value.

These are observable reason classes, not a recovery of NaN versus infinity
after JSON serialization. Matching OTHER_NONFINITE is agreement under the
requested taxonomy, with both reasons retained for audit.

Source basis: p15diag/r_source/robumeta_robu.R:271 computes Satterthwaite
df as B_trace_square/B_square_trace; lines 275-279 compute SE from variance,
t=b.r/SE, then p and CI from t/df/SE.
p15diag/r_source/clubSandwich_Satterthwaite_df.R:3-5 computes
2*E_coef^2/V_coef (including undefined 0/0);
clubSandwich_coef_test.R:27-35 and 51-54 derive SE, t and Satterthwaite p.
rve-reproducible/app/shared/rve.js:355-369
computes df and SE; lines 401-408 compute t=estimate/SE, p and CI.
The app's df fallback must be judged by its own resulting df, never by R's.
The app source SHA-256 is
ee2e2eb93663a65dcd6b525735481da4584ca9802a7c678706d3b4185150eb61,
matching engine-full-allmeta-meta.json. The captured-engine copy has the
same text with different line endings.

Every undefined comparison, including a passing one, records quantity,
coefficient index, values, reason_app, reason_R, and pass/fail. Existing
failure records also receive the reason fields. Strict baseline mode keeps
the former finite-only numeric predicate for a reproducible before count.
No reference values, engine captures, or archived expectations are edited.
