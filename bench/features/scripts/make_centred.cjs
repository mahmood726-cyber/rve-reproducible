// Build the pre-registered centred configuration set and run the unchanged engine on it.
const fs=require('fs'),path=require('path'),crypto=require('crypto');
const WT='C:/mh-lanes/p10-11-15/wt-rve', LANE='C:/mh-lanes/f1000-15-19/p15-codex17';
require(path.join(WT,'shared/stats-qt.js'));
const RVE=require(path.join(WT,'shared/rve.js'));
const E=require(path.join(__dirname,'rve-extras.prereg.js'));
const ids=fs.readFileSync(path.join(__dirname,'centring_config_ids.txt'),'utf8').trim().split('\n');
const idset=new Set(ids);
const keys=fs.readFileSync(path.join(LANE,'configuration-ledger.csv'),'utf8').trim().split(/\r?\n/).slice(1).map(l=>l.split(',')[0]);
const cs=JSON.parse(fs.readFileSync(path.join(LANE,'configurations.json'),'utf8'));
const byId=new Map(cs.map(c=>[c.id,c]));
const out=[];
for(const id of ids){
  const c=byId.get(id); if(!c) throw Error('missing '+id);
  const index=keys.indexOf(id)+1; if(index<1) throw Error('no ledger index '+id);
  const cen=E.centreRows(c.rows);
  out.push({id,index,rho:c.rho,rows:c.rows,centred_rows:cen.rows,means:cen.means});
}
const cfgFile=path.join(__dirname,'centred_configs.json');
if(!fs.existsSync(cfgFile)) fs.writeFileSync(cfgFile,JSON.stringify(out));
else if(fs.readFileSync(cfgFile,'utf8')!==JSON.stringify(out)) throw Error('centred_configs.json differs from regenerated content');
if(process.argv[2]==='configs-only'){console.log('configs written',out.length);process.exit(0);}
const engFile=path.join(__dirname,'centred_engine.jsonl');
const done=fs.existsSync(engFile)?fs.readFileSync(engFile,'utf8').trim().split(/\n/).filter(Boolean).length:0;
for(let i=done;i<out.length;i++){
  const o=out[i], c={rows:o.rows,rho:o.rho}, cen={rows:o.centred_rows}, id=o.id, index=o.index;
  const rec={id,index};
  try{const f=RVE.fitCORR(cen.rows,{rho:c.rho});rec.centred={status:'ok',fit:{tau2:f.tau2,k_total:f.k_total,m_clusters:f.m_clusters,p:f.p,method:f.method},summary:RVE.summary(f),kappa:E.kappaXtWX(cen.rows,f.weights)};}
  catch(e){rec.centred={status:'refused',reason:e.message};}
  try{const f=RVE.fitCORR(c.rows,{rho:c.rho});rec.uncentred={status:'ok',kappa:E.kappaXtWX(c.rows,f.weights)};}
  catch(e){rec.uncentred={status:'refused',reason:e.message};}
  fs.appendFileSync(engFile,JSON.stringify(rec)+String.fromCharCode(10));
  if(i%50===0)console.log(i,new Date().toISOString());
}
const h=f=>crypto.createHash('sha256').update(fs.readFileSync(f)).digest('hex');
fs.writeFileSync(path.join(__dirname,'centred_engine_meta.json'),JSON.stringify({node:process.version,n:out.length,hashes:{rve:h(path.join(WT,'shared/rve.js')),statsqt:h(path.join(WT,'shared/stats-qt.js')),extras_prereg:h(path.join(__dirname,'rve-extras.prereg.js')),configs:h(path.join(__dirname,'centred_configs.json'))}},null,2));
console.log('engine done',out.length);
