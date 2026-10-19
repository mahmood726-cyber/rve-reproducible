from pathlib import Path
import json
load=lambda p:json.loads(Path(p).read_text(encoding='utf-8'))
old=load('corpus-before-metadata.json');new=load('corpus.json')
checks=[]
checks.append(dict(name='same ordered effect definitions',passed=[x['id'] for x in old]==[x['id'] for x in new]))
for a,b in zip(old,new):
 checks.append(dict(name=a['id'],passed={k:v for k,v in a.items() if k!='metadata'}=={k:v for k,v in b.items() if k!='metadata'}))
Path('metadata-integrity.json').write_text(json.dumps(checks,indent=2),encoding='utf-8')
print(sum(c['passed'] for c in checks),'/',len(checks),'metadata-only extension checks pass')
if not all(c['passed'] for c in checks):raise SystemExit(1)
