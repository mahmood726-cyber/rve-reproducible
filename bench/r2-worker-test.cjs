const fs=require('fs'),path=require('path'),assert=require('assert');const {Worker}=require('worker_threads');
require('./patched/shared/stats-qt.js');const api=require('./patched/shared/rve.js');
const cs=JSON.parse(fs.readFileSync('r2-small.json'));
cs.push({id:'explicit-software-empty-fixture',rows:[],rho:.8});
const worker=new Worker(path.resolve('r2-capture-worker.cjs'),{workerData:{variant:path.resolve('patched')}});
let index=0;
worker.on('message',msg=>{const c=cs[index];let expected;try{const fit=api.fitCORR(c.rows,{rho:c.rho});expected={id:c.id,status:'ok',fit,summary:api.summary(fit)};}catch(e){expected={id:c.id,status:'refused',reason:e.message};}
assert.strictEqual(msg.index,index);assert.strictEqual(JSON.stringify(msg.a),JSON.stringify(expected));index++;
if(index===cs.length){fs.writeFileSync('r2-worker-proof.json',JSON.stringify({cases:index,byte_equal_serialized_results:true},null,2));worker.terminate();console.log('Worker/serial equality PASS',index);}else worker.postMessage({index,c:cs[index]});});
worker.on('error',e=>{throw e;});worker.postMessage({index,c:cs[index]});
