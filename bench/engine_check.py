import json,sys,math,collections
from pathlib import Path
v=sys.argv[1];apps=json.loads(Path(f'engine-{v}.json').read_text()); fail=[];count=collections.Counter()
for i,a in enumerate(apps,1):
 f=Path('reference',f'{i:06d}.json')
 if not f.exists():continue
 r=json.loads(f.read_text())
 if a['status']!=r['status']:fail.append((i,'status',a['status'],r['status']));continue
 if r['status']!='ok':continue
 for j,(s,t) in enumerate(zip(a['summary'],r['table'])):
  for aq,rq in [('estimate','b.r'),('se','SE'),('df','dfs'),('t','t'),('p','prob'),('ci_lo','CI.L'),('ci_hi','CI.U')]:
   x,y=s[aq],t[rq];d=abs(x-y)/(max(1,abs(y)) if aq in ('estimate','se','df','t') else 1) if x is not None and y is not None else math.inf
   if d>1e-9:fail.append((i,aq,x,y,d))
Path(f'engine-failures-{v}.json').write_text(json.dumps(fail,indent=2))
print(v,len(fail),'failures',collections.Counter(f[1] for f in fail));print(fail[:15])
