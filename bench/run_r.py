import os, subprocess, sys
from pathlib import Path
env=os.environ.copy()
env['R_ENVIRON_USER']=str(Path('empty.Renviron').resolve())
env['R_LIBS_USER']=str(Path('../re/Rlib_dta').resolve())
env['R_LIBS']=str(Path('Rlib').resolve())
env['EXTRA_R_LIB']=str(Path(os.environ['LOCALAPPDATA'])/'R/win-library/4.6')
with open(sys.argv[1]+('-'+'-'.join(sys.argv[2:]) if len(sys.argv)>2 else '')+'.log','w',encoding='utf-8') as log:
    p=subprocess.run(['Rscript','--no-save','--no-restore',*sys.argv[1:]],env=env,stdout=log,stderr=subprocess.STDOUT)
print(sys.argv[1], 'exit',p.returncode)
sys.exit(p.returncode)
