"""Recheck all 448 immutable supplementary rho references at the same gate."""
from pathlib import Path
import collections
import hashlib
import json
import os
from option_a import category, reason, numeric_check, undefined

HERE = Path(__file__).resolve().parent
D = Path('<HOST>/p15diag')
read = lambda p: json.loads(p.read_text(encoding='utf-8'))
samples = read(D/'rho_work/rho_sample.json')
label = os.environ.get('P15_RHO_LABEL', 'rho')
captures = [json.loads(x) for x in (HERE/f'{label}-engine.jsonl').read_text().splitlines()]
assert len(samples) == len(captures) == 448
hashes = {}
references = []
for i, s in enumerate(samples, 1):
    p = D/f'rho_work/rho_ref_v3/{i:04d}.json'
    raw = p.read_bytes()
    hashes[p.name] = hashlib.sha256(raw).hexdigest()
    r = json.loads(raw)
    assert r['design'] == s['design']
    references.append(r)

results = {}
for rule in ['finite-only', 'option-a']:
    fails, undefined_checks = [], []
    counts = collections.Counter()
    for sample, captured, ref in zip(samples, captures, references):
        assert captured['design'] == sample['design']
        assert captured['grid'] == [0.4, 0.6]
        assert len(captured['fits']) == 2
        for f, rk in zip(captured['fits'], ['r04', 'r06']):
            r = ref[rk]
            a = dict(status='refused', reason=f['error']) if 'error' in f else dict(status='ok', summary=f['summary'])
            def check(q, x, y, j=None, exact=False):
                ra = rr = None
                if exact:
                    ok, diff = x == y, 0
                else:
                    aq = q.removeprefix('club_')
                    ra = reason(x, aq, a, j, 'app')
                    rr = reason(y, aq, r, j, 'club' if q.startswith('club_') else 'robumeta')
                    ok, diff = numeric_check(x, y, 'absolute' if aq in ('p','ci_lo','ci_hi') else 'relative', rule, ra, rr)
                counts['checks'] += 1
                counts['passes'] += int(ok)
                record = dict(design=sample['design'], rho=f['rho'], quantity=q, coefficient=j,
                              app=x, reference=y, difference=diff, reason_app=ra, reason_R=rr, passed=ok)
                if not exact and (undefined(x) or undefined(y)):
                    undefined_checks.append(record)
                if not ok:
                    fails.append(record)
            check('status', a['status'], r['status'], exact=True)
            if a['status'] == r['status'] == 'refused':
                check('refusal_category', category(a['reason']), category(r['reason']), exact=True)
            if a['status'] != 'ok' or r['status'] != 'ok':
                continue
            check('tau2', f['tau2'], r['tau2'])
            check('coefficient_count', len(f['summary']), len(r['table']), exact=True)
            for j, (s,t) in enumerate(zip(f['summary'],r['table'])):
                for aq,rq in [('estimate','b.r'),('se','SE'),('t','t'),('df','dfs'),('p','prob'),('ci_lo','CI.L'),('ci_hi','CI.U')]:
                    check(aq,s[aq],t[rq],j)
                cb = r['club']
                check('club_reference_success','error' not in cb,True,exact=True)
                if 'error' not in cb:
                    for aq,rq in [('estimate','beta'),('se','SE'),('t','tstat'),('df','df_Satt'),('p','p_Satt')]:
                        v=cb[rq]
                        check('club_'+aq,s[aq],v[j] if isinstance(v,list) else v,j)
    results[rule] = dict(counts, designs=448, passing_designs=448-len({f['design'] for f in fails}),
                         fits=896, passing_fits=896-len({(f['design'],f['rho']) for f in fails}))
    (HERE/f'{label}-failures-{rule}.json').write_text(json.dumps(fails,indent=2))
    (HERE/f'{label}-undefined-{rule}.json').write_text(json.dumps(undefined_checks,indent=2))
results['coverage'] = dict(references=448, expected=448, captures=448,
    successful_R_fits=sum(r[k]['status']=='ok' for r in references for k in ['r04','r06']),
    sensitivity_errors=[s['design'] for s,r in zip(samples,references) if isinstance(r['sens'],dict) and 'error' in r['sens']])
(HERE/'rho-reference-sha256.json').write_text(json.dumps(hashes,indent=2))
(HERE/f'{label}-results.json').write_text(json.dumps(results,indent=2))
print(json.dumps(results,indent=2))
