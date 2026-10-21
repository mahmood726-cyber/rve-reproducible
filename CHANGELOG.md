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

**Release identifiers left unfilled.** For the v1.1 layer the allmeta release is recorded as `<ALLMETA_RELEASE>`, and
its DOI as `<ALLMETA_RELEASE_DOI>`. The engine ships in allmeta v1.9.0, which has not been cut yet. A provenance commit
should fill both tokens with the v1.9.0 tag and DOI once they exist, record equivalence with the v1.9.0 bytes, make
the verifier require the filled values, and re-pin SOURCE_SHA256.json. The verifier currently requires the tokens to
be present and unfilled.

## 1.0.0 (unreleased; not yet published)

Initial reproducibility archive for the paper-15 validation of allmeta rve-meta (robust variance estimation,
CORR weights, CR2/Satterthwaite) against robumeta 2.1 and clubSandwich 0.7.0. The page is the one committed at
allmeta e042af5 (draft PR #146); the allmeta release and its DOI are pending and are recorded as
`[ALLMETA RELEASE PENDING]`. When the release exists, a provenance commit should fill those placeholders,
update the verifier assertion on them and re-pin SOURCE_SHA256.json.
