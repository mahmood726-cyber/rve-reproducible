"""Execute the original comparator with only IO paths adapted, then compare every check."""
from pathlib import Path
import hashlib
import json
import os
import sys
from reference_cache import load_cache

here=Path(__file__).resolve().parent
D=Path('<HOST>/p15diag')
source=(D/'compare_engine.py').read_text()
original_hash=hashlib.sha256((D/'compare_engine.py').read_bytes()).hexdigest()
os.chdir(D)
cache=load_cache()
os.chdir(here)
cache={(D/k).as_posix():v for k,v in cache.items()}
# No numerical, exact, status, or refusal comparison is changed below.
source=source.replace('cache=load_cache()', 'cache=verified_cache')
source=source.replace("open('configuration-ledger.csv',encoding='utf-8')", "open(D/'configuration-ledger.csv',encoding='utf-8')")
source=source.replace("Path('reference',f'{i:06d}.json')", "D/'reference'/f'{i:06d}.json'")
source=source.replace("Path(f'engine-full-{variant}.jsonl')", 'original_capture')
proof=[]
for variant,capture in [('baseline',D/'engine-full-allmeta.jsonl'),('final',here/'engine-full-combined.jsonl')]:
    sys.argv=['compare_engine.py', 'original-'+variant]
    exec(compile(source,str(D/'compare_engine.py'),'exec'),
         dict(D=D,verified_cache=cache,original_capture=capture))
    original=json.loads((here/f'engine-results-original-{variant}.json').read_text())
    current=json.loads((here/f'engine-results-{variant}-finite.json').read_text())
    for k in ['configurations','captured','checks','passes','quantities','failures']:
        assert original[k]==current[k], (variant,k)
    old=json.loads((here/f'engine-failures-full-original-{variant}.json').read_text())
    new=json.loads((here/f'engine-failures-full-{variant}-finite.json').read_text())
    assert old==[{k:f[k] for k in ['id','quantity','app','reference','difference']} for f in new]
    proof.append(dict(variant=variant,checks=original['checks'],all_checks_and_failures_identical=True))
report=dict(original_comparator_sha256=original_hash,verified_reference_bytes=len(cache),results=proof)
(here/'comparator-equivalence.json').write_text(json.dumps(report,indent=2))
print('Original and lane finite-only comparators agree on every check for both complete captures.')
