"""One sequential R invocation; completed reference checkpoints are preserved."""
import os, subprocess, sys
from pathlib import Path
H = Path(__file__).resolve().parent
a, b = map(int, sys.argv[1:3])
env = {k.upper():v for k,v in os.environ.items()}
env.update(R_ENVIRON_USER='NUL', R_LIBS_USER='<HOST>/<RLIB-DIR>/Rlib_dta', R_LIBS='<HOST>/<RLIB-DIR>/Rlib_extra')
logpath = H / f'evidence/generation_{a:04d}_{b:04d}.log'
assert not logpath.exists(), 'Preserve previous raw logs; select a fresh range or log name'
with logpath.open('w', encoding='utf-8') as log:
    p = subprocess.run([r'C:\Program Files\R\R-4.6.0\bin\Rscript.exe', 'rho_ref_v3.R', str(a), str(b)], cwd=H, env=env, stdout=log, stderr=subprocess.STDOUT)
print(logpath.read_text(encoding='utf-8', errors='replace')[-3000:])
print('R exit', p.returncode)
raise SystemExit(p.returncode)
