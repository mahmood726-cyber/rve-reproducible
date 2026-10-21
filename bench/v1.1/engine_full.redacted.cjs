const fs=require('fs'),path=require('path'),crypto=require('crypto');
const variant=process.argv[2];
const cs=JSON.parse(fs.readFileSync('<HOST>/p15diag/configurations.json','utf8'));
const engine=path.resolve('../..');
const hashes={};for(const f of ['shared/rve.js','shared/stats-qt.js','shared/rve-eigen.js'])hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(path.join(engine,f))).digest('hex');
const metadata={variant,node:process.version,host:'local Windows host',hashes,configurations:cs.length};
const meta=`engine-full-${variant}-meta.json`,file=`engine-full-${variant}.jsonl`;
if(fs.existsSync(meta)&&JSON.stringify(JSON.parse(fs.readFileSync(meta,'utf8')))!==JSON.stringify(metadata)){
 const old=JSON.parse(fs.readFileSync(meta,'utf8')),proof=JSON.parse(fs.readFileSync('configuration-extension-proof.json','utf8'));
 if(!process.argv.includes('--extend')||JSON.stringify(old.hashes)!==JSON.stringify(hashes)||old.configurations!==proof.old_count||metadata.configurations!==proof.new_count||!proof.all_old_configurations_identical)throw Error('Capture provenance changed without verified append-only extension');
}
fs.writeFileSync(meta,JSON.stringify(metadata,null,2));
const previous=fs.existsSync(file)?fs.readFileSync(file,'utf8').trim().split('\n').filter(Boolean).map(s=>JSON.parse(s).id):[];
if(previous.some((id,i)=>id!==cs[i].id))throw Error('Capture keys do not match ledger');
// Independent fits run concurrently; only the coordinator writes ledger-ordered captures.
const {Worker}=require('worker_threads');
const count=Math.min(3,Math.max(1,require('os').availableParallelism()-1));
let next=previous.length,writeIndex=previous.length,finished=0;
const pending=new Map(),workers=[];
function flush() {
 while(pending.has(writeIndex)) {
  const a=pending.get(writeIndex);pending.delete(writeIndex);
  fs.appendFileSync(file,JSON.stringify(a)+'\n');
  if(writeIndex%100===0)console.log(variant,writeIndex,cs.length);
  writeIndex++;
 }
}
if(next===cs.length)console.log(variant,cs.length,'engine configurations captured');
else for(let w=0;w<count;w++) {
 const worker=new Worker(path.resolve('r2-capture-worker.cjs'),{workerData:{variant:engine}});
 workers.push(worker);
 function dispatch(){if(next<cs.length){const index=next++;worker.postMessage({index,c:cs[index]});}}
 worker.on('message',({index,a})=>{
  if(a.id!==cs[index].id || pending.has(index) || index<writeIndex)throw Error('Worker ledger mismatch');
  pending.set(index,a);finished++;flush();
  if(writeIndex===cs.length){for(const x of workers)x.terminate();console.log(variant,cs.length,'engine configurations captured');}
  else dispatch();
 });
 worker.on('error',e=>{console.error(e);process.exitCode=1;for(const x of workers)x.terminate();});
 dispatch();
}
