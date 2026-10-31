# Runs every generated script in its own Rscript process (2 at a time) on the node.
import json, subprocess, sys, concurrent.futures, time
from pathlib import Path
H = Path(r'<HOST>/p101115\rveup'); RS = r'C:\Program Files\R\R-4.6.0\bin\Rscript.exe'
(H / 'rs_out').mkdir(exist_ok=True); (H / 'rs_log').mkdir(exist_ok=True)
names = sorted(p.stem for p in (H / 'rscripts').glob('*.R'))
def one(n):
    out = H / 'rs_out' / (n + '.json')
    if out.exists(): return n, 'skip'
    with open(H / 'rs_log' / (n + '.txt'), 'w', encoding='utf-8') as log:
        r = subprocess.run([RS, str(H / 'runner.R'), str(H / 'rscripts' / (n + '.R')), str(out)], stdout=log, stderr=subprocess.STDOUT, timeout=900)
    return n, r.returncode
t = time.time()
with concurrent.futures.ThreadPoolExecutor(2) as ex:
    for i, (n, rc) in enumerate(ex.map(one, names), 1):
        if i % 25 == 0: print(i, len(names), round(time.time() - t), flush=True)
print('DONE', len(names), round(time.time() - t), flush=True)
