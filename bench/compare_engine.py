import json,collections,math,sys,csv
from pathlib import Path
from reference_cache import load_cache, reference_json
cache=load_cache()
variant=sys.argv[1];keys=[r['id'] for r in csv.DictReader(open('configuration-ledger.csv',encoding='utf-8'))]
stats=collections.defaultdict(lambda:dict(checks=0,passes=0,max_difference=0));fail=[]
def check(key,q,x,y,mode='relative'):
 d=0
 if mode=='exact':ok=x==y
 else:
  ok=isinstance(x,(float,int)) and isinstance(y,(float,int)) and math.isfinite(x) and math.isfinite(y)
  d=abs(x-y)/(max(1,abs(y)) if mode=='relative' else 1) if ok else None
  ok=ok and d<=1e-9
 s=stats[q];s['checks']+=1;s['passes']+=int(ok)
 if d is not None:s['max_difference']=max(s['max_difference'],d)
 if not ok:fail.append(dict(id=key,quantity=q,app=x,reference=y,difference=d))
file=Path(f'engine-full-{variant}.jsonl');n=0
for i,line in enumerate(file.read_text(encoding='utf-8').splitlines(),1):
 a=json.loads(line);n=i;key=keys[i-1];check(key,'key',a['id'],key,'exact');p=Path('reference',f'{i:06d}.json');check(key,'reference_present',(p.as_posix() in cache if cache is not None else p.exists()),True,'exact')
 if not (p.as_posix() in cache if cache is not None else p.exists()):continue
 r=reference_json(cache,p);check(key,'reference_key',r['id'],key,'exact');check(key,'status',a['status'],r['status'],'exact')
 if a['status']=='refused' and r['status']=='refused':
  def category(reason):
   s=reason.lower()
   if 'm<=p' in s:return 'insufficient clusters'
   if 'singular' in s or 'rank deficien' in s:return 'rank deficiency'
   if 'no rows' in s or 'no valid rows' in s:return 'no rows'
   return s
  check(key,'refusal_category',category(a['reason']),category(r['reason']),'exact')
 if a['status']!='ok' or r['status']!='ok':continue
 fit=a['fit'];check(key,'tau2',fit['tau2'],r['tau2']);check(key,'method',fit['method'],'CR2','exact')
 for q,k in [('n','k_total'),('m','m_clusters'),('p','p')]:check(key,'design_columns' if q=='p' else q,fit[k],r[q],'exact')
 check(key,'coefficient_count',len(a['summary']),len(r['table']),'exact')
 for j,(s,t) in enumerate(zip(a['summary'],r['table'])):
  for aq,rq in [('estimate','b.r'),('se','SE'),('t','t'),('df','dfs'),('p','prob'),('ci_lo','CI.L'),('ci_hi','CI.U')]:check(key,aq,s[aq],t[rq],'absolute' if aq in ['p','ci_lo','ci_hi'] else 'relative')
  cb=r['club'];check(key,'club_reference_success','error' not in cb,True,'exact')
  if 'error' not in cb:
   for aq,rq in [('estimate','beta'),('se','SE'),('t','tstat'),('df','df_Satt'),('p','p_Satt')]:
    v=cb[rq];v=v[j] if isinstance(v,list) else v;check(key,'club_'+aq,s[aq],v,'absolute' if aq=='p' else 'relative')
for key in keys[n:]:check(key,'app_present',False,True,'exact')
result=dict(variant=variant,scope='direct shipped engine; not browser/display/export validation',configurations=len(keys),captured=n,checks=sum(s['checks'] for s in stats.values()),passes=sum(s['passes'] for s in stats.values()),quantities=dict(stats))
result['failures']=result['checks']-result['passes']
Path(f'engine-results-{variant}.json').write_text(json.dumps(result,indent=2));Path(f'engine-failures-full-{variant}.json').write_text(json.dumps(fail,indent=2))
print(f"{variant}: {result['passes']}/{result['checks']} engine checks pass; {n}/{len(keys)} captures")
