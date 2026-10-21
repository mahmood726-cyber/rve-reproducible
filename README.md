# Robust variance estimation in the browser: validation of allmeta rve-meta against robumeta and clubSandwich

Validation archive for allmeta F1000 paper 15. The page is `rve-meta` (engine `shared/rve.js` + `shared/stats-qt.js`),
validated against robumeta 2.1 `robu(..., modelweights = "CORR", rho = r, small = TRUE)` and clubSandwich 0.7.0
`coef_test(fit, vcov = "CR2", test = "Satterthwaite")` in R 4.6.0. The corpus has 16,270 configurations from 118
datasets: every intercept-only and single-moderator design the page accepts, at rho = 0, 0.2, 0.5, 0.8 and 1.

**Provenance.** The page was committed on allmeta branch `fix/rve-meta-cr2-parity-p15-v2` at commit
`e042af5736887b2d5ead82ac569163d586548bf1` (draft PR #146). Branch head `09e169150c23` is a merge of main and does
not change any page file. The pre-fix page is allmeta `origin/main` `387660898b5b7a2571736da3149371c20f079bba`.
allmeta release: **[ALLMETA RELEASE PENDING]**. allmeta release DOI: **[ALLMETA RELEASE PENDING]**. This archive
gives no version number and no DOI for the release.

**Versions.**
- R 4.6.0 (ucrt), robumeta 2.1, clubSandwich 0.7.0 and metadat 1.6.0 (`packageVersion`). metadat appears as 1.6-0 in its DESCRIPTION.
- metafor 5.2.1 was used only to build the corpus with `escalc`.
- Node v24.15.0 ran the direct-engine captures.
- Microsoft Edge 151.0.4129.78 with Playwright 1.64.1 ran the browser audit.
- R references used locale C.
- validate.R runs the comparators with Python 3. They need only the standard library.

## Results (strict criterion, unchanged)

Numerical agreement is |app − R| / max(1, |R|) ≤ 1e-9 for the estimate, SE, t, df and τ² (and for the clubSandwich
estimate, SE, t and df). It is |app − R| ≤ 1e-9 for p and the CI limits. Status and refusal category must match
exactly. Every number below is in `expected/paper_values.json` and is reproduced by `validate.R`.

| Comparison | Original page (387660898b) | Patched page (e042af5) |
|---|---:|---:|
| Direct engine vs R (robumeta + clubSandwich) | 511,964 / 546,655 checks; 11,921 failing configurations | **544,324 / 546,941 checks; 785 failing configurations** |
| Browser page, display and exports vs R | 840,829 / 876,415 checks; 12,206 failing configurations | 873,759 / 876,415 checks; 790 failing configurations |
| Browser UI contract (archived observations) | 6 / 17 | 17 / 17 |

**This is not full strict agreement.** 785 patched configurations fail the strict criterion. They stay failures.
Each one is listed in `results/diagnosis/failing-configurations-patched.csv` with its diagnosed cause:

| Diagnosed cause (patched engine) | Configurations |
|---|---:|
| Ill-conditioned design, κ₂(XᵀWX) > 10⁻⁹/u = 9.0×10⁶ (numerical checks only) | 584 |
| Ill-conditioned design with an acceptance disagreement: R refuses on complex eigenvalues, the app fits | 2 |
| Exact fit with near-zero reference SE (≤ 5.8×10⁻¹³) | 190 |
| robumeta and clubSandwich disagree, with disjoint acceptance intervals (dat.besson2016) | 4 |
| Refusal reason differs: the app gives m ≤ p, R gives a complex-eigenvalue error | 5 |
| **Total** | **785** |

So 586 failing configurations are ill-conditioned, 190 are exact fits and 4 are robumeta-versus-clubSandwich
conflicts. Seven are refusal disagreements: the 5 reason mismatches plus the 2 acceptance mismatches, and those 2 are
also among the 586. The cause labels come from archived diagnosis files. The strict categories are in
`results/diagnosis/strict-diagnosis.json.xz`. The condition numbers and κ tiers are in `results/conditioning/`,
produced by `bench/conditioning/conditioning.py` and `summarise.py`. The κ-tier classification was formulated after
the failures had been seen. It is post hoc and is never used as a pass criterion here.

**Denominators.** The two variants have different denominators. A refusal-category check is added only when both the
app and R refuse: original 294 such checks, patched 580. R refuses 582 configurations, and app and R both fit 15,688.

The browser comparison adds parser, display and export checks. It fails in 5 more configurations than the engine
(790 versus 785). Those 5 fail only on 35 `display_row` checks. In those rows only the t cell differs, |t| is at least
1.9×10¹⁶ (exact fits), and the difference lies in digits beyond the 17 significant digits a binary64 value holds.

## Reproduce (one command)

Requirements:
- R 4.6.0 with robumeta 2.1, clubSandwich 0.7.0, metadat 1.6.0, jsonlite and digest.
- Python ≥ 3.8 on PATH as `python` or `py`, or named in the `PYTHON` environment variable.

If jsonlite or digest lives in a separate library, set `R_LIBS_USER` to it. No package is downloaded. From the archive
root:

```text
Rscript validate.R
```

validate.R takes these steps:
1. Checks the R and package versions. It stops on any mismatch.
2. SHA-256-checks every input in `SOURCE_SHA256.json` and refuses unpinned files.
3. Decompresses the inputs into a new `.validate-work/` and verifies every decompressed file against `analysis/compression_proof.json`.
4. Refits robu + coef_test fresh for all 16,270 configurations, using at most two R worker processes, with the job's
   own reference recipe. `analysis/reference_core.R` is byte-identical to `bench/reference.R` lines 10-26, and
   `analysis/test_safeguards.py` checks this. No archived reference is used.
5. Runs the unmodified R2 strict comparator (`bench/compare_engine.py`) on the archived original and patched engine
   captures. It also replays the unmodified browser comparator (`bench/browser/compare.py`) on the archived browser
   captures. Both use the fresh references. The browser is not re-run.
6. Tallies the archived browser UI observations.
7. Prints per-quantity totals and grand totals.

It exits non-zero on wrong versions, an input mismatch, missing, extra or duplicate coverage, or **any** per-quantity
count, total, failing-configuration count or failing (configuration, quantity) set that differs from
`expected/paper_values.json`.

It also reports how many fresh reference files are byte-identical to the archived R2 references. This is
informational. `.validate-work/` must not exist beforehand, so move it aside before a repeat run.

The archived end-to-end run is recorded in `results/validate-run.json`: host, duration, exit code and printed totals.
Its console log, with host paths redacted, is `outputs/validate_R.log`. That run took 2,204 s (about 37 min) with two
workers on a 4-core Windows host. All 16,270 fresh reference files were byte-identical to the archived R2 references.
The archived references end in CRLF because R `writeLines` writes CRLF on Windows. On other platforms that
informational byte count may differ. The gate does not use it: it uses the comparison counts. Only Windows has been
run.

Other checks do not need the R packages:
- `python analysis/verify_archive.py [--full]` checks the inventory, sizes, xz proofs, page bytes, the reference
  bundle, the expected values against archived evidence, the release placeholders and a private-path scan. It also
  verifies the version 1.1 layer by SHA-256. It then re-runs both comparator modes (finite-only and Option A) on the
  archived 1.0.0 and v1.1 captures, plus the rho recheck. Every count must equal `expected/v1.1_values.json` exactly,
  and every output must equal the archived integration output. It also requires the v1.1 release tokens to stay
  unfilled (about 1 min). `--full`
  also replays both unmodified comparators on the archived references and requires byte-identical engine results.
- `python analysis/test_safeguards.py` plants a defect for every gate and checks that the gate fails (it runs
  `analysis/test_gate.R` with Rscript).
- `python analysis/make_outputs.py` rebuilds the tables in `outputs/` and re-runs the unmodified conditioning scripts
  against `results/conditioning/` (numpy, pandas and matplotlib, see requirements.txt).

## Browser audit (completed)

The browser audit was run on the host on 2026-10-19. It used Microsoft Edge 151 through Playwright 1.64.1
(`bench/browser/playwright.r3host.config.cjs`, port 8088), took 57.5 min and exited 0. It drove both page variants
over all 16,270 configurations: the parser, the display table and five exports (JSON, CSV, Markdown, report .md and
.txt). It also ran a 17-item UI contract.

The raw captures are `results/browser/app-{original,patched}.jsonl.xz`. The other outputs are `browser-*.json`,
`ui-*.json`, `downloads-*/`, `browser-host.json` and `browser-host.log`. The archived comparator outputs are
`compare-results-*.json` and `compare-failures-*.json.xz`. validate.R does not launch a browser. It replays the
comparison on these archived observations against fresh R references.

## Version 1.1 layer: the merged exact-R engine

Version 1.1 adds a layer for the engine that replaced the e042af5 page. It was merged into allmeta main by pull request
#210 at commit `575cb29468f814ad09401d78f1a75fbda16b8abc`. The engine combines a stable C-locale factor ordering, a
64-significand-bit extended sum and corrected mean with a WebAssembly DSYEVR/DGEEV eigen backend
(`shared/rve-eigen.js`). allmeta release: **`<ALLMETA_RELEASE>`**. allmeta release DOI: **`<ALLMETA_RELEASE_DOI>`**.
Both are left unfilled until the release exists. Nothing in the 1.0.0 layer above is changed.

- `app-v1.1/` holds the rve-meta page and every file it loads (two stylesheets, eight scripts) at the 575cb29 Git LF
  bytes. It also holds `shared/numerics/`: the backend build script, runtime, notes and `LICENSES-rve-eigen.md`.
  **`shared/rve-eigen.js` is GPL-3.0, as distributed by webR.** It embeds the webR builds of R's BLAS/LAPACK. The rest
  of the page is MIT. `app-v1.1/app-sha256.json` lists the hashes.
- `results/v1.1/engine/` holds the full-corpus capture of the merged engine, `engine-full-final-j.jsonl.xz`. It is 35 MB
  uncompressed and 3.3 MB as xz, so it is included. Its uncompressed SHA-256 is
  `5d9dae530490ec54ac56bf15872096b250de93491d73e7bb65cc6c93cb8aed41`. The final-j, final-k, final-k-commit and combined
  captures on the integration host were byte-identical. The final-k-commit capture metadata records source hashes equal
  to the 575cb29 bytes of `shared/rve.js`, `shared/rve-eigen.js` and `shared/stats-qt.js`. The comparison outputs
  for both comparator modes are here, for the merged engine (`final-j-*`) and for the e042af5 baseline
  (`baseline-*`). The baseline capture is the archived `results/engine/engine-full-patched.jsonl.xz`.
- `results/v1.1/changed-status/` lists every configuration whose status changed, in both modes. Both `newly_failing`
  lists are empty.
- `results/v1.1/residuals/` holds the residual evidence for the 49 configurations that fail in both modes.
- `results/v1.1/rho/` holds the 448-design supplementary rho recheck: the captures, references, results and the
  fresh-R locale proof.
- `results/v1.1/planted/` holds the planted-defect result (a 2e-9 relative change to one estimate is rejected in
  both modes) and the planted-engine defects.
- `results/v1.1/exposure/` holds the lane-K exposure scan of numeric cluster IDs (670,000 values, 0 conflicts with the
  fixed rule), with the scan scripts and the `as-character` fixtures from 575cb29.
- `bench/v1.1/` holds the integration scripts, the Option A rule text, the integration reports and the upstream licence
  texts.

`results/v1.1/MANIFEST.json` records every evidence file's source and SHA-256. Files that held host paths are stored as
`*.redacted.*` copies, with the path prefix replaced by `<HOST>/`. The manifest keeps the SHA-256 of the unredacted
file.

| Comparator mode, unchanged 1e-9 tolerance | e042af5 page | Merged engine (575cb29) |
|---|---:|---:|
| Finite-only (the 1.0.0 rule) | 15,485 / 16,270 | **16,136 / 16,270** |
| Option A | 15,520 / 16,270 | **16,221 / 16,270** |
| Supplementary rho recheck, finite-only / Option A (designs) | 421 / 422 of 448 | 442 / 443 of 448 |

**Option A comparator rule** (`analysis/option_a.py`, `analysis/compare_modes.py`). Both-undefined counts as agreement
ONLY when the app and R are undefined for the SAME reason. Each side records its own reason code (`REFUSED:<category>`,
`DF_NONPOSITIVE`, `SE_ZERO` or `OTHER_NONFINITE`) from its own SE and df, never from the other side's. The 1e-9
tolerance is unchanged, and a finite value against an undefined one always fails. The finite-only mode is the 1.0.0
predicate, and it is still reported. On the merged engine, **85 configurations** differ between the two modes. In
each of them the app and R are both undefined (t and p against robumeta and clubSandwich, with SE exactly 0 on both sides), giving 510 checks, all
`SE_ZERO` on both sides. They fail under finite-only and pass under Option A: 16,136 + 85 = 16,221. The remaining
49 configurations fail in both modes, on clubSandwich checks only (`results/v1.1/residuals/`).
`analysis/test_option_a.py` plants three defects that must fail in both modes: app null where R has a number, R null
where the app has a number, and both null with different reasons. It also plants a 2e-9 estimate change.

## Layout

| Path | Contents |
|---|---|
| `app/` | The nine files the page loads, as Git LF bytes at e042af5, plus `app-sha256.json`. |
| `app-original/` | The same nine files at 387660898b, the pre-fix page used for the "original" numbers. |
| `bench/` | Unmodified job scripts, unmodified reports and package documentation with licences (`bench/documentation/`). The scripts cover corpus, configuration, R reference, engine capture, comparators, diagnosis, patch generator and R2 traces. The reports are RESULTS.md, RESULT_R2.md, STRICT_DIAGNOSIS.md, STUCK_FAILURES.md and the task specifications. Also here: `fix.patch`, the browser harness (`bench/browser/`), the conditioning scripts (`bench/conditioning/`) and the CRLF engine files exactly as captured (`bench/captured-engine/`). |
| `data/` | `configurations.json.xz`, the configuration, column and dataset ledgers, exclusions, coverage, the corpus and the environment records. |
| `results/engine/` | Engine captures for both variants (xz), capture metadata, the archived R2 comparison outputs, and the API/edge fixtures. |
| `results/reference/` | The archived R2 R references: one JSON line per configuration (xz), with a per-file SHA-256 index. |
| `results/diagnosis/` | The strict diagnosis, failing configurations with causes, R2 traces and proofs, and reference disagreements. |
| `results/conditioning/` | Condition numbers per configuration, the post hoc tier summary, the exact-fit check and the figure. |
| `results/browser/` | The browser audit captures, downloads, UI checks and comparator outputs. |
| `expected/paper_values.json` | Pinned counts, read from archived evidence by `analysis/build_archive.py`. |
| `analysis/` | validate.R helpers, the build, verification, safeguard and output scripts, and the compression proof. |
| `app-v1.1/`, `results/v1.1/`, `bench/v1.1/` | The version 1.1 layer: the merged engine at allmeta 575cb29, its evidence and the integration scripts (see above). |
| `outputs/` | Derived artefacts (tables, numbers, logs, fresh validate outputs). These are not source evidence and are not pinned. |

`SOURCE_SHA256.json` pins every file except `outputs/`, `results/validate-run.json`, scratch directories and itself.

Large files are stored with deterministic xz (Python lzma, preset 6, CRC64). Their uncompressed SHA-256 values,
including that of the 105 MB `configurations.json`, are recorded in `analysis/compression_proof.json`. Every file is
under 90 MB and the archive is under 500 MB.

The engine captures were made from Windows working copies of the three changed files. Those copies had CRLF line
endings, and their hashes are in `results/engine/engine-full-patched-meta.json`. They equal the committed LF bytes in
`app/` after CRLF→LF; `verify_archive.py` checks this.

## Limits

- **Not full strict agreement.** The 785 failing configurations are documented, not waived. No tolerance, reference
  record, comparator or configuration was changed.
- **The two references themselves differ.** In the 4 dat.besson2016 configurations, no single answer can pass both
  robumeta and clubSandwich (`r2-reference-disagreements.json`). These 4 are part of 11 configurations, with 30 checks
  in total, that have disjoint acceptance intervals.
- **R and the app take different eigen paths.** In 7 configurations R fails on complex eigenvalues produced by
  rounding asymmetry in a symmetric block, while the app uses a symmetric eigensolver
  (`results/diagnosis/r2-complex-trace.json`). The app was not made to imitate R's failure.
- **The conditioning tiers are post hoc.** They classify failures and are not a pass criterion. The tiered totals in
  `expected/paper_values.json` (`tiered_totals_post_hoc`) are not 1e-9 agreement.
- **Datasets are numerical test fixtures.** Moderators are chosen by a mechanical eligibility rule
  (`bench/configure.py`). Dependent effect sizes are test inputs, not substantive findings. Package examples can
  include simulated data.
- **Two effect definitions are excluded.** dat.begg1989::002 and dat.tian2009::001 have no aligned clustering
  column (`data/cluster-exclusions.json`). The dataset-level inclusion decision for every enumerated dataset is in
  `data/dataset-ledger.csv`: 118 included, 1 excluded.
- **Some job materials are left out.** Round 3 (Rules C/K/X) was blocked on the job host (`bench/R3_BLOCKED.md`) and
  is not part of this archive. Job files that held host paths or access details were not archived. These include the
  round-1 task file, progress notes and the scout scripts. The R2 environment record is archived with its two library
  paths redacted (`data/r2-environment.redacted.json`).

| Item | Static | Dynamic / source-backed |
|---|---|---|
| Criterion | 1e-9 tolerances, exact status and refusal category, CORR/small = TRUE/CR2/Satterthwaite | Executed robu/coef_test fits on every configuration |
| Corpus | Archived recipes, eligibility rule and rho grid | 16,270 configurations from package data (`data/`) |
| App | e042af5 and 387660898b page bytes | Engine and browser captures of every configuration |
| Findings | Expected counts pinned from archived outputs | Fresh R refits plus unmodified comparators reproduce every count |
| Diagnosis | Cause labels and the post hoc κ threshold 10⁻⁹/u | Condition numbers and categories computed from captures and references |
| Provenance | Commit identifiers; release and DOI pending | SHA-256 inventory, xz proofs, CRLF/LF equivalence |

MIT applies to the archive tooling. Bundled package documentation and source keep their upstream GPL licences and
citations (`bench/documentation/`). The robumeta and clubSandwich binaries are not redistributed. Their CRAN URLs
and SHA-256 values are in `bench/packages-provenance.json`.

## Evidence integrity

After the 19 Oct 2026 browser audit, the lane's review_final.py reported 16301/16301 evidence-integrity checks passing (bench/RESULT.md is the earlier 17 Oct report and says 16295/16301). Neither number is a numerical agreement count.
