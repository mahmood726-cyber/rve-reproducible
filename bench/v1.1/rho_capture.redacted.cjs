const fs=require('node:fs'), path=require('node:path'), crypto=require('node:crypto');
const {Worker,isMainThread,parentPort,workerData}=require('node:worker_threads');
const root=process.env.P15_ENGINE_ROOT || path.resolve(__dirname,'../..');
if (!isMainThread) {
  require(path.join(root,'shared/stats-qt.js'));
  require(path.join(root,'shared/rve.js'));
  const extras=require(path.join(root,'shared/rve-extras.js'));
  parentPort.on('message',({index,c})=>parentPort.postMessage({index,record:{
    design:c.design,...extras.rhoSensitivity(c.rows,[0.4,0.6])}}));
} else {
  const input='<HOST>/p15diag/rho_work/rho_sample.json';
  const cs=JSON.parse(fs.readFileSync(input,'utf8'));
  const label=process.env.P15_RHO_LABEL || 'rho';
  const file=path.join(__dirname,label+'-engine.jsonl'), meta=path.join(__dirname,label+'-engine-meta.json');
  const hashes={};
  for(const f of ['shared/rve.js','shared/stats-qt.js','shared/rve-eigen.js','shared/rve-extras.js'])
    if(fs.existsSync(path.join(root,f))) hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(path.join(root,f))).digest('hex');
  const metadata={node:process.version,hashes,input_sha256:crypto.createHash('sha256').update(fs.readFileSync(input)).digest('hex')};
  if(fs.existsSync(meta) && fs.readFileSync(meta,'utf8')!==JSON.stringify(metadata,null,2)) throw Error('Provenance changed');
  fs.writeFileSync(meta,JSON.stringify(metadata,null,2));
  const previous=fs.existsSync(file)?fs.readFileSync(file,'utf8').trim().split('\n').filter(Boolean).map(JSON.parse):[];
  if(previous.some((r,i)=>r.design!==cs[i].design)) throw Error('Sample mismatch');
  let next=previous.length, written=previous.length;
  const pending=new Map(), workers=[];
  if(next===cs.length) console.log('448/448 captured');
  else for(let w=0;w<2;w++) {
    const worker=new Worker(__filename);workers.push(worker);
    function send(){if(next<cs.length){const index=next++;worker.postMessage({index,c:cs[index]});}}
    worker.on('message',({index,record})=>{
      pending.set(index,record);
      while(pending.has(written)) {
        fs.appendFileSync(file,JSON.stringify(pending.get(written))+'\n');pending.delete(written++);
        if(written%25===0)console.log(written,'/',cs.length);
      }
      if(written===cs.length){workers.forEach(w=>w.terminate());console.log('448/448 captured');}
      else send();
    });
    worker.on('error',e=>{console.error(e);process.exitCode=1;workers.forEach(w=>w.terminate());});
    send();
  }
}
