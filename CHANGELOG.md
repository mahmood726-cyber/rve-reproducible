# Changelog

## 1.1.0 (unreleased; not yet published)

Adds a version 1.1 layer for the merged exact-R engine: allmeta pull request #210, merge commit
`575cb29468f814ad09401d78f1a75fbda16b8abc`. The 1.0.0 layer is unchanged.

- `app-v1.1/`: the rve-meta page and every file it loads at the 575cb29 bytes, including `shared/rve-eigen.js`
  (GPL-3.0, as distributed by webR) and `shared/numerics/` with `LICENSES-rve-eigen.md`.
- `results/v1.1/`: the full-corpus capture (included as xz, 35 MB uncompressed) and the results for both comparator
  modes. Finite-only: 15,485 -> 16,136 / 16,270. Option A: 15,520 -> 16,221 / 16,270. Neither mode has a newly failing
  configuration. Also here: the changed-status lists, the residual evidence for the 49 configurations that still
  fail, the rho recheck (442 / 443 of 448 designs) with its locale proof, the planted-defect results, and the lane-K
  exposure scan with the as-character fixtures.
- The Option A comparator rule (`analysis/option_a.py`, `analysis/compare_modes.py`): both-undefined counts as
  agreement only when the app and R are undefined for the same reason. It accounts for 85 configurations. Planted
  must-fail checks are in `analysis/test_option_a.py`.
- `analysis/verify_archive.py` verifies the layer by hashes. It re-runs both comparator modes and the rho recheck on
  the archived captures and asserts the counts in `expected/v1.1_values.json` exactly.

- Feature-check evidence (`results/features/`, `bench/features/`): the inputs, outputs, logs, pre-registrations and
  unmodified comparators behind the centring (56,265 / 56,265; invariance 23,698 / 23,842; κ 3,363 / 3,408),
  R-script export (353 scripts, 9,040 / 9,051) and rho-table (21,126 / 21,280 on 442 designs) counts, measured on the
  corrected engine (e042af5 bytes) with the `feat/rve-meta-usability-centring` extras. `analysis/compare_features.py`
  replays the comparators; the verifier asserts `expected/features_values.json`, the archived outputs and the archived
  log text exactly, and `analysis/test_features.py` plants a defect in each. The same script splits the v1.1 rho
  recheck's 24,086 checks into the 21,280 shared ones and the 2,806 that only that comparator or only those six extra
  designs contribute (README).

**Release identifiers.** The v1.1 layer's engine ships in allmeta **v1.9.0**, tag commit
`d38d3fd70656f3fedfa03916573fe0bf904f5e9c`, DOI **10.5281/zenodo.23833871**. Every `app-v1.1/` file has the same
Git blob at v1.9.0 except `shared/build-info.js` (release version, commit and build time only). The full-corpus capture
re-run on the v1.9.0 engine bytes is byte-identical to the archived one, and the rendered rve-meta browser tests pass
on the v1.9.0 bytes in Edge 155, Chromium 147, Firefox 148 and WebKit 26.4 (`RELEASE_EQUIVALENCE.md`,
`results/v1.1/release-v1.9.0/`). The verifier requires these identifiers.

## 1.0.0 (unreleased; not yet published)

Initial reproducibility archive for the paper-15 validation of allmeta rve-meta (robust variance estimation,
CORR weights, CR2/Satterthwaite) against robumeta 2.1 and clubSandwich 0.7.0. The page is the one committed at
allmeta e042af5 (draft PR #146); the allmeta release and its DOI are pending and are recorded as
`[ALLMETA RELEASE PENDING]`. When the release exists, a provenance commit should fill those placeholders,
update the verifier assertion on them and re-pin SOURCE_SHA256.json.
