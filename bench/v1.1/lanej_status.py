"""Lane J corpus status: v1.8.0 baseline -> PR head 8ad97fa ('final') -> lane J
('final-j'), under both comparator rules, plus record identity of the lane J
capture against the 8ad97fa capture. Run after compare_engine.py has written
engine-*-final-j-{finite,option-a}.json.  ->  lanej-status.json"""
from pathlib import Path
import hashlib
import json

H = Path(__file__).resolve().parent
read = lambda p: json.loads(Path(p).read_text(encoding='utf-8'))
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
out = {'rules': {}}
for rule in ['finite', 'option-a']:
    res = {k: read(H / f'engine-results-{v}-{rule}.json') for k, v in
           [('v1.8.0', 'baseline'), ('8ad97fa', 'final'), ('lane-j', 'final-j')]}
    fails = {k: {x['id'] for x in read(H / f'engine-failures-full-{v}-{rule}.json')} for k, v in
             [('v1.8.0', 'baseline'), ('8ad97fa', 'final'), ('lane-j', 'final-j')]}
    for r in res.values():
        assert r['configurations'] == r['captured'] == 16270
    out['rules'][rule] = {
        'passing': {k: r['passing_configurations'] for k, r in res.items()},
        'failed_checks': {k: r['failures'] for k, r in res.items()},
        'checks': {k: r['checks'] for k, r in res.items()},
        'newly_failing_vs_v1.8.0': sorted(fails['lane-j'] - fails['v1.8.0']),
        'fixed_vs_v1.8.0': len(fails['v1.8.0'] - fails['lane-j']),
        'newly_failing_vs_8ad97fa': sorted(fails['lane-j'] - fails['8ad97fa']),
        'fixed_vs_8ad97fa': sorted(fails['8ad97fa'] - fails['lane-j']),
    }
pr = (H / 'engine-full-combined.jsonl').read_text(encoding='utf-8').splitlines()
lj = (H / 'engine-full-final-j.jsonl').read_text(encoding='utf-8').splitlines()
assert len(pr) == len(lj) == 16270
same = sum(a == b for a, b in zip(pr, lj))
out['capture_identity'] = {
    'records': len(lj), 'byte_identical_records': same,
    'differing_ids': [json.loads(b)['id'] for a, b in zip(pr, lj) if a != b],
    '8ad97fa_capture_sha256': sha(H / 'engine-full-combined.jsonl'),
    'lane_j_capture_sha256': sha(H / 'engine-full-final-j.jsonl'),
    'lane_j_meta': read(H / 'engine-full-final-j-meta.json'),
}
(H / 'lanej-status.json').write_text(json.dumps(out, indent=2) + '\n', encoding='utf-8')
for rule, r in out['rules'].items():
    print(rule, r['passing'], 'newly failing vs v1.8.0:', len(r['newly_failing_vs_v1.8.0']),
          'vs 8ad97fa:', len(r['newly_failing_vs_8ad97fa']), 'fixed vs 8ad97fa:', len(r['fixed_vs_8ad97fa']))
print('byte-identical records', same, '/', len(lj))
