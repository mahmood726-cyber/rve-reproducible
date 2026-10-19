const fs=require('fs'),vm=require('vm');
let s=fs.readFileSync('patched/shared/rve.js','utf8');
s=s.replace('    var cov, dfArr;','    return {preflightOnly:true};\n    var cov, dfArr;');vm.runInThisContext(s);
const cs=JSON.parse(fs.readFileSync('configurations.json'));
const previous=new Map(fs.readFileSync('engine-full-patched.jsonl','utf8').trim().split('\n').map(x=>{const a=JSON.parse(x);return [a.id,a];}));
const changed=[];for(const c of cs){let a;try{AlmRVE.fitCORR(c.rows,{rho:c.rho});a={status:'ok'};}catch(e){a={status:'refused',reason:e.message};}const b=previous.get(c.id);if(a.status!==b.status)changed.push({id:c.id,before:b.status,...a});}
fs.writeFileSync('r2-condition-preflight.json',JSON.stringify({configurations:cs.length,scope:'only design solves and domain guards; not a full capture',changed},null,2));console.log(JSON.stringify(changed,null,2));
