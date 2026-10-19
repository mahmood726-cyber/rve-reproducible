from pathlib import Path
import json,hashlib,collections,subprocess,tempfile,shutil
from reference_cache import load_cache, reference_json
cache=load_cache()
load=lambda p:reference_json(cache,p) if Path(p).parent==Path('reference') else json.loads(Path(p).read_text(encoding='utf-8'))
checks=[]
def check(name,passed,detail=None):checks.append(dict(name=name,pass_=bool(passed),detail=detail))
cs=load('configurations.json');keys=[c['id'] for c in cs]
check('reference cache coverage',cache is None or len(cache)==len(keys))
proof=load('configuration-extension-proof.json')
check('extension current hash',hashlib.sha256(Path('configurations.json').read_bytes()).hexdigest()==proof['new_sha256'])
check('extension previous prefix hash',hashlib.sha256(json.dumps(cs[:proof['old_count']],ensure_ascii=True,separators=(',',':')).encode()).hexdigest()==proof['old_sha256'])
check('extension count',len(cs)==proof['new_count'])

check('configuration keys unique',len(keys)==len(set(keys)))
grids=collections.defaultdict(set)
for c in cs:grids[c['id'].rsplit('::rho=',1)[0]].add(c['rho'])
check('rho grid complete',all(grid=={0,.2,.5,.8,1} for grid in grids.values()))
reference=[]
for i,c in enumerate(cs,1):
 p=Path('reference',f'{i:06d}.json')
 try:r=load(p);reference.append(r);check(f'reference key {i}',r['id']==c['id'])
 except Exception as e:check(f'reference key {i}',False,str(e))
for v in ['original','patched']:
 p=Path(f'app-{v}.jsonl')
 appkeys=[json.loads(line)['id'] for line in p.open(encoding='utf-8')] if p.exists() else []
 check(v+' complete ordered page coverage',appkeys==keys)
 r=load(f'results-{v}.json');check(v+' counters',r['checks']==sum(z['checks'] for z in r['quantities'].values()) and r['passes']==sum(z['passes'] for z in r['quantities'].values()))
 check(v+' failed checks retained',len(load(f'failures-{v}.json'))==r['failures'])
 check(v+' browser metadata',Path(f'browser-{v}.json').exists())
 check(v+' focused tests',Path(f'ui-{v}.json').exists())
 p=Path(f'engine-full-{v}.jsonl')
 enginekeys=[json.loads(line)['id'] for line in p.read_text(encoding='utf-8').splitlines()] if p.exists() else []
 check(v+' complete ordered direct-engine coverage',enginekeys==keys)
 er=load(f'engine-results-{v}.json')
 check(v+' direct-engine counters',er['checks']==sum(z['checks'] for z in er['quantities'].values()) and er['passes']==sum(z['passes'] for z in er['quantities'].values()))
 check(v+' direct-engine failures retained',len(load(f'engine-failures-full-{v}.json'))==er['failures'])
 em=load(f'engine-full-{v}-meta.json')
 check(v+' direct-engine source hashes',all(hashlib.sha256(Path(v,p).read_bytes()).hexdigest()==h for p,h in em['hashes'].items()))
 check(v+' direct-engine metadata count',em['configurations']==len(keys))
source=load('source-manifest.json');check('original hashes',all(hashlib.sha256(Path('original',p).read_bytes()).hexdigest()==h for p,h in source['files'].items()))
check('patch applies',subprocess.run(['git','apply','--check','--directory=original','fix.patch'],capture_output=True).returncode==0)
with tempfile.TemporaryDirectory(dir='.') as tmp:
 base=Path(tmp).resolve();assert Path.cwd().resolve() in base.parents
 changed=['rve-meta/index.html','shared/rve.js','shared/stats-qt.js']
 for name in changed:
  dest=base/name;dest.parent.mkdir(parents=True,exist_ok=True);shutil.copyfile(Path('original',name),dest)
 applied=subprocess.run(['git','apply','--directory='+base.relative_to(Path.cwd().resolve()).as_posix(),'fix.patch'],capture_output=True)
 check('patch content equals tested copy after newline normalization',applied.returncode==0 and all((base/name).read_text(encoding='utf-8')==Path('patched',name).read_text(encoding='utf-8') for name in changed))
environment=load('environment.json');check('pinned R library first',environment['pinned_library_first']);check('R_LIBS has no metafor',not environment['scratch_R_LIBS_has_metafor'])
anchors={}
needles={'rve-meta/index.html':['with a CR1','max="0.99"','function parseInput','v = 0','function run()','window.__almLastRVE = function'], 'shared/rve.js':['function invert','< 1e-12','var clKj = {}','var crit = qt ?','function summary'], 'shared/stats-qt.js':['EPS = 3e-7','if (df < 1)']}
for name,terms in needles.items():
 lines=Path('original',name).read_text(encoding='utf-8').splitlines()
 for term in terms:anchors[term]=[f'{name}:{i}' for i,l in enumerate(lines,1) if term in l]
Path('root-causes.json').write_text(json.dumps(anchors,indent=2))
Path('review.json').write_text(json.dumps(checks,indent=2))
print(sum(c['pass_'] for c in checks),'/',len(checks),'evidence integrity checks pass')
