import json,collections,hashlib,zipfile
from pathlib import Path
from reference_cache import load_cache, reference_json
cache=load_cache()
load=lambda p:reference_json(cache,p) if Path(p).parent==Path('reference') else json.loads(Path(p).read_text(encoding='utf-8'))
cs=load('configurations.json');versions=load('packages/provenance.json');source=load('source-manifest.json');extension=load('configuration-extension-proof.json')
original=load('results-original.json');patched=load('results-patched.json')
ui={v:load(f'ui-{v}.json') if Path(f'ui-{v}.json').exists() else [] for v in ['original','patched']}
refs=[load(p) for p in sorted(Path('reference').glob('*.json'))]
text=f'''# RVE page validation against robumeta and clubSandwich

Source snapshot: origin/main `{source['commit']}`. Only copied files were edited; no commit or push.

Original: **{original['passes']}/{original['checks']} checks pass**. Patched: **{patched['passes']}/{patched['checks']} checks pass**. Missing evidence counts as failure. See machine-readable results and full failure lists; this is not an unconditional validation claim.

## Scope and provenance

R 4.6.0, metafor 5.2.1, metadat 1.6.0; robumeta {versions['robumeta']['version']}, clubSandwich {versions['clubSandwich']['version']}. Requested CRAN install.packages failed to access its index. Python downloaded the same CRAN binary repository archives, then R install.packages(repos=NULL,type="win.binary") installed them into this job's scratch library. Archive URLs and SHA-256 hashes are in packages/provenance.json. The pinned metafor/metadat library was first in .libPaths; R_LIBS names the scratch library without metafor. clubSandwich reports that its binary was built under R 4.6.1; it loaded under 4.6.0. All numerical runs were local; no offload host was used.

The corpus reconstructs job16's documented effect-size recipes, retaining aligned source metadata, and enumerates all installed metadat datasets. Five supplemental datasets were available: robumeta corrdat, hierdat, oswald2013, and clubSandwich dropoutPrevention and SATcoaching. oswald2013 uses metafor::escalc ZCOR on R/N. This is a software-testing corpus, including package examples; no clinical result or independently verified trial-ID claim is made.

{len(cs)} unique configurations from {len(set(c['dataset'] for c in cs))} datasets. Rho is 0, 0.2, 0.5, 0.8, 1. Every aligned column matching the declared study/trial/article/district/author/paper/publication/experiment/ID naming rule is tried as clustering, including singleton clusterings. For each clustering: intercept-only and each numeric scalar column separately, excluding the cluster and canonical yi/vi/sei. Text/factor columns are not automatically dummy-coded because the page accepts numeric predictors. Predictor combinations are outside this exhaustive single-moderator scope. Constant and effect-alias predictors remain included, so rank-deficient and exact-fit cases are visible rather than silently filtered.

Missing/nonfinite effects, nonpositive variances and missing cluster/moderator values are excluded with source-row records. The configuration ledger, column ledger, construction attempts, coverage ledger and cluster exclusions record eligibility and limits. Metadata from transformed rows is not guessed. No study-count cap was imposed. Source cluster labels are percent-encoded reversibly for the page's comma-separated input, preserving cluster membership; no clinical identifiers are invented. Numerical inputs use binary64 round trips; both sides use the same SE-squared variances from the reusable corpus recipes.

Reference records available: {len(refs)}/{len(cs)}; statuses {dict(collections.Counter(r['status'] for r in refs))}. Reference warnings and errors are retained. m<=p and rank-deficient designs are guarded explicitly; an R fit's own error is retained when it occurs first. Successful fits use robu(modelweights="CORR", small=TRUE), with coef_test(vcov="CR2",test="Satterthwaite") on that same fit. The clubSandwich documentation specifies its default target as inverse fitted weights, matching this comparison.

## What the page actually does

The page fits the CORR model, HTJ moment tau-squared, CR2 sandwich SEs and coefficient-specific Satterthwaite df. It reports coefficient, SE, signed t, df, Student-t 95% CI and two-sided p, plus effect/cluster/coefficient counts, tau-squared and rho. It has no I-squared output, no HIER option, no method selector and no plot. R's I.2 is retained as reference metadata and is not claimed as a validated page output. JSON/CSV/Markdown and Methods+Results text/Markdown exports share the captured fit/summary. No generated executable R export is offered.

Browser tests use only port 8088 through ../pwlock.sh. The actual copied page executes; the runner wraps the public fit function solely to capture parsed inputs and exceptions, without reimplementing the estimator. The table and export payload are captured for every completed configuration. Focused tests click all five download buttons; full-content JSON equality is checked. CSV and Markdown download checks establish successful generation, not exhaustive content equivalence. Missing browser captures never pass.

## Tolerances

1e-9 relative to max(1,abs(R)) for coefficient, SE, t, df and tau-squared; 1e-9 absolute for p and both CI endpoints. Counts, input identity, rho, statuses, rendered rows and export clearing are exact. The display uses its own captured numerical result at the page's shown decimals. The clubSandwich SE, df, signed t, beta and p are checked independently. No post-hoc tolerance relaxation or substitution of corrected references is used.

## Proposed fixes and limits

fix.patch changes only app-side files. Root causes include the contradictory CR1 introduction (rve-meta/index.html), silently zero-filled invalid predictors and inconsistent row widths (parseInput), stale last-fit exports after failure (run), the rho control excluding 1, missing low-df caution, prototype-key cluster maps (shared/rve.js), an absolute matrix pivot cutoff, silent normal-inference fallback, and insufficient Student-t incomplete-beta convergence precision (shared/stats-qt.js). The patch uses fail-closed input/dependency checks, clears prior exports, permits rho=1, warns at df<4, uses null-prototype maps and scale-aware inversion, and tightens the incomplete-beta iteration tolerance. Exact original file:line anchors are in root-causes.json.

Constant/effect-alias predictors and poorly conditioned designs can produce nearly zero residual SEs. Tiny floating-point differences can then dominate t and p even when coefficient and SE absolute differences meet tolerance. Such cases remain in failure lists. This audit does not turn failed strict checks into passes merely because an explanation exists. Any unresolved checks are release blockers for an unconditional numerical-parity claim.

| Quantity | Original pass/checks | Patched pass/checks | Original max difference | Patched max difference |
|---|---:|---:|---:|---:|
'''
for q in sorted(set(original['quantities'])|set(patched['quantities'])):
 a=original['quantities'].get(q,dict(passes=0,checks=0,max_difference=0));b=patched['quantities'].get(q,dict(passes=0,checks=0,max_difference=0))
 text+=f"| {q} | {a['passes']}/{a['checks']} | {b['passes']}/{b['checks']} | {a['max_difference']:.12g} | {b['max_difference']:.12g} |\n"
text+='\n## Focused browser checks\n\n'
for v in ui:text+=(f"{v}: {sum(x['pass'] for x in ui[v])}/{len(ui[v])} checks pass.\n\n" if ui[v] else f"{v}: no focused browser evidence; not run.\n\n")
for v in ui:
 p=Path(f'browser-{v}.json')
 if p.exists():text+=f"{v} browser version: {load(p)['browser']}.\n\n"
for v in ui:
 p=Path(f'edge-{v}.json')
 if p.exists():
  e=load(p)['checks'];text+=f"Separate synthetic large-variance fixture, {v}: {sum(x['pass'] for x in e)}/{len(e)} checks pass. The original absolute pivot cutoff rejects this R-accepted fit; the patch's scale-relative cutoff accepts it and is checked against all coefficient inference fields.\n\n"
text+='''## Hardcode disclosure

| Item | Static or dynamic |
|---|---|
| Rho grid and acceptance tolerances | Static task specification |
| Cluster-name eligibility, single-moderator scope | Static disclosed audit rule |
| Effects, variances, source rows, fitted results, counts | Dynamic package data and actual execution |
| Malformed-input focused cases | Explicit synthetic software fixtures, not research outputs |

## Reproduction

The archive requires the pinned metafor/metadat library at ../re/Rlib_dta and jsonlite in the configured extra R library. Run install.R (or download_packages.py then install_archives.R for the documented network workaround), run_r.py corpus.R, run_r.py extra.R, configure.py, append_shards.py, run_references.py, reference_cache.py, patch_app.py; install the pinned tests/package.json dependencies, then `bash ../pwlock.sh <this-job>/tests <this-job>/browser.log -- --config=playwright.config.cjs`. Run compare.py original, compare.py patched, run_r.py edge.R, node edge.cjs, review_final.py and report.py. See source-manifest.json and artifact-manifest.json for provenance. R outputs are resumable by numbered reference file; deleting a reference file recomputes that case. No publication, portfolio status promotion, commit or push was performed.
'''
engines={v:load(f'engine-results-{v}.json') for v in ui if Path(f'engine-results-{v}.json').exists()}
browser_complete=all(r['app_records']==len(cs) for r in [original,patched]) and all(ui.values())
header='# RVE validation against robumeta and clubSandwich\n\n'
header+=f"Source snapshot: origin/main `{source['commit']}`. Source clone untouched; no commit or push.\n\n"
if browser_complete:
 header+=f"Browser original: **{original['passes']}/{original['checks']} checks pass**. Patched: **{patched['passes']}/{patched['checks']} checks pass**. Strict failures are retained.\n\n"
else:
 header+='**INCOMPLETE: the required browser audit is blocked.** The mandated ../pwlock.sh cannot create its hardcoded shared lock directory: `mkdir: Permission denied`. That directory lies outside this session\'s writable workspace. The waiting process was stopped after confirming the failure. RESUME.md explicitly defers browser execution to the host; exact commands are in BROWSER_TODO.md. The lock and sandbox were not bypassed.\n\n'
 header+=f"Browser captures: original {original['app_records']}/{len(cs)}, patched {patched['app_records']}/{len(cs)}. Missing browser evidence is not a pass. Frontend parser, display and export changes in fix.patch remain unverified in a real browser.\n\n"
for v,r in engines.items():header+=f"Direct engine {v}: **{r['passes']}/{r['checks']} checks pass**, {r['captured']}/{r['configurations']} configurations captured. This is not browser or export validation.\n\n"
text=header+text[text.index('## Scope and provenance'):]
text=text.replace('scale-aware inversion','a scale-relative matrix pivot criterion')
text=text.replace('each numeric scalar column separately','each numeric scalar or numeric-coercible text/logical column separately')
text=text.replace('including singleton clusterings.', f"including singleton clusterings. Explicit constructor-returned studlab columns and documented person, team, site and site_station identifiers are also eligible (documented-clusters.json). Multi-arm metadata is retained from the documented pairwise construction; no alignment is inferred from row counts alone. The append-only metadata extension preserved all {extension['old_count']:,} previous configurations exactly and added {extension['new_count']-extension['old_count']:,} configurations (configuration-extension-proof.json).")
text=text.replace('The configuration ledger, column ledger, construction attempts, coverage ledger and cluster exclusions','The final dataset ledger, configuration ledger, column ledger, construction attempts, construction coverage ledger and cluster exclusions')
start=text.index('Browser tests use only port 8088')
end=text.index('\n\n## Tolerances',start)
text=text[:start]+'''The supplied browser harness uses only port 8088 through ../pwlock.sh. It loads the actual copied page and wraps its public fit function solely to capture parsed inputs and exceptions. It records the table and all five export-handler blob contents per configuration; native download actions are separate focused checks. JSON, CSV, data Markdown and report data are compared to the captured result. Browser execution and coverage are stated explicitly above; the existence of this harness is not evidence of an executed test. Export-only covariance off-diagonals and weights are not independently compared to R; the requested per-coefficient quantities and tau-squared define the numerical comparison.

The independent direct-engine harness loads the copied shared/rve.js and shared/stats-qt.js unchanged, records their hashes and Node version, and supplies the same corpus numbers. It neither reimplements the estimator nor exercises the page parser, table, controls or exports. All numerical runs were local; the optional SSH offload attempt failed host-key verification because its known-hosts file was unreadable, and verification was not disabled.'''+text[end:]
if engines:
 table='\n## Direct-engine numerical comparison (separate denominator)\n\n| Quantity | Original pass/checks | Patched pass/checks | Original max difference | Patched max difference |\n|---|---:|---:|---:|---:|\n'
 for q in sorted(set().union(*(r['quantities'] for r in engines.values()))):
  values=[engines.get(v,{}).get('quantities',{}).get(q,dict(passes=0,checks=0,max_difference=0)) for v in ['original','patched']]
  a,b=values;table+=f"| {q} | {a['passes']}/{a['checks']} | {b['passes']}/{b['checks']} | {a['max_difference']:.12g} | {b['max_difference']:.12g} |\n"
 text=text.replace('## Focused browser checks',table+'\n## Focused browser checks')
for v in ui:
 p=Path(f'contract-{v}.json')
 if p.exists():
  checks=load(p)['checks'];text+=f"\nDirect API synthetic contracts, {v}: {sum(c['pass'] for c in checks)}/{len(checks)} pass. These do not test the browser parser.\n"
exclusions=load('cluster-exclusions.json')
text+='\nExcluded effect definitions lacking aligned clustering metadata: '+', '.join(x['base'] for x in exclusions)+'. Their source row lengths or names did not align; no clustering was guessed. These are explicit coverage limits, not numerical passes.\n'
text+='\nThe resume consolidated existing reference JSON bytes into reference-byte-cache.json using parallel reads, SHA-256 verification and source size/mtime guards. No R fits or data were regenerated. Rebuild this byte cache with `python reference_cache.py` after extracting the archive, because file timestamps can change. It only reads existing references.\n'
text+='\nSee STRICT_DIAGNOSIS.md and strict-diagnosis.json for the retained strict-failure breakdown. See BROWSER_TODO.md for exact deferred host commands.\n'
Path('RESULTS.md').write_text(text,encoding='utf-8')
Path('results.json').write_text(json.dumps(dict(status='browser audit completed' if browser_complete else 'browser blocked; numerical scope only',original=original,patched=patched,engine=engines,ui={v:dict(checks=len(ui[v]),passes=sum(x['pass'] for x in ui[v])) for v in ui}),indent=2))
blockers=[]
if not browser_complete:blockers.append('Required browser audit blocked: ../pwlock.sh cannot create its shared lock (Permission denied outside writable workspace). No UI/display/export pass is claimed. Host browser execution is deferred explicitly by RESUME.md; exact commands are in BROWSER_TODO.md.')
if patched['failures']:blockers.append(f"Page evidence/comparison ledger has {patched['failures']} failed checks; this includes missing evidence. See failures-patched.json.")
if 'patched' in engines and engines['patched']['failures']:blockers.append(f"Strict patched direct-engine comparison has {engines['patched']['failures']} failed checks. See engine-failures-full-patched.json. No tolerance waivers applied.")
if blockers:Path('STUCK_FAILURES.md').write_text('\n\n'.join(blockers)+'\n')
print(f"Original {original['passes']}/{original['checks']} checks pass; patched {patched['passes']}/{patched['checks']} checks pass")
