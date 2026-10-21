"""A one-record capture avoids duplicating the full corpus for the 2e-9 plant."""
from pathlib import Path
import copy
import csv
import json
import os
import subprocess
import sys

here = Path(__file__).resolve().parent
D = Path('<HOST>/p15diag')
key = 'dat.bauer2002::001::study::year::rho=0'
with (here/'engine-full-combined.jsonl').open() as stream:
    for index, line in enumerate(stream, 1):
        a = json.loads(line)
        if a['id'] == key:
            break
    else:
        raise AssertionError('Plant target missing')
source = here/'planted-source'
(source/'reference').mkdir(parents=True, exist_ok=True)
raw = (D/f'reference/{index:06d}.json').read_bytes()
(source/'reference/000001.json').write_bytes(raw)
with (source/'configuration-ledger.csv').open('w',newline='',encoding='utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['id'])
    writer.writerow([key])
r = json.loads(raw)
changed = copy.deepcopy(a)
delta = 2e-9 * max(1,abs(r['table'][0]['b.r']))
changed['summary'][0]['estimate'] += delta
result = dict(id=key, coefficient=0, quantity='estimate', before=a['summary'][0]['estimate'],
              after=changed['summary'][0]['estimate'], delta=delta, reference=r['table'][0]['b.r'], rules={})
for name, record in [('control',a),('planted',changed)]:
    capture = here/f'{name}-one.jsonl'
    capture.write_text(json.dumps(record)+'\n')
    for rule in ['finite-only','option-a']:
        label = f'{name}-{rule}'
        env = dict(os.environ,P15_SOURCE=str(source),P15_CAPTURE=str(capture),P15_RULE=rule)
        p = subprocess.run([sys.executable,'compare_engine.py',label],cwd=here,env=env,capture_output=True,text=True,check=True)
        report = json.loads((here/f'engine-results-{label}.json').read_text())
        failures = json.loads((here/f'engine-failures-full-{label}.json').read_text())
        assert report['captured'] == 1
        assert report['passing_configurations'] == (1 if name=='control' else 0)
        if name == 'planted':
            assert any(f['quantity']=='estimate' and f['difference']>1e-9 for f in failures)
        result['rules'][label] = dict(passing=report['passing_configurations'], failures=failures)
(here/'planted-result.json').write_text(json.dumps(result,indent=2))
print('Unmodified control passes; planted 2e-9 estimate defect rejected in both modes.')
