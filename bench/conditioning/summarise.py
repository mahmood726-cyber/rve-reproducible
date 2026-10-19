"""Summarise conditioning.csv into CONDITIONING.md, conditioning-summary.json and fig_conditioning.png.

Proposed tiering rule (stated here BEFORE the counts are printed, but chosen AFTER the lane's
failures had been seen; it must be presented as post hoc):
  kappa = 2-norm condition number of X'WX, W = the CORR weights the fit actually uses.
  Tier A (kappa <= 1e-9 / u, u = 2^-53, threshold 9.007e6): unchanged 1e-9 gate.
  Tier B (kappa >  9.007e6): every numerical check uses tolerance kappa * u with the same
  scaling as the strict gate (relative to max(1,|R|), absolute for p and CI).
  Status and refusal-category checks are exact in both tiers (no tolerance can apply).
The threshold is the point at which the first-order forward-error bound kappa*u of a backward-
stable solve exceeds the gate tolerance; it uses no observed difference and no tuned constant.
"""
import collections, csv, json, math
from pathlib import Path
import numpy as np
import pandas as pd

HERE = Path(__file__).resolve().parent
SRC = HERE.parent / 'codex17'
u = np.finfo(float).eps / 2
T = 1e-9 / u
d = pd.read_csv(HERE / 'conditioning.csv')
d['fail'] = d.failed_checks > 0
d['tier'] = np.where(d.kappa_XtWX_fit.isna(), 'no fit (refused by app)', np.where(d.kappa_XtWX_fit > T, 'B', 'A'))
both_ok = (d.app_status == 'ok') & (d.ref_status == 'ok')
S = {}
S['threshold'] = T
S['n_configurations'] = len(d)
S['n_failed_configurations'] = int(d.fail.sum()); S['n_failed_checks'] = int(d.failed_checks.sum())
S['tier_counts'] = d.tier.value_counts().to_dict()
S['tier_by_fail'] = {t: dict(total=int((d.tier == t).sum()), failing=int((d.fail & (d.tier == t)).sum())) for t in d.tier.unique()}
f = d[d.fail]
S['category_by_tier'] = {f'{c} | {t}': int(n) for (c, t), n in f.groupby(['lane_category', 'tier']).size().items()}
# Matrix-choice sensitivity: does the classification of failing configurations change?
def tier_of(col):
    return np.where(d[col].isna(), 'none', np.where(d[col] > T, 'B', 'A'))
for col in ['kappa_XtW0X', 'kappa_XtX']:
    alt = tier_of(col); base = tier_of('kappa_XtWX_fit')
    S[f'sensitivity_{col}'] = dict(all_configs_same_tier=int((alt == base).sum()),
                                   failing_configs_same_tier=int(((alt == base) & d.fail).sum()))
# The gap: no configuration (pass or fail) of either tier boundary region fails.
S['configs_with_kappa_in_1e6_1e10'] = int(((d.kappa_XtWX_fit > 1e6) & (d.kappa_XtWX_fit < 1e10)).sum())
S['failing_configs_with_kappa_in_1e6_1e10'] = int(((d.kappa_XtWX_fit > 1e6) & (d.kappa_XtWX_fit < 1e10) & d.fail).sum())
S['max_kappa_failing_tierA'] = float(d[d.fail & (d.tier == 'A')].kappa_XtWX_fit.max())
S['min_kappa_failing_tierB'] = float(d[d.fail & (d.tier == 'B')].kappa_XtWX_fit.min())
# Tier B under kappa*u.
Bn = d[(d.tier == 'B') & d.fail & both_ok]
ratio = Bn.max_scaled_diff / (Bn.kappa_XtWX_fit * u)
S['tierB_numeric_failing'] = len(Bn)
S['tierB_numeric_pass_under_kappa_u'] = int((ratio <= 1).sum())
S['tierB_ratio_diff_over_kappa_u'] = dict(min=float(ratio.min()), median=float(ratio.median()), max=float(ratio.max()))
S['tierB_status_disagreements'] = d[(d.tier == 'B') & d.fail & ~both_ok].id.tolist()
S['tierB_moderator_counts_all'] = d[d.tier == 'B'].moderator.value_counts().head(6).to_dict()
S['tierB_failing_year_share'] = [int((f[f.tier == 'B'].moderator == 'year').sum()), int((f.tier == 'B').sum())]
# Tier A failures that a conditioning rule cannot reach.
A = f[f.tier == 'A']
S['tierA_failing_by_category'] = A.lane_category.value_counts().to_dict()
S['tierA_failing_kappa_max'] = float(A.kappa_XtWX_fit.max())
nz = A[A.lane_category.str.startswith('near')]
S['nearzero_moderator_top'] = nz.moderator.value_counts().head(5).to_dict()
S['nearzero_max_ref_SE'] = float(nz.min_ref_SE.max())
# Both-null subclass: every failing check has app = reference = non-finite (JSON null).
lane = json.load(open(SRC / 'engine-failures-full-patched.json', encoding='utf-8'))
by = collections.defaultdict(list)
for x in lane: by[x['id']].append(x)
allnull = [k for k, v in by.items() if all(x['app'] is None and x['reference'] is None for x in v)]
somenull = [k for k, v in by.items() if any(x['difference'] is None for x in v)]
S['configs_failing_only_on_both_nonfinite'] = len(allnull)
S['configs_with_any_nonfinite_check'] = len(somenull)
S['checks_both_nonfinite'] = sum(1 for x in lane if x['app'] is None and x['reference'] is None)
# Reference disagreements (robumeta vs clubSandwich disjoint intervals).
dis = json.load(open(SRC / 'r2-reference-disagreements.json', encoding='utf-8'))
dj = sorted({x['id'] for x in dis['differences'] if x['disjoint_acceptance_intervals']})
S['disjoint_reference_configs'] = {k: d.set_index('id').loc[k, 'tier'] for k in dj}
S['disjoint_reference_checks'] = sum(1 for x in dis['differences'] if x['disjoint_acceptance_intervals'])
# CI absolute-scale observation (diagnostic only).
inf_cat = f[f.lane_category.str.startswith('inference')]
ci_only = inf_cat[inf_cat.failed_quantities.str.fullmatch(r'(ci_hi:\d+;?|ci_lo:\d+;?)+')]
S['inference_category_ci_only'] = len(ci_only)
S['inference_category_ci_only_pass_if_ci_relative'] = int((ci_only.max_ci_pure_relative <= 1e-9).sum())
# Per-quantity maximum difference among failing configurations, by tier.
qcols = [c for c in d.columns if c.startswith('d_')]
S['per_quantity_max_failing'] = {t: {c[2:]: (None if not np.isfinite(v) else float(v)) if not pd.isna(v) else None
                                     for c, v in f[f.tier == t][qcols].replace(np.inf, np.nan).max().items()} for t in ['A', 'B']}
S['per_quantity_n_nonfinite_failing'] = {t: {c[2:]: int(np.isinf(f[f.tier == t][c]).sum()) for c in qcols} for t in ['A', 'B']}
# Centring check for the 'year' tier-B designs: kappa after centring the moderator (no fit; same weights).
cfg = {c['id']: c for c in json.load(open(SRC / 'configurations.json', encoding='utf-8')) if c['moderator'] == 'year'}
apps = {}
for line in (SRC / 'engine-full-patched.jsonl').read_text(encoding='utf-8').splitlines():
    a = json.loads(line)
    if a['id'] in cfg and a['status'] == 'ok': apps[a['id']] = a
kc = []
for k, a in apps.items():
    X = np.array([r['X'] for r in cfg[k]['rows']], float); w = np.array(a['fit']['weights'])
    Xc = X.copy(); Xc[:, 1] -= np.average(X[:, 1], weights=w)
    s = np.linalg.svd(Xc.T @ (w[:, None] * Xc), compute_uv=False); kc.append(s[0] / s[-1])
kc = np.array(kc)
yb = d[(d.moderator == 'year')]
S['year_designs'] = dict(n_fitted=len(kc), tierB_uncentred=int((yb.tier == 'B').sum()),
                         tierB_after_centring=int((kc > T).sum()), max_kappa_centred=float(kc.max()),
                         median_kappa_centred=float(np.median(kc)))
(HERE / 'conditioning-summary.json').write_text(json.dumps(S, indent=2, default=str), encoding='utf-8')

# Figure.
fig, axes = plt_axes = None, None
import matplotlib; matplotlib.use('Agg'); import matplotlib.pyplot as plt
ok = d[both_ok & d.kappa_XtWX_fit.notna()].copy()
floor = 1e-17
fig, ax = plt.subplots(1, 2, figsize=(11, 4.6), sharey=True)
for a_, col, ttl in [(ax[0], 'max_fit_diff', 'Fit quantities (b, SE, df, tau², club b/SE/df)'),
                     (ax[1], 'max_inference_diff', 'Inference quantities (t, p, CI)')]:
    y = ok[col].replace(np.inf, 1e3).fillna(floor).clip(lower=floor)
    pas = ~ok.fail
    a_.scatter(ok.kappa_XtWX_fit[pas], y[pas], s=6, c='#2a78d6', alpha=.35, marker='o', linewidths=0, label=f'passes gate (n={int(pas.sum())})')
    a_.scatter(ok.kappa_XtWX_fit[~pas], y[~pas], s=14, c='#eb6834', alpha=.8, marker='x', linewidths=.9, label=f'fails gate (n={int((~pas).sum())})')
    a_.axhline(1e-9, color='#52514e', lw=1, ls='--'); a_.text(1.3, 1.6e-9, 'gate 1e-9', fontsize=8, color='#52514e')
    a_.axvline(T, color='#52514e', lw=1, ls=':'); a_.text(T * 1.4, 1e-5, 'κ = 1e-9/u\n(proposed tier\nboundary)', fontsize=8, color='#52514e')
    k = np.logspace(0, 13.5, 50); a_.plot(k, k * u, color='#0b0b0b', lw=1); a_.text(3e12, 3e-4 * 1.0, 'κ·u', fontsize=8)
    a_.set_xscale('log'); a_.set_yscale('log'); a_.set_title(ttl, fontsize=10); a_.set_xlabel('κ₂(XᵀWX), fitted CORR weights')
    a_.set_ylim(floor / 2, 1e4); a_.grid(alpha=.2, lw=.5)
    for s in ['top', 'right']: a_.spines[s].set_visible(False)
ax[0].set_ylabel('max scaled |app − R| per configuration\n(gate scaling; non-finite shown at top, zero at floor)')
h,l=ax[1].get_legend_handles_labels(); fig.legend(h,l,loc='lower center',ncol=2,fontsize=9,frameon=False)
fig.suptitle(f'rve-meta vs robumeta/clubSandwich: {len(ok)} configurations both programs fitted', fontsize=11)
fig.tight_layout(rect=(0,0.06,1,1)); fig.savefig(HERE / 'fig_conditioning.png', dpi=200)
print(json.dumps(S, indent=1, default=str)[:6000])

# Tiered-gate totals (check level). Tier B numeric checks use kappa*u; a configuration passes all
# its numeric checks iff its max scaled difference <= kappa*u (same scaling as strict).
lane_by = collections.Counter(x['id'] for x in lane)
tierB_numeric_ids = set(Bn[(Bn.max_scaled_diff <= Bn.kappa_XtWX_fit * u)].id)
tiered_fail_checks = sum(n for k, n in lane_by.items() if k not in tierB_numeric_ids)
tiered_fail_cfgs = len([k for k in lane_by if k not in tierB_numeric_ids])
total_checks = json.load(open(SRC / 'engine-results-patched.json'))['checks']
S2 = dict(total_checks=total_checks, strict_failed_checks=len(lane), strict_failed_configs=len(lane_by),
          tiered_failed_checks=tiered_fail_checks, tiered_failed_configs=tiered_fail_cfgs,
          tiered_passed_checks=total_checks - tiered_fail_checks,
          tierB_checks_reclassified=len(lane) - tiered_fail_checks)
S['tiered_totals'] = S2
(HERE / 'conditioning-summary.json').write_text(json.dumps(S, indent=2, default=str), encoding='utf-8')
print(S2)
