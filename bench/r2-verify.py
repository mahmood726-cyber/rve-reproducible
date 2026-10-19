from pathlib import Path
import subprocess,json,hashlib
names=['rve-meta/index.html','shared/rve.js','shared/stats-qt.js']
paths=[Path('patched',n) for n in names]+[Path('fix.patch')]
a={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
subprocess.run(['python','patch_app.py'],check=True)
b={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
assert a==b
Path('r2-idempotence.json').write_text(json.dumps({'pass':a==b,'hashes':b},indent=2))
for n in names[1:]:subprocess.run(['node','--check',str(Path('patched',n))],check=True)
root=Path('r2-patch-proof');root.mkdir(exist_ok=True)
for name in names:
 p=root/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_text(Path('original',name).read_text(encoding='utf-8'),encoding='utf-8',newline='\n')
subprocess.run(['git','apply','--check',str(Path('fix.patch').resolve())],cwd=root,check=True)
subprocess.run(['git','apply',str(Path('fix.patch').resolve())],cwd=root,check=True)
result={n:(root/n).read_text(encoding='utf-8')==Path('patched',n).read_text(encoding='utf-8') for n in names}
assert all(result.values())
Path('r2-patch-proof.json').write_text(json.dumps(result,indent=2))
for filename in ['contract-patched.json','edge-patched.json']:
 r=json.loads(Path(filename).read_text());checks=r['checks'] if isinstance(r,dict) else r
 assert all(c['pass'] for c in checks),filename
print('Idempotence, syntax, clean patch equivalence and saved API/edge checks PASS')
