import json,math,sys,collections,csv,io
from pathlib import Path
variant=sys.argv[1]
configs=json.loads(Path('configurations.json').read_text())
appfile=Path(f'app-{variant}.jsonl')
appids=[];byid={}
if appfile.exists():
 with appfile.open(encoding='utf-8') as f:
  while True:
   pos=f.tell();line=f.readline()
   if not line:break
   a=json.loads(line);appids.append(a['id']);byid[a['id']]=pos
apphandle=appfile.open(encoding='utf-8') if appfile.exists() else None
counts=collections.defaultdict(lambda:dict(checks=0,passes=0,max_difference=0)); failures=[]
def check(key,q,a,b,mode='exact'):
 d=0
 if mode=='exact':ok=a==b
 else:
  ok=isinstance(a,(int,float)) and isinstance(b,(int,float)) and math.isfinite(a) and math.isfinite(b)
  if ok:d=abs(a-b)/(max(1,abs(b)) if mode=='relative' else 1);ok=d<=1e-9
  else:d=None
 z=counts[q];z['checks']+=1;z['passes']+=int(ok)
 if d is not None:z['max_difference']=max(z['max_difference'],d)
 if not ok:failures.append(dict(id=key,quantity=q,app=a,reference=b,difference=d))
check('ledger','unique_app_keys',len(byid),len(appids))
check('ledger','extra_app_keys',sorted(set(byid)-{c['id'] for c in configs}),[])
for i,c in enumerate(configs,1):
 key=c['id'];pos=byid.get(key);a=None;rp=Path('reference',f'{i:06d}.json')
 if pos is not None:apphandle.seek(pos);a=json.loads(apphandle.readline())
 check(key,'app_present',a is not None,True);check(key,'reference_present',rp.exists(),True)
 if a is None or not rp.exists():continue
 r=json.loads(rp.read_text());check(key,'reference_key',r['id'],key)
 check(key,'JSON_export',a.get('export_json_matches'),True)
 exports=a.get('exports',{})
 for kind in ['json','csv','md','report-md','report-txt']:check(key,'export_'+kind+'_present',len(exports.get(kind,[])),1)
 def flat(o,prefix=''):
  out={}
  for k,v in o.items():
   k=prefix+'.'+k if prefix else k
   if isinstance(v,dict):out.update(flat(v,k))
   else:out[k]=v
  return out
 expected=flat(a['result'] or {})
 def value(s):
  if s=='':return None
  try:return json.loads(s)
  except ValueError:return s
 if len(exports.get('csv',[]))==1:
  parsed={r['key']:value(r['value']) for r in csv.DictReader(io.StringIO(exports['csv'][0]))};check(key,'CSV_content',parsed,expected)
 if len(exports.get('md',[]))==1:
  lines=exports['md'][0].splitlines()[2:];parsed={line.split('|')[1].strip():value(line.split('|')[2].strip()) for line in lines};check(key,'Markdown_content',parsed,expected)
 if len(exports.get('report-md',[]))==1 and len(exports.get('md',[]))==1:check(key,'report_MD_data',exports['md'][0] in exports['report-md'][0] if expected else 'No results yet' in exports['report-md'][0],True)
 if len(exports.get('report-txt',[]))==1:
  lines=exports['report-txt'][0].splitlines();parsed={line.split(': ',1)[0]:value(line.split(': ',1)[1]) for line in lines if ': ' in line and line.split(': ',1)[0] in expected};check(key,'report_text_data',parsed,expected)
 check(key,'status',a['status'],r['status'])
 if r['status']=='refused':
  def category(reason):
   s=reason.lower()
   if 'm<=p' in s:return 'insufficient clusters'
   if 'singular' in s or 'rank deficien' in s:return 'rank deficiency'
   if 'no rows' in s or 'no valid rows' in s:return 'no rows'
   return s
  check(key,'refusal_category',category(a['reason']),category(r['reason']))
  check(key,'refusal_export_cleared',a['result'],None);continue
 if a['status']!='ok':continue
 rows=a['rows'];check(key,'input_count',len(rows),len(c['rows']))
 from urllib.parse import unquote
 check(key,'input_identity',[{**x,'cluster':unquote(x['cluster'])} for x in rows],c['rows'])
 fit=a['result']['fit'];summ=a['result']['summary']
 check(key,'coefficient_count',len(summ),len(r['table']))
 for q,f in [('n','k_total'),('m','m_clusters'),('p','p')]:check(key,'design_columns' if q=='p' else q,fit[f],r[q])
 check(key,'rho',fit['rho'],c['rho']);check(key,'tau2',fit['tau2'],r['tau2'],'relative')
 check(key,'method',fit['method'],'CR2')
 for j,(s,t) in enumerate(zip(summ,r['table'])):
  check(key,'export_beta_consistency',fit['beta'][j],s['estimate']);check(key,'export_se_consistency',fit['se_robust'][j],s['se']);check(key,'export_df_consistency',fit['df'][j],s['df']);check(key,'coefficient_index',s['coef_index'],j)
  for aq,rq in [('estimate','b.r'),('se','SE'),('t','t'),('df','dfs'),('p','prob'),('ci_lo','CI.L'),('ci_hi','CI.U')]:
   check(key,f'{aq}',s[aq],t[rq],'absolute' if aq in ('p','ci_lo','ci_hi') else 'relative')
  cb=r.get('club',{})
  if 'error' in cb:check(key,'club_reference_success',False,True)
  else:
   for aq,rq in [('estimate','beta'),('se','SE'),('t','tstat'),('df','df_Satt'),('p','p_Satt')]:
    v=cb[rq];v=v[j] if isinstance(v,list) else v;check(key,'club_'+aq,s[aq],v,'absolute' if aq=='p' else 'relative')
  # Rendered precision: comparisons against own captured output, not extra rounded reference targets.
  def fmt(v,d):
   if v is None or not math.isfinite(v):return '\u2014'
   from decimal import Decimal,ROUND_HALF_UP
   return str(Decimal.from_float(v).quantize(Decimal(1).scaleb(-d),rounding=ROUND_HALF_UP))
  expected=['(intercept)' if j==0 else c['moderator'],fmt(s['estimate'],3),fmt(s['se'],3),fmt(s['t'],2),fmt(s['df'],2),fmt(s['ci_lo'],3)+', '+fmt(s['ci_hi'],3),'<0.001' if s['p'] is not None and s['p']<.001 else fmt(s['p'],3)]
  check(key,'display_row',a['cells'][j] if j<len(a['cells']) else None,expected)
total=sum(x['checks'] for x in counts.values());passed=sum(x['passes'] for x in counts.values())
result=dict(variant=variant,checks=total,passes=passed,failures=total-passed,quantities=dict(counts),app_records=len(appids),configurations=len(configs))
Path(f'results-{variant}.json').write_text(json.dumps(result,indent=2));Path(f'failures-{variant}.json').write_text(json.dumps(failures,indent=2))
for q,z in sorted(counts.items()):print(q,f"{z['passes']}/{z['checks']}",z['max_difference'])
print(f'{passed}/{total} checks pass')
