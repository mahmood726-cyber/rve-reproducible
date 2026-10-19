"""Finish the non-browser audit once both resumed engine captures are complete."""
from pathlib import Path
import csv
import hashlib
import json
import subprocess
import sys
import time
import zipfile

load = lambda p: json.loads(Path(p).read_text(encoding='utf-8'))
ledger = list(csv.DictReader(open('configuration-ledger.csv', encoding='utf-8')))
total = len(ledger)
commands = load('resume-commands.json') if '--finalize-only' in sys.argv else []

def checkpoint(message):
    with Path('PROGRESS.md').open('a', encoding='utf-8') as f:
        f.write('\n' + message + '\n')
    print(message, flush=True)

def run(args):
    started = time.time()
    result = subprocess.run(args, capture_output=True, text=True, encoding='utf-8', errors='replace')
    record = dict(command=' '.join(args), exit_code=result.returncode,
                  elapsed_seconds=round(time.time()-started, 3), stdout=result.stdout, stderr=result.stderr)
    commands.append(record)
    Path('resume-commands.json').write_text(json.dumps(commands, indent=2), encoding='utf-8')
    checkpoint(record['command'] + ': exit ' + str(result.returncode) + '\n' + result.stdout.strip())
    if result.returncode:
        raise RuntimeError(record)

if '--wait' in sys.argv:
    deadline = time.monotonic() + 7200
    while True:
        counts = {v: Path(f'engine-full-{v}.jsonl').read_bytes().count(b'\n') for v in ['original', 'patched']}
        print('Waiting for complete captures:', counts, flush=True)
        if all(n == total for n in counts.values()):
            break
        if time.monotonic() >= deadline:
            raise RuntimeError('Engine wait exceeded two hours; existing captures preserved')
        time.sleep(30)

for v in ['original', 'patched']:
    count = Path(f'engine-full-{v}.jsonl').read_bytes().count(b'\n')
    if count != total:
        raise RuntimeError(f'{v} incomplete: {count}/{total}; wait for existing worker')

steps = [
    ['python', 'verify_metadata.py'],
    ['python', 'dataset_ledger.py'],
    ['python', 'compare_engine.py', 'original'],
    ['python', 'compare_engine.py', 'patched'],
    ['python', 'diagnose_failures.py'],
    ['python', 'review_final.py'],
    ['python', 'report.py'],
]
if '--finalize-only' in sys.argv:
    steps = steps[-2:]
for args in steps:
    run(args)

review = load('review.json')
failed_review = [r for r in review if not r['pass_']]
text = ['# Job 17 resume result', '',
        '**Non-browser audit completed; strict numerical failures and deferred browser validation remain blockers.** No tolerance waivers, regenerated datasets, commits or pushes. The source clone was not edited.', '',
        '| Command | Exact result |', '|---|---|',
        f'| `python run_references.py` | Exit 0; {total}/{total} reference files already present; 0 recomputed |',
        f'| `python reference_cache.py` | {total}/{total} existing reference byte hashes and source stamps verified; 0 fits recomputed |']
for v, old in [('original', 10397), ('patched', 10389)]:
    er = load(f'engine-results-{v}.json')
    br = load(f'results-{v}.json')
    text += [f'| `node engine_full.cjs {v} --extend` | {er["captured"]}/{total} captures; {er["captured"]-old} appended to existing {old} |',
             f'| `python compare_engine.py {v}` | {er["passes"]}/{er["checks"]} pass; {er["failures"]} fail |',
             f'| `python compare.py {v}` | {br["passes"]}/{br["checks"]} pass; {br["failures"]} fail; {br["app_records"]}/{total} browser captures |']
mi = load('metadata-integrity.json')
dl = load('dataset-ledger.json')
text += [f'| `python verify_metadata.py` | {sum(r["passed"] for r in mi)}/{len(mi)} pass |',
         f'| `python dataset_ledger.py` | {sum(r["status"]=="included" for r in dl)} included; {sum(r["status"]=="excluded" for r in dl)} excluded datasets |']
diagnosis = load('strict-diagnosis.json')
text += ['| `python diagnose_failures.py` | ' + '; '.join(f'{v}: {d["failed_checks"]} failed checks across {d["failed_configurations"]} cases' for v,d in diagnosis.items()) + ' |',
         f'| `python review_final.py` | {sum(r["pass_"] for r in review)}/{len(review)} integrity checks pass; {len(failed_review)} fail |',
         '| `python report.py` | Exit 0; blocked-browser report generated in RESULTS.md and results.json |',
         '| `python package_artifacts.py` | PACKAGE_COUNT_PENDING files in rve-validation.zip; SHA-256 manifest included |', '',
         'The comparison scripts report failed checks in their JSON output even when their process exit code is 0. Final-review failures:', '']
text += ['- ' + r['name'] for r in failed_review]
text += ['', 'Still unrun: the host Playwright command in BROWSER_TODO.md; all real browser parser, display, control and export tests. The browser comparison commands above executed against missing captures and do not count as browser execution. After the host supplies evidence, rerun the comparisons, review and report and refresh this summary/archive.', '',
         'Strict numerical failures are diagnosed in STRICT_DIAGNOSIS.md and strict-diagnosis.json, with full unaltered failures in engine-failures-full-original.json and engine-failures-full-patched.json. Detailed scope, limitations and before/after tables are in RESULTS.md. Proposed app changes are in fix.patch.', '',
         '| Item | Static or dynamic |', '|---|---|',
         '| Rho grid and strict tolerances | Static task requirements |',
         '| Eligibility and diagnostic labels | Static disclosed audit rules |',
         '| Counts, fit results and provenance hashes | Dynamic on-disk evidence and execution |', '']
Path('RESULT.md').write_text('\n'.join(text), encoding='utf-8')
checkpoint('Final comparison, diagnosis, integrity review and blocked-browser report completed. RESULT.md written; packaging next.')
package = subprocess.run(['python', 'package_artifacts.py'], capture_output=True, text=True)
print(package.stdout, flush=True)
Path('packaging-execution.json').write_text(json.dumps(dict(command='python package_artifacts.py', exit_code=package.returncode, stdout=package.stdout, stderr=package.stderr), indent=2), encoding='utf-8')
if package.returncode:
    raise RuntimeError(package.stderr)
with zipfile.ZipFile('rve-validation.zip') as z:
    manifest = json.loads(z.read('artifact-manifest.json'))
    checked = sum(hashlib.sha256(z.read(name)).hexdigest() == digest for name, digest in manifest.items())
    assert checked == len(manifest)
    assert z.testzip() is None
    validation = dict(archive_files=len(z.namelist()), hashes_checked=checked, hash_failures=0, crc_failures=0)
Path('archive-verification.json').write_text(json.dumps(validation, indent=2), encoding='utf-8')
checkpoint('Archive verified: ' + json.dumps(validation) + '. Browser remains delegated to host; strict failures retained without waivers.')
