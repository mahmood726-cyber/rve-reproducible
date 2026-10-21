import math
import unittest
from option_a import reason, numeric_check


def app(se=0, df=2, status='ok'):
    return dict(status=status, reason='RVE: m<=p; insufficient clusters for inference',
                summary=[dict(se=se, df=df)])


class OptionATest(unittest.TestCase):
    def test_finite_gate_unchanged(self):
        for mode in ['finite-only', 'option-a']:
            self.assertTrue(numeric_check(1, 1, 'relative', mode, None, None)[0])
            self.assertFalse(numeric_check(1 + 2e-9, 1, 'relative', mode, None, None)[0])
            self.assertFalse(numeric_check(100 + 2e-9, 100, 'absolute', mode, None, None)[0])

    def test_matching_undefined_only_in_option_a(self):
        self.assertTrue(numeric_check(None, math.nan, 'relative', 'option-a', 'SE_ZERO', 'SE_ZERO')[0])
        self.assertFalse(numeric_check(None, None, 'relative', 'finite-only', 'SE_ZERO', 'SE_ZERO')[0])
        self.assertFalse(numeric_check(None, None, 'relative', 'option-a', 'SE_ZERO', 'OTHER_NONFINITE')[0])
        self.assertFalse(numeric_check(None, 0, 'relative', 'option-a', 'SE_ZERO', None)[0])
        self.assertFalse(numeric_check('NaN', 'NaN', 'relative', 'option-a', None, None)[0])

    def test_priority_and_scope(self):
        self.assertEqual(reason(None, 'p', app(df=0), 0, 'app'), 'DF_NONPOSITIVE')
        self.assertEqual(reason(None, 'ci_lo', app(df=None), 0, 'app'), 'DF_NONPOSITIVE')
        self.assertEqual(reason(None, 't', app(), 0, 'app'), 'SE_ZERO')
        self.assertEqual(reason(None, 'p', app(), 0, 'app'), 'SE_ZERO')
        self.assertEqual(reason(None, 't', app(se=1e-300), 0, 'app'), 'OTHER_NONFINITE')
        self.assertEqual(reason(None, 'ci_hi', app(), 0, 'app'), 'OTHER_NONFINITE')
        for q in ['estimate', 'se', 'tau2']:
            self.assertEqual(reason(None, q, app(), 0, 'app'), 'OTHER_NONFINITE')
        self.assertEqual(reason(None, 'df', app(), 0, 'app'), 'DF_NONPOSITIVE')
        self.assertEqual(reason(None, 'p', app(status='refused'), 0, 'app'), 'REFUSED:insufficient clusters')
        self.assertIsNone(reason(1, 'p', app(status='refused'), 0, 'app'))
        self.assertIsNone(reason('NA', 'p', app(), 0, 'app'))

    def test_club_uses_only_its_own_coefficient(self):
        r = dict(status='ok', table=[dict(SE=0, dfs=None), dict(SE=0, dfs=0)],
                 club=dict(SE=[1, 0], df_Satt=[3, 4]))
        self.assertEqual(reason(None, 'p', r, 0, 'robumeta'), 'DF_NONPOSITIVE')
        self.assertEqual(reason(None, 'p', r, 0, 'club'), 'OTHER_NONFINITE')
        self.assertEqual(reason(None, 'p', r, 1, 'club'), 'SE_ZERO')
        r['club'] = dict(SE=0, df_Satt=4)
        self.assertEqual(reason(None, 'p', r, 0, 'club'), 'SE_ZERO')


if __name__ == '__main__':
    unittest.main()
