const fs=require('fs'),path=require('path'),crypto=require('crypto');
const variant=process.argv[2];
const cs=JSON.parse(fs.readFileSync('configurations.json','utf8'));
const hashes={};for(const f of ['shared/rve.js','shared/stats-qt.js'])hashes[f]=crypto.createHash('sha256').update(fs.readFileSync(path.join(variant,f))).digest('hex');
const metadata={variant,node:process.version,host:'local Windows host',hashes,configurations:cs.length};
const meta=`engine-full-${variant}-meta.json`,file=`engine-full-${variant}.jsonl`;
if(fs.existsSync(meta)&&JSON.stringify(JSON.parse(fs.readFileSync(meta,'utf8')))!==JSON.stringify(metadata)){
 const old=JSON.parse(fs.readFileSync(meta,'utf8')),proof=JSON.parse(fs.readFileSync('configuration-extension-proof.json','utf8'));
 if(!process.argv.includes('--extend')||JSON.stringify(old.hashes)!==JSON.stringify(hashes)||old.configurations!==proof.old_count||metadata.configurations!==proof.new_count||!proof.all_old_configurations_identical)throw Error('Capture provenance changed without verified append-only extension');
}
fs.writeFileSync(meta,JSON.stringify(metadata,null,2));
const previous=fs.existsSync(file)?fs.readFileSync(file,'utf8').trim().split('\n').filter(Boolean).map(s=>JSON.parse(s).id):[];
if(previous.some((id,i)=>id!==cs[i].id))throw Error('Capture keys do not match ledger');
require(path.resolve(variant,'shared/stats-qt.js'));const RVE=require(path.resolve(variant,'shared/rve.js'));
for(let i=previous.length;i<cs.length;i++){
 const c=cs[i];let a;
 try{const fit=RVE.fitCORR(c.rows,{rho:c.rho});a={id:c.id,status:'ok',fit,summary:RVE.summary(fit)}}catch(e){a={id:c.id,status:'refused',reason:e.message}}
 fs.appendFileSync(file,JSON.stringify(a)+'\n');if(i%100===0)console.log(variant,i,cs.length);
}
console.log(variant,cs.length,'engine configurations captured');
