import psutil,json
from pathlib import Path
root=Path.cwd().resolve()
for p in psutil.process_iter():
 try:
  if p.name().lower()=='rscript.exe' and 'reference.R' in p.cmdline() and Path(p.cwd()).resolve()==root:
   print('Stopping own resumable reference process',p.pid);p.terminate()
 except (psutil.AccessDenied,psutil.NoSuchProcess):pass
cs=json.loads(Path('configurations.json').read_text());Path('shards').mkdir(exist_ok=True)
for start in range(1,len(cs)+1,250):
 Path('shards',f'{start:06d}.json').write_text(json.dumps(cs[start-1:start+249],separators=(',',':')))
print('Shard files created')
