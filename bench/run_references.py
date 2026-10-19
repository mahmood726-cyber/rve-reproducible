from pathlib import Path
import subprocess,concurrent.futures
def run(p):
 start=int(p.stem);total=len(__import__('json').loads(p.read_text()))
 if all(Path('reference',f'{i:06d}.json').exists() for i in range(start,start+total)):return
 r=subprocess.run(['python','run_r.py','reference.R',str(start)])
 if r.returncode:raise RuntimeError(f'Shard {start} failed')
with concurrent.futures.ThreadPoolExecutor(max_workers=2) as pool:list(pool.map(run,sorted(Path('shards').glob('*.json'))))
