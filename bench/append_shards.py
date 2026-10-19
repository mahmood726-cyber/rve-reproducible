from pathlib import Path
import json
cs=json.loads(Path('configurations.json').read_text())
for start in range(1,len(cs)+1,250):
 p=Path('shards',f'{start:06d}.json');s=json.dumps(cs[start-1:start+249],separators=(',',':'))
 if not p.exists() or p.read_text()!=s:p.write_text(s)
print(len(cs),'configurations in',len(list(Path('shards').glob('*.json'))),'shards')
