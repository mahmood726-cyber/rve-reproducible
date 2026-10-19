import subprocess,json,pathlib,datetime
commands = [[r'C:\Program Files\R\R-4.6.0\bin\Rscript.exe','--version'],[r'C:\Program Files\R\R-4.6.0\bin\x64\Rscript.exe','--version'],[r'C:\Program Files\nodejs\node.exe','--version']] 
results = [] 
for command in commands: 
    p = subprocess.run(command,capture_output=True,text=True,timeout=20) 
    results.append(dict(command=command,exit_code=p.returncode,stdout=p.stdout,stderr=p.stderr)) 
report = dict(time=datetime.datetime.now(datetime.timezone.utc).isoformat(),checks=results) 
pathlib.Path('r3-startup-check.json').write_text(json.dumps(report,indent=2),encoding='utf-8') 
print(json.dumps(report,indent=2))
