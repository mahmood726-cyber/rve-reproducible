import csv, json, random
from pathlib import Path
H = Path(__file__).resolve().parent
rows = list(csv.DictReader(open('C:/mh-lanes/p10-11-15/p15prep/conditioning.csv', encoding='utf-8')))
keys = [r['id'] for r in csv.DictReader(open('C:/mh-lanes/f1000-15-19/p15-codex17/configuration-ledger.csv', encoding='utf-8'))]
index = {k: i + 1 for i, k in enumerate(keys)}
elig = [r for r in rows if r['ref_status'] == 'ok']
rng = random.Random(20261019)
by = {}
for r in elig: by.setdefault(r['dataset'], []).append(r['id'])
sample = []
for ds in sorted(by):
    pool = sorted(by[ds]); k = min(2, len(pool)); sample += rng.sample(pool, k)
rest = sorted(set(r['id'] for r in elig) - set(sample))
sample += rng.sample(rest, 300 - len(sample))
tierB = (H / 'centring_config_ids.txt').read_text(encoding='utf-8').split()
okc = [cid for i, cid in enumerate(tierB, 1) if json.loads((H / 'centred_ref' / f'{i:04d}.json').read_text(encoding='utf-8'))['status'] == 'ok']
cen = rng.sample(sorted(okc), 50)
out = dict(seed=20261019, datasets=len(by), uncentred=[dict(id=c, index=index[c]) for c in sample],
           centred=[dict(id=c, index=index[c], tierB_pos=tierB.index(c) + 1) for c in cen])
(H / 'rscript_sample.json').write_text(json.dumps(out, indent=1), encoding='utf-8')
print(len(by), len(sample), len(set(sample)), len(cen))
