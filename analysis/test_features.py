"""Feature-check safeguards: each planted 2e-9 change to ONE archived engine value must change the replayed count it
belongs to, and must leave the other two checks at their expected values. A control replay (no plant) must equal
expected/features_values.json. Exit status non-zero on any failure. Usage: python analysis/test_features.py"""
import json, sys
from pathlib import Path
from compare_features import run_all, summary

ROOT = Path(__file__).resolve().parent.parent
exp = json.loads((ROOT / 'expected/features_values.json').read_text(encoding='utf-8'))['summary']
results = []
def check(name, ok):
    results.append(bool(ok)); print(('PASS ' if ok else 'FAIL ') + name, flush=True)

key = dict(centring=lambda s: s['centring']['P1'], rscripts=lambda s: s['rscripts']['total'],
           rho=lambda s: s['rho']['groups']['new_refs_04_06'])
for plant in ['centring', 'rscripts', 'rho']:
    s = summary(run_all(plant))
    hit = key[plant](s)
    check(f'plant {plant}: replayed count drops below expected ({hit[0]}/{hit[1]} vs {key[plant](exp)[0]}/{key[plant](exp)[1]})',
          hit[1] == key[plant](exp)[1] and hit[0] < key[plant](exp)[0])
    check(f'plant {plant}: summary no longer equals expected', s != exp)
    check(f'plant {plant}: the other checks are unaffected', all(key[o](s) == key[o](exp) for o in key if o != plant))
check('control: unplanted replay equals expected exactly', summary(run_all(None)) == exp)
print(f'{sum(results)}/{len(results)} feature safeguard checks pass')
sys.exit(0 if all(results) else 1)
