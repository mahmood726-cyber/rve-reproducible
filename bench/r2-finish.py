import json,time,subprocess,hashlib
from pathlib import Path
started=time.monotonic()
while True:
 lines=Path('engine-full-patched.jsonl').read_text(encoding='utf-8').splitlines()
 try:last=json.loads(lines[-1])
 except (ValueError,IndexError):time.sleep(5);continue
 print('Final-source capture:',len(lines),'/ 16270;',last['id'],flush=True)
 if len(lines)==16270:break
 if len(lines)>16270:raise RuntimeError('Excess capture records')
 if time.monotonic()-started>10800:raise RuntimeError('Capture monitoring limit; preserve progress and inspect engine')
 time.sleep(60)
meta=json.loads(Path('engine-full-patched-meta.json').read_text())
for n,h in meta['hashes'].items():assert hashlib.sha256(Path('patched',n).read_bytes()).hexdigest()==h
for script,args in [('compare_engine.py',['patched']),('diagnose_failures.py',[]),('r2-report.py',[])]:
 subprocess.run(['python',script,*args],check=True)
Path('r2-finished.json').write_text(json.dumps({'completed_capture':16270,'engine_hashes':meta['hashes'],'report':'RESULT_R2.md'},indent=2))
print('R2 post-processing complete',flush=True)
