// Explicit synthetic API fixtures. These are not study data or browser tests.
const fs=require('fs'),vm=require('vm'),path=require('path');
for(const variant of ['original','patched']){
 const context={};vm.createContext(context);for(const f of ['stats-qt.js','rve.js'])vm.runInContext(fs.readFileSync(path.join(variant,'shared',f),'utf8'),context);
 const api=context.AlmRVE,checks=[];
 const rows=()=>[.2,.4,.1,.6,.3].map((yi,i)=>({cluster:String(i),yi,vi:.03+i*.01,X:[1,i]}));
 function refuses(name,make,opts={rho:.8}){let threw=false;try{api.fitCORR(make(),opts)}catch(e){threw=true}checks.push({name,pass:threw});}
 refuses('nonfinite predictor',()=>{const r=rows();r[0].X[1]=NaN;return r});
 refuses('nonfinite effect',()=>{const r=rows();r[0].yi=NaN;return r});
 refuses('nonpositive variance',()=>{const r=rows();r[0].vi=0;return r});
 refuses('inconsistent predictor count',()=>{const r=rows();r[4].X.push(2);return r});
 refuses('empty cluster',()=>{const r=rows();r[0].cluster='';return r});
 refuses('rho out of range',rows,{rho:1.1});
 refuses('rho nonfinite',rows,{rho:NaN});
 refuses('m<=p',()=>rows().slice(0,2));
 refuses('rank deficiency',()=>rows().map(r=>({...r,X:[1,1]})));
 let r=rows();r[0].cluster='__proto__';
 try{checks.push({name:'prototype cluster supported',pass:api.summary(api.fitCORR(r,{rho:.8})).every(s=>['estimate','se','df','p','ci_lo','ci_hi'].every(k=>Number.isFinite(s[k])))});}catch(e){checks.push({name:'prototype cluster supported',pass:false,error:e.message})}
 const fit=api.fitCORR(rows(),{rho:.8}),stats=context.AlmStats;context.AlmStats=null;let threw=false;try{api.summary(fit)}catch(e){threw=true}context.AlmStats=stats;checks.push({name:'missing Student-t dependency refused',pass:threw});
 checks.push({name:'NaN Student-t input stays undefined',pass:Number.isNaN(context.AlmStats.pt(NaN,4))});
 fs.writeFileSync(`contract-${variant}.json`,JSON.stringify({scope:'synthetic direct engine API contracts; not browser validation',checks},null,2));console.log(variant,checks.filter(x=>x.pass).length+'/'+checks.length,'API checks pass');
}
