"""Materialise the inputs validate.R needs into a NEW work directory.

Decompresses the archived xz files (multi-part files are one xz stream split into parts) and checks every
decompressed file against the uncompressed SHA-256 recorded in analysis/compression_proof.json; copies the
unmodified comparators and reference writer. No archived R reference is placed in the work directory.
Usage: python analysis/materialize.py <new-work-dir>
"""
import hashlib, json, lzma, shutil, sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
work = Path(sys.argv[1])
work.mkdir(parents=True, exist_ok=False)
(work / 'reference').mkdir()
proof = {p['stored']: p for p in json.loads((ROOT / 'analysis/compression_proof.json').read_text(encoding='utf-8'))}


def unpack(stored, dest):
    rec = proof[stored]
    parts = rec.get('parts', [stored])
    dec, h, n = lzma.LZMADecompressor(), hashlib.sha256(), 0
    with open(dest, 'wb') as out:
        for part in parts:
            with open(ROOT / part, 'rb') as f:
                while True:
                    chunk = f.read(1 << 20)
                    if not chunk:
                        break
                    data = dec.decompress(chunk)
                    h.update(data); n += len(data); out.write(data)
    if not dec.eof or n != rec['original_bytes'] or h.hexdigest() != rec['original_sha256']:
        raise SystemExit(f'Decompressed bytes differ from the compression proof: {stored}')
    print(f'materialised {dest.name}: {n} bytes, SHA-256 verified', flush=True)


unpack('data/configurations.json.xz', work / 'configurations.json')
for v in ['original', 'patched']:
    unpack(f'results/engine/engine-full-{v}.jsonl.xz', work / f'engine-full-{v}.jsonl')
    unpack(f'results/browser/app-{v}.jsonl.xz', work / f'app-{v}.jsonl')
for src, name in [('bench/json17.R', 'json17.R'), ('analysis/reference_core.R', 'reference_core.R'),
                  ('bench/compare_engine.py', 'compare_engine.py'), ('bench/reference_cache.py', 'reference_cache.py'),
                  ('bench/browser/compare.py', 'compare.py'), ('data/configuration-ledger.csv', 'configuration-ledger.csv')]:
    shutil.copyfile(ROOT / src, work / name)
assert not (work / 'reference-byte-cache.json').exists()
print('work directory ready:', work, flush=True)
