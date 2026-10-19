const fs=require('fs'),vm=require('vm'),path=require('path');
const data=JSON.parse(fs.readFileSync('edge-reference.json','utf8'));
for(const v of ['original','patched']){
 const context={};vm.createContext(context);
 for(const f of ['stats-qt.js','rve.js'])vm.runInContext(fs.readFileSync(path.join(v,'shared',f),'utf8'),context);
 const rows=data.rows.map(r=>({...r,X:Array.isArray(r.X)?r.X:[r.X]}));
 const checks=[];let result;
 try{const fit=context.AlmRVE.fitCORR(rows,{rho:.8});result={fit,summary:context.AlmRVE.summary(fit)};checks.push({name:'large variance accepted like R',pass:true});
 for(const [a,b] of [['estimate','b.r'],['se','SE'],['t','t'],['df','dfs'],['p','prob'],['ci_lo','CI.L'],['ci_hi','CI.U']]){const x=result.summary[0][a],y=data.reference[b];checks.push({name:a,pass:Number.isFinite(x)&&Math.abs(x-y)<=1e-9*(a==='p'||a.startsWith('ci_')?1:Math.max(1,Math.abs(y))),app:x,reference:y});}
 }catch(e){checks.push({name:'large variance accepted like R',pass:false,error:e.message});}
 fs.writeFileSync(`edge-${v}.json`,JSON.stringify({checks,result},null,2));console.log(v,checks.filter(x=>x.pass).length+'/'+checks.length,'edge checks pass');
}
