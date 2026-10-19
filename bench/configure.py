import json, math, re, csv
from pathlib import Path
load=lambda p:json.loads(Path(p).read_text(encoding='utf-8'))
bases=load('corpus.json');documented=load('documented-clusters.json')
extra=load('extra-data.json')
for name,z in extra.items():
 if 'data' not in z: continue
 d=z['data']; y,v={'corrdat':('effectsize','var'),'hierdat':('effectsize','var'),'dropoutPrevention':('LOR1','varLOR'),'SATcoaching':('d','V'),'oswald2013':('yi','vi')}[name]
 good=[i for i in range(len(d[y])) if isinstance(d[y][i],(float,int)) and isinstance(d[v][i],(float,int)) and math.isfinite(d[y][i]) and d[v][i]>0]
 bases.append(dict(id=z['package']+'::'+name,dataset=z['package']+'::'+name,definition=f'stored {y}/{v}' if name!='oswald2013' else 'escalc ZCOR R/N',te=[d[y][i] for i in good],se=[math.sqrt(d[v][i]) for i in good],source_rows=[i+1 for i in good],metadata=dict(mapping='source rows retained',columns={k:dict(type='numeric' if all(a is None or isinstance(a,(float,int)) for a in vals) else 'text',values=[vals[i] for i in good]) for k,vals in d.items() if k not in [y,v]})))
configs=[]; ledger=[]; excluded=[]
def numeric(x):
 try: return x is not None and str(x).strip()!='' and math.isfinite(float(x))
 except (TypeError,ValueError): return False
def predictor(c):
 vals=c['values']
 return c['type']=='numeric' or (any(numeric(x) for x in vals) and all(x is None or numeric(x) for x in vals))
for b in bases:
 cols=b['metadata']['columns']; n=len(b['te']); clusters=[]
 for name,c in cols.items():
  # Explicitly enumerate identifier-like fields, including singleton clusterings.
  iscl=bool(re.search(r'study|studlab|trial|article|district|author|paper|publication|experiment|(^id$)|(^id[._])|([._]id$)',name,re.I)) or name in documented.get(b['dataset'],{}).get('columns',[])
  if iscl: clusters.append(name)
  ledger.append(dict(base=b['id'],column=name,cluster=iscl,predictor=name not in ('yi','vi','sei') and predictor(c),reason='named grouping identifier' if iscl else 'not a named grouping identifier',mapping=b['metadata']['mapping']))
 if not clusters: excluded.append(dict(base=b['id'],reason='no aligned named study/ID clustering column')); continue
 for cl in clusters:
  for mod in [None]+[k for k,c in cols.items() if k not in (cl,'yi','vi','sei') and predictor(c)]:
   cv=cols[cl]['values']; mv=cols[mod]['values'] if mod else [0]*n
   idx=[i for i in range(n) if cv[i] is not None and str(cv[i]).strip() and (not mod or numeric(mv[i]))]
   rows=[dict(cluster=str(cv[i]),yi=b['te'][i],vi=b['se'][i]**2,X=[1]+([float(mv[i])] if mod else [])) for i in idx]
   included=set(idx)
   for rho in [0,.2,.5,.8,1]:
    key=f"{b['id']}::{cl}::{mod or '(intercept)'}::rho={rho}"
    configs.append(dict(id=key,base=b['id'],dataset=b['dataset'],definition=b['definition'],cluster=cl,moderator=mod,rho=rho,rows=rows,source_rows=[b['source_rows'][i] for i in idx],omitted_rows=[b['source_rows'][i] for i in range(n) if i not in included]))
if Path('configurations.json').exists():
 import hashlib
 oldhash=hashlib.sha256(Path('configurations.json').read_bytes()).hexdigest()
 old=load('configurations.json');new={c['id']:c for c in configs}
 for c in old:assert new[c['id']]==c,'existing configuration changed'
 oldkeys={c['id'] for c in old};configs=old+[c for c in configs if c['id'] not in oldkeys]
Path('configurations.json').write_text(json.dumps(configs,ensure_ascii=True,separators=(',',':')))
if 'oldhash' in locals():
 Path('configuration-extension-proof.json').write_text(json.dumps(dict(old_count=len(old),new_count=len(configs),old_sha256=oldhash,new_sha256=hashlib.sha256(Path('configurations.json').read_bytes()).hexdigest(),all_old_configurations_identical=True),indent=2))
Path('cluster-exclusions.json').write_text(json.dumps(excluded,indent=2))
with open('column-ledger.csv','w',newline='',encoding='utf-8') as f:
 w=csv.DictWriter(f,fieldnames=list(ledger[0]));w.writeheader();w.writerows(ledger)
with open('configuration-ledger.csv','w',newline='',encoding='utf-8') as f:
 fields=['id','dataset','cluster','moderator','rho','n','m']; w=csv.DictWriter(f,fieldnames=fields);w.writeheader()
 for c in configs:w.writerow({**{k:c[k] for k in fields[:5]},'n':len(c['rows']),'m':len(set(r['cluster'] for r in c['rows']))})
print(len(configs),'configurations;',len(set(c['dataset'] for c in configs)),'datasets; max n',max(len(c['rows']) for c in configs))
