# Pre-registration: predictor centring for ill-conditioned rve-meta designs (paper 15)

**Written:** 2026-10-19T12:03:14Z (UTC); version 2 written 2026-10-19T12:04:18Z, before any centred design was fitted, before any centred R reference was generated and before any κ comparison was run.
**Author:** Claude (agent lane wt-rve, branch feat/rve-meta-usability-centring), for Mahmood Ahmad.
**Version 2.** Version 1 (sha256 3977c970297b0ce9344a99cb3b0d7a1b1d3aa4ffc045974a9a60dad59f78ab29, written 12:03:14 UTC) contained a garbled P3-uncentred sentence; it was rewritten at the time stamped below, still before any centred fit, R reference or κ comparison had been run. Nothing else changed.
**Hash of this file:** recorded in `PREREG_CENTRING.md.sha256` (sibling file) immediately after writing.

## Inputs (all read-only, hashes as of writing)

| Input | sha256 |
|---|---|
| `C:\mh-lanes\f1000-15-19\p15-codex17\configurations.json` (16,270 configurations; identical content on baseimage `P15\configurations.json`) | 91b6f6fe0935e36650a0bcb13126937f7ed978ad2d9535b9ebdbded8db0f3b73 |
| `C:\mh-lanes\p10-11-15\p15prep\conditioning.csv` | 5d996ddb29ac7b747c4e2e41bbd0dd1c9af3dfd0c2bb276f1eb86b65f8ace749 |
| `centring_config_ids.txt` (this folder; the configuration set below, one id per line) | b41d0eb23feca054dc91bbacef4257f6ca962b5ee445e8b702f2ba769cafebea |
| `shared/rve.js` (validated engine, unchanged) | c12a87ce03827a20c47ec97a4ec70dec72aeb1adcd66f8dd0294538aaf6b61ac |
| `shared/stats-qt.js` (unchanged) | fb4110ba8e4b2e784193fde258ac37086713dc8d75a3295f84272d6fbdba8efb |
| `shared/rve-extras.js` (centring + κ code under test, at time of writing) | cbfa4153de181b4aa814b694d29804f8b2e676a9dfc3f35d3805f6ab1ec4ef4f |

## Configuration set (fixed now)

All configurations in `conditioning.csv` with `kappa_XtWX_fit > 9.0e6` (κ₂ of XᵀWX at the engine's fitted CORR weights, uncentred design): **1,705 configurations** (70 datasets; every one has p = 2, i.e. intercept + one moderator; 341 designs × ρ ∈ {0, 0.2, 0.5, 0.8, 1}; κ range 9.16×10⁶ – 1.63×10¹³). Uncentred status in the lane: 1,703 ok/ok, 2 app-ok / R-refused (complex eigenvalues). No configuration lies between 9.0×10⁶ and 1e-9/u = 9.007×10⁶, so the set is the same under either threshold. The set is listed in `centring_config_ids.txt`; no configuration will be added or removed after seeing results.

## Procedure

1. **Centring (Node, `AlmRVEExtras.centreRows`):** for each configuration, subtract the arithmetic mean over effect rows of every predictor column (not the intercept): x_c = x − mean(x). The centred rows (exact binary64 values) are written to JSON and are the *only* design given to both the engine and R, so both see identical inputs.
2. **Engine:** `AlmRVE.fitCORR(centredRows, {rho})` + `AlmRVE.summary` from the unchanged `shared/rve.js`/`shared/stats-qt.js` in Node; κ from `AlmRVEExtras.kappaXtWX(rows, fit.weights)` for both the centred and the uncentred design.
3. **R references (baseimage node, R 4.6.0, robumeta 2.1, clubSandwich 0.7.0):** the lane's `reference.R` logic unchanged in substance (`robu(yi ~ x, studynum, var.eff.size = vi, modelweights = "CORR", rho, small = TRUE)`, the m ≤ p and rank guards, `coef_test(vcov = "CR2", test = "Satterthwaite")`), run on the centred rows, numbers written with 17 significant digits. In the same run R computes `kappa(XtWX, exact = TRUE)` with XtWX = crossprod(X, w·X) from robu's own fitted weights and design (`X.full`, `data.full$r.weights`), for the centred design and, by a second robu fit, for the uncentred design. R also echoes the parsed centred X so input fidelity can be checked bitwise.
4. **Comparison (Python):** a copy of `compare_engine.py`'s check function with no change to quantities, scaling or threshold.

## Comparators and tolerances

- **P1 (primary): centred engine vs R on the centred design**, the unchanged strict comparator: exact for status / refusal category / n / m / p / coefficient count / method; relative-scaled |a−r|/max(1,|r|) ≤ 1e-9 for τ², estimate, SE, t, df and the clubSandwich estimate, SE, t, df; absolute ≤ 1e-9 for p, CI lower, CI upper and clubSandwich p.
- **P2 (invariance oracle): centred engine vs the existing *uncentred* lane references** (`p15-codex17\reference\NNNNNN.json`), for the quantities that are mathematically invariant to centring: τ² and, for the slope (coefficient 2 only), estimate, SE, t, df, p, CI lower, CI upper, and clubSandwich estimate, SE, t, df, p. Same scaling and 1e-9 threshold as P1. Intercept quantities are excluded (they change by design). Configurations whose uncentred reference is refused are reported separately and excluded from P2 checks.
- **P3 (κ):** engine κ vs R `kappa(XtWX, exact = TRUE)`, relative difference |κ_app − κ_R| / κ_R ≤ 1e-6, separately for centred and uncentred designs.

## Predictions (made now)

- **P1:** every centred configuration that both sides fit passes every P1 check at 1e-9, and status agrees for all 1,705.
- **P2:** every P2 check passes at 1e-9. (Caveat stated in advance: the uncentred references were themselves computed on designs with κ up to 1.6×10¹³, so their own forward error can reach κ·u ≈ 1.8×10⁻³ relative; P2 failures, if any, cannot by themselves be attributed to either side.)
- **P3 centred:** all centred κ ≤ 9.0×10⁶ and all agree with R at 1e-6.
- **P3 uncentred:** agreement at 1e-6 is predicted only for configurations with κ·u ≤ 1e-7, i.e. κ ≤ 9.0×10⁸ (both sides form XᵀWX in floating point, so each κ carries relative error up to about κ·u). For κ > 9.0×10⁸ no agreement is predicted; counts are reported as they fall.

Every count will be reported exactly as observed, including failures, and none of the above predictions, tolerances or the configuration set will be changed after results are seen.
