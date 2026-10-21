# P15 integration result

**16,136 of 16,270 at 1e-9 under the finite-only rule; 16,221 of 16,270 at
1e-9 under Option A. Zero newly failing configurations versus the specified
16,270-case baseline, in either mode.** One combined engine is installed in
`shared/rve.js`, with the portable eigen backend loaded by the app.

**Scope limitation:** the separate 448-design rho recheck has one newly
failing fit, Linde 2016 at rho 0.4. Fresh R controls establish a difference
between its English-locale reference and the main corpus's C-locale
contract. Thus the main-baseline zero-regression requirement is met, but
this is **not a claim of zero regressions across both reference tiers**.
The supplemental failure is retained, not waived or counted as a pass.

| Rule, unchanged 1e-9 tolerance | Before | Final | Fixed | Newly failing |
|---|---:|---:|---:|---:|
| Finite-only | 15,485 / 16,270 | **16,136 / 16,270** | 651 | **0** |
| Option A | 15,520 / 16,270 | **16,221 / 16,270** | 701 | **0** |

The exhaustive changed-status lists are
[finite-only CSV](audit/p15-integration/changed-status-finite.csv) and
[Option-A CSV](audit/p15-integration/changed-status-option-a.csv), with JSON
counterparts whose `newly_failing` arrays are both empty. The final capture
contains all 16,270 independently executed fits in ledger order.
[Final verification](audit/p15-integration/final-verification.json) and
[provenance](audit/p15-integration/provenance.json) record counts, source and
capture hashes, and the baseline's identity with this checkout's HEAD.

The implementation combines lane A's stable C-locale factor ordering,
64-significand-bit extended sum, and corrected mean with lane B's corrected
DSYEVR/DGEEV WebAssembly backend and complex-refusal precedence. Caller rows
remain unchanged and returned weights retain caller order. The existing
Student-t helper, inverse-square-root cutoff, references, and 1e-9 gate are
unchanged. The page loads the backend before the engine and permits its
WebAssembly compilation in CSP. No dataset-specific branch, reference
lookup, oracle substitution, SE floor, or blended reference value enters
the production engine. No git writes were performed.

Option A is implemented in this lane's comparator copy using each side's
own SE and df. Club comparisons use that coefficient's clubSandwich SE and
df_Satt, independently of robumeta. Null/nonfinite pairs pass only with
equal reason codes; finite-versus-undefined and invalid strings fail.
Every undefined comparison, passing or failing, retains both reasons and
the coefficient index in the `undefined-*.json` audits. The finite-only
mode preserves the former predicate. Executing the original comparator
with only IO paths adapted reproduces **every check, maximum difference,
and failure** on both the baseline and final captures:
[equivalence proof](audit/p15-integration/comparator-equivalence.json).

The finite-only result has 134 failed configurations: 85 undefined-result
cases and 49 R-reference disagreements. All 85 undefined cases pass Option
A with independently matching reasons. The remaining 49 fail **only
clubSandwich checks**; all robumeta checks pass under Option A.

| Documented residual group | Configurations | Measured R-versus-R example |
|---|---:|---|
| Disjoint single-quantity acceptance intervals | 11 | Besson, dam_ID/photoperiod, rho .2, df[0]: robumeta 61.61264930150112 versus clubSandwich 1.0017747750229908; absolute gap **60.61087452647813**, summed interval radii 6.261442407652412e-8. |
| Disjoint joint inference constraints | 19 | Steurer 001, author/year, rho 0, df[1]: 1.058336793054193 versus 1.058336791792225; relative gate difference **1.1924066831359533e-9**. The proof also uses the joint SE, df and CI constraints. |
| Measured numerical sensitivity, without an impossibility proof | 19 | Steurer 002, author/year, rho 0, t[1]: 7.294438865431318 versus 7.294438873420561; relative gate difference **1.0952512158289136e-9**. |

The first 30 have documented incompatible constraints. The last 19 are
measured R-side sensitivity, **not proof that no internally consistent
compromise could pass**. Their failures remain in the score. All 49 IDs,
individual R-versus-R measurements, joint interval evidence, and available
controlled R reruns are in
[residual-evidence.json](audit/p15-integration/residual-evidence.json).
The evidence comes from DIAG and lane C; lane C's 12 diagnostic tests were
rerun successfully. For example, its reverse-order control changes Steurer
001's upper CI by 4.253345764482219e-7 and Steurer 002's club t by
3.851990185926504e-9 on the relative gate.

**Supplementary rho recheck:** reference coverage **448/448**, captured
designs **448/448**, and successful R reference fits **896/896**. The
production `rhoSensitivity` API was freshly executed at rho 0.4 and 0.6.
Coverage and numerical agreement are reported separately.

| Rho rule | Baseline passing designs | Final passing designs | Final passing fits |
|---|---:|---:|---:|
| Finite-only | 421 / 448 | **442 / 448** | 886 / 896 |
| Option A | 422 / 448 | **443 / 448** | 888 / 896 |

Both modes fix 42 supplemental fits and newly fail one:
`dat.linde2016::001::author::year`, rho 0.4, upper CI[0]. Its final
absolute error against the English-locale archive is 1.6199166452679492e-9.
Fresh R 4.6.0 / robumeta 2.1 / clubSandwich 0.7.0 controls reproduce the
English archive exactly and measure:

- R C-locale upper CI: **38.60824466095785**.
- R English-locale upper CI: **38.608244662580475**.
- R-versus-R absolute difference: **1.6226238130911952e-9**.
- Final engine versus R C-locale difference: **2.7071678232459817e-12**.

The De Bruin year design also crosses the gate between locales: its upper
CI changes by 1.7051149825419998e-8 at both rho values. It was already failing
in the baseline. Remaining supplemental failures are Besson, Roever and
Ursino club-reference disagreements, plus Lloyd's undefined case only in
finite-only mode. No alternate-locale result replaces any reference or
production output. See [rho results](audit/p15-integration/rho-results.json),
[rho status changes](audit/p15-integration/rho-changed-status.json), and
[fresh R locale proof](audit/p15-integration/rho-locale-proof.json).
All 448 reference byte hashes are retained. Five archived formatted
`sensitivity()` tables contain errors, including four resource-limit
errors; these are not counted as successful table reproductions. The
numbers above compare the full-precision fits, not rounded strings.

**Planted defect:** the previously failing Bauer configuration passes after
integration. Increasing only its captured estimate[0] by
`2e-9 * max(1, abs(R estimate))` is **rejected in both modes**, while its
unmodified control passes both. A one-record capture and byte-identical
reference subset avoid duplicating the full JSONL:
[planted-result.json](audit/p15-integration/planted-result.json).

**Tests before/after:**

- Before integration: nine A/B Node reproducer tests, **7 failed, 2 skipped,
  0 passed**; the two skips concern arithmetic helpers absent in baseline.
- Combined arithmetic/eigen/refusal tests: **15/15 passed**. The arithmetic
  suite includes 505 installed-R vectors, 1,010 bit-exact sum/mean checks.
- Page wiring test: **failed before**, then passed after the script/CSP fix.
- Final Node suite: **16/16 passed**, no skips or failures.
- Option-A unit tests: **4/4 passed** after the initial missing-module failure.
- Existing Python RVE/extras tests: **19/19 passed**.
- Existing lane C diagnostic tests: **12/12 passed**.
- Generated eigen bundle rebuild: byte-identical to the full-run hash.

Logs are under [audit/p15-integration](audit/p15-integration/). Installed
Chromium could not launch because Windows denied process-channel access.
The browser-global VM and page script/CSP test pass; a rendered browser run
is **not claimed**. The reproducible browser smoke test and failed-launch
log are retained.

Reproduction commands are in
[the audit README](audit/p15-integration/README.md). The single deliverable
patch is [p15-final.patch](../p15-final.patch), assembled from read-only git
diffs of this `allmeta` tree, including new source, tests and compact audit
files. Large execution captures remain local and are identified by hashes;
no duplicate full-run JSONL copy is included. Inputs in the other lanes
remain read-only.

LANE DONE
