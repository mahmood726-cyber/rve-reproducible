"""Feature-check evidence set (results/features/, bench/features/): replay the UNMODIFIED feature-lane comparators.

The three comparators are bench/features/scripts/compare_centred.redacted.py, compare_rscripts.redacted.py and
bench/features/scripts-p15d/compare_rho.redacted.py. Each is copied into a scratch directory with ONE line changed: the
redacted lane path `LANE = Path('<HOST>/p101115/P15')` is pointed at a scratch copy of the archived R references
(results/reference/r-reference.jsonl.xz, the same 16,270 files the lanes read). Their inputs are materialised from the
archived bundles exactly as the lanes laid them out. Nothing in the archive is written.

plant (optional) changes ONE archived input value in the scratch copy before the comparator runs, so that a test can
prove the replay detects it:
  centring  centred engine estimate[0] of the first configuration, + 2e-9 * max(1, |value|)
  rscripts  b.r of the first coefficient of script u_001, + 2e-9 * max(1, |value|)
  rho       estimate[0] at rho 0.4 of the first design without a known failure, + 2e-9 * max(1, |value|)
Usage: python analysis/compare_features.py [centring|rscripts|rho]   (prints the three comparators' outputs)
"""
import collections, json, lzma, os, shutil, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
FR, FB = ROOT / 'results/features', ROOT / 'bench/features'
LANE_LINE = "LANE = Path('<HOST>/p101115/P15')"
PLANTS = ('centring', 'rscripts', 'rho')


def xz(rel):
    return lzma.decompress((ROOT / rel).read_bytes())


def bundle(rel):
    return json.loads(xz(rel))


def write_bundle(d, texts):
    d.mkdir(parents=True, exist_ok=True)
    for name, text in texts.items():
        (d / name).write_bytes(text.encode('utf-8'))


def bump(v):
    return v + 2e-9 * max(1.0, abs(v))


def script(src, dst, lane):
    text = (FB / src).read_text(encoding='utf-8')
    assert text.count(LANE_LINE) == 1, f'{src}: expected exactly one redacted LANE line'
    dst.write_text(text.replace(LANE_LINE, f'LANE = Path({str(lane)!r})'), encoding='utf-8', newline='')


def materialise(tmp, plant=None):
    assert plant in (None,) + PLANTS
    lane = tmp / 'lane'
    (lane / 'reference').mkdir(parents=True)
    idx = json.loads((ROOT / 'results/reference/reference-index.json').read_text(encoding='utf-8'))
    lines = xz('results/reference/r-reference.jsonl.xz').split(b'\n')[:-1]
    assert len(lines) == len(idx) == 16270
    for l, r in zip(lines, idx):
        (lane / 'reference' / r['file']).write_bytes(l + b'\n')
    pre = FB / 'prereg'
    cref = bundle('results/features/centring/centred_ref-bundle.json.xz')
    # centring
    c = tmp / 'centring'; c.mkdir()
    script('scripts/compare_centred.redacted.py', c / 'compare_centred.py', lane)
    eng = xz('results/features/centring/centred_engine.jsonl.xz')
    if plant == 'centring':
        rows = eng.decode('utf-8').splitlines()
        first = json.loads(rows[0]); first['centred']['summary'][0]['estimate'] = bump(first['centred']['summary'][0]['estimate'])
        rows[0] = json.dumps(first); eng = ('\n'.join(rows) + '\n').encode('utf-8')
    (c / 'centred_engine.jsonl').write_bytes(eng)
    (c / 'centred_configs.json').write_bytes(xz('results/features/centring/centred_configs.json.xz'))
    shutil.copyfile(FR / 'centring/centring_config_ids.txt', c / 'centring_config_ids.txt')
    shutil.copyfile(pre / 'PREREG_CENTRING.md.sha256', c / 'PREREG_CENTRING.md.sha256')
    write_bundle(c / 'centred_ref', cref)
    # R-script export
    r = tmp / 'rscripts'; r.mkdir()
    script('scripts/compare_rscripts.redacted.py', r / 'compare_rscripts.py', lane)
    (r / 'rscripts_manifest.json').write_bytes(xz('results/features/rscripts/rscripts_manifest.json.xz'))
    out = bundle('results/features/rscripts/rs_out-bundle.json.xz')
    if plant == 'rscripts':
        o = json.loads(out['u_001.json']); o['table'][0]['b.r'] = bump(o['table'][0]['b.r']); out['u_001.json'] = json.dumps(o)
    write_bundle(r / 'rs_out', out)
    write_bundle(r / 'centred_ref', cref)
    for n in ['fixture_ref_f_corrdat.json', 'fixture_ref_f_ds2.json', 'fixture_ref_f_small.json']:
        shutil.copyfile(FR / 'rscripts' / n, r / n)
    shutil.copyfile(pre / 'PREREG_RSCRIPT_SAMPLE.md.sha256', r / 'PREREG_RSCRIPT_SAMPLE.md.sha256')
    # rho table (comparator view of the p15d lane: 442 designs with fresh fixed-locale R references)
    h = tmp / 'rho'; ci = h / 'compare_inputs'; ci.mkdir(parents=True)
    script('scripts-p15d/compare_rho.redacted.py', h / 'compare_rho.py', lane)
    sample = xz('results/features/rho/compare_inputs/rho_sample.json.xz')
    eng = xz('results/features/rho/compare_inputs/rho_engine.jsonl.xz')
    if plant == 'rho':
        S = json.loads(sample); rows = eng.decode('utf-8').splitlines()
        k = next(i for i, s in enumerate(S) if not s['known_failure'])
        e = json.loads(rows[k]); fit = next(f for f in e['fits'] if f['rho'] == 0.4)
        fit['summary'][0]['estimate'] = bump(fit['summary'][0]['estimate']); rows[k] = json.dumps(e)
        eng = ('\n'.join(rows) + '\n').encode('utf-8')
    (ci / 'rho_sample.json').write_bytes(sample)
    (ci / 'rho_engine.jsonl').write_bytes(eng)
    for n in ['rho_engine_meta.json', 'PREREG_RHO.md.sha256']:
        shutil.copyfile(FR / 'rho/compare_inputs' / n, ci / n)
    write_bundle(ci / 'rho_ref', bundle('results/features/rho/compare_inputs/rho_ref-bundle.json.xz'))
    return c, r, h


def run_all(plant=None):
    """Run the three comparators; return {name: dict(stdout=..., outputs={file: parsed JSON})}."""
    tmp = Path(tempfile.mkdtemp(prefix='.verify-features-', dir=ROOT))
    try:
        c, r, h = materialise(tmp, plant)
        env = dict(os.environ, PYTHONUTF8='1')
        res = {}
        for name, d, prog, outs in [('centring', c, 'compare_centred.py', ['centring_results.json', 'centring_failures.json', 'centring_kappa.json']),
                                    ('rscripts', r, 'compare_rscripts.py', ['rscript_results.json', 'rscript_failures.json']),
                                    ('rho', h, 'compare_rho.py', ['compare_inputs/rho_results.json', 'compare_inputs/rho_failures.json'])]:
            p = subprocess.run([sys.executable, '-I', '-X', 'utf8', prog], cwd=d, env=env, capture_output=True)
            if p.returncode != 0:
                raise RuntimeError(f'{prog} exited {p.returncode}: {p.stderr.decode("utf-8", "replace")[-500:]}')
            res[name] = dict(stdout=p.stdout.decode('utf-8').replace('\r\n', '\n'),
                             outputs={o: json.loads((d / o).read_text(encoding='utf-8')) for o in outs})
        return res
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def summary(res):
    """The counts the paper cites, read from the comparators' own outputs."""
    cr = res['centring']['outputs']['centring_results.json']
    rs = res['rscripts']['outputs']['rscript_results.json']
    rh = res['rho']['outputs']['compare_inputs/rho_results.json']
    st = rs['strata']
    return dict(
        centring=dict(configurations=cr['configurations'],
                      P1=[cr['P1']['passes'], cr['P1']['checks'], cr['P1_failing_configurations']],
                      P2=[cr['P2']['passes'], cr['P2']['checks'], cr['P2_failing_configurations']],
                      P3=[cr['P3']['passes'], cr['P3']['checks'], cr['P3_failing_configurations']],
                      centred_kappa_over_9e6=cr['centred_kappa_over_threshold'], input_echo_mismatches=cr['input_echo_mismatches']),
        rscripts=dict(scripts=rs['scripts'], run_status=rs['run_status'],
                      strata={k: [v['passes'], v['checks'], v['failing_scripts']] for k, v in st.items()},
                      total=[sum(v['passes'] for v in st.values()), sum(v['checks'] for v in st.values())]),
        rho=dict(designs=rh['designs'], known_failure_designs=rh['known_failure_designs'], sensitivity_errors=rh['sensitivity_errors'],
                 groups={g: [v['passes'], v['checks'], v['failing_designs'], v['failing_designs_not_known']] for g, v in rh['groups'].items()}))


def rho_denominator():
    """Reconcile the feature-lane rho table (442 designs) with the v1.1 rho recheck (448 designs, analysis/compare_rho.py).
    Uses the v1.1 recheck's own check sequence on the archived captures and references and splits its checks by
    (a) whether the design is one of the six the fixed-locale lane skipped and (b) whether the check type exists in the
    feature-lane comparator. coefficient_count, club_reference_success and refusal_category exist only in the v1.1 one."""
    sys.path.insert(0, str(ROOT / 'analysis'))
    from compare_rho import RHO, rho_inputs
    from option_a import category, numeric_check, reason
    samples, refs, ok = rho_inputs()
    skipped = {x['index'] for x in json.loads((FR / 'rho/skipped.json').read_text(encoding='utf-8'))}
    out = {}
    for label in ['baseline', 'final-j']:
        caps = [json.loads(x) for x in (RHO / f'rho-{label}-engine.jsonl').read_text(encoding='utf-8').splitlines()]
        n, p = collections.Counter(), collections.Counter()
        for i, (sample, cap, ref) in enumerate(zip(samples, caps, refs), 1):
            grp = 'skipped_6' if i in skipped else 'designs_442'
            for f, rk in zip(cap['fits'], ['r04', 'r06']):
                r = ref[rk]
                a = dict(status='refused', reason=f['error']) if 'error' in f else dict(status='ok', summary=f['summary'])

                def check(q, x, y, j=None, exact=False):
                    if exact:
                        good = x == y
                    else:
                        aq = q.removeprefix('club_')
                        good = numeric_check(x, y, 'absolute' if aq in ('p', 'ci_lo', 'ci_hi') else 'relative', 'finite-only',
                                             reason(x, aq, a, j, 'app'), reason(y, aq, r, j, 'club' if q.startswith('club_') else 'robumeta'))[0]
                    kind = q if q in ('coefficient_count', 'club_reference_success', 'refusal_category') else 'shared'
                    n[grp, kind] += 1; p[grp, kind] += int(good)
                check('status', a['status'], r['status'], exact=True)
                if a['status'] == r['status'] == 'refused':
                    check('refusal_category', category(a['reason']), category(r['reason']), exact=True)
                if a['status'] != 'ok' or r['status'] != 'ok':
                    continue
                check('tau2', f['tau2'], r['tau2'])
                check('coefficient_count', len(f['summary']), len(r['table']), exact=True)
                for j, (s, t) in enumerate(zip(f['summary'], r['table'])):
                    for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
                        check(aq, s[aq], t[rq], j)
                    cb = r['club']
                    check('club_reference_success', 'error' not in cb, True, exact=True)
                    if 'error' not in cb:
                        for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                            v = cb[rq]
                            check('club_' + aq, s[aq], v[j] if isinstance(v, list) else v, j)
        out[label] = dict(parts={f'{g}/{k}': [p[g, k], c] for (g, k), c in sorted(n.items())},
                          total=[sum(p.values()), sum(n.values())])
    return dict(reference_hashes_ok=ok, skipped_indices=sorted(skipped), finite_only=out)


if __name__ == '__main__':
    plant = sys.argv[1] if len(sys.argv) > 1 else None
    res = run_all(plant)
    print(json.dumps(summary(res), indent=1))
    if plant is None:
        print(json.dumps(rho_denominator(), indent=1))
