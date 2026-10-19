"""Write SOURCE_SHA256.json: SHA-256 of every source file (outputs/, results/validate-run.json and scratch excluded)."""
import json
from archive_rules import ROOT, sha256, source_files

pins = {rel: sha256(ROOT / rel) for rel in source_files()}
(ROOT / 'SOURCE_SHA256.json').write_text(json.dumps(pins, indent=1, sort_keys=True) + '\n', encoding='utf-8', newline='\n')
print(f'pinned {len(pins)} source files')
