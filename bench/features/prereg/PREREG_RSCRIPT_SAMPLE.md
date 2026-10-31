# Pre-stated sample for the R-script export validation (rve-meta, paper 15)

**Written:** 2026-10-19T13:01:14Z (UTC), before any sample was drawn or any generated script was run. Hash in `PREREG_RSCRIPT_SAMPLE.md.sha256`.

**Seed:** `20261019` (Python `random.Random(20261019)`), recorded before drawing.

**Population:** the 16,270 lane configurations (`p15-codex17/configurations.json`, sha256 91b6f6fe…3b73), restricted to those whose lane R reference has `status == "ok"` (a script is only expected to reproduce a fit R produced).

**Strata and draw (in this order, one RNG stream):**
1. For each dataset in sorted order, draw 2 configurations uniformly without replacement from that dataset's eligible configurations (all of them if fewer than 2).
2. Draw further configurations uniformly without replacement from all remaining eligible configurations until the sample holds 300.
3. Centred stratum: draw 50 configurations uniformly from the pre-registered tier-B set (`centring_config_ids.txt`) whose centred R reference (`centred_ref/`) is ok; scripts are generated with centring on and compared with the centred references.
4. Fixtures (multi-predictor, p = 3 or 4): the app's small example (5 clusters, 2 predictors), the hub spec's DS2 (8 clusters, 2 predictors) and the in-app robumeta `corrdat` example (39 clusters, 3 predictors), each at ρ = 0.8. Their references are produced by a separate, hand-written R call (`fixture_ref.R`), not by the generated script.

**Procedure:** scripts are generated in Node by `AlmRVEExtras.toRScript` (the same function the page's "R script (.R)" button calls), each run in its own `Rscript` process on the baseimage node (R 4.6.0, robumeta 2.1, clubSandwich 0.7.0) via a wrapper that `source()`s the script unchanged and then writes `fit$reg_table`, `fit$mod_info$tau.sq` and `ct` with 17 significant digits. The wrapper also writes back the parsed data columns so input fidelity can be checked bitwise.

**Comparator:** the strict lane comparator at 1e-9 (relative-scaled for τ², estimate, SE, t, df and clubSandwich estimate/SE/t/df; absolute for p, CI limits and clubSandwich p), every coefficient.

**Prediction:** all scripts run without error and every check passes at 1e-9 for the 300 + 3 uncentred scripts. For the 50 centred scripts R recomputes the means itself (`x - mean(x)`), which may differ from the app's means in the last bit; a pass at 1e-9 is still predicted because the centred designs are well conditioned. Counts will be reported as observed.
