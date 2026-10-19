"""Check that every near-zero-SE failing configuration is an exact fit: yi linear in X (OLS residual)."""
import json, numpy as np, pandas as pd
from pathlib import Path
H = Path(__file__).resolve().parent
d = pd.read_csv(H / 'conditioning.csv'); ids = set(d[d.lane_category.str.startswith('near', na=False)].id)
c = [x for x in json.load(open(H.parent / 'codex17' / 'configurations.json', encoding='utf-8')) if x['id'] in ids]
mx = 0.0; same = 0
for x in c:
    X = np.array([r['X'] for r in x['rows']]); y = np.array([r['yi'] for r in x['rows']])
    b, *_ = np.linalg.lstsq(X, y, rcond=None)
    mx = max(mx, float(np.abs(y - X @ b).max() / max(1, np.abs(y).max())))
    same += bool(np.array_equal(X[:, 1], y))
out = dict(n=len(c), moderator_identical_to_yi=same, max_relative_ols_residual=mx)
(H / 'exactfit.json').write_text(json.dumps(out, indent=2)); print(out)
