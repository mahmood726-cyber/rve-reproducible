"""Option A safeguards: the rule's unit cases and planted must-fail checks on real archived records.
Exit status non-zero on any failure. Usage: python analysis/test_option_a.py

Planted checks (each on one configuration with its archived R reference, run through analysis/compare_modes.py):
  - app null where R has a number          -> must fail in both modes
  - R null where the app has a number       -> must fail in both modes
  - both null with DIFFERENT reasons        -> must fail in both modes (app side and R side planted separately)
  - both null with the SAME reason          -> control: passes Option A, fails finite-only
  - 2e-9 relative change to one estimate    -> must fail in both modes (unmodified control passes both)
"""
import copy, json, math, sys
from compare_modes import archived_references, compare, ledger_keys, read_lines
from option_a import numeric_check, reason

results = []
def check(name, ok):
    results.append(bool(ok)); print(('PASS ' if ok else 'FAIL ') + name, flush=True)

# 1. unit cases (bench/v1.1/test_option_a.py, same assertions)
for mode in ['finite-only', 'option-a']:
    check(f'{mode}: finite gate unchanged', numeric_check(1, 1, 'relative', mode, None, None)[0]
          and not numeric_check(1 + 2e-9, 1, 'relative', mode, None, None)[0] and not numeric_check(100 + 2e-9, 100, 'absolute', mode, None, None)[0])
check('option-a: same reason passes; finite-only rejects', numeric_check(None, math.nan, 'relative', 'option-a', 'SE_ZERO', 'SE_ZERO')[0]
      and not numeric_check(None, None, 'relative', 'finite-only', 'SE_ZERO', 'SE_ZERO')[0])
check('option-a: different reasons fail', not numeric_check(None, None, 'relative', 'option-a', 'SE_ZERO', 'OTHER_NONFINITE')[0])
check('option-a: undefined versus finite fails', not numeric_check(None, 0, 'relative', 'option-a', 'SE_ZERO', None)[0])
check('option-a: strings are invalid, not undefined', not numeric_check('NaN', 'NaN', 'relative', 'option-a', None, None)[0])
check('option-a: two missing reasons never pass', not numeric_check(None, None, 'relative', 'option-a', None, None)[0])
app = lambda se=0, df=2, status='ok': dict(status=status, reason='RVE: m<=p; insufficient clusters for inference', summary=[dict(se=se, df=df)])
check('reason priority: DF_NONPOSITIVE before SE_ZERO; SE_ZERO only for exact zero',
      reason(None, 'p', app(df=0), 0, 'app') == 'DF_NONPOSITIVE' and reason(None, 't', app(), 0, 'app') == 'SE_ZERO'
      and reason(None, 't', app(se=1e-300), 0, 'app') == 'OTHER_NONFINITE' and reason(None, 'p', app(status='refused'), 0, 'app') == 'REFUSED:insufficient clusters')
r = dict(status='ok', table=[dict(SE=0, dfs=None), dict(SE=0, dfs=0)], club=dict(SE=[1, 0], df_Satt=[3, 4]))
check('reason: club uses only its own coefficient', reason(None, 'p', r, 0, 'robumeta') == 'DF_NONPOSITIVE'
      and reason(None, 'p', r, 0, 'club') == 'OTHER_NONFINITE' and reason(None, 'p', r, 1, 'club') == 'SE_ZERO')

# 2. planted checks on real records
keys, refs = ledger_keys(), archived_references()
cap = read_lines('results/v1.1/engine/engine-full-final-j.jsonl.xz')
find = lambda k: keys.index(k)
def run(line, ref, key, rule):
    res, fl, _ = compare([json.dumps(line) if isinstance(line, dict) else line], [ref], [key], rule, 'plant')
    return res['passing_configurations'], fl

FINITE = 'dat.aloe2013::001::study::(intercept)::rho=0'     # passes both modes, every value finite
UNDEF = 'dat.bakdash2021::001::Author::es.z::rho=0'        # one of the 85: t and p undefined on both sides, both SE_ZERO
BAUER = 'dat.bauer2002::001::study::year::rho=0'
i, u, b = find(FINITE), find(UNDEF), find(BAUER)
for rule in ['finite-only', 'option-a']:
    check(f'{rule}: control {FINITE} passes', run(cap[i], refs[i], FINITE, rule)[0] == 1)
    a = json.loads(cap[i]); a['summary'][0]['t'] = None
    n, fl = run(a, refs[i], FINITE, rule)
    check(f'{rule}: PLANT app null where R has a number -> fails', n == 0 and any(f['quantity'] == 't' and f['app'] is None for f in fl))
    ref = copy.deepcopy(refs[i]); ref['table'][0]['t'] = None
    n, fl = run(cap[i], ref, FINITE, rule)
    check(f'{rule}: PLANT R null where the app has a number -> fails', n == 0 and any(f['quantity'] == 't' and f['reference'] is None for f in fl))
    # both undefined, different reasons: a 5e-324 SE still passes the SE check (difference 5e-324) but makes that
    # side's reason for undefined t OTHER_NONFINITE instead of SE_ZERO
    a = json.loads(cap[u]); a['summary'][0]['se'] = 5e-324
    n, fl = run(a, refs[u], UNDEF, rule)
    check(f'{rule}: PLANT both null, DIFFERENT reasons (app side) -> fails', n == 0 and all(f['app'] is None and f['reference'] is None for f in fl)
          and any(f['quantity'] == 't' and (rule == 'finite-only' or (f['reason_app'], f['reason_R']) == ('OTHER_NONFINITE', 'SE_ZERO')) for f in fl))
    ref = copy.deepcopy(refs[u]); ref['table'][0]['SE'] = 5e-324
    n, fl = run(cap[u], ref, UNDEF, rule)
    check(f'{rule}: PLANT both null, DIFFERENT reasons (R side) -> fails', n == 0 and all(f['app'] is None and f['reference'] is None for f in fl)
          and any(f['quantity'] == 't' and (rule == 'finite-only' or (f['reason_app'], f['reason_R']) == ('SE_ZERO', 'OTHER_NONFINITE')) for f in fl))
    n, fl = run(cap[u], refs[u], UNDEF, rule)
    check(f'{rule}: control both null with the SAME reason ' + ('passes' if rule == 'option-a' else 'fails (finite-only)'),
          n == (1 if rule == 'option-a' else 0) and all(f['reason_app'] == f['reason_R'] == 'SE_ZERO' for f in fl))
    check(f'{rule}: control {BAUER} passes', run(cap[b], refs[b], BAUER, rule)[0] == 1)
    a = json.loads(cap[b]); a['summary'][0]['estimate'] += 2e-9 * max(1, abs(refs[b]['table'][0]['b.r']))
    n, fl = run(a, refs[b], BAUER, rule)
    check(f'{rule}: PLANT 2e-9 relative change to estimate[0] -> fails', n == 0 and {f['quantity'] for f in fl} == {'estimate', 'club_estimate'})

print(f'{sum(results)}/{len(results)} Option A safeguard tests pass')
sys.exit(0 if all(results) else 1)
