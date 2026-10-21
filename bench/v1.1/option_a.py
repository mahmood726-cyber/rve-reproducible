"""RULE_OPTION_A.md: classify each side independently; keep the 1e-9 gate."""
import math


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
    both_finite = finite(x) and finite(y)
    d = abs(x-y) / (max(1, abs(y)) if scale == 'relative' else 1) if both_finite else None
    ok = both_finite and d <= 1e-9
    if rule == 'option-a' and undefined(x) and undefined(y):
        ok = reason_app is not None and reason_app == reason_R
    return ok, d
