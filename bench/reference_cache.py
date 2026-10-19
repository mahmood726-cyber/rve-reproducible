"""Cache exact existing reference bytes; never fit or alter a reference."""
from pathlib import Path
import concurrent.futures
import hashlib
import json

CACHE = Path('reference-byte-cache.json')

def read_one(p):
    before = p.stat()
    raw = p.read_bytes()
    after = p.stat()
    if (before.st_size, before.st_mtime_ns) != (after.st_size, after.st_mtime_ns):
        raise RuntimeError(f'Reference changed during read: {p}')
    json.loads(raw)
    return dict(path=p.as_posix(), size=len(raw), mtime_ns=after.st_mtime_ns,
                sha256=hashlib.sha256(raw).hexdigest(), raw=raw.decode('utf-8'))

def load_cache():
    if not CACHE.exists():
        return None
    records = json.loads(CACHE.read_text(encoding='utf-8'))
    def verify(r):
        raw = r['raw'].encode('utf-8')
        st = Path(r['path']).stat()
        if len(raw) != r['size'] or hashlib.sha256(raw).hexdigest() != r['sha256']:
            raise RuntimeError('Corrupt cached reference: ' + r['path'])
        if st.st_size != r['size'] or st.st_mtime_ns != r['mtime_ns']:
            raise RuntimeError('Reference changed since cache construction: ' + r['path'])
        return r['path'], r
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
        result = dict(pool.map(verify, records))
    if len(result) != len(records):
        raise RuntimeError('Duplicate reference paths in cache')
    return result

def reference_json(cache, p):
    key = Path(p).as_posix()
    if cache is not None:
        if key not in cache:
            raise RuntimeError('Reference missing from cache: ' + key)
        return json.loads(cache[key]['raw'])
    return json.loads(Path(p).read_text(encoding='utf-8'))

if __name__ == '__main__':
    paths = sorted(Path('reference').glob('*.json'))
    with concurrent.futures.ThreadPoolExecutor(max_workers=16) as pool:
        records = list(pool.map(read_one, paths))
    CACHE.write_text(json.dumps(records, separators=(',', ':')), encoding='utf-8')
    print(f'Cached {len(records)} existing references; zero recomputed', flush=True)
    verified = load_cache()
    print(f'{len(verified)}/{len(records)} cached byte hashes and source stamps verified', flush=True)
