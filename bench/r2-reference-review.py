import json, math, collections
from pathlib import Path
from reference_cache import load_cache
cache=load_cache(); differences=[]; impossible=[]
for record in cache.values():
 r=json.loads(record['raw'])
 if r['status']!='ok' or 'error' in r['club']:continue
 for j,t in enumerate(r['table']):
  for q,a,b in [('estimate','b.r','beta'),('se','SE','SE'),('df','dfs','df_Satt'),('t','t','tstat'),('p','prob','p_Satt')]:
   x=t[a]; y=r['club'][b]; y=y[j] if isinstance(y,list) else y
   if not isinstance(x,(int,float)) or not isinstance(y,(int,float)): continue
   tx=1e-9*(1 if q=='p' else max(1,abs(x))); ty=1e-9*(1 if q=='p' else max(1,abs(y)))
   if abs(x-y)>min(tx,ty):
    d=dict(id=r['id'],coefficient=j,quantity=q,robumeta=x,clubSandwich=y,difference=abs(x-y),disjoint_acceptance_intervals=abs(x-y)>tx+ty)
    differences.append(d)
    if d['disjoint_acceptance_intervals']:impossible.append(d)
Path('r2-reference-disagreements.json').write_text(json.dumps(dict(differences=differences,disjoint=impossible),indent=2))
print('Reference differences',len(differences),'disjoint',len(impossible),'configs',len({d['id'] for d in impossible}))
print(collections.Counter(d['quantity'] for d in impossible))
