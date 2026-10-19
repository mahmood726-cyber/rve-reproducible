from pathlib import Path
import json,collections,csv
load=lambda p:json.loads(Path(p).read_text(encoding='utf-8'))
configs=load('configurations.json');coverage=load('coverage.json');groups=collections.defaultdict(list)
for c in configs:groups[c['dataset']].append(c)
names=list(coverage)+[n for n in groups if n not in coverage]
rows=[]
for name in names:
 cases=groups[name];source=coverage.get(name,{})
 reason='included under declared clustering/moderator eligibility rule' if cases else ('no eligible effect/variance construction: '+source.get('reason','') if source.get('status')=='excluded' else 'no aligned named clustering column; see cluster-exclusions.json and metadata mapping decisions')
 rows.append(dict(dataset=name,status='included' if cases else 'excluded',configurations=len(cases),effect_definitions=len({c['base'] for c in cases}),cluster_columns=sorted({c['cluster'] for c in cases}),moderator_columns=sorted({c['moderator'] for c in cases if c['moderator']}),reason=reason))
Path('dataset-ledger.json').write_text(json.dumps(rows,indent=2))
with open('dataset-ledger.csv','w',newline='',encoding='utf-8') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]));w.writeheader();w.writerows(rows)
print(collections.Counter(r['status'] for r in rows))
