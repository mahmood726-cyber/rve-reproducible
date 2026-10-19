"""Shared archive rules: inventory scope, size limits and the private-path scan."""
import hashlib, re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EXCLUDED = re.compile(r'^(outputs/|\.validate-work/|\.verify-[^/]*/|\.git/|results/validate-run\.json$|SOURCE_SHA256\.json$)|(^|/)__pycache__/')
MAX_FILE = 90 * 1024 * 1024
MAX_TOTAL = 500 * 1024 * 1024
TEXT = {'.R', '.py', '.cjs', '.js', '.mjs', '.json', '.md', '.txt', '.csv', '.html', '.css', '.cff', '.patch', '.log', '.sha256', ''}
PRIVATE = re.compile(r'claude-temp|[A-Za-z]:[/\\]+Users[/\\]|\b100\.\d{1,3}\.\d{1,3}\.\d{1,3}\b|\.ssh\b|ed25519|\bmahmo\b|allmeta-offload|'
                     r'scratchpad|(?<![A-Za-z])[FD]:[/\\]', re.I)
RULE_FILES = {'analysis/archive_rules.py', 'analysis/test_safeguards.py'}  # these contain the patterns themselves


def sha256(path):
    h = hashlib.sha256()
    with open(path, 'rb') as f:
        while chunk := f.read(1 << 20):
            h.update(chunk)
    return h.hexdigest()


def source_files(root=ROOT):
    out = []
    for p in sorted(root.rglob('*')):
        if p.is_file():
            rel = p.relative_to(root).as_posix()
            if not EXCLUDED.search(rel):
                out.append(rel)
    return out


def private_hits(root=ROOT, files=None):
    hits = []
    for rel in files or source_files(root):
        p = root / rel
        if p.suffix not in TEXT or rel in RULE_FILES:
            continue
        for n, line in enumerate(p.read_text(encoding='utf-8', errors='replace').splitlines(), 1):
            m = PRIVATE.search(line)
            if m:
                hits.append(f'{rel}:{n}: {m.group(0)!r}')
    return hits
