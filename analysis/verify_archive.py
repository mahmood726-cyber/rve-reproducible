"""Verify the archive without R: inventory, sizes, compression, app bytes, reference bundle, expected values,
private-path scan and release placeholders. With --full, also replays the UNMODIFIED archived comparators
(bench/compare_engine.py, bench/browser/compare.py) on the ARCHIVED references and captures and requires the
archived comparison outputs to be reproduced exactly. Exit status is non-zero on any failure.
Usage: python analysis/verify_archive.py [--full]
"""
import collections, csv, hashlib, io, json, lzma, shutil, subprocess, sys, tempfile
from pathlib import Path
from archive_rules import ROOT, MAX_FILE, MAX_TOTAL, sha256, source_files, private_hits

results = []
def check(name, ok, detail=''):
    results.append((name, bool(ok)))
    print(('PASS ' if ok else 'FAIL ') + name + (f' -- {detail}' if detail else ''), flush=True)

read = lambda rel: json.loads((ROOT / rel).read_text(encoding='utf-8'))
pairs_sha = lambda fl: hashlib.sha256(('\n'.join(sorted(f"{f['id']}\t{f['quantity']}" for f in fl)) + '\n').encode('utf-8')).hexdigest()

# 1. inventory
pins = read('SOURCE_SHA256.json'); files = source_files()
check('inventory: pinned set equals source files', set(pins) == set(files), f'{len(pins)} pinned, {len(files)} present')
bad = [f for f in files if f in pins and sha256(ROOT / f) != pins[f]]
check('inventory: every SHA-256 matches', not bad, ', '.join(bad[:5]))

# 2. sizes (everything except scratch)
top = lambda p: p.relative_to(ROOT).parts[0]
allf = [p for p in ROOT.rglob('*') if p.is_file() and top(p) not in ('.git', '.validate-work') and not top(p).startswith('.verify-')]
big = [p.relative_to(ROOT).as_posix() for p in allf if p.stat().st_size >= MAX_FILE]
total = sum(p.stat().st_size for p in allf)
check('sizes: every file < 90 MB', not big, ', '.join(big))
check('sizes: archive < 500 MB', total < MAX_TOTAL, f'{total / 2**20:.1f} MB in {len(allf)} files')

# 3. compression proof
proof = read('analysis/compression_proof.json')
for rec in proof:
    parts = rec.get('parts', [rec['stored']])
    dec, h, hs, n = lzma.LZMADecompressor(), hashlib.sha256(), hashlib.sha256(), 0
    for part in parts:
        with open(ROOT / part, 'rb') as f:
            while chunk := f.read(1 << 20):
                hs.update(chunk); d = dec.decompress(chunk); h.update(d); n += len(d)
    check(f"xz: {rec['stored']}", dec.eof and hs.hexdigest() == rec['stored_sha256'] and h.hexdigest() == rec['original_sha256']
          and n == rec['original_bytes'] and all(sha256(ROOT / p) == rec.get('part_sha256', {p: rec['stored_sha256']})[p] for p in parts),
          f"{n} bytes in {len(parts)} part(s)")

# 4. page bytes
app = read('app/app-sha256.json'); orig = read('app-original/app-sha256.json')
check('app: shipped page files match app-sha256.json', all(sha256(ROOT / 'app' / f) == h for f, h in app['files'].items()), f"{len(app['files'])} files")
check('app-original: files match app-sha256.json', all(sha256(ROOT / 'app-original' / f) == h for f, h in orig['files'].items()))
ok = True
for f, rec in app['captured_engine_bytes']['files'].items():
    cap = (ROOT / 'bench/captured-engine/patched' / f).read_bytes()
    ok &= hashlib.sha256(cap).hexdigest() == rec['captured_crlf_sha256'] and cap.replace(b'\r\n', b'\n') == (ROOT / 'app' / f).read_bytes()
check('app: captured CRLF engine files equal the committed LF bytes after CRLF->LF', ok)
for v, src in [('patched', 'bench/captured-engine/patched'), ('original', 'app-original')]:
    meta = read(f'results/engine/engine-full-{v}-meta.json')
    check(f'engine {v}: capture meta hashes equal archived engine bytes', all(sha256(ROOT / src / f) == h for f, h in meta['hashes'].items()))

# 5. reference bundle
idx = read('results/reference/reference-index.json')
ledger = list(csv.DictReader(io.StringIO((ROOT / 'data/configuration-ledger.csv').read_text(encoding='utf-8'))))
lines = lzma.decompress((ROOT / 'results/reference/r-reference.jsonl.xz').read_bytes()).split(b'\n')[:-1]
check('references: one line per configuration, keyed and hashed as indexed',
      len(lines) == len(idx) == len(ledger) and all(hashlib.sha256(l + b'\n').hexdigest() == r['sha256'] and r['id'] == c['id'] == json.loads(l)['id']
                                                    for l, r, c in zip(lines, idx, ledger)), f'{len(lines)} references')

# 6. expected values against archived evidence
exp = read('expected/paper_values.json')
for v in ['original', 'patched']:
    er = read(f'results/engine/engine-results-{v}.json'); e = exp['variants'][v]
    fl = json.loads(lzma.decompress((ROOT / 'results/engine/engine-failures-full-original.json.xz').read_bytes())) if v == 'original' else read('results/engine/engine-failures-full-patched.json')
    check(f'expected engine {v}: totals and per-quantity counts equal archived results',
          (e['checks'], e['passes']) == (er['checks'], er['passes']) and all(e['quantities'][q]['checks'] == s['checks'] and e['quantities'][q]['passes'] == s['passes'] for q, s in er['quantities'].items())
          and set(e['quantities']) == set(er['quantities']), f"{e['passes']}/{e['checks']}")
    check(f'expected engine {v}: failing (id, quantity) digest and configuration count', pairs_sha(fl) == e['failing_id_quantity_pairs_sha256'] and len({f['id'] for f in fl}) == e['failed_configurations'], f"{e['failed_configurations']} configurations")
    br = read(f'results/browser/compare-results-{v}.json'); b = exp['browser'][v]
    bf = json.loads(lzma.decompress((ROOT / f'results/browser/compare-failures-{v}.json.xz').read_bytes()))
    check(f'expected browser {v}: totals, per-quantity counts and failing digest equal archived compare output',
          (b['checks'], b['passes']) == (br['checks'], br['passes']) and pairs_sha(bf) == b['failing_id_quantity_pairs_sha256']
          and all(b['quantities'][q]['passes'] == s['passes'] and b['quantities'][q]['checks'] == s['checks'] for q, s in br['quantities'].items()), f"{b['passes']}/{b['checks']}")
    ui = read(f'results/browser/ui-{v}.json')
    check(f'expected browser UI {v}', exp['browser_ui'][v]['passes'] == sum(1 for x in ui if x.get('pass') is True) and exp['browser_ui'][v]['checks'] == len(ui))
rows = list(csv.DictReader(open(ROOT / 'results/diagnosis/failing-configurations-patched.csv', encoding='utf-8')))
check('causes: failing-configurations-patched.csv covers every failing configuration once',
      len(rows) == len({r['id'] for r in rows}) == exp['variants']['patched']['failed_configurations']
      and sum(int(r['failed_checks']) for r in rows) == exp['variants']['patched']['failures'])
check('causes: counts equal expected', dict(collections.Counter(r['diagnosed_cause'] for r in rows)) == exp['patched_failure_causes'], json.dumps(exp['patched_failure_causes']))

# 7. provenance placeholders and private paths
PH = '[ALLMETA RELEASE PENDING]'
check('release placeholders present; no allmeta DOI asserted',
      all(PH in (ROOT / f).read_text(encoding='utf-8') for f in ['README.md', 'CITATION.cff', '.zenodo.json', 'app/app-sha256.json'])
      and 'zenodo' not in (ROOT / 'CITATION.cff').read_text(encoding='utf-8').lower())
z = read('.zenodo.json')
check('.zenodo.json metadata', z['upload_type'] == 'software' and z['license'] == 'MIT' and z['creators'][0]['orcid'] == '0000-0001-9107-3704'
      and any(r['relation'] == 'isDerivedFrom' and r['identifier'] == 'https://github.com/mahmood726-cyber/allmeta' for r in z['related_identifiers']))
hits = private_hits(files=files)
check('privacy: no host paths, addresses or key names in text files', not hits, '; '.join(hits[:8]))


# 8. optional full replay of the unmodified comparators on archived evidence
def replay():
    tmp = Path(tempfile.mkdtemp(prefix='.verify-', dir=ROOT))
    try:
        (tmp / 'reference').mkdir()
        for l, r in zip(lines, idx): (tmp / 'reference' / r['file']).write_bytes(l + b'\n')
        subprocess.run([sys.executable, str(ROOT / 'analysis/materialize.py'), str(tmp / 'm')], check=True)
        for f in (tmp / 'm').iterdir():
            if f.is_file(): shutil.move(str(f), tmp / f.name)
        env = dict(__import__('os').environ, PYTHONUTF8='1')
        for v in ['original', 'patched']:
            subprocess.run([sys.executable, 'compare_engine.py', v], cwd=tmp, check=True, env=env)
            check(f'replay engine {v}: unmodified comparator reproduces archived engine-results byte for byte',
                  (tmp / f'engine-results-{v}.json').read_bytes() == (ROOT / f'results/engine/engine-results-{v}.json').read_bytes())
            subprocess.run([sys.executable, 'compare.py', v], cwd=tmp, check=True, env=env, stdout=subprocess.DEVNULL)
            a, b = json.loads((tmp / f'results-{v}.json').read_text()), read(f'results/browser/compare-results-{v}.json')
            check(f'replay browser {v}: unmodified comparator reproduces archived totals and per-quantity counts',
                  (a['checks'], a['passes']) == (b['checks'], b['passes']) and a['quantities'] == b['quantities'], f"{a['passes']}/{a['checks']}")
    finally:
        shutil.rmtree(tmp, ignore_errors=True)

if '--full' in sys.argv:
    replay()
failed = [n for n, ok in results if not ok]
print(f'{len(results) - len(failed)}/{len(results)} archive checks pass')
sys.exit(1 if failed else 0)
