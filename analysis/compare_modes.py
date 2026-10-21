"""Direct-engine comparator with two modes: finite-only (the 1.0.0 predicate) and option-a (analysis/option_a.py).

The comparison logic is that of the integration lane's comparator (bench/v1.1/compare_engine.redacted.py), which
itself adapts only the IO of the unmodified bench/compare_engine.py and adds the Option A predicate and audit fields.
Here only the IO is adapted again: captures and references are read from the archive (xz), nothing is written
unless an output directory is given.
Usage: python analysis/compare_modes.py <capture (.jsonl or .jsonl.xz, archive-relative)> <variant> <finite-only|option-a> [out-dir]
"""
import collections, csv, io, json, lzma, sys
from pathlib import Path
from option_a import RULES, category, reason, undefined, numeric_check

ROOT = Path(__file__).resolve().parent.parent


def read_lines(rel):
    raw = (ROOT / rel).read_bytes()
    if str(rel).endswith('.xz'):
        raw = lzma.decompress(raw)
    return raw.decode('utf-8').splitlines()


def archived_references():
    return [json.loads(l) for l in read_lines('results/reference/r-reference.jsonl.xz')]


def ledger_keys():
    return [r['id'] for r in csv.DictReader(io.StringIO((ROOT / 'data/configuration-ledger.csv').read_text(encoding='utf-8')))]


def compare(capture_lines, references, keys, rule, variant):
    """references[i] is the R reference for keys[i] (None if absent). Returns (result, failures, undefined_checks)."""
    assert rule in RULES, rule
    undefined_checks, fail = [], []
    stats = collections.defaultdict(lambda: dict(checks=0, passes=0, max_difference=0))
    st = dict(coefficient=None, a=None, r=None)

    def check(key, q, x, y, mode='relative'):
        d = 0; ra = rr = None
        if mode == 'exact':
            ok = x == y
        else:
            quantity = q.removeprefix('club_')
            ra = reason(x, quantity, st['a'], st['coefficient'], 'app')
            rr = reason(y, quantity, st['r'], st['coefficient'], 'club' if q.startswith('club_') else 'robumeta')
            ok, d = numeric_check(x, y, mode, rule, ra, rr)
            if undefined(x) or undefined(y):
                undefined_checks.append(dict(id=key, quantity=q, coefficient=st['coefficient'], app=x, reference=y,
                                             reason_app=ra, reason_R=rr, passed=ok))
        s = stats[q]; s['checks'] += 1; s['passes'] += int(ok)
        if d is not None:
            s['max_difference'] = max(s['max_difference'], d)
        if not ok:
            fail.append(dict(id=key, quantity=q, app=x, reference=y, difference=d, coefficient=st['coefficient'],
                             reason_app=ra, reason_R=rr))

    n = 0
    for i, line in enumerate(capture_lines, 1):
        a = json.loads(line); st['a'] = a; n = i; key = keys[i - 1]
        check(key, 'key', a['id'], key, 'exact')
        r = references[i - 1] if i - 1 < len(references) else None
        check(key, 'reference_present', r is not None, True, 'exact')
        if r is None:
            continue
        st['r'] = r
        check(key, 'reference_key', r['id'], key, 'exact'); check(key, 'status', a['status'], r['status'], 'exact')
        if a['status'] == 'refused' and r['status'] == 'refused':
            check(key, 'refusal_category', category(a['reason']), category(r['reason']), 'exact')
        if a['status'] != 'ok' or r['status'] != 'ok':
            continue
        st['coefficient'] = None
        fit = a['fit']; check(key, 'tau2', fit['tau2'], r['tau2']); check(key, 'method', fit['method'], 'CR2', 'exact')
        for q, k in [('n', 'k_total'), ('m', 'm_clusters'), ('p', 'p')]:
            check(key, 'design_columns' if q == 'p' else q, fit[k], r[q], 'exact')
        check(key, 'coefficient_count', len(a['summary']), len(r['table']), 'exact')
        for j, (s, t) in enumerate(zip(a['summary'], r['table'])):
            st['coefficient'] = j
            for aq, rq in [('estimate', 'b.r'), ('se', 'SE'), ('t', 't'), ('df', 'dfs'), ('p', 'prob'), ('ci_lo', 'CI.L'), ('ci_hi', 'CI.U')]:
                check(key, aq, s[aq], t[rq], 'absolute' if aq in ['p', 'ci_lo', 'ci_hi'] else 'relative')
            cb = r['club']; check(key, 'club_reference_success', 'error' not in cb, True, 'exact')
            if 'error' not in cb:
                for aq, rq in [('estimate', 'beta'), ('se', 'SE'), ('t', 'tstat'), ('df', 'df_Satt'), ('p', 'p_Satt')]:
                    v = cb[rq]; v = v[j] if isinstance(v, list) else v
                    check(key, 'club_' + aq, s[aq], v, 'absolute' if aq == 'p' else 'relative')
    for key in keys[n:]:
        check(key, 'app_present', False, True, 'exact')
    result = dict(variant=variant, rule=rule, scope='direct shipped engine; not browser/display/export validation',
                  configurations=len(keys), captured=n, checks=sum(s['checks'] for s in stats.values()),
                  passes=sum(s['passes'] for s in stats.values()), quantities=dict(stats))
    result['failures'] = result['checks'] - result['passes']
    result['passing_configurations'] = len(keys) - len({f['id'] for f in fail})
    return result, fail, undefined_checks


if __name__ == '__main__':
    capture, variant, rule = sys.argv[1:4]
    res, fl, und = compare(read_lines(capture), archived_references(), ledger_keys(), rule, variant)
    if len(sys.argv) > 4:
        out = Path(sys.argv[4]); out.mkdir(parents=True, exist_ok=True)
        for name, obj in [(f'engine-results-{variant}.json', res), (f'engine-failures-full-{variant}.json', fl), (f'undefined-{variant}.json', und)]:
            (out / name).write_text(json.dumps(obj, indent=2), encoding='utf-8', newline='\n')
    print(f"{variant} ({rule}): {res['passes']}/{res['checks']} checks; {res['passing_configurations']}/{res['configurations']} configurations")
