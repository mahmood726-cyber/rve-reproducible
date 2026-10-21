"""Option A comparator rule (bench/v1.1/RULE_OPTION_A.md): both-undefined counts as agreement ONLY when the app and R
are undefined for the SAME reason.

The numeric tolerance is unchanged: 1e-9, absolute for p and CI limits, relative to max(1, |R|) otherwise. Exact
checks and the refusal-category comparison are unchanged. Each side's reason code is derived from that side's own
record and coefficient only, never from the other side:
  app        -> its own summary se and df
  robumeta   -> that coefficient's SE and dfs
  club       -> that coefficient's clubSandwich SE and df_Satt (never robumeta's fields)
Ordered taxonomy for an undefined value (null or non-finite number):
  REFUSED:<category>  the side refused the fit
  DF_NONPOSITIVE      undefined df, or undefined p/CI with that side's df non-finite, null or <= 0
  SE_ZERO             undefined t or p with that side's SE exactly 0
  OTHER_NONFINITE     anything else
A finite value has no reason. Finite against undefined always fails. Non-numeric strings are invalid, not undefined.
Mode 'finite-only' is the 1.0.0 predicate: a numeric check passes only if both values are finite and within tolerance.
The predicate is the integration lane's bench/v1.1/option_a.py. This copy adds the docstring, RULES and a guard
that rejects an unknown mode.
"""
import math

RULES = ('finite-only', 'option-a')


def finite(x):
    return isinstance(x, (float, int)) and math.isfinite(x)


def undefined(x):
    return x is None or isinstance(x, (float, int)) and not math.isfinite(x)


def category(reason):
    s = reason.lower()
    if 'm<=p' in s:
        return 'insufficient clusters'
    if 'singular' in s or 'rank deficien' in s:
        return 'rank deficiency'
    if 'no rows' in s or 'no valid rows' in s:
        return 'no rows'
    return s


def reason(value, quantity, record, coefficient, source):
    if not undefined(value):
        return None
    if record['status'] == 'refused':
        return 'REFUSED:' + category(record['reason'])
    if source == 'app':
        row = record['summary'][coefficient] if coefficient is not None else {}
        se, df = row.get('se'), row.get('df')
    elif source == 'robumeta':
        row = record['table'][coefficient] if coefficient is not None else {}
        se, df = row.get('SE'), row.get('dfs')
    elif source == 'club':
        def field(name):
            v = record['club'].get(name)
            return v[coefficient] if isinstance(v, list) else v
        se, df = field('SE'), field('df_Satt')
    else:
        raise ValueError(source)
    if quantity == 'df' or quantity in ('p', 'ci_lo', 'ci_hi') and (not finite(df) or df <= 0):
        return 'DF_NONPOSITIVE'
    if quantity in ('t', 'p') and se == 0:
        return 'SE_ZERO'
    return 'OTHER_NONFINITE'


def numeric_check(x, y, scale, rule, reason_app, reason_R):
    assert rule in RULES, rule
    both_finite = finite(x) and finite(y)
    d = abs(x - y) / (max(1, abs(y)) if scale == 'relative' else 1) if both_finite else None
    ok = both_finite and d <= 1e-9
    if rule == 'option-a' and undefined(x) and undefined(y):
        ok = reason_app is not None and reason_app == reason_R
    return ok, d
