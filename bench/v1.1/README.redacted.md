# P15 integration audit

The source inputs in `<HOST>/p15diag`, `p15fixA`, `p15fixB`, and
`p15invC` are read-only. The main corpus has 16,270 configurations and pins
R's C locale. The supplementary 448-design rho corpus pins
`English_United States.utf8`. See the recorded locale controls and RESULT.md
for the measured differences.

Run the following from this directory. Full captures resume only when the
source hashes match; use a fresh label after a numerical code change.

```powershell
node engine_full.cjs combined
node rho_capture.cjs
$env:P15_CAPTURE = '<HOST>/p15diag/engine-full-allmeta.jsonl'
$env:P15_RULE = 'finite-only'
python compare_engine.py baseline-finite
$env:P15_RULE = 'option-a'
python compare_engine.py baseline-option-a
$env:P15_CAPTURE = 'engine-full-combined.jsonl'
$env:P15_RULE = 'finite-only'
python compare_engine.py final-finite
$env:P15_RULE = 'option-a'
python compare_engine.py final-option-a
python -m unittest test_option_a
python verify_comparator.py
python verify_planted.py
python verify_rho.py
python finalize.py
```

`compare_engine.py` adapts the original comparator's input/output paths and
adds the independently derived Option-A predicate and audit fields. Its
finite-only mode is checked against execution of the original comparator,
with only IO adaptation, on both complete captures. Every original check,
maximum difference and failure must be identical. The original reference
cache helper verifies cached byte hashes and source stamps before use.

`verify_planted.py` uses a one-record subset with a byte-identical reference;
it changes only one output estimate by 2e-9 relative to max(1,abs(R)). It
checks both the unmodified passing control and rejection in each mode.

`rho_capture.cjs` calls the production `rhoSensitivity` API at 0.4 and 0.6.
`P15_ENGINE_ROOT` and `P15_RHO_LABEL` select a baseline source and separate
capture name. The final result and baseline result are different executions,
not duplicate copies. `verify_rho.py` uses the matching label and records
both numerical results and reference coverage. Formatted sensitivity tables
are not substitutes for the full-precision fit checks.

Run the local Node tests from the repository root:

```text
node --test --test-isolation=none rve-meta/tests/*.node.cjs
python -m pytest tests/test_rve.py tests/test_rve_extras.py -q -p no:cacheprovider
```

`browser_check.py` attempts installed Chromium against the actual page/CSP.
On this host Windows denies Chromium process-channel access. The independent
Node page test verifies script loading order, the CSP WebAssembly permission
and browser-global execution, but is not a rendered-browser test.

The patch is built with read-only `git diff` and `git diff --no-index` for
new files; no index/object/commit writes are needed. Full captures stay local
and are excluded from the patch. The patch contains their hashes, compact
results, failure/undefined audits, reproducible scripts and focused fixtures.
