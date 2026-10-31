"""Run unchanged comparator, complete existing-reference coverage, and real plants."""
import ast, collections, copy, json, math, shutil, subprocess, sys
from pathlib import Path
from audit import H, E, ARCHIVE, S

def run_comparator(script, logpath):
    with logpath.open('w',encoding='utf-8') as log:
        p=subprocess.run([sys.executable,str(script)],cwd=H,stdout=log,stderr=subprocess.STDOUT)
    assert p.returncode==0, logpath.read_text(encoding='utf-8')[-4000:]
    data=script.parent/'compare_inputs'
    return json.loads((data/'rho_results.json').read_text()),json.loads((data/'rho_failures.json').read_text())

def full_lane():
    # Reuse the comparator's function AST verbatim; only enumerate the complete
    # original sample because existing lane references cover the six R exclusions.
    tree=ast.parse((H/'compare_rho.py').read_text())
    defs=ast.Module(body=[n for n in tree.body if isinstance(n,ast.FunctionDef)],type_ignores=[])
    stats={'lane_refs_0_02_08_1':collections.defaultdict(lambda:dict(checks=0,passes=0,max_difference=0.0))}
    ns=dict(collections=collections, math=math, stats=stats, fails=[])
    exec(compile(defs,'unchanged comparator functions','exec'),ns)
    engines=[json.loads(l) for l in (H/'rho_engine.jsonl').read_text().splitlines() if l.strip()]
    lane=Path('<HOST>/p101115/P15')
    for s,e in zip(S,engines):
        assert s['design']==e['design']
        fits={f['rho']:f for f in e['fits']}
        for rho,key in [(0,'0'),(.2,'0.2'),(.8,'0.8'),(1,'1')]:
            r=json.loads((lane/'reference'/f"{s['ref_index'][key]:06d}.json").read_text())
            ns['compare_fit']('lane_refs_0_02_08_1',s['known_failure'],s['design'],fits[rho],r)
    st=stats['lane_refs_0_02_08_1']
    out=dict(designs=len(S),checks=sum(v['checks'] for v in st.values()),passes=sum(v['passes'] for v in st.values()),failing_designs=len({f['design'] for f in ns['fails']}),failing_designs_not_known=len({f['design'] for f in ns['fails'] if not f['known_failure']}),quantities=dict(st))
    (E/'lane_all_results.json').write_text(json.dumps(out,indent=2))
    (E/'lane_all_failures.json').write_text(json.dumps(ns['fails'],indent=2))
    msg=f"Existing lane references, all 448 designs: {out['passes']}/{out['checks']}; failing designs {out['failing_designs']} (not known {out['failing_designs_not_known']})"
    (E/'lane_all.log').write_text(msg+'\n'); print(msg)

def plant_run(name,s,e,ref):
    dest=H/'plants'/name
    data=dest/'compare_inputs'
    (data/'rho_ref').mkdir(parents=True,exist_ok=True)
    shutil.copyfile(H/'compare_rho.py',dest/'compare_rho.py')
    (data/'rho_sample.json').write_text(json.dumps([s]),encoding='utf-8')
    (data/'rho_engine.jsonl').write_text(json.dumps(e)+'\n',encoding='utf-8')
    (data/'rho_ref/0001.json').write_bytes(ref)
    for n in ['PREREG_RHO.md.sha256','rho_engine_meta.json']: shutil.copyfile(H/n,data/n)
    return run_comparator(dest/'compare_rho.py',dest/'comparison.log')

def plants(failures):
    data=H/'compare_inputs'
    samples=json.loads((data/'rho_sample.json').read_text())
    engines=[json.loads(l) for l in (data/'rho_engine.jsonl').read_text().splitlines()]
    failed={f['design'] for f in failures}
    chosen=None
    for i,(s,e) in enumerate(zip(samples,engines),1):
        if s['known_failure'] or s['design'] in failed: continue
        f=next(f for f in e['fits'] if f['rho']==.4)
        for j,row in enumerate(f.get('summary',[])):
            if abs(row['estimate'])>1:
                chosen=i,s,e,j; break
        if chosen: break
    assert chosen
    i,s,e,j=chosen
    raw=(data/f'rho_ref/{i:04d}.json').read_bytes()
    baseline,bfails=plant_run('baseline',s,e,raw)
    assert not bfails
    changed=copy.deepcopy(e)
    fit=next(f for f in changed['fits'] if f['rho']==.4)
    old=fit['summary'][j]['estimate']
    fit['summary'][j]['estimate']=old*(1+1e-8)
    er,ef=plant_run('engine_relative',s,changed,raw)
    assert any(f['group']=='new_refs_04_06' and f['quantity']=='estimate' for f in ef)
    ref=json.loads(raw)
    picked=None
    for row in ref['sens']:
        if row['quantity'].strip()!='Coefficient': continue
        # First coefficient row, ordinary decimal notation, actual R print string.
        for col,sv in list(row.items())[2:]:
            v=sv.strip()
            if not v[-1].isdigit() or 'e' in v.lower(): continue
            rho=float(col.split('=')[1])
            app=next(f for f in e['fits'] if f['rho']==rho)['summary'][0]['estimate']
            decimals=len(v.split('.')[1]) if '.' in v else 0
            tol=.5*10**(-decimals)+1e-12
            assert abs(app-float(v))<=tol
            # Change exactly one unit in the final digit, without a carry.
            last=int(v[-1])
            for digit in [str(n) for n in (last+1,last-1) if 0<=n<=9]:
                changed_sv=v[:-1]+digit
                if digit!=v[-1] and abs(app-float(changed_sv))>tol:
                    row[col]=sv.replace(v,changed_sv)
                    picked=dict(column=col,before=sv,after=row[col],app=app,tolerance=tol,difference=abs(app-float(changed_sv)))
                    break
            if picked: break
        if picked: break
    assert picked
    sr,sf=plant_run('sensitivity_last_digit',s,e,json.dumps(ref).encode('utf-8'))
    assert len(sf)==1 and sf[0]['group']=='sensitivity_strings' and sf[0]['quantity']=='coefficient'
    out=dict(design=s['design'],baseline=dict(passes=sum(v['passes'] for v in baseline['groups'].values()),checks=sum(v['checks'] for v in baseline['groups'].values()),failures=bfails),engine=dict(before=old,after=fit['summary'][j]['estimate'],relative_perturbation=1e-8,detected=True,failures=ef),sensitivity=dict(**picked,detected=True,failures=sf),detected=2,total=2)
    (E/'plants.json').write_text(json.dumps(out,indent=2))
    msg=f"Plants: baseline {out['baseline']['passes']}/{out['baseline']['checks']}; engine +1e-8 relative detected 1/1; actual sensitivity string last digit detected 1/1; total 2/2"
    (E/'plants.log').write_text(msg+'\n'); print(msg)

if __name__=='__main__':
    results,failures=run_comparator(H/'compare_rho.py',E/'compare_rho.log')
    for group,v in results['groups'].items(): print(group, f"{v['passes']}/{v['checks']}")
    full_lane()
    plants(failures)
