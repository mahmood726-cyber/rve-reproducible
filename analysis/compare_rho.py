"""Supplementary rho recheck comparator, both modes, on the archived 448-design captures and references.

The logic is that of the integration lane's bench/v1.1/verify_rho.redacted.py with only the IO adapted: the designs,
references and captures are read from results/v1.1/rho/ and every reference's SHA-256 is checked against
rho-reference-sha256.json. Nothing is written.
Usage: python analysis/compare_rho.py <final-j|baseline>
"""
import collections, hashlib, json, lzma, sys
from pathlib import Path
from option_a import category, reason, numeric_check, undefined

ROOT = Path(__file__).resolve().parent.parent
RHO = ROOT / 'results/v1.1/rho'


def rho_inputs():
    samples = json.loads(lzma.decompress((RHO / 'rho_sample.json.xz').read_bytes()))
    bundle = json.loads(lzma.decompress((RHO / 'rho-reference-bundle.json.xz').read_bytes()))
    hashes = json.loads((RHO / 'rho-reference-sha256.json').read_text(encoding='utf-8'))
    names = [f'{i:04d}.json' for i in range(1, len(samples) + 1)]
    hashes_ok = sorted(bundle) == sorted(hashes) == names and all(
        hashlib.sha256(bundle[n].encode('utf-8')).hexdigest() == hashes[n] for n in names)
    return samples, [json.loads(bundle[n]) for n in names], hashes_ok


def compare(label, samples, references):
    captures = [json.loads(x) for x in (RHO / f'rho-{label}-engine.jsonl').read_text(encoding='utf-8').splitlines()]
    assert len(samples) == len(captures) == len(references) == 448
    results = {}
    for rule in ['finite-only', 'option-a']:
        fails = []
        counts = collections.Counter()
        for sample, captured, ref in zip(samples, captures, references):
            assert ref['design'] == sample['design'] == captured['design'] and captured['grid'] == [0.4, 0.6] and len(captured['fits']) == 2
            for f, rk in zip(captured['fits'], ['r04', 'r06']):
                r = ref[rk]
                a = dict(status='refused', reason=f['error']) if 'error' in f else dict(status='ok', summary=f['summary'])
                def check(q, x, y, j=None, exact=False):
                    if exact:
                        ok = x == y
                    else:
                        aq = q.removeprefix('club_')
                        ra = reason(x, aq, a, j, 'app')
                        rr = reason(y, aq, r, j, 'club' if q.startswith('club_') else 'robumeta')
                        ok = numeric_check(x, y, 'absolute' if aq in ('p', 'ci_lo', 'ci_hi') else 'relative', rule, ra, rr)[0]
                    counts['checks'] += 1
                    counts['passes'] += int(ok)
                    if not ok:
                        fails.append((sample['design'], f['rho'], q, j))
                check('status', a['status'], r['status'], exact=True)
                if a['status'] == r['status'] == 'refused':
                    check('refusal_category', category(a['reason']), category(r['reason']), exact=True)
                if a['status'] != 'ok' or r['status'] != 'ok':
                    continue
                check('tau2', f['tau2'], r['tau2'])
                check('coefficient_count', len(f['summary']), len(r['table']), exact=True)
                for j, (s, t) in enumerate(zip(f['summary'], r['table'])):
                    for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
                        check(aq, s[aq], t[rq], j)
                    cb = r['club']
                    check('club_reference_success', 'error' not in cb, True, exact=True)
                    if 'error' not in cb:
                        for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                            v = cb[rq]
                            check('club_' + aq, s[aq], v[j] if isinstance(v, list) else v, j)
        results[rule] = dict(counts, designs=448, passing_designs=448 - len({x[0] for x in fails}),
                             fits=896, passing_fits=896 - len({x[:2] for x in fails}))
    return results


if __name__ == '__main__':
    s, refs, ok = rho_inputs()
    print('reference hashes', 'ok' if ok else 'MISMATCH')
    print(json.dumps(compare(sys.argv[1], s, refs), indent=2))
