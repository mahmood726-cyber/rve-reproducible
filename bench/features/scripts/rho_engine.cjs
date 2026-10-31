const fs=require('fs'),path=require('path'),crypto=require('crypto');
const D=__dirname; require(path.join(D,'engine/stats-qt.js')); require(path.join(D,'engine/rve.js')); const E=require(path.join(D,'engine/rve-extras.js'));
const S=JSON.parse(fs.readFileSync(path.join(D,'rho_sample.json'),'utf8')); const out=path.join(D,'rho_engine.jsonl');
const done=fs.existsSync(out)?fs.readFileSync(out,'utf8').split(/\n/).filter(Boolean).length:0;
for(let i=done;i<S.length;i++){const r=E.rhoSensitivity(S[i].rows);fs.appendFileSync(out,JSON.stringify({design:S[i].design,fits:r.fits,flags:r.flags})+String.fromCharCode(10));if(i%25===0)console.log(i,new Date().toISOString());}
const h=f=>crypto.createHash('sha256').update(fs.readFileSync(path.join(D,'engine',f))).digest('hex');
fs.writeFileSync(path.join(D,'rho_engine_meta.json'),JSON.stringify({node:process.version,host:require('os').hostname(),hashes:{rve:h('rve.js'),statsqt:h('stats-qt.js'),extras:h('rve-extras.js')}}));console.log('DONE');
