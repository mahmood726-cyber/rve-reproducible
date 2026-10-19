"""Assemble the rve-reproducible archive from the paper-15 validation job folder.

Usage (from anywhere):  py analysis/build_archive.py <job-folder> <prep-folder> <archive-root>

<job-folder>  : the R2 validation job folder (configurations.json, reference/, engine-full-*.jsonl, ...)
<prep-folder> : folder holding the lane's conditioning analysis (conditioning.py/.csv, summarise.py, ...)
                and lf/ with the three changed page files extracted from allmeta e042af5 (git LF bytes).
<archive-root>: the archive being built (this repository).

Only copies, deterministic xz compression and derived ledgers. No fit is run and no
reference, capture or comparison value is altered. Host-specific browser-audit outputs
(app-*.jsonl, browser-*.json, ui-*.json, downloads-*/, browser-host.*) are never read.
"""
import collections, csv, hashlib, io, json, lzma, re, shutil, sys
from pathlib import Path

JOB, PREP, ROOT = (Path(a).resolve() for a in sys.argv[1:4])
assert (JOB / 'configurations.json').exists() and (PREP / 'conditioning.csv').exists()
sha = lambda b: hashlib.sha256(b).hexdigest()
proof = []

def put(dest, data):
    p = ROOT / dest; p.parent.mkdir(parents=True, exist_ok=True); p.write_bytes(data)

def copy(src, dest):
    put(dest, Path(src).read_bytes())

def xz(src_bytes, dest):
    stored = lzma.compress(src_bytes, format=lzma.FORMAT_XZ, check=lzma.CHECK_CRC64, preset=6)
    assert lzma.decompress(stored) == src_bytes
    put(dest, stored)
    proof.append(dict(stored=dest, original_name=Path(dest).name[:-3], original_bytes=len(src_bytes),
                      original_sha256=sha(src_bytes), stored_sha256=sha(stored),
                      method='Python lzma FORMAT_XZ, CHECK_CRC64, preset 6 (deterministic)'))

PART = 80 * 1024 * 1024
def xz_stream(src, dest):
    """Stream-compress a large file; split the single xz stream into <=80 MiB parts when needed."""
    comp, h, n, tmp = lzma.LZMACompressor(format=lzma.FORMAT_XZ, check=lzma.CHECK_CRC64, preset=6), hashlib.sha256(), 0, ROOT / (dest + '.tmp')
    tmp.parent.mkdir(parents=True, exist_ok=True)
    with open(src, 'rb') as f, open(tmp, 'wb') as out:
        while chunk := f.read(1 << 24):
            h.update(chunk); n += len(chunk); out.write(comp.compress(chunk))
        out.write(comp.flush())
    size = tmp.stat().st_size
    rec = dict(stored=dest, original_name=Path(src).name, original_bytes=n, original_sha256=h.hexdigest(),
               method='Python lzma FORMAT_XZ, CHECK_CRC64, preset 6 (deterministic), streamed in 16 MiB chunks')
    if size <= PART:
        tmp.replace(ROOT / dest); rec['stored_sha256'] = sha((ROOT / dest).read_bytes())
    else:
        parts, whole = [], hashlib.sha256()
        with open(tmp, 'rb') as f:
            k = 0
            while data := f.read(PART):
                k += 1; name = f'{dest}.part{k:02d}'; (ROOT / name).write_bytes(data); whole.update(data)
                parts.append(name); rec.setdefault('part_sha256', {})[name] = sha(data)
        tmp.unlink(); rec['parts'] = parts; rec['stored_sha256'] = whole.hexdigest()
        rec['note'] = 'One xz stream split into parts; concatenate the parts in order to obtain the stored stream.'
    proof.append(rec)

# ---------------------------------------------------------------- app (shipped page, e042af5)
DEPS = ['rve-meta/index.html', 'shared/forced-colors.css', 'hub/app-style.css', 'shared/stats-qt.js', 'shared/rve.js',
        'shared/app-flow.js', 'shared/autosave.js', 'hub/shared/a11y-landmarks.js', 'hub/shared/results-export.js']
CHANGED = ['rve-meta/index.html', 'shared/stats-qt.js', 'shared/rve.js']
app_hash, orig_hash, crlf = {}, {}, {}
for f in DEPS:
    captured = (JOB / 'patched' / f).read_bytes()
    if f in CHANGED:
        lf = (PREP / 'lf' / f).read_bytes()
        assert b'\r' not in lf and captured.replace(b'\r\n', b'\n') == lf, f
        put('bench/captured-engine/patched/' + f, captured)
        crlf[f] = dict(captured_crlf_sha256=sha(captured), git_lf_sha256=sha(lf), identical_after_crlf_to_lf=True)
        data = lf
    else:
        data = captured
        assert b'\r\n' not in data, f
    put('app/' + f, data); app_hash[f] = sha(data)
    o = (JOB / 'original' / f).read_bytes(); put('app-original/' + f, o); orig_hash[f] = sha(o)
put('app/app-sha256.json', json.dumps(dict(
    description='Every file rve-meta/index.html loads (two stylesheets, seven scripts), as committed on allmeta branch '
                'fix/rve-meta-cr2-parity-p15-v2 at commit e042af5736887b2d5ead82ac569163d586548bf1 (draft PR #146); '
                'byte-identical Git LF blob bytes. Unchanged at branch head 09e169150c23e1c6a35bbdf10a3a31cf1eea5023.',
    release='[ALLMETA RELEASE PENDING]', doi='[ALLMETA RELEASE PENDING]',
    files=app_hash,
    captured_engine_bytes=dict(note='The engine captures (results/engine/engine-full-patched*.json*) were produced from Windows '
                               'working copies of the three changed files with CRLF line endings (hashes recorded in '
                               'engine-full-patched-meta.json). They equal the committed LF bytes after CRLF->LF; the captured '
                               'bytes are kept in bench/captured-engine/patched/.', files=crlf)), indent=2).encode() + b'\n')
put('app-original/app-sha256.json', json.dumps(dict(
    description='Pre-fix page: the same nine files at allmeta origin/main 387660898b5b7a2571736da3149371c20f079bba '
                '(the source of the original-variant captures).', files=orig_hash), indent=2).encode() + b'\n')

# ---------------------------------------------------------------- bench (scripts, reports, docs, licences)
BENCH = '''reference.R json17.R corpus.R metadata.R extra.R supplemental-exact.R environment.R r2-environment.R install.R
install_archives.R edge.R r2-complex.R r2-trace.R r2-source.R configure.py prepare_corpus.py append_shards.py shard.py
run_references.py run_r.py setup.py download_packages.py dataset_ledger.py verify_metadata.py compare_engine.py
diagnose_failures.py append_refusal_diagnosis.py reference_cache.py engine_check.py patch_app.py report.py review_final.py
r2-report.py r2-verify.py r2-reference-review.py r2-finish.py finish_resume.py package_artifacts.py r3-startup-check.py
engine.cjs engine_full.cjs r2-before-engine_full.cjs r2-capture-worker.cjs contract.cjs edge.cjs r2-condition-preflight.cjs
r2-probe.cjs r2-scout.cjs r2-trace.cjs r2-worker-test.cjs r2-invert.js fix.patch RESULTS.md RESULT.md RESULT_R2.md
r2-precondition-RESULT_R2.md STRICT_DIAGNOSIS.md STUCK_FAILURES.md TASK_R2.md TASK_R3.md R3_RULE.sha256 R3_BLOCKED.md
HOST_NOTE_R3.md r2-robu-source.txt r2-solve-default-source.txt'''.split()
for f in BENCH: copy(JOB / f, 'bench/' + f)
# Validate-time reference recipe: bench/reference.R lines 10-26 verbatim, wrapped as a function.
NL = bytes([10])
L = (JOB / 'reference.R').read_bytes().split(NL)
put('analysis/reference_core.R', b"# Generated by analysis/build_archive.py from bench/reference.R: the body below is byte-identical to" + NL +
    b"# bench/reference.R lines 10-26 (the R2 per-configuration reference recipe), wrapped as a function so that" + NL +
    b"# validate.R can refit configurations without shard files. analysis/test_safeguards.py asserts the identity." + NL +
    b"reference_one <- function(c) {" + NL + NL.join(L[9:26]) + NL + b" res[['warnings']]<-warnings" + NL + b" res" + NL + b"}" + NL)
for p in sorted((JOB / 'documentation').iterdir()): copy(p, 'bench/documentation/' + p.name)
for p in sorted((JOB / 'r2-patch-proof').rglob('*')):
    if p.is_file(): copy(p, 'bench/r2-patch-proof/' + p.relative_to(JOB / 'r2-patch-proof').as_posix())
copy(JOB / 'packages/provenance.json', 'bench/packages-provenance.json')
for f in ['audit.spec.cjs', 'package.json', 'playwright.config.cjs', 'playwright.r3.config.cjs', 'playwright.r3host.config.cjs']:
    copy(JOB / 'tests' / f, 'bench/browser/' + f)
copy(JOB / 'compare.py', 'bench/browser/compare.py')
for f in ['conditioning.py', 'summarise.py', 'exactfit.py', 'CONDITIONING.md']: copy(PREP / f, 'bench/conditioning/' + f)

# ---------------------------------------------------------------- data
cfg_bytes = (JOB / 'configurations.json').read_bytes(); xz(cfg_bytes, 'data/configurations.json.xz')
for f in ['configuration-ledger.csv', 'column-ledger.csv', 'dataset-ledger.csv', 'dataset-ledger.json', 'cluster-exclusions.json',
          'documented-clusters.json', 'configuration-extension-proof.json', 'construction-attempts.json', 'coverage.json',
          'corpus.json', 'corpus-before-metadata.json', 'corpus.rds', 'metadata-integrity.json', 'source-manifest.json',
          'environment.json', 'extra-data.json']:
    copy(JOB / f, 'data/' + f)
r2env = json.loads((JOB / 'r2-environment.json').read_text(encoding='utf-8'))
for k in list(r2env):
    if k.endswith('_path'): r2env[k] = '[host library path redacted]'
r2env['note'] = 'Copy of the job r2-environment.json with the two absolute library paths redacted; all other fields verbatim.'
put('data/r2-environment.redacted.json', json.dumps(r2env, indent=2).encode() + b'\n')

# ---------------------------------------------------------------- results: engine captures
for v in ['original', 'patched']:
    xz((JOB / f'engine-full-{v}.jsonl').read_bytes(), f'results/engine/engine-full-{v}.jsonl.xz')
    for f in [f'engine-full-{v}-meta.json', f'engine-results-{v}.json', f'contract-{v}.json', f'edge-{v}.json']:
        copy(JOB / f, 'results/engine/' + f)
xz((JOB / 'engine-failures-full-original.json').read_bytes(), 'results/engine/engine-failures-full-original.json.xz')
copy(JOB / 'engine-failures-full-patched.json', 'results/engine/engine-failures-full-patched.json')
copy(JOB / 'edge-reference.json', 'results/engine/edge-reference.json')

# ---------------------------------------------------------------- results: R references (one JSON line per file)
ledger = list(csv.DictReader(io.StringIO((JOB / 'configuration-ledger.csv').read_text(encoding='utf-8'))))
assert len(ledger) == 16270
buf, index = bytearray(), []
for i, row in enumerate(ledger, 1):
    raw = (JOB / 'reference' / f'{i:06d}.json').read_bytes()
    assert raw.endswith(b'\n') and raw.count(b'\n') == 1 and json.loads(raw)['id'] == row['id'], i
    buf += raw; index.append(dict(file=f'{i:06d}.json', id=row['id'], bytes=len(raw), sha256=sha(raw)))
assert len(list((JOB / 'reference').glob('*.json'))) == 16270
xz(bytes(buf), 'results/reference/r-reference.jsonl.xz')
put('results/reference/reference-index.json', json.dumps(index, indent=1).encode() + b'\n')

# ---------------------------------------------------------------- results: diagnosis and history
xz((JOB / 'strict-diagnosis.json').read_bytes(), 'results/diagnosis/strict-diagnosis.json.xz')
for f in ['r2-reference-disagreements.json', 'r2-transitions.json', 'r2-final-recapture-proof.json', 'r2-complex-trace.json',
          'r2-complex-cases.json', 'r2-js-trace.json', 'r2-small-step-comparison.json', 'r2-trace-1.json', 'r2-trace-2.json',
          'r2-trace-3.json', 'r2-inference-probe.json', 'r2-condition-preflight.json', 'r2-idempotence.json',
          'r2-artifact-hashes.json', 'r2-finished.json', 'r2-worker-proof.json', 'r2-patch-proof.json', 'r2-small.json',
          'r2-before-engine-results-patched.json', 'r2-before-engine-failures-full-patched.json',
          'r2-precondition-engine-results-patched.json', 'root-causes.json', 'results.json', 'r3-startup-check.json']:
    copy(JOB / f, 'results/diagnosis/' + f)
for f in ['conditioning.csv', 'conditioning-summary.json', 'exactfit.json']: copy(PREP / f, 'results/conditioning/' + f)
copy(PREP / 'fig_conditioning.png', 'results/conditioning/fig_conditioning.png')

# Failing configurations with diagnosed causes (patched) and categories (original); counts derived, never typed.
diag = json.loads((JOB / 'strict-diagnosis.json').read_text(encoding='utf-8'))
summ = json.loads((PREP / 'conditioning-summary.json').read_text(encoding='utf-8'))
T = summ['threshold']; disjoint = set(summ['disjoint_reference_configs'])
cond = {r['id']: r for r in csv.DictReader(open(PREP / 'conditioning.csv', encoding='utf-8'))}
fails = json.loads((JOB / 'engine-failures-full-patched.json').read_text(encoding='utf-8'))
fq = collections.defaultdict(collections.Counter)
for f in fails: fq[f['id']][f['quantity']] += 1
rows = []
for c in diag['patched']['cases']:
    k = cond[c['id']]; kap = float(k['kappa_XtWX_fit']) if k['kappa_XtWX_fit'] not in ('', 'nan') else None
    tier = 'no fit (refused by app)' if kap is None or kap != kap else ('B' if kap > T else 'A')
    cat = c['category']
    if cat == 'refusal reason disagreement': cause = 'refusal disagreement: reason (app m<=p; R complex-eigenvalue error)'
    elif cat == 'acceptance/refusal disagreement': cause = 'refusal disagreement: acceptance (R refuses, app fits); design ill-conditioned'
    elif tier == 'B': cause = 'ill-conditioned design (kappa_2(XtWX) > 1e-9/u = 9.0e6)'
    elif tier == 'A' and cat.startswith('near-zero'): cause = 'exact fit (near-zero reference SE)'
    elif tier == 'A' and c['id'] in disjoint: cause = 'robumeta vs clubSandwich reference conflict (disjoint acceptance intervals)'
    else: cause = 'UNCLASSIFIED'
    rows.append(dict(id=c['id'], dataset=k['dataset'], moderator=k['moderator'], rho=k['rho'], n=k['n'], p=k['p'],
                     app_status=c['app_status'], reference_status=c['reference_status'], failed_checks=c['failed_checks'],
                     failed_quantities=';'.join(f'{q}:{n}' for q, n in sorted(fq[c['id']].items())),
                     strict_category=cat, kappa_XtWX_fit=k['kappa_XtWX_fit'], conditioning_tier=tier, diagnosed_cause=cause,
                     app_reason=c['app_reason'] or '', reference_reason=c['reference_reason'] or ''))
assert not [r for r in rows if r['diagnosed_cause'] == 'UNCLASSIFIED'], 'unclassified failing configuration'
assert {r['id'] for r in rows} == set(fq) and sum(r['failed_checks'] for r in rows) == len(fails)
out = io.StringIO(); w = csv.DictWriter(out, fieldnames=list(rows[0]), lineterminator='\n'); w.writeheader(); w.writerows(rows)
put('results/diagnosis/failing-configurations-patched.csv', out.getvalue().encode('utf-8'))
out = io.StringIO(); w = csv.writer(out, lineterminator='\n'); w.writerow(['id', 'strict_category', 'failed_checks'])
for c in diag['original']['cases']: w.writerow([c['id'], c['category'], c['failed_checks']])
put('results/diagnosis/failing-configurations-original.csv', out.getvalue().encode('utf-8'))
causes = collections.Counter(r['diagnosed_cause'] for r in rows)

# ---------------------------------------------------------------- results: browser audit (host run, Edge 151)
for v in ['original', 'patched']:
    xz_stream(JOB / f'app-{v}.jsonl', f'results/browser/app-{v}.jsonl.xz')
    for f in [f'browser-{v}.json', f'ui-{v}.json']: copy(JOB / f, 'results/browser/' + f)
    copy(JOB / f'results-{v}.json', f'results/browser/compare-results-{v}.json')
    xz((JOB / f'failures-{v}.json').read_bytes(), f'results/browser/compare-failures-{v}.json.xz')
    for p in sorted((JOB / f'downloads-{v}').rglob('*')):
        if p.is_file(): copy(p, f'results/browser/downloads-{v}/' + p.relative_to(JOB / f'downloads-{v}').as_posix())
for f in ['browser-host.json', 'browser-host.log']: copy(JOB / f, 'results/browser/' + f)

# ---------------------------------------------------------------- expected values (all read from archived evidence)
def pairs_sha(failures):
    lines = sorted(f"{f['id']}\t{f['quantity']}" for f in failures)
    return sha(('\n'.join(lines) + '\n').encode('utf-8')), len(lines)
exp = dict(note='Every value below is read from archived evidence by analysis/build_archive.py; validate.R must reproduce '
                'each per-quantity count exactly. This is the documented strict result, NOT full strict agreement.',
           tolerance=dict(relative='|app-R|/max(1,|R|) <= 1e-9 for estimate, se, t, df, tau2 and club_estimate/se/t/df',
                          absolute='|app-R| <= 1e-9 for p, ci_lo, ci_hi and club_p', exact='key, presence, status, refusal category, method, n, m, p, coefficient count'),
           variants={})
for v in ['original', 'patched']:
    er = json.loads((JOB / f'engine-results-{v}.json').read_text(encoding='utf-8'))
    fl = json.loads(lzma.decompress((ROOT / 'results/engine/engine-failures-full-original.json.xz').read_bytes())) if v == 'original' else fails
    h, n = pairs_sha(fl); assert n == er['failures']
    exp['variants'][v] = dict(configurations=er['configurations'], captured=er['captured'], checks=er['checks'], passes=er['passes'],
                              failures=er['failures'], failed_configurations=len({f['id'] for f in fl}),
                              failing_id_quantity_pairs_sha256=h,
                              quantities={q: dict(checks=s['checks'], passes=s['passes'], max_difference=s['max_difference'])
                                          for q, s in er['quantities'].items()},
                              strict_categories=diag[v]['categories'])
    assert exp['variants'][v]['failed_configurations'] == diag[v]['failed_configurations']
exp['browser'], exp['browser_ui'] = {}, {}
for v in ['original', 'patched']:
    br = json.loads((JOB / f'results-{v}.json').read_text(encoding='utf-8'))
    bf = json.loads((JOB / f'failures-{v}.json').read_text(encoding='utf-8'))
    h, n = pairs_sha(bf); assert n == br['failures'] == br['checks'] - br['passes']
    exp['browser'][v] = dict(checks=br['checks'], passes=br['passes'], failures=br['failures'], app_records=br['app_records'],
                             failed_configurations=len({f['id'] for f in bf}), failing_id_quantity_pairs_sha256=h,
                             quantities={q: dict(checks=z['checks'], passes=z['passes'], max_difference=z['max_difference'])
                                         for q, z in br['quantities'].items()})
    ui = json.loads((JOB / f'ui-{v}.json').read_text(encoding='utf-8'))
    exp['browser_ui'][v] = dict(checks=len(ui), passes=sum(1 for x in ui if x.get('pass') is True),
                                failing=[x['name'] for x in ui if x.get('pass') is not True])
exp['patched_failure_causes'] = dict(sorted(causes.items()))
exp['conditioning_summary'] = {k: summ[k] for k in ['threshold', 'tier_counts', 'tier_by_fail', 'category_by_tier', 'disjoint_reference_checks']}
exp['conditioning_summary']['tiered_totals_post_hoc'] = summ.get('tiered_totals')
put('expected/paper_values.json', json.dumps(exp, indent=2).encode() + b'\n')
put('analysis/compression_proof.json', json.dumps(proof, indent=2).encode() + b'\n')
print('causes', dict(causes))
print('built', ROOT)
