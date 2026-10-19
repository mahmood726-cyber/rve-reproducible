"""Describe retained strict failures without changing any acceptance decision."""
from pathlib import Path
import collections
import csv
import json
import math

from reference_cache import load_cache, reference_json
cache = load_cache()
load = lambda p: reference_json(cache,p) if Path(p).parent==Path('reference') else json.loads(Path(p).read_text(encoding='utf-8'))
ledger = list(csv.DictReader(open('configuration-ledger.csv', encoding='utf-8')))
indices = {c['id']: i for i, c in enumerate(ledger, 1)}
out = {}
lines = ['# Strict failure diagnosis', '',
         'All failures remain failures at the specified 1e-9 tolerances. Categories below describe observed evidence, not waivers or proof of a unique mathematical cause.', '']
for variant in ['original', 'patched']:
    failures = load(f'engine-failures-full-{variant}.json')
    bycase = collections.defaultdict(list)
    for f in failures:
        bycase[f['id']].append(f)
    details = []
    for line in Path(f'engine-full-{variant}.jsonl').read_text(encoding='utf-8').splitlines():
        app = json.loads(line)
        key = app['id']
        if key not in bycase:
            continue
        ref = load(Path('reference', f'{indices[key]:06d}.json'))
        fs = bycase[key]
        if app['status'] != ref['status']:
            category = 'acceptance/refusal disagreement'
        elif any(f['quantity'] == 'refusal_category' for f in fs):
            category = 'refusal reason disagreement'
        elif any(f['quantity'] == 'club_reference_success' for f in fs):
            category = 'clubSandwich reference error'
        elif any(isinstance(t.get('SE'), (int, float)) and t['SE'] <= 1e-12 for t in ref.get('table', [])):
            category = 'near-zero reference SE; t/p sensitive to residual rounding'
        elif any(f['quantity'] in ('df', 'club_df', 'se', 'club_se', 'estimate', 'tau2') for f in fs):
            category = 'fit/variance/df numerical mismatch; unresolved'
        else:
            category = 'inference mismatch despite fit quantities meeting tolerance'
        details.append(dict(id=key, category=category, failed_checks=len(fs),
                            quantities=dict(collections.Counter(f['quantity'] for f in fs)),
                            app_status=app['status'], reference_status=ref['status'],
                            app_reason=app.get('reason'), reference_reason=ref.get('reason'),
                            reference_SE=[t.get('SE') for t in ref.get('table', [])],
                            reference_df=[t.get('dfs') for t in ref.get('table', [])],
                            examples=fs[:3]))
    summary = dict(failed_checks=len(failures), failed_configurations=len(bycase),
                   quantities=dict(collections.Counter(f['quantity'] for f in failures)),
                   categories=dict(collections.Counter(d['category'] for d in details)), cases=details)
    out[variant] = summary
    lines += [f'## {variant}', '', f'{len(failures)} failed checks across {len(bycase)} configurations.', '',
              '| Observed category | Configurations |', '|---|---:|']
    lines += [f'| {k} | {v} |' for k, v in summary['categories'].items()]
    lines += ['', 'Failed quantities: ' + json.dumps(summary['quantities'], sort_keys=True), '']
lines += ['## Interpretation and remaining work', '',
          'R2 isolated the inference functions using R fit inputs for the 590 baseline inference-category configurations: no CI or p check exceeded tolerance (r2-inference-probe.json). Thus these failures cannot be attributed to the t implementation alone. R2 traces demonstrate arithmetic-order differences in LU inversion and sandwich multiplication on the three smallest fit cases; matching these orders reproduces their robumeta coefficients and SEs exactly. Near-zero SE remains a descriptive category only. The JSON companion retains every failing check. See RESULT_R2.md and r2-reference-disagreements.json for remaining reference conflicts; none are waived.', '',
          'Acceptance/refusal differences and fit/variance/df mismatches remain unresolved blockers. No reference substitutions, excluded failing cases, or relaxed tolerances were used. Browser parser, display and export checks remain unrun by host instruction; direct-engine evidence cannot resolve them.', '',
          '| Item | Static or dynamic |', '|---|---|',
          '| Acceptance tolerance | Static task requirement, unchanged |',
          '| 1e-12 near-zero-SE diagnostic label | Static descriptive threshold only; does not affect pass/fail |',
          '| Counts, statuses, SE, df and differences | Dynamic captured engine and R reference records |', '']
Path('strict-diagnosis.json').write_text(json.dumps(out, indent=2), encoding='utf-8')
Path('STRICT_DIAGNOSIS.md').write_text('\n'.join(lines), encoding='utf-8')
print(json.dumps({v: {k: r[k] for k in ['failed_checks', 'failed_configurations', 'categories']} for v, r in out.items()}, indent=2))

import append_refusal_diagnosis
