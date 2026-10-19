const fs=require('fs'),vm=require('vm');
require('./patched/shared/stats-qt.js');
let s=fs.readFileSync('patched/shared/rve.js','utf8').replace('return { M: Minv,', 'return { XtWX, XtWy:Xty, M: Minv,').replace('beta: beta, cov_robust:', 'trace: {f0,Qe,denom,termA,termB,weights,Q,Alist}, beta: beta, cov_robust:');
vm.runInThisContext(s);
fs.writeFileSync('r2-js-trace.json',JSON.stringify(JSON.parse(fs.readFileSync('r2-small.json')).map(c=>({id:c.id,fit:AlmRVE.fitCORR(c.rows,{rho:c.rho})})),null,2));
