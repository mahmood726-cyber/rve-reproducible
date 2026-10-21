const {parentPort,workerData}=require('worker_threads');
const path=require('path');
require(path.join(workerData.variant,'shared/stats-qt.js'));
const RVE=require(path.join(workerData.variant,'shared/rve.js'));
parentPort.on('message',({index,c})=>{
 let a;
 try {const fit=RVE.fitCORR(c.rows,{rho:c.rho});a={id:c.id,status:'ok',fit,summary:RVE.summary(fit)};}
 catch(e){a={id:c.id,status:'refused',reason:e.message};}
 parentPort.postMessage({index,a});
});
