# Pre-registration: ρ-sensitivity table validation (rve-meta, paper 15)

**Written:** 2026-10-19T14:53:50Z (UTC), before the sample was drawn, before any ρ = 0.4 / 0.6 reference or sensitivity() output was generated and before any comparison. Hash in `PREREG_RHO.md.sha256`.

**Code under test:** `AlmRVEExtras.rhoSensitivity(rows)` in `shared/rve-extras.js` (sha256 e24c34ba4abdbcfcb9514523274824082b668a1220e82dfb3e994670db05518c at writing), which calls the unchanged `AlmRVE.fitCORR`/`summary` (rve.js c12a87ce…61ac, stats-qt.js fb4110ba…efb) at ρ ∈ {0, 0.2, 0.4, 0.6, 0.8, 1}.

**Sample (seed 20261020, Python random.Random):** a *design* is a lane configuration without its ρ suffix. Eligible: designs whose lane reference at ρ = 0.8 has status ok. For each dataset in sorted order draw up to 4 designs uniformly without replacement.

**References:** (a) new R references at ρ = 0.4 and 0.6 with the lane's reference.R logic (robu CORR small = TRUE + coef_test CR2 Satterthwaite) on the baseimage node; (b) the existing lane references at ρ = 0, 0.2, 0.8, 1; (c) `robumeta::sensitivity()` on the ρ = 0.8 fit, which prints coefficient, SE and τ² as rounded strings for the same 6 values of ρ.

**Comparators:** (a) and (b): the strict lane comparator at 1e-9 (relative-scaled for τ², estimate, SE, t, df, clubSandwich estimate/SE/t/df; absolute for p, CI limits, clubSandwich p). (c): |app − value| ≤ 0.5×10^(−d) + 1e-12, where d is the number of decimals in the printed string. Status (ok / refused) is compared exactly.

**Predictions:** (a) every check passes at 1e-9 except in designs that already fail the strict lane gate at ρ = 0.5 or 0.8 (tier-B ill-conditioned or exact-fit designs, `conditioning.csv` failed_checks > 0); (b) the same, since the engine call is identical to the lane's; (c) every value agrees to the printed precision. Counts will be reported as observed, split by whether the design has a known strict-gate failure.

**Engine host:** the engine is run in Node on the baseimage node (local CPU is saturated); file hashes are recorded with the output.
