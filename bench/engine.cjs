const fs=require('fs'),path=require('path');
const variant=process.argv[2]||'original';
require(path.resolve(variant,'shared/stats-qt.js'));
const RVE=require(path.resolve(variant,'shared/rve.js'));
const cs=JSON.parse(fs.readFileSync('configurations.json','utf8'));
const out=[];const max=Number(process.argv[3]||cs.length);
for(let i=0;i<Math.min(max,cs.length);i++){
 const c=cs[i];try{const fit=RVE.fitCORR(c.rows,{rho:c.rho});out.push({id:c.id,status:'ok',fit,summary:RVE.summary(fit)});}catch(e){out.push({id:c.id,status:'refused',reason:e.message});}
 if(i%100===0)console.log(variant,i);
}
fs.writeFileSync(`engine-${variant}.json`,JSON.stringify(out));
