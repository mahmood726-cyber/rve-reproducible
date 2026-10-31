"""Compare outputs of the generated R scripts with stored references (PREREG_RSCRIPT_SAMPLE.md)."""
import collections, json, math
from pathlib import Path

H = Path(__file__).resolve().parent
LANE = Path('<HOST>/p101115/P15')
man = json.loads((H / 'rscripts_manifest.json').read_text(encoding='utf-8'))
stats = {k: collections.defaultdict(lambda: dict(checks=0, passes=0, max_difference=0.0)) for k in ('uncentred', 'centred', 'fixture')}
fails = []
input_exact = collections.Counter()
run_status = collections.Counter()


def check(kind, name, q, x, y, mode='relative'):
    d = 0
    if mode == 'exact':
        ok = x == y
    else:
        ok = isinstance(x, (float, int)) and isinstance(y, (float, int)) and math.isfinite(x) and math.isfinite(y)
        d = (abs(x - y) / (max(1, abs(y)) if mode == 'relative' else 1)) if ok else None
        ok = ok and d <= 1e-9
    s = stats[kind][q]; s['checks'] += 1; s['passes'] += int(ok)
    if d is not None: s['max_difference'] = max(s['max_difference'], d)
    if not ok: fails.append(dict(kind=kind, name=name, quantity=q, script=x, reference=y, difference=d))


for m in man:
    kind, name = m['kind'], m['name']
    p = H / 'rs_out' / f'{name}.json'
    if not p.exists():
        run_status[kind + ':missing'] += 1; check(kind, name, 'ran', False, True, 'exact'); continue
    o = json.loads(p.read_text(encoding='utf-8'))
    run_status[kind + ':' + o['status']] += 1
    check(kind, name, 'ran', o['status'], 'ok', 'exact')
    if o['status'] != 'ok': continue
    # input fidelity: parsed R columns equal the binary64 values the app holds
    cols = list(o['data'].keys())
    vals = {c: (v if isinstance(v, list) else [v]) for c, v in o['data'].items()}
    want = {'yi': [r['yi'] for r in m['rows']], 'vi': [r['vi'] for r in m['rows']]}
    q = len(m['rows'][0]['X']) - 1
    pred_cols = [c for c in cols if c not in ('yi', 'vi') and not c.endswith('_c')][:q]
    for j, c in enumerate(pred_cols): want[c] = [r['X'][j + 1] for r in m['rows']]
    exact = all(vals[c] == want[c] for c in want) and o['cluster'] == [r['cluster'] for r in m['rows']]
    input_exact[(kind, exact)] += 1
    if kind == 'uncentred':
        ref = json.loads((LANE / 'reference' / f"{m['index']:06d}.json").read_text(encoding='utf-8'))
        assert ref['id'] == m['id']
    elif kind == 'centred':
        ref = json.loads((H / 'centred_ref' / f"{m['tierB_pos']:04d}.json").read_text(encoding='utf-8'))
        assert ref['id'] == m['id']
    else:
        ref = json.loads((H / f'fixture_ref_{name}.json').read_text(encoding='utf-8'))
    check(kind, name, 'tau2', o['tau2'], ref['tau2'])
    check(kind, name, 'coefficient_count', len(o['table']), len(ref['table']), 'exact')
    for j, (s, t) in enumerate(zip(o['table'], ref['table'])):
        for qn in ['b.r', 'SE', 't', 'dfs', 'prob', 'CI.L', 'CI.U']:
            check(kind, name, qn, s[qn], t[qn], 'absolute' if qn in ('prob', 'CI.L', 'CI.U') else 'relative')
        cb, rc = o['club'], ref['club']
        if 'error' in rc:
            continue
        for qn in ['beta', 'SE', 'tstat', 'df_Satt', 'p_Satt']:
            a = cb[qn][j] if isinstance(cb[qn], list) else cb[qn]
            b = rc[qn][j] if isinstance(rc[qn], list) else rc[qn]
            check(kind, name, 'club_' + qn, a, b, 'absolute' if qn == 'p_Satt' else 'relative')

out = dict(prereg_sha256=(H / 'PREREG_RSCRIPT_SAMPLE.md.sha256').read_text().strip(), scripts=len(man),
           run_status=dict(run_status), input_exact={f'{k[0]}:{k[1]}': v for k, v in input_exact.items()},
           strata={k: dict(checks=sum(s['checks'] for s in v.values()), passes=sum(s['passes'] for s in v.values()),
                           failing_scripts=len({f['name'] for f in fails if f['kind'] == k}),
                           quantities={q: dict(s) for q, s in v.items()}) for k, v in stats.items()})
(H / 'rscript_results.json').write_text(json.dumps(out, indent=2), encoding='utf-8')
(H / 'rscript_failures.json').write_text(json.dumps(fails, indent=1), encoding='utf-8')
print(json.dumps({k: v for k, v in out.items() if k != 'strata'}, indent=1))
for k, v in out['strata'].items():
    print(k, f"{v['passes']}/{v['checks']} checks pass; {v['failing_scripts']} scripts with any failure")
    for q, s in sorted(v['quantities'].items()):
        print(f"   {q:16s} {s['passes']:5d}/{s['checks']:<5d} max diff {s['max_difference']:.3g}")
