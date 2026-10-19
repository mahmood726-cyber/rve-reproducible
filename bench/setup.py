from pathlib import Path
import subprocess, shutil, json, hashlib, re
root=Path('C:/Projects/allmeta-work')
commit=subprocess.check_output(['git','-C',str(root),'rev-parse','origin/main'],text=True).strip()
files=subprocess.check_output(['git','-C',str(root),'ls-tree','-r','--name-only',commit],text=True).splitlines()
selected=[p for p in files if p.startswith(('rve-meta/','shared/','hub/shared/')) and '/node_modules/' not in p]
selected+=['hub/app-style.css']
manifest={}
for p in selected:
    data=subprocess.check_output(['git','-C',str(root),'show',f'{commit}:{p}'])
    dest=Path('original')/p; dest.parent.mkdir(parents=True,exist_ok=True); dest.write_bytes(data)
    manifest[p]=hashlib.sha256(data).hexdigest()
shutil.copytree('original','patched',dirs_exist_ok=True)
Path('source-manifest.json').write_text(json.dumps({'commit':commit,'files':manifest},indent=2))
for f in ['corpus.R','metadata.R','json17.R','supplemental-exact.R']:
    shutil.copyfile(Path('../codex16')/f,f)
shutil.copytree('../codex16/documentation','documentation',dirs_exist_ok=True)
Path('empty.Renviron').write_text('')
Path('.gitignore').write_text('PROGRESS.md\nnode_modules/\nRlib/\n__pycache__/\n')
