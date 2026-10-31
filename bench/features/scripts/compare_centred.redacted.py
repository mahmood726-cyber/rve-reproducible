"""Compare centred engine results with R (PREREG_CENTRING.md v2): P1, P2, P3.

check() is copied from p15-codex17/compare_engine.py unchanged in substance
(same modes, same scaling, same 1e-9 threshold).
"""
import collections, json, math, sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
LANE = Path('<HOST>/p101115/P15')
U = 2.0 ** -53

eng = [json.loads(l) for l in (HERE / 'centred_engine.jsonl').read_text(encoding='utf-8').splitlines() if l.strip()]
cfg = json.loads((HERE / 'centred_configs.json').read_text(encoding='utf-8'))
ids = (HERE / 'centring_config_ids.txt').read_text(encoding='utf-8').split()
assert len(eng) == len(cfg) == len(ids) == 1705, (len(eng), len(cfg), len(ids))


def make_stats():
    return collections.defaultdict(lambda: dict(checks=0, passes=0, max_difference=0.0))


def checker(stats, fails):
    def check(key, q, x, y, mode='relative', tol=1e-9):
        d = 0
        if mode == 'exact':
            ok = x == y
        else:
            ok = isinstance(x, (float, int)) and isinstance(y, (float, int)) and not isinstance(x, bool) and math.isfinite(x) and math.isfinite(y)
            if ok:
                if mode == 'relative':
                    d = abs(x - y) / max(1, abs(y))
                elif mode == 'absolute':
                    d = abs(x - y)
                elif mode == 'pure_relative':
                    d = abs(x - y) / abs(y)
            else:
                d = None
            ok = ok and d <= tol
        s = stats[q]; s['checks'] += 1; s['passes'] += int(ok)
        if d is not None:
            s['max_difference'] = max(s['max_difference'], d)
        if not ok:
            fails.append(dict(id=key, quantity=q, app=x, reference=y, difference=d))
    return check


def category(reason):
    s = reason.lower()
    if 'm<=p' in s: return 'insufficient clusters'
    if 'singular' in s or 'rank deficien' in s: return 'rank deficiency'
    if 'no rows' in s or 'no valid rows' in s: return 'no rows'
    return s


P1, P1f = make_stats(), []
P2, P2f = make_stats(), []
P3, P3f = make_stats(), []
c1, c2, c3 = checker(P1, P1f), checker(P2, P2f), checker(P3, P3f)
echo_mismatch = 0
p2_skipped_refused_ref = []
kappa_rows = []
for i, (a, c) in enumerate(zip(eng, cfg), 1):
    key = c['id']
    assert a['id'] == key == ids[i - 1]
    r = json.loads((HERE / 'centred_ref' / f'{i:04d}.json').read_text(encoding='utf-8'))
    assert r['id'] == key
    ac = a['centred']
    # ---- P1: centred engine vs R on the centred design -------------------------------
    c1(key, 'status', ac['status'], r['status'], 'exact')
    if ac['status'] == 'refused' and r['status'] == 'refused':
        c1(key, 'refusal_category', category(ac['reason']), category(r['reason']), 'exact')
    if ac['status'] == 'ok' and r['status'] == 'ok':
        xs = [row['X'][1] for row in c['centred_rows']]
        if r.get('x_echo') != xs:
            echo_mismatch += 1
        fit = ac['fit']
        c1(key, 'tau2', fit['tau2'], r['tau2']); c1(key, 'method', fit['method'], 'CR2', 'exact')
        for q, k in [('n', 'k_total'), ('m', 'm_clusters'), ('p', 'p')]:
            c1(key, 'design_columns' if q == 'p' else q, fit[k], r[q], 'exact')
        c1(key, 'coefficient_count', len(ac['summary']), len(r['table']), 'exact')
        for j, (s, t) in enumerate(zip(ac['summary'], r['table'])):
            for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
                c1(key, aq, s[aq], t[rq], 'absolute' if aq in ['p', 'ci_lo', 'ci_hi'] else 'relative')
            cb = r['club']; c1(key, 'club_reference_success', 'error' not in cb, True, 'exact')
            if 'error' not in cb:
                for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                    v = cb[rq]; v = v[j] if isinstance(v, list) else v
                    c1(key, 'club_' + aq, s[aq], v, 'absolute' if aq == 'p' else 'relative')
    # ---- P2: centred engine vs existing UNCENTRED lane reference (invariant quantities) --
    ur = json.loads((LANE / 'reference' / f"{c['index']:06d}.json").read_text(encoding='utf-8'))
    assert ur['id'] == key
    if ur['status'] != 'ok':
        p2_skipped_refused_ref.append(dict(id=key, uncentred_reference_status=ur['status'], reason=ur.get('reason'), centred_engine_status=ac['status'], centred_R_status=r['status']))
    elif ac['status'] != 'ok':
        c2(key, 'status', ac['status'], 'ok', 'exact')
    else:
        c2(key, 'status', ac['status'], 'ok', 'exact')
        c2(key, 'tau2', ac['fit']['tau2'], ur['tau2'])
        s = ac['summary'][1]; t = ur['table'][1]
        for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
            c2(key, 'slope_' + aq, s[aq], t[rq], 'absolute' if aq in ['p', 'ci_lo', 'ci_hi'] else 'relative')
        cb = ur['club']
        if 'error' not in cb:
            for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                v = cb[rq]; v = v[1] if isinstance(v, list) else v
                c2(key, 'slope_club_' + aq, s[aq], v, 'absolute' if aq == 'p' else 'relative')
    # ---- P3: kappa ------------------------------------------------------------------
    row = dict(id=key)
    if ac['status'] == 'ok' and r['status'] == 'ok':
        c3(key, 'kappa_centred', ac['kappa'], r['kappa'], 'pure_relative', 1e-6)
        row.update(kc_app=ac['kappa'], kc_R=r['kappa'], kc_R_svd=r.get('kappa_sqrtw_svd'))
    au, ru = a['uncentred'], r.get('uncentred_kappa', {})
    if au['status'] == 'ok' and 'kappa' in ru:
        band = 'uncentred_kappa_le_9e8' if ru['kappa'] <= 9.0e8 else 'uncentred_kappa_gt_9e8'
        c3(key, band, au['kappa'], ru['kappa'], 'pure_relative', 1e-6)
        row.update(ku_app=au['kappa'], ku_R=ru['kappa'], ku_R_svd=ru.get('kappa_sqrtw_svd'))
    kappa_rows.append(row)


def summary(stats):
    return dict(checks=sum(s['checks'] for s in stats.values()), passes=sum(s['passes'] for s in stats.values()), quantities={k: dict(v) for k, v in stats.items()})


def configs_failing(fails):
    return len({f['id'] for f in fails})


kc = [x for x in kappa_rows if 'kc_app' in x]
ku = [x for x in kappa_rows if 'ku_app' in x]
out = dict(
    prereg_sha256=(HERE / 'PREREG_CENTRING.md.sha256').read_text().strip(),
    configurations=len(cfg),
    engine_status=collections.Counter(a['centred']['status'] for a in eng),
    R_status=collections.Counter(json.loads((HERE / 'centred_ref' / f'{i:04d}.json').read_text(encoding='utf-8'))['status'] for i in range(1, 1706)),
    input_echo_mismatches=echo_mismatch,
    P1=summary(P1), P1_failing_configurations=configs_failing(P1f),
    P2=summary(P2), P2_failing_configurations=configs_failing(P2f), P2_skipped_uncentred_reference_refused=p2_skipped_refused_ref,
    P3=summary(P3), P3_failing_configurations=configs_failing(P3f),
    centred_kappa_max_app=max(x['kc_app'] for x in kc) if kc else None,
    centred_kappa_over_threshold=sum(1 for x in kc if x['kc_app'] > 9.0e6),
    uncentred_kappa_range_R=[min(x['ku_R'] for x in ku), max(x['ku_R'] for x in ku)] if ku else None,
    uncentred_kappa_le_9e8_n=sum(1 for x in ku if x['ku_R'] <= 9.0e8),
)
(HERE / 'centring_results.json').write_text(json.dumps(out, indent=2, default=dict), encoding='utf-8')
(HERE / 'centring_failures.json').write_text(json.dumps(dict(P1=P1f, P2=P2f, P3=P3f), indent=1), encoding='utf-8')
(HERE / 'centring_kappa.json').write_text(json.dumps(kappa_rows), encoding='utf-8')
for name in ['P1', 'P2', 'P3']:
    s = out[name]; print(name, f"{s['passes']}/{s['checks']} checks pass;", out[name + '_failing_configurations'], 'configurations with any failure')
    for q, v in sorted(s['quantities'].items()):
        print(f"   {q:32s} {v['passes']:6d}/{v['checks']:<6d} max diff {v['max_difference']:.3g}")
print('engine status', dict(out['engine_status']), 'R status', dict(out['R_status']), 'echo mismatches', echo_mismatch)
print('P2 skipped (uncentred ref refused):', len(p2_skipped_refused_ref))
print('centred kappa max', out['centred_kappa_max_app'], 'over threshold', out['centred_kappa_over_threshold'])
print('uncentred kappa R range', out['uncentred_kappa_range_R'], 'n<=9e8', out['uncentred_kappa_le_9e8_n'])
