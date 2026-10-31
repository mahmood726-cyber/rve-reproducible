const fs=require('fs'),path=require('path');
const WT='C:/mh-lanes/p10-11-15/wt-rve',LANE='C:/mh-lanes/f1000-15-19/p15-codex17';
require(path.join(WT,'shared/stats-qt.js'));require(path.join(WT,'shared/rve.js'));
const E=require(path.join(WT,'shared/rve-extras.js'));
const S=JSON.parse(fs.readFileSync(path.join(__dirname,'rscript_sample.json'),'utf8'));
const cs=JSON.parse(fs.readFileSync(path.join(LANE,'configurations.json'),'utf8'));const byId=new Map(cs.map(c=>[c.id,c]));
const dir=path.join(__dirname,'rscripts');fs.mkdirSync(dir,{recursive:true});
const man=[];const gen='2026-10-19 (validation run)';
function emit(name,o){fs.writeFileSync(path.join(dir,name+'.R'),E.toRScript(Object.assign({version:'validation',generated:gen},o)));}
S.uncentred.forEach((s,i)=>{const c=byId.get(s.id);const name='u_'+String(i+1).padStart(3,'0');const names=c.moderator?[c.moderator]:[];
 emit(name,{rows:c.rows,names,rho:c.rho,centred:false});man.push({name,kind:'uncentred',id:s.id,index:s.index,rows:c.rows,rho:c.rho});});
S.centred.forEach((s,i)=>{const c=byId.get(s.id);const name='c_'+String(i+1).padStart(3,'0');
 emit(name,{rows:c.rows,names:[c.moderator],rho:c.rho,centred:true});man.push({name,kind:'centred',id:s.id,index:s.index,tierB_pos:s.tierB_pos,rows:c.rows,rho:c.rho});});
const small="study1, 0.45, 0.04, 1, 6\nstudy1, 0.38, 0.05, 1, 6\nstudy1, 0.55, 0.06, 1, 6\nstudy2, 0.22, 0.03, 1, 12\nstudy2, 0.31, 0.04, 1, 12\nstudy3, 0.18, 0.02, 0, 18\nstudy3, 0.25, 0.03, 0, 18\nstudy3, 0.30, 0.04, 0, 18\nstudy4, 0.60, 0.05, 1, 4\nstudy4, 0.55, 0.06, 1, 4\nstudy5, 0.12, 0.02, 0, 24\nstudy5, 0.20, 0.03, 0, 24\nstudy5, 0.16, 0.025, 0, 24";
const DS2={study:[1,1,2,2,2,3,3,4,4,4,5,5,6,6,6,7,7,8,8],yi:[0.90,0.40,0.10,0.55,0.30,1.20,0.80,0.05,0.45,0.20,0.70,1.10,0.33,0.61,0.15,0.95,0.50,0.25,0.72],vi:[0.05,0.08,0.03,0.06,0.04,0.09,0.05,0.02,0.07,0.03,0.05,0.10,0.04,0.06,0.03,0.08,0.05,0.03,0.07],x1:[1,1,0,0,0,1,1,0,0,0,1,1,0,0,0,1,1,0,0],x2:[2,5,3,8,1,4,9,2,6,3,5,7,1,4,2,6,8,3,5]};
const ds2rows=DS2.study.map((s,i)=>({cluster:String(s),yi:DS2.yi[i],vi:DS2.vi[i],X:[1,DS2.x1[i],DS2.x2[i]]}));
const corr=E.parseStudies(fs.readFileSync(path.join(__dirname,'corrdat_example.txt'),'utf8'));
const fx=[['f_small',E.parseStudies(small).rows,['intervention','dose_weeks']],['f_ds2',ds2rows,['x1','x2']],['f_corrdat',corr.rows,corr.predictorNames]];
for(const [name,rows,names] of fx){emit(name,{rows,names,rho:0.8,centred:false});man.push({name,kind:'fixture',rows,rho:0.8,names});}
fs.writeFileSync(path.join(__dirname,'rscripts_manifest.json'),JSON.stringify(man));
console.log(man.length,'scripts');
