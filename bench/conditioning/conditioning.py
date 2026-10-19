"""Paper-15 decision material: design conditioning vs strict-gate differences.

Read-only over ../codex17. Recomputes every comparison exactly as codex17/compare_engine.py
does (same quantities, same scaling, same 1e-9 threshold), then attaches condition numbers.
No fits are run; no reference or app value is altered.

Outputs (this folder): conditioning.csv (one row per configuration), conditioning-summary.json.
"""
import collections, csv, json, math, sys
from pathlib import Path
import numpy as np

SRC = Path(__file__).resolve().parent.parent / 'codex17'
OUT = Path(__file__).resolve().parent
TOL = 1e-9
U = np.finfo(float).eps / 2  # unit roundoff 1.11e-16

keys = [r['id'] for r in csv.DictReader(open(SRC / 'configuration-ledger.csv', encoding='utf-8'))]
cfg = {c['id']: c for c in json.load(open(SRC / 'configurations.json', encoding='utf-8'))}
refs = {r['path']: json.loads(r['raw']) for r in json.load(open(SRC / 'reference-byte-cache.json', encoding='utf-8'))}
apps = [json.loads(l) for l in (SRC / 'engine-full-patched.jsonl').read_text(encoding='utf-8').splitlines()]
assert len(apps) == len(keys) == 16270

def cat(reason):
    s = reason.lower()
    if 'm<=p' in s: return 'insufficient clusters'
    if 'singular' in s or 'rank deficien' in s: return 'rank deficiency'
    if 'no rows' in s or 'no valid rows' in s: return 'no rows'
    return s

def kappa(M):
    try:
        s = np.linalg.svd(M, compute_uv=False)
    except np.linalg.LinAlgError:
        return math.inf
    return math.inf if s[-1] <= 0 else float(s[0] / s[-1])

rows = []
fail_checks_total = 0
for i, (key, a) in enumerate(zip(keys, apps), 1):
    assert a['id'] == key
    r = refs[f'reference/{i:06d}.json']; assert r['id'] == key
    c = cfg[key]
    X = np.array([row['X'] for row in c['rows']], dtype=float) if c['rows'] else np.zeros((0, 0))
    p = X.shape[1] if X.size else 0
    # Input-only weights: robumeta CORR with tau2 = 0, w_ij = 1/(k_j * mean(v_j)).
    k_unw = k_w0 = k_fit = math.nan
    if p:
        cl = [row['cluster'] for row in c['rows']]; v = np.array([row['vi'] for row in c['rows']])
        grp = collections.defaultdict(list)
        for j, g in enumerate(cl): grp[g].append(j)
        w0 = np.empty(len(cl))
        for idx in grp.values(): w0[idx] = 1.0 / (len(idx) * v[idx].mean())
        k_unw = kappa(X.T @ X)
        k_w0 = kappa(X.T @ (w0[:, None] * X))
        if a['status'] == 'ok':
            w = np.array(a['fit']['weights'], dtype=float)
            k_fit = kappa(X.T @ (w[:, None] * X))
    # Exact re-implementation of compare_engine.py checks (numerical part + status/category).
    qmax = collections.defaultdict(float); failed = collections.Counter(); kinds = []
    def chk(q, x, y, mode):
        ok = isinstance(x, (int, float)) and isinstance(y, (int, float)) and math.isfinite(x) and math.isfinite(y)
        if not ok:
            failed[q] += 1; qmax[q] = math.inf; return
        d = abs(x - y) / (max(1, abs(y)) if mode == 'relative' else 1)
        qmax[q] = max(qmax[q], d)
        if d > TOL: failed[q] += 1
    status_fail = a['status'] != r['status']
    if status_fail: failed['status'] += 1
    if a['status'] == 'refused' and r['status'] == 'refused' and cat(a['reason']) != cat(r['reason']):
        failed['refusal_category'] += 1
    if a['status'] == 'ok' and r['status'] == 'ok':
        chk('tau2', a['fit']['tau2'], r['tau2'], 'relative')
        for j, (s, t) in enumerate(zip(a['summary'], r['table'])):
            for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
                chk(aq, s[aq], t[rq], 'absolute' if aq in ('p', 'ci_lo', 'ci_hi') else 'relative')
            cb = r['club']
            if 'error' not in cb:
                for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                    vv = cb[rq]; vv = vv[j] if isinstance(vv, list) else vv
                    chk('club_' + aq, s[aq], vv, 'absolute' if aq == 'p' else 'relative')
    nfail = sum(failed.values()); fail_checks_total += nfail
    se_ref = [t.get('SE') for t in r.get('table', []) if isinstance(t.get('SE'), (int, float))]
    # Pure relative difference |a-r|/|r| on CI endpoints (diagnostic only; not the gate).
    ci_rel = 0.0
    if a['status'] == 'ok' and r['status'] == 'ok':
        for s, t in zip(a['summary'], r['table']):
            for aq, rq in [('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
                if t[rq] != 0: ci_rel = max(ci_rel, abs(s[aq] - t[rq]) / abs(t[rq]))
    rows.append(dict(
        id=key, dataset=c['dataset'], moderator=c['moderator'] or '(intercept)', rho=c['rho'], n=len(c['rows']), p=p,
        app_status=a['status'], ref_status=r['status'],
        kappa_XtX=k_unw, kappa_XtW0X=k_w0, kappa_XtWX_fit=k_fit,
        min_ref_SE=min(se_ref) if se_ref else math.nan,
        max_scaled_diff=max(qmax.values()) if qmax else math.nan,
        max_fit_diff=max([qmax[q] for q in ('estimate', 'se', 'df', 'tau2', 'club_estimate', 'club_se', 'club_df') if q in qmax] or [math.nan]),
        max_inference_diff=max([qmax[q] for q in ('t', 'p', 'ci_lo', 'ci_hi', 'club_t', 'club_p') if q in qmax] or [math.nan]),
        max_ci_pure_relative=ci_rel,
        failed_checks=nfail, failed_quantities=';'.join(f'{q}:{n}' for q, n in sorted(failed.items())),
        **{f'd_{q}': qmax.get(q, math.nan) for q in ('estimate', 'se', 't', 'df', 'p', 'ci_lo', 'ci_hi', 'tau2', 'club_estimate', 'club_se', 'club_t', 'club_df', 'club_p')}))

# Cross-check against the lane's own failure file (must reproduce 2617 / 785 exactly).
lane = json.load(open(SRC / 'engine-failures-full-patched.json', encoding='utf-8'))
lane_ids = {f['id'] for f in lane}
mine = {r['id'] for r in rows if r['failed_checks']}
assert fail_checks_total == len(lane) == 2617, (fail_checks_total, len(lane))
assert mine == lane_ids and len(mine) == 785, (len(mine), len(lane_ids))
diag = {c['id']: c['category'] for c in json.load(open(SRC / 'strict-diagnosis.json', encoding='utf-8'))['patched']['cases']}
for r in rows: r['lane_category'] = diag.get(r['id'], '')

with open(OUT / 'conditioning.csv', 'w', newline='', encoding='utf-8') as f:
    w = csv.DictWriter(f, fieldnames=list(rows[0].keys())); w.writeheader(); w.writerows(rows)
print('reproduced lane failures exactly: 2617 checks / 785 configurations')
