from pathlib import Path
import hashlib,json,zipfile,concurrent.futures
from reference_cache import load_cache
cache=load_cache()
files=[]
for p in Path('.').iterdir():
 if p.is_file() and (p.suffix in ('.py','.R','.json','.jsonl','.csv','.md','.patch','.cjs') or p.name in ['.gitignore','empty.Renviron']) and p.name not in ['archive-verification.json','packaging-execution.json','PROGRESS.md','setup.py','prepare_corpus.py','shard.py','stop_browser_wait.py','TASK.md','TEMPLATE_TASK16.md','engine.cjs','engine_check.py','engine-original.json','engine-patched.json','engine-failures-original.json','engine-failures-patched.json'] and not p.name.startswith(('cor_','frag_','lfk_','rve_')):files.append(p)
for folder in ['original','patched','reference','shards','documentation','packages','downloads-original','downloads-patched']:
 files+=list(p for p in Path(folder).rglob('*') if p.is_file())
files+=[Path('tests/audit.spec.cjs'),Path('tests/playwright.config.cjs'),Path('tests/package.json')]
result=Path('RESULT.md')
if result.exists():
 text=result.read_text(encoding='utf-8')
 count=len(set(files)|{Path('artifact-manifest.json')})
 text=text.replace('PACKAGE_COUNT_PENDING',str(count))
 result.write_text(text,encoding='utf-8')
def payload(p):
 if cache is not None and p.as_posix() in cache:return p,cache[p.as_posix()]['raw'].encode('utf-8')
 return p,p.read_bytes()
with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
 data=dict(pool.map(payload,set(files)-{Path('artifact-manifest.json')}))
manifest={p.as_posix():hashlib.sha256(raw).hexdigest() for p,raw in data.items()}
Path('artifact-manifest.json').write_text(json.dumps(manifest,indent=2));files.append(Path('artifact-manifest.json'))
with zipfile.ZipFile('rve-validation.zip','w',compression=zipfile.ZIP_DEFLATED,compresslevel=6) as z:
 for p in sorted(set(files)):z.writestr(p.as_posix(),data[p] if p in data else p.read_bytes())
print('Archived',len(set(files)),'files')
