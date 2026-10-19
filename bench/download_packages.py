import urllib.request,gzip,re,hashlib,json
from pathlib import Path
base='https://cloud.r-project.org/bin/windows/contrib/4.6/'
index=gzip.decompress(urllib.request.urlopen(base+'PACKAGES.gz').read()).decode()
records={}
Path('packages').mkdir(exist_ok=True)
for name in ['robumeta','clubSandwich']:
    block=next(b for b in index.split('\n\n') if b.startswith('Package: '+name+'\n'))
    version=re.search(r'^Version: (.+)$',block,re.M)[1]
    url=base+name+'_'+version+'.zip'
    data=urllib.request.urlopen(url).read(); Path('packages',name+'.zip').write_bytes(data)
    records[name]={'version':version,'url':url,'sha256':hashlib.sha256(data).hexdigest()}
Path('packages/provenance.json').write_text(json.dumps(records,indent=2))
