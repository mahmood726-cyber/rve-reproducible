const {test,expect}=require('@playwright/test');
const fs=require('fs'),path=require('path');
const root=path.resolve(__dirname,'..');
const cases=JSON.parse(fs.readFileSync(path.join(root,'configurations.json'),'utf8'));
for(const variant of ['original','patched']) test(variant,async({page,browser})=>{
 await page.goto(`http://127.0.0.1:8088/${variant}/rve-meta/`);
 await page.waitForFunction(()=>window.AlmRVE&&window.__almLastRVE);
 const meta={browser:browser.version(),default:await page.evaluate(()=>({result:__almLastRVE(),text:document.querySelector('#meta-row').textContent,table:document.querySelector('#coef-body').innerText}))};
 fs.writeFileSync(path.join(root,`browser-${variant}.json`),JSON.stringify(meta));
 await page.evaluate(()=>{const original=AlmRVE.fitCORR;AlmRVE.fitCORR=function(rows,opts){window.__auditRows=rows;window.__auditError=null;try{return original(rows,opts)}catch(e){window.__auditError=e.message;throw e;}}});
 const file=path.join(root,`app-${variant}.jsonl`);fs.writeFileSync(file,'');
 for(let i=0;i<cases.length;i++){
  const c=cases[i];
  const rec=await page.evaluate(async c=>{
   window.__auditRows=null;window.__auditError=null;
   document.querySelector('#src').value=c.rows.map(r=>[encodeURIComponent(r.cluster),r.yi,r.vi,...r.X.slice(1)].join(',')).join('\n');
   document.querySelector('#f-rho').value=c.rho;document.querySelector('#f-names').value=c.moderator||'';
   document.querySelector('#btn-run').click();
   const text=document.querySelector('#meta-row').textContent, cells=Array.from(document.querySelectorAll('#coef-body tr')).map(tr=>Array.from(tr.cells).map(td=>td.textContent));
   const payload=window.__almLastRVE?window.__almLastRVE():null;
   const exports={},blobs=[];const create=URL.createObjectURL,click=HTMLAnchorElement.prototype.click;
   URL.createObjectURL=function(blob){blobs.push(blob);return create.call(URL,blob)};
   HTMLAnchorElement.prototype.click=function(){if(!this.download)return click.call(this)};
   try {
    for(const button of document.querySelectorAll('#alm-export-mount button')){
     blobs.length=0;button.click();await Promise.resolve();await Promise.resolve();
     exports[button.dataset.action]=await Promise.all(blobs.map(b=>b.text()));
    }
   }finally{URL.createObjectURL=create;HTMLAnchorElement.prototype.click=click;}
   const json=exports.json&&exports.json.length===1?JSON.parse(exports.json[0]):null;
   return {id:c.id,status:cells.length?'ok':'refused',reason:window.__auditError||text,rows:window.__auditRows,result:payload,export_json_matches:JSON.stringify(json)===JSON.stringify(payload||{}),exports,text,cells};
  },c);
  fs.appendFileSync(file,JSON.stringify(rec)+'\n');
  if(i%100===0)console.log(variant,i,cases.length);
 }
 // Focused end-to-end parser, stale export and control checks.
 const checks=[{name:'CR2 introduction',pass:await page.locator('header p').evaluate(e=>e.textContent.includes('CR2')&&!e.textContent.includes('CR1'))},{name:'default low-df warning',pass:meta.default.result.summary.every(s=>s.df>=4)||/df < 4/.test(meta.default.text)}];
 async function input(text,rho=.8){return page.evaluate(({text,rho})=>{document.querySelector('#src').value=text;document.querySelector('#f-rho').value=rho;document.querySelector('#btn-run').click();return {text:document.querySelector('#meta-row').textContent,result:window.__almLastRVE?__almLastRVE():null,cells:document.querySelectorAll('#coef-body tr').length};},{text,rho});}
 const valid='a,.2,.03,1\nb,.4,.04,2\nc,.1,.02,4\nd,.6,.05,3';
 for(const [name,txt] of [['nonfinite',valid.replace(',1\n',',NaN\n')],['blank',valid.replace(',1\n',',\n')],['width',valid+',5'],['rank',valid.replace(/,[1234](\n|$)/g,',1$1')],['m<=p','a,.2,.03,1\nb,.4,.04,2'],['empty','']]){
  await input(valid);const r=await input(txt);checks.push({name,pass:r.cells===0&&r.result===null,actual:r});
 }
 await input(valid,1);checks.push({name:'rho endpoint',pass:await page.locator('#f-rho').evaluate(e=>e.checkValidity())});
 const special=await input(valid.replace('a,','__proto__,'));checks.push({name:'prototype cluster',pass:special.cells===2&&special.result.summary.every(s=>Number.isFinite(s.se))});
 const deps=await page.evaluate(()=>{const s=AlmStats;window.AlmStats=null;try{AlmRVE.summary({p:1,df:[2],beta:[1],se_robust:[1]});return false}catch(e){return true}finally{window.AlmStats=s}});checks.push({name:'missing Student-t dependency',pass:deps});
 await input(valid);
 const expectedExport=await page.evaluate(()=>__almLastRVE());
 const buttons=await page.locator('#alm-export-mount button').allTextContents();
 fs.mkdirSync(path.join(root,`downloads-${variant}`),{recursive:true});
 for(let i=0;i<buttons.length;i++){
  const [dl]=await Promise.all([page.waitForEvent('download'),page.locator('#alm-export-mount button').nth(i).click()]);
  const dest=path.join(root,`downloads-${variant}`,dl.suggestedFilename());await dl.saveAs(dest);
  checks.push({name:'download '+buttons[i],pass:fs.statSync(dest).size>0,file:dl.suggestedFilename()});
  if(dl.suggestedFilename().endsWith('.json'))checks.push({name:'JSON content equals displayed fit',pass:JSON.stringify(JSON.parse(fs.readFileSync(dest,'utf8')))===JSON.stringify(expectedExport)});
 }
 fs.writeFileSync(path.join(root,`ui-${variant}.json`),JSON.stringify(checks,null,2));
});
