"""Configurations that returned a fit on the v1.8.0 baseline capture but are
refused by the final engine, with the refusal reasons (review m1 changelog).
python newly_refused.py BASELINE.jsonl FINAL.jsonl OUT.json"""
import collections, json, sys

def load(path):
    with open(path, encoding='utf-8') as f:
        return [json.loads(line) for line in f if line.strip()]

base, final = load(sys.argv[1]), load(sys.argv[2])
assert len(base) == len(final) == 16270, (len(base), len(final))
assert all(b['id'] == f['id'] for b, f in zip(base, final))
changed = [{'id': f['id'], 'reason': f['reason']} for b, f in zip(base, final)
           if b['status'] == 'ok' and f['status'] == 'refused']
recovered = [b['id'] for b, f in zip(base, final) if b['status'] == 'refused' and f['status'] == 'ok']
reworded = [{'id': f['id'], 'before': b['reason'], 'after': f['reason']} for b, f in zip(base, final)
            if b['status'] == f['status'] == 'refused' and b['reason'] != f['reason']]
out = {'baseline': sys.argv[1], 'final': sys.argv[2], 'configurations': len(final),
       'newly_refused': len(changed), 'by_reason': collections.Counter(c['reason'] for c in changed),
       'designs': sorted({c['id'].split('::rho=')[0] for c in changed}),
       'newly_fitted': len(recovered), 'list': changed,
       'refusal_reason_changed': len(reworded),
       'reason_changes': collections.Counter(f"{r['before']} -> {r['after']}" for r in reworded),
       'reworded': reworded}
with open(sys.argv[3], 'w', encoding='utf-8', newline='\n') as f:
    json.dump(out, f, indent=2)
    f.write('\n')
print(json.dumps({k: out[k] for k in ('newly_refused', 'by_reason', 'newly_fitted',
                                      'refusal_reason_changed', 'reason_changes')}))
for d in out['designs']:
    print(' ', d)
