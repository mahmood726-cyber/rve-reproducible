"""Safeguard tests: each protection in the archive must be able to fail. Exit status non-zero on any failure.
Usage: python analysis/test_safeguards.py   (runs analysis/test_gate.R with Rscript if RSCRIPT or Rscript is available)
"""
import os, shutil, subprocess, sys, tempfile
from pathlib import Path
from archive_rules import ROOT, private_hits

results = []
def check(name, ok):
    results.append(bool(ok)); print(('PASS ' if ok else 'FAIL ') + name, flush=True)

# 1. The validate-time recipe is the R2 recipe: reference_core.R body == bench/reference.R lines 10-26, byte for byte.
ref = (ROOT / 'bench/reference.R').read_bytes().split(b'\n')
core = (ROOT / 'analysis/reference_core.R').read_bytes().split(b'\n')
start = core.index(b'reference_one <- function(c) {') + 1
check('reference_core.R lines are byte-identical to bench/reference.R lines 10-26', core[start:start + 17] == ref[9:26])
check('reference_core.R adds only the return of res', core[start + 17:] == [b" res[['warnings']]<-warnings", b' res', b'}', b''])
check('reference_core.R recipe keeps robu(CORR, small=TRUE) and coef_test(CR2, Satterthwaite)',
      b"modelweights='CORR'" in b'\n'.join(core) and b'small=TRUE' in b'\n'.join(core) and b"vcov='CR2',test='Satterthwaite'" in b'\n'.join(core))

# 2. Worker partition: every configuration exactly once for W = 1 and W = 2 (the rule in validate_worker.R).
src = (ROOT / 'analysis/validate_worker.R').read_text(encoding='utf-8')
check('worker partition rule is the documented modulo rule', 'idx <- which((seq_along(cs) - 1L) %% W == w - 1L)' in src)
for W in (1, 2):
    seen = sorted(i for w in range(1, W + 1) for i in range(1, 16271) if (i - 1) % W == w - 1)
    check(f'partition W={W} covers 16270 configurations once', seen == list(range(1, 16271)))
check('worker forces locale C for all categories', "Sys.setlocale('LC_ALL', 'C')" in src)
v = (ROOT / 'validate.R').read_text(encoding='utf-8')
check('validate.R caps workers at two', 'W <- min(2L,' in v)
check('validate.R refuses an existing work directory', ".validate-work exists" in v)

# 3. materialize.py refuses an existing work directory (no earlier output can seed a run).
with tempfile.TemporaryDirectory() as t:
    r = subprocess.run([sys.executable, str(ROOT / 'analysis/materialize.py'), t], capture_output=True)
    check('materialize.py refuses an existing directory', r.returncode != 0)

# 4. The privacy scan detects a planted host path and address.
with tempfile.TemporaryDirectory() as t:
    p = Path(t) / 'x.md'; p.write_text('ok\nsee C:/Users/someone/file and 100.64.1.2\n', encoding='utf-8')
    check('privacy scan detects planted path and address', len(private_hits(Path(t), ['x.md'])) == 1)
    p.write_text('clean text\n', encoding='utf-8')
    check('privacy scan passes clean text', private_hits(Path(t), ['x.md']) == [])

# 5. R gate tests (versions, inventory, coverage, per-quantity counts, failure digest), each with a planted defect.
rs = os.environ.get('RSCRIPT') or shutil.which('Rscript')
if rs:
    r = subprocess.run([rs, '--vanilla', 'analysis/test_gate.R'], cwd=ROOT, capture_output=True, text=True)
    print(r.stdout.strip())
    check('analysis/test_gate.R: all R gate tests pass', r.returncode == 0)
else:
    check('Rscript available for analysis/test_gate.R (set RSCRIPT)', False)
print(f'{sum(results)}/{len(results)} safeguard tests pass')
sys.exit(0 if all(results) else 1)
