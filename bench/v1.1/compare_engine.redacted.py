import json,collections,math,sys,csv,os,gzip
from option_a import reason, undefined, numeric_check
from pathlib import Path
from reference_cache import load_cache, reference_json
source=Path(os.environ.get('P15_SOURCE','<HOST>/p15diag'))
rule=os.environ.get('P15_RULE','finite-only')
assert rule in ('finite-only','option-a')
cwd=Path.cwd()
os.chdir(source)
try: cache=load_cache()
finally: os.chdir(cwd)
if cache is not None: cache={(source/k).as_posix():v for k,v in cache.items()}
variant=sys.argv[1];keys=[r['id'] for r in csv.DictReader(open(source/'configuration-ledger.csv',encoding='utf-8'))]
undefined_checks=[]
coefficient=None
stats=collections.defaultdict(lambda:dict(checks=0,passes=0,max_difference=0));fail=[]
def check(key,q,x,y,mode='relative'):
 d=0; ra=rr=None
 if mode=='exact':ok=x==y
 else:
  quantity=q.removeprefix('club_')
  ra=reason(x,quantity,a,coefficient,'app')
  rr=reason(y,quantity,r,coefficient,'club' if q.startswith('club_') else 'robumeta')
  ok,d=numeric_check(x,y,mode,rule,ra,rr)
  if undefined(x) or undefined(y):
   undefined_checks.append(dict(id=key,quantity=q,coefficient=coefficient,app=x,reference=y,reason_app=ra,reason_R=rr,passed=ok))
 s=stats[q];s['checks']+=1;s['passes']+=int(ok)
 if d is not None:s['max_difference']=max(s['max_difference'],d)
 if not ok:fail.append(dict(id=key,quantity=q,app=x,reference=y,difference=d,coefficient=coefficient,reason_app=ra,reason_R=rr))
file=Path(os.environ.get('P15_CAPTURE',f'engine-full-{variant}.jsonl'));n=0
for i,line in enumerate((gzip.open(file,'rt',encoding='utf-8') if file.suffix=='.gz' else file.open(encoding='utf-8')),1):
 a=json.loads(line);n=i;key=keys[i-1];check(key,'key',a['id'],key,'exact');p=source/'reference'/f'{i:06d}.json';check(key,'reference_present',(p.as_posix() in cache if cache is not None else p.exists()),True,'exact')
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
 coefficient=None
 fit=a['fit'];check(key,'tau2',fit['tau2'],r['tau2']);check(key,'method',fit['method'],'CR2','exact')
 for q,k in [('n','k_total'),('m','m_clusters'),('p','p')]:check(key,'design_columns' if q=='p' else q,fit[k],r[q],'exact')
 check(key,'coefficient_count',len(a['summary']),len(r['table']),'exact')
 for j,(s,t) in enumerate(zip(a['summary'],r['table'])):
  coefficient=j
  for aq,rq in [('estimate','b.r'),('se','SE'),('t','t'),('df','dfs'),('p','prob'),('ci_lo','CI.L'),('ci_hi','CI.U')]:check(key,aq,s[aq],t[rq],'absolute' if aq in ['p','ci_lo','ci_hi'] else 'relative')
  cb=r['club'];check(key,'club_reference_success','error' not in cb,True,'exact')
  if 'error' not in cb:
   for aq,rq in [('estimate','beta'),('se','SE'),('t','tstat'),('df','df_Satt'),('p','p_Satt')]:
    v=cb[rq];v=v[j] if isinstance(v,list) else v;check(key,'club_'+aq,s[aq],v,'absolute' if aq=='p' else 'relative')
for key in keys[n:]:check(key,'app_present',False,True,'exact')
result=dict(variant=variant,rule=rule,scope='direct shipped engine; not browser/display/export validation',configurations=len(keys),captured=n,checks=sum(s['checks'] for s in stats.values()),passes=sum(s['passes'] for s in stats.values()),quantities=dict(stats))
result['failures']=result['checks']-result['passes']
Path(f'engine-results-{variant}.json').write_text(json.dumps(result,indent=2));Path(f'engine-failures-full-{variant}.json').write_text(json.dumps(fail,indent=2))
print(f"{variant}: {result['passes']}/{result['checks']} engine checks pass; {n}/{len(keys)} captures")

result['passing_configurations']=len(keys)-len({f['id'] for f in fail})
Path(f'engine-results-{variant}.json').write_text(json.dumps(result,indent=2))
Path(f'undefined-{variant}.json').write_text(json.dumps(undefined_checks,indent=2))
print(f"{result['passing_configurations']}/{len(keys)} configurations ({rule})")
