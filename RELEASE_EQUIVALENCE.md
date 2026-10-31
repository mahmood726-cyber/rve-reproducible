# Equivalence of the archived v1.1 layer with allmeta v1.9.0

allmeta v1.9.0: tag `v1.9.0`, commit `d38d3fd70656f3fedfa03916573fe0bf904f5e9c`, DOI 10.5281/zenodo.23833871
(concept DOI 10.5281/zenodo.20516880). Its parent is `6ce55eb9232b17b6fb0948ec8217d653acf28b57`; the release commit
changes only `CHANGELOG.md`, `CITATION.cff` and `shared/build-info.js`. The v1.1 layer (`app-v1.1/`) was taken from the
PR #210 merge commit `575cb29468f814ad09401d78f1a75fbda16b8abc`, which is an ancestor of v1.9.0.

All 15 files listed in `app-v1.1/app-sha256.json` were compared with their v1.9.0 Git blobs
(`results/v1.1/release-v1.9.0/release-equivalence.json`). 14 are byte-identical: the page `rve-meta/index.html`, the
engine `shared/rve.js`, `shared/stats-qt.js` and `shared/rve-eigen.js`, `shared/rve-extras.js`, the other scripts and
stylesheets the page loads, and `shared/numerics/`. The one that differs:

| File | Difference from the archived 575cb29 bytes | Effect on results |
|---|---|---|
| `shared/build-info.js` | `version` v1.8.0 -> v1.9.0, `sha`/`shortSha` -> 6ce55eb, `builtAt` -> the release build time; nothing else (the verifier blanks those four fields and requires the rest to be equal). The v1.9.0 bytes are kept as `results/v1.1/release-v1.9.0/build-info.v1.9.0.js`. | none on numbers: the engine captures do not load it, and the page only stamps it into exports |

No archived file was replaced; `app-v1.1/` keeps the 575cb29 bytes that the evidence was produced from.

Check by execution (31 Oct 2026, Windows integration host, Node v24.13.0) on the v1.9.0 bytes (`git archive` of the tag,
LF):

- Full-corpus engine capture with the unmodified capture scripts (`bench/v1.1/engine_full.redacted.cjs`, only the
  configuration path set; `bench/v1.1/r2-capture-worker.cjs`): 16,270 configurations, capture SHA-256
  `5d9dae530490ec54ac56bf15872096b250de93491d73e7bb65cc6c93cb8aed41`, byte-identical to the archived `results/v1.1/engine/engine-full-final-j.jsonl.xz` (uncompressed
  `5d9dae53…ed41`); the run was stopped once by the host session at 1,800 configurations and resumed by the script's own append mode (`capture-identity-v1.9.0.txt`). Every count of both comparator modes therefore applies unchanged. Log and metadata:
  `capture-v1.9.0.log`, `engine-full-v1.9.0-meta.json` (its source hashes equal the archived 575cb29 engine bytes).
- Rendered browser tests, Playwright 1.59.1, one worker, port 8088 (`pw.v190.config.mjs`): the four rve-meta specs in
  Edge 155.0.4283.62 and bundled Chromium 147.0.7727.15 (32 each), and the R-fixture render spec in Firefox 148.0.2
  and WebKit 26.4 (6 each): **76 passed**, none failed (`pw-v1.9.0.log`). The builds are printed by
  `browser_versions.mjs` (`browser-versions.log`). This is not a full-corpus browser run.

R references were not regenerated. The 1.0.0 layer (`app/`, e042af5, draft PR #146) and the feature-check evidence
(`results/features/`, corrected engine) are kept unchanged as validated and are not claimed to be byte-identical to
v1.9.0.

All of the archive's v1.1 comparison results therefore apply unchanged to allmeta v1.9.0.
