"""Rebuild tables, numbers and the conditioning figure from archived evidence into outputs/.

Tables are built from results/ only and assert their totals. The conditioning analysis is re-run with the
UNMODIFIED lane scripts (bench/conditioning/conditioning.py, summarise.py, exactfit.py) in a temporary folder laid
out as they expect (../codex17), and the regenerated files are compared with results/conditioning/.
Usage: python analysis/make_outputs.py [--skip-conditioning]
"""
import collections, csv, io, json, lzma, math, shutil, subprocess, sys, tempfile
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'outputs'; OUT.mkdir(exist_ok=True)
read = lambda rel: json.loads((ROOT / rel).read_text(encoding='utf-8'))
exp = read('expected/paper_values.json')
sci = lambda x: f'{x:.2e}' if x else '0'

def table(kind, a, b, stem, label):
    qs = list(dict.fromkeys(list(a['quantities']) + list(b['quantities'])))
    rows = []
    for q in qs:
        x, y = a['quantities'].get(q, {}), b['quantities'].get(q, {})
        rows.append(dict(quantity=q, original_checks=x.get('checks', 0), original_passes=x.get('passes', 0), original_max_difference=sci(x.get('max_difference', 0)),
                         patched_checks=y.get('checks', 0), patched_passes=y.get('passes', 0), patched_max_difference=sci(y.get('max_difference', 0))))
    tot = dict(quantity='Total', original_checks=sum(r['original_checks'] for r in rows), original_passes=sum(r['original_passes'] for r in rows), original_max_difference='',
               patched_checks=sum(r['patched_checks'] for r in rows), patched_passes=sum(r['patched_passes'] for r in rows), patched_max_difference='')
    assert (tot['original_checks'], tot['original_passes']) == (a['checks'], a['passes']), (kind, 'original')
    assert (tot['patched_checks'], tot['patched_passes']) == (b['checks'], b['passes']), (kind, 'patched')
    rows.append(tot)
    with open(OUT / f'{stem}.csv', 'w', newline='', encoding='utf-8') as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]), lineterminator='\n'); w.writeheader(); w.writerows(rows)
    md = [f'{label}', '', '| Quantity | Original checks | Original passes | Original max diff | Patched checks | Patched passes | Patched max diff |', '|---|---:|---:|---:|---:|---:|---:|']
    md += [f"| {r['quantity']} | {r['original_checks']:,} | {r['original_passes']:,} | {r['original_max_difference']} | {r['patched_checks']:,} | {r['patched_passes']:,} | {r['patched_max_difference']} |" for r in rows]
    (OUT / f'{stem}.md').write_text('\n'.join(md) + '\n', encoding='utf-8')
    print(f"{stem}: original {tot['original_passes']:,}/{tot['original_checks']:,}; patched {tot['patched_passes']:,}/{tot['patched_checks']:,}")

table('engine', read('results/engine/engine-results-original.json'), read('results/engine/engine-results-patched.json'), 'table1_engine_by_quantity',
      'Table 1. Direct-engine strict checks by quantity (1e-9; robumeta 2.1 and clubSandwich 0.7.0 references).')
table('browser', read('results/browser/compare-results-original.json'), read('results/browser/compare-results-patched.json'), 'table3_browser_by_quantity',
      'Table 3. Browser (page, display and export) checks by quantity, Microsoft Edge 151, same references.')
rows = list(csv.DictReader(open(ROOT / 'results/diagnosis/failing-configurations-patched.csv', encoding='utf-8')))
by = collections.defaultdict(lambda: [0, 0])
for r in rows: by[r['diagnosed_cause']][0] += 1; by[r['diagnosed_cause']][1] += int(r['failed_checks'])
with open(OUT / 'table2_failure_causes.csv', 'w', newline='', encoding='utf-8') as f:
    w = csv.writer(f, lineterminator='\n'); w.writerow(['diagnosed_cause', 'configurations', 'failed_checks'])
    for k, (c, n) in sorted(by.items(), key=lambda kv: -kv[1][0]): w.writerow([k, c, n])
    w.writerow(['Total', sum(c for c, _ in by.values()), sum(n for _, n in by.values())])
assert sum(c for c, _ in by.values()) == exp['variants']['patched']['failed_configurations']
refusal = sum(1 for r in rows if r['strict_category'] in ('refusal reason disagreement', 'acceptance/refusal disagreement'))
numbers = dict(engine={v: {k: exp['variants'][v][k] for k in ['checks', 'passes', 'failures', 'failed_configurations']} for v in exp['variants']},
               browser={v: {k: exp['browser'][v][k] for k in ['checks', 'passes', 'failures', 'failed_configurations']} for v in exp['browser']},
               browser_ui={v: {k: exp['browser_ui'][v][k] for k in ['checks', 'passes']} for v in exp['browser_ui']},
               patched_failure_causes={k: dict(configurations=c, failed_checks=n) for k, (c, n) in by.items()},
               refusal_disagreements_total=refusal)
(OUT / 'numbers.json').write_text(json.dumps(numbers, indent=2) + '\n', encoding='utf-8')
print('causes:', {k: c for k, (c, _) in by.items()}, '; refusal disagreements (reason + acceptance):', refusal)

if '--skip-conditioning' not in sys.argv:
    tmp = Path(tempfile.mkdtemp(prefix='.verify-cond-', dir=ROOT))
    try:
        src, prep = tmp / 'codex17', tmp / 'prep'; src.mkdir(); prep.mkdir()
        unxz = lambda rel: lzma.decompress((ROOT / rel).read_bytes())
        (src / 'configurations.json').write_bytes(unxz('data/configurations.json.xz'))
        (src / 'engine-full-patched.jsonl').write_bytes(unxz('results/engine/engine-full-patched.jsonl.xz'))
        (src / 'strict-diagnosis.json').write_bytes(unxz('results/diagnosis/strict-diagnosis.json.xz'))
        for rel in ['data/configuration-ledger.csv', 'results/engine/engine-failures-full-patched.json', 'results/engine/engine-results-patched.json',
                    'results/diagnosis/r2-reference-disagreements.json']:
            shutil.copyfile(ROOT / rel, src / Path(rel).name)
        idx = read('results/reference/reference-index.json')
        lines = unxz('results/reference/r-reference.jsonl.xz').decode('utf-8').split('\n')[:-1]
        (src / 'reference-byte-cache.json').write_text(json.dumps([dict(path=f"reference/{r['file']}", raw=l + '\n') for r, l in zip(idx, lines)]), encoding='utf-8')
        for f in ['conditioning.py', 'summarise.py', 'exactfit.py']: shutil.copyfile(ROOT / 'bench/conditioning' / f, prep / f)
        subprocess.run([sys.executable, 'conditioning.py'], cwd=prep, check=True)
        new = list(csv.DictReader(open(prep / 'conditioning.csv', encoding='utf-8')))
        old = list(csv.DictReader(open(ROOT / 'results/conditioning/conditioning.csv', encoding='utf-8')))
        exact_cols = ['id', 'app_status', 'ref_status', 'failed_checks', 'failed_quantities', 'lane_category']
        same_exact = all(a[c] == b[c] for a, b in zip(new, old) for c in exact_cols) and len(new) == len(old)
        def rel(a, b):
            x, y = float(a or 'nan'), float(b or 'nan')
            return 0.0 if (x == y or (math.isnan(x) and math.isnan(y))) else abs(x - y) / max(abs(y), 1e-300)
        kmax = max(rel(a[c], b[c]) for a, b in zip(new, old) for c in ['kappa_XtX', 'kappa_XtW0X', 'kappa_XtWX_fit'])
        print(f'conditioning.csv regenerated: failure columns identical={same_exact}; max relative kappa difference={kmax:.3g}; '
              f'byte-identical={(prep / "conditioning.csv").read_bytes() == (ROOT / "results/conditioning/conditioning.csv").read_bytes()}')
        shutil.copyfile(ROOT / 'results/conditioning/conditioning.csv', prep / 'conditioning.csv')  # summarise the archived table
        subprocess.run([sys.executable, 'summarise.py'], cwd=prep, check=True, stdout=subprocess.DEVNULL)
        subprocess.run([sys.executable, 'exactfit.py'], cwd=prep, check=True, stdout=subprocess.DEVNULL)
        d = OUT / 'conditioning'; d.mkdir(exist_ok=True)
        for f in ['conditioning-summary.json', 'fig_conditioning.png', 'exactfit.json']: shutil.copyfile(prep / f, d / f)
        s_new, s_old = json.loads((prep / 'conditioning-summary.json').read_text()), read('results/conditioning/conditioning-summary.json')
        print('conditioning-summary.json regenerated from the archived table: identical =', s_new == s_old,
              '; exactfit.json identical =', json.loads((prep / 'exactfit.json').read_text()) == read('results/conditioning/exactfit.json'))
        assert same_exact and s_new['tier_by_fail'] == s_old['tier_by_fail'] and s_new['category_by_tier'] == s_old['category_by_tier']
    finally:
        shutil.rmtree(tmp, ignore_errors=True)
