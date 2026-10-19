const fs=require('fs');const st=require('./patched/shared/stats-qt.js');
const cs=JSON.parse(fs.readFileSync('configurations.json'));
const failures=JSON.parse(fs.readFileSync('r2-before.json')).cases;
const ids=new Set(failures.filter(c=>c.category.startsWith('inference')).map(c=>c.id));let out=[];
for(let i=0;i<cs.length;i++)if(ids.has(cs[i].id)) {const r=JSON.parse(fs.readFileSync(`reference/${String(i+1).padStart(6,'0')}.json`));for(const t of r.table)out.push({id:cs[i].id,df:t.dfs,qt:st.qt(.975,t.dfs),qtR:(t['CI.U']-t['b.r'])/t.SE,p:2*st.pt(-Math.abs(t.t),t.dfs),pR:t.prob,ciError:Math.abs(t['b.r']+st.qt(.975,t.dfs)*t.SE-t['CI.U'])});}
fs.writeFileSync('r2-inference-probe.json',JSON.stringify(out,null,2));console.log('isolated CI failures',out.filter(x=>x.ciError>1e-9).length,'max',Math.max(...out.map(x=>x.ciError)),'p failures',out.filter(x=>Math.abs(x.p-x.pR)>1e-9).length);
