# RVE validation against robumeta and clubSandwich

Source snapshot: origin/main `387660898b5b7a2571736da3149371c20f079bba`. Source clone untouched; no commit or push.

Browser original: **840829/876415 checks pass**. Patched: **873759/876415 checks pass**. Strict failures are retained.

Direct engine original: **511964/546655 checks pass**, 16270/16270 configurations captured. This is not browser or export validation.

Direct engine patched: **544324/546941 checks pass**, 16270/16270 configurations captured. This is not browser or export validation.

## Scope and provenance

R 4.6.0, metafor 5.2.1, metadat 1.6.0; robumeta 2.1, clubSandwich 0.7.0. Requested CRAN install.packages failed to access its index. Python downloaded the same CRAN binary repository archives, then R install.packages(repos=NULL,type="win.binary") installed them into this job's scratch library. Archive URLs and SHA-256 hashes are in packages/provenance.json. The pinned metafor/metadat library was first in .libPaths; R_LIBS names the scratch library without metafor. clubSandwich reports that its binary was built under R 4.6.1; it loaded under 4.6.0. All numerical runs were local; no offload host was used.

The corpus reconstructs job16's documented effect-size recipes, retaining aligned source metadata, and enumerates all installed metadat datasets. Five supplemental datasets were available: robumeta corrdat, hierdat, oswald2013, and clubSandwich dropoutPrevention and SATcoaching. oswald2013 uses metafor::escalc ZCOR on R/N. This is a software-testing corpus, including package examples; no clinical result or independently verified trial-ID claim is made.

16270 unique configurations from 118 datasets. Rho is 0, 0.2, 0.5, 0.8, 1. Every aligned column matching the declared study/trial/article/district/author/paper/publication/experiment/ID naming rule is tried as clustering, including singleton clusterings. Explicit constructor-returned studlab columns and documented person, team, site and site_station identifiers are also eligible (documented-clusters.json). Multi-arm metadata is retained from the documented pairwise construction; no alignment is inferred from row counts alone. The append-only metadata extension preserved all 13,625 previous configurations exactly and added 2,645 configurations (configuration-extension-proof.json). For each clustering: intercept-only and each numeric scalar or numeric-coercible text/logical column separately, excluding the cluster and canonical yi/vi/sei. Text/factor columns are not automatically dummy-coded because the page accepts numeric predictors. Predictor combinations are outside this exhaustive single-moderator scope. Constant and effect-alias predictors remain included, so rank-deficient and exact-fit cases are visible rather than silently filtered.

Missing/nonfinite effects, nonpositive variances and missing cluster/moderator values are excluded with source-row records. The final dataset ledger, configuration ledger, column ledger, construction attempts, construction coverage ledger and cluster exclusions record eligibility and limits. Metadata from transformed rows is not guessed. No study-count cap was imposed. Source cluster labels are percent-encoded reversibly for the page's comma-separated input, preserving cluster membership; no clinical identifiers are invented. Numerical inputs use binary64 round trips; both sides use the same SE-squared variances from the reusable corpus recipes.

Reference records available: 16270/16270; statuses {'ok': 15688, 'refused': 582}. Reference warnings and errors are retained. m<=p and rank-deficient designs are guarded explicitly; an R fit's own error is retained when it occurs first. Successful fits use robu(modelweights="CORR", small=TRUE), with coef_test(vcov="CR2",test="Satterthwaite") on that same fit. The clubSandwich documentation specifies its default target as inverse fitted weights, matching this comparison.

## What the page actually does

The page fits the CORR model, HTJ moment tau-squared, CR2 sandwich SEs and coefficient-specific Satterthwaite df. It reports coefficient, SE, signed t, df, Student-t 95% CI and two-sided p, plus effect/cluster/coefficient counts, tau-squared and rho. It has no I-squared output, no HIER option, no method selector and no plot. R's I.2 is retained as reference metadata and is not claimed as a validated page output. JSON/CSV/Markdown and Methods+Results text/Markdown exports share the captured fit/summary. No generated executable R export is offered.

The supplied browser harness uses only port 8088 through ../pwlock.sh. It loads the actual copied page and wraps its public fit function solely to capture parsed inputs and exceptions. It records the table and all five export-handler blob contents per configuration; native download actions are separate focused checks. JSON, CSV, data Markdown and report data are compared to the captured result. Browser execution and coverage are stated explicitly above; the existence of this harness is not evidence of an executed test. Export-only covariance off-diagonals and weights are not independently compared to R; the requested per-coefficient quantities and tau-squared define the numerical comparison.

The independent direct-engine harness loads the copied shared/rve.js and shared/stats-qt.js unchanged, records their hashes and Node version, and supplies the same corpus numbers. It neither reimplements the estimator nor exercises the page parser, table, controls or exports. All numerical runs were local; the optional SSH offload attempt failed host-key verification because its known-hosts file was unreadable, and verification was not disabled.

## Tolerances

1e-9 relative to max(1,abs(R)) for coefficient, SE, t, df and tau-squared; 1e-9 absolute for p and both CI endpoints. Counts, input identity, rho, statuses, rendered rows and export clearing are exact. The display uses its own captured numerical result at the page's shown decimals. The clubSandwich SE, df, signed t, beta and p are checked independently. No post-hoc tolerance relaxation or substitution of corrected references is used.

## Proposed fixes and limits

fix.patch changes only app-side files. Root causes include the contradictory CR1 introduction (rve-meta/index.html), silently zero-filled invalid predictors and inconsistent row widths (parseInput), stale last-fit exports after failure (run), the rho control excluding 1, missing low-df caution, prototype-key cluster maps (shared/rve.js), an absolute matrix pivot cutoff, silent normal-inference fallback, and insufficient Student-t incomplete-beta convergence precision (shared/stats-qt.js). The patch uses fail-closed input/dependency checks, clears prior exports, permits rho=1, warns at df<4, uses null-prototype maps and a scale-relative matrix pivot criterion, and tightens the incomplete-beta iteration tolerance. Exact original file:line anchors are in root-causes.json.

Constant/effect-alias predictors and poorly conditioned designs can produce nearly zero residual SEs. Tiny floating-point differences can then dominate t and p even when coefficient and SE absolute differences meet tolerance. Such cases remain in failure lists. This audit does not turn failed strict checks into passes merely because an explanation exists. Any unresolved checks are release blockers for an unconditional numerical-parity claim.

| Quantity | Original pass/checks | Patched pass/checks | Original max difference | Patched max difference |
|---|---:|---:|---:|---:|
| CSV_content | 16270/16270 | 16270/16270 | 0 | 0 |
| JSON_export | 16270/16270 | 16270/16270 | 0 | 0 |
| Markdown_content | 16270/16270 | 16270/16270 | 0 | 0 |
| app_present | 16270/16270 | 16270/16270 | 0 | 0 |
| ci_hi | 19697/29781 | 29243/29781 | 1.22506316984e-05 | 4.01182478527e-06 |
| ci_lo | 19694/29781 | 29241/29781 | 1.19526066555e-05 | 2.37269705394e-06 |
| club_df | 29711/29781 | 29721/29781 | 60.6308199835 | 60.6308199835 |
| club_estimate | 29738/29781 | 29742/29781 | 8.17367752898e-09 | 4.08639089175e-09 |
| club_p | 23399/29781 | 29571/29781 | 1 | 0.999988407889 |
| club_se | 29700/29781 | 29718/29781 | 2.58153759658e-06 | 2.58157696142e-06 |
| club_t | 29210/29781 | 29340/29781 | 69.1453769751 | 6.14460577688 |
| coefficient_count | 15688/15688 | 15688/15688 | 0 | 0 |
| coefficient_index | 29781/29781 | 29781/29781 | 0 | 0 |
| design_columns | 15688/15688 | 15688/15688 | 0 | 0 |
| df | 29741/29781 | 29751/29781 | 2.51890495142e-09 | 2.57374798824e-09 |
| display_row | 29756/29781 | 29746/29781 | 0 | 0 |
| estimate | 29738/29781 | 29742/29781 | 8.17367752898e-09 | 4.08639089175e-09 |
| export_beta_consistency | 29781/29781 | 29781/29781 | 0 | 0 |
| export_csv_present | 16270/16270 | 16270/16270 | 0 | 0 |
| export_df_consistency | 29781/29781 | 29781/29781 | 0 | 0 |
| export_json_present | 16270/16270 | 16270/16270 | 0 | 0 |
| export_md_present | 16270/16270 | 16270/16270 | 0 | 0 |
| export_report-md_present | 16270/16270 | 16270/16270 | 0 | 0 |
| export_report-txt_present | 16270/16270 | 16270/16270 | 0 | 0 |
| export_se_consistency | 29781/29781 | 29781/29781 | 0 | 0 |
| extra_app_keys | 1/1 | 1/1 | 0 | 0 |
| input_count | 15688/15688 | 15688/15688 | 0 | 0 |
| input_identity | 15688/15688 | 15688/15688 | 0 | 0 |
| m | 15688/15688 | 15688/15688 | 0 | 0 |
| method | 15688/15688 | 15688/15688 | 0 | 0 |
| n | 15688/15688 | 15688/15688 | 0 | 0 |
| p | 23403/29781 | 29586/29781 | 1 | 0.999988407889 |
| reference_key | 16270/16270 | 16270/16270 | 0 | 0 |
| reference_present | 16270/16270 | 16270/16270 | 0 | 0 |
| refusal_category | 285/582 | 575/582 | 0 | 0 |
| refusal_export_cleared | 0/582 | 580/582 | 0 | 0 |
| report_MD_data | 16270/16270 | 16270/16270 | 0 | 0 |
| report_text_data | 16270/16270 | 16270/16270 | 0 | 0 |
| rho | 15688/15688 | 15688/15688 | 0 | 0 |
| se | 29716/29781 | 29756/29781 | 4.67638968854e-09 | 4.59333822295e-09 |
| status | 15982/16270 | 16268/16270 | 0 | 0 |
| t | 29241/29781 | 29361/29781 | 69.1453769751 | 6.14460577688 |
| tau2 | 15678/15688 | 15678/15688 | 2.68731215058e-09 | 1.33851477124e-09 |
| unique_app_keys | 1/1 | 1/1 | 0 | 0 |


## Direct-engine numerical comparison (separate denominator)

| Quantity | Original pass/checks | Patched pass/checks | Original max difference | Patched max difference |
|---|---:|---:|---:|---:|
| ci_hi | 19697/29781 | 29243/29781 | 1.22506316984e-05 | 4.01183933718e-06 |
| ci_lo | 19694/29781 | 29241/29781 | 1.19526066555e-05 | 2.37271342485e-06 |
| club_df | 29711/29781 | 29721/29781 | 60.6308199835 | 60.6308199835 |
| club_estimate | 29738/29781 | 29742/29781 | 8.17367752898e-09 | 4.08639089175e-09 |
| club_p | 23399/29781 | 29571/29781 | 1 | 0.999988407889 |
| club_reference_success | 29781/29781 | 29781/29781 | 0 | 0 |
| club_se | 29700/29781 | 29718/29781 | 2.58153759658e-06 | 2.58157696142e-06 |
| club_t | 29210/29781 | 29340/29781 | 69.1453769751 | 6.14460577688 |
| coefficient_count | 15688/15688 | 15688/15688 | 0 | 0 |
| design_columns | 15688/15688 | 15688/15688 | 0 | 0 |
| df | 29741/29781 | 29751/29781 | 2.51890495142e-09 | 2.57374798824e-09 |
| estimate | 29738/29781 | 29742/29781 | 8.17367752898e-09 | 4.08639089175e-09 |
| key | 16270/16270 | 16270/16270 | 0 | 0 |
| m | 15688/15688 | 15688/15688 | 0 | 0 |
| method | 15688/15688 | 15688/15688 | 0 | 0 |
| n | 15688/15688 | 15688/15688 | 0 | 0 |
| p | 23403/29781 | 29586/29781 | 1 | 0.999988407889 |
| reference_key | 16270/16270 | 16270/16270 | 0 | 0 |
| reference_present | 16270/16270 | 16270/16270 | 0 | 0 |
| refusal_category | 285/294 | 575/580 | 0 | 0 |
| se | 29716/29781 | 29756/29781 | 4.67638968854e-09 | 4.59333822295e-09 |
| status | 15982/16270 | 16268/16270 | 0 | 0 |
| t | 29241/29781 | 29361/29781 | 69.1453769751 | 6.14460577688 |
| tau2 | 15678/15688 | 15678/15688 | 2.68731215058e-09 | 1.33851477124e-09 |

## Focused browser checks

original: 6/17 checks pass.

patched: 17/17 checks pass.

original browser version: 151.0.4129.78.

patched browser version: 151.0.4129.78.

Separate synthetic large-variance fixture, original: 0/1 checks pass. The original absolute pivot cutoff rejects this R-accepted fit; the patch's scale-relative cutoff accepts it and is checked against all coefficient inference fields.

Separate synthetic large-variance fixture, patched: 8/8 checks pass. The original absolute pivot cutoff rejects this R-accepted fit; the patch's scale-relative cutoff accepts it and is checked against all coefficient inference fields.

## Hardcode disclosure

| Item | Static or dynamic |
|---|---|
| Rho grid and acceptance tolerances | Static task specification |
| Cluster-name eligibility, single-moderator scope | Static disclosed audit rule |
| Effects, variances, source rows, fitted results, counts | Dynamic package data and actual execution |
| Malformed-input focused cases | Explicit synthetic software fixtures, not research outputs |

## Reproduction

The archive requires the pinned metafor/metadat library at ../re/Rlib_dta and jsonlite in the configured extra R library. Run install.R (or download_packages.py then install_archives.R for the documented network workaround), run_r.py corpus.R, run_r.py extra.R, configure.py, append_shards.py, run_references.py, reference_cache.py, patch_app.py; install the pinned tests/package.json dependencies, then `bash ../pwlock.sh <this-job>/tests <this-job>/browser.log -- --config=playwright.config.cjs`. Run compare.py original, compare.py patched, run_r.py edge.R, node edge.cjs, review_final.py and report.py. See source-manifest.json and artifact-manifest.json for provenance. R outputs are resumable by numbered reference file; deleting a reference file recomputes that case. No publication, portfolio status promotion, commit or push was performed.

Direct API synthetic contracts, original: 1/12 pass. These do not test the browser parser.

Direct API synthetic contracts, patched: 12/12 pass. These do not test the browser parser.

Excluded effect definitions lacking aligned clustering metadata: dat.begg1989::002, dat.tian2009::001. Their source row lengths or names did not align; no clustering was guessed. These are explicit coverage limits, not numerical passes.

The resume consolidated existing reference JSON bytes into reference-byte-cache.json using parallel reads, SHA-256 verification and source size/mtime guards. No R fits or data were regenerated. Rebuild this byte cache with `python reference_cache.py` after extracting the archive, because file timestamps can change. It only reads existing references.

See STRICT_DIAGNOSIS.md and strict-diagnosis.json for the retained strict-failure breakdown. See BROWSER_TODO.md for exact deferred host commands.
