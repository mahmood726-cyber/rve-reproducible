"""Compare AlmRVEExtras.rhoSensitivity output with R (PREREG_RHO.md)."""
import collections, json, math
from pathlib import Path

H = Path(__file__).resolve().parent / 'compare_inputs'
LANE = Path('<HOST>/p101115/P15')
S = json.loads((H / 'rho_sample.json').read_text(encoding='utf-8'))
eng = [json.loads(l) for l in (H / 'rho_engine.jsonl').read_text(encoding='utf-8').splitlines() if l.strip()]
assert len(eng) == len(S)
stats = {k: collections.defaultdict(lambda: dict(checks=0, passes=0, max_difference=0.0)) for k in ('new_refs_04_06', 'lane_refs_0_02_08_1', 'sensitivity_strings')}
fails = []


def check(group, known, design, q, x, y, mode='relative', tol=1e-9):
    d = 0
    if mode == 'exact':
        ok = x == y
    else:
        ok = isinstance(x, (int, float)) and isinstance(y, (int, float)) and math.isfinite(x) and math.isfinite(y)
        d = (abs(x - y) / (max(1, abs(y)) if mode == 'relative' else 1)) if ok else None
        ok = ok and d <= tol
    key = q + (' [known-failure design]' if known else '')
    s = stats[group][key]; s['checks'] += 1; s['passes'] += int(ok)
    if d is not None: s['max_difference'] = max(s['max_difference'], d)
    if not ok: fails.append(dict(group=group, design=design, known_failure=known, quantity=q, app=x, reference=y, difference=d))


def compare_fit(group, known, design, f, r):
    check(group, known, design, 'status', 'refused' if 'error' in f else 'ok', r['status'], 'exact')
    if 'error' in f or r['status'] != 'ok':
        return
    check(group, known, design, 'tau2', f['tau2'], r['tau2'])
    for j, (s, t) in enumerate(zip(f['summary'], r['table'])):
        for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
            check(group, known, design, aq, s[aq], t[rq], 'absolute' if aq in ('p', 'ci_lo', 'ci_hi') else 'relative')
        cb = r['club']
        if 'error' not in cb:
            for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                v = cb[rq]; v = v[j] if isinstance(v, list) else v
                check(group, known, design, 'club_' + aq, s[aq], v, 'absolute' if aq == 'p' else 'relative')


sens_parse_errors = 0
for i, (s, e) in enumerate(zip(S, eng), 1):
    assert e['design'] == s['design']
    known = s['known_failure']
    r = json.loads((H / 'rho_ref' / f'{i:04d}.json').read_text(encoding='utf-8'))
    fits = {f['rho']: f for f in e['fits']}
    compare_fit('new_refs_04_06', known, s['design'], fits[0.4], r['r04'])
    compare_fit('new_refs_04_06', known, s['design'], fits[0.6], r['r06'])
    for rho, key in [(0, '0'), (0.2, '0.2'), (0.8, '0.8'), (1, '1')]:
        lr = json.loads((LANE / 'reference' / f"{s['ref_index'][key]:06d}.json").read_text(encoding='utf-8'))
        compare_fit('lane_refs_0_02_08_1', known, s['design'], fits[rho], lr)
    # sensitivity() strings: rows = (label, "Coefficient"/"Std. Error"/"Estimate", 6 rho columns)
    sens = r['sens']
    if isinstance(sens, dict) and 'error' in sens:
        sens_parse_errors += 1
        continue
    grid = [0, 0.2, 0.4, 0.6, 0.8, 1]
    coef = 0
    for row in sens:
        vals = list(row.values())
        kind = vals[1].strip()
        strings = vals[2:8]
        for rho, sv in zip(grid, strings):
            sv = sv.strip()
            f = fits[rho]
            if 'error' in f:
                check('sensitivity_strings', known, s['design'], 'app_fit_available', False, True, 'exact'); continue
            dec = len(sv.split('.')[1]) if '.' in sv else 0
            tol = 0.5 * 10 ** (-dec) + 1e-12
            if kind == 'Coefficient':
                check('sensitivity_strings', known, s['design'], 'coefficient', f['summary'][coef]['estimate'], float(sv), 'absolute', tol)
            elif kind == 'Std. Error':
                check('sensitivity_strings', known, s['design'], 'se', f['summary'][coef]['se'], float(sv), 'absolute', tol)
            else:
                check('sensitivity_strings', known, s['design'], 'tau2', f['tau2'], float(sv), 'absolute', tol)
        if kind == 'Std. Error':
            coef += 1

out = dict(prereg_sha256=(H / 'PREREG_RHO.md.sha256').read_text().strip(), designs=len(S),
           known_failure_designs=sum(1 for s in S if s['known_failure']), sensitivity_errors=sens_parse_errors,
           engine_meta=json.loads((H / 'rho_engine_meta.json').read_text()) if (H / 'rho_engine_meta.json').exists() else None,
           groups={g: dict(checks=sum(v['checks'] for v in st.values()), passes=sum(v['passes'] for v in st.values()),
                           failing_designs=len({f['design'] for f in fails if f['group'] == g}),
                           failing_designs_not_known=len({f['design'] for f in fails if f['group'] == g and not f['known_failure']}),
                           quantities={q: dict(v) for q, v in st.items()}) for g, st in stats.items()})
(H / 'rho_results.json').write_text(json.dumps(out, indent=2), encoding='utf-8')
(H / 'rho_failures.json').write_text(json.dumps(fails, indent=1), encoding='utf-8')
print(json.dumps({k: v for k, v in out.items() if k != 'groups'}, indent=1))
for g, v in out['groups'].items():
    print(g, f"{v['passes']}/{v['checks']} pass; failing designs {v['failing_designs']} (not known-failure: {v['failing_designs_not_known']})")
    for q, x in sorted(v['quantities'].items()):
        if x['passes'] != x['checks'] or '[known' not in q:
            print(f"   {q:44s} {x['passes']:6d}/{x['checks']:<6d} max {x['max_difference']:.3g}")
