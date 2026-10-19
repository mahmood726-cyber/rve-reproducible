# Job 17 round 2: close the patched-engine strict failures (no waivers)
Start from patched/ and fix.patch; evidence in STRICT_DIAGNOSIS.md, strict-diagnosis.json, engine-failures-full-patched.json.
Root cause FIRST per category (debugging discipline: state what and why before any fix):
1. fit/variance/df mismatch (115 configs: estimate 43, se 65, df 40, tau2 10, club_*): compare against robumeta::robu
   source (installed in Rlib) step by step on 3 smallest failing cases; find the algorithmic difference
   (small-sample df, weights, rho handling, tau2 truncation, CR2 adjustment vs clubSandwich).
2. refusal reason disagreement (85) and acceptance/refusal (2): align the refusal categories with what R does.
3. inference mismatch with fit in tolerance (590): t-quantile/incomplete-beta accuracy; low df.
4. near-zero SE (245): report separately; may be legitimately ill-conditioned - only label them, never relax.
Keep tolerances. Patch idempotently via patch_app.py; rerun node engine_full.cjs patched (re-capture all 16270) then
compare_engine.py patched and diagnose_failures.py. No browser runs (write any into BROWSER_TODO.md).
Write RESULT_R2.md: root cause per category with evidence, before/after counts, remaining failures with reasons.
