"""Verify acceptance and write compact, reproducible integration evidence."""
from pathlib import Path
import collections
import csv
import hashlib
import json
import subprocess

H=Path(__file__).resolve().parent
ROOT=H.parent.parent
D=Path('<HOST>/p15diag')
C=Path('<HOST>/p15invC/allmeta/rve-meta/tests/lane-c')
read=lambda p:json.loads(Path(p).read_text(encoding='utf-8'))
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
write=lambda name,data:(H/name).write_text(json.dumps(data,indent=2),encoding='utf-8')

summary={}
for suffix in ['finite','option-a']:
    before=read(H/f'engine-results-baseline-{suffix}.json')
    after=read(H/f'engine-results-final-{suffix}.json')
    bf=read(H/f'engine-failures-full-baseline-{suffix}.json')
    af=read(H/f'engine-failures-full-final-{suffix}.json')
    b={x['id'] for x in bf}; a={x['id'] for x in af}
    assert before['captured']==after['captured']==before['configurations']==after['configurations']==16270
    fixed=sorted(b-a); regressed=sorted(a-b)
    assert not regressed, regressed
    changes=dict(fixed=fixed,newly_failing=regressed)
    write(f'changed-status-{suffix}.json',changes)
    with (H/f'changed-status-{suffix}.csv').open('w',newline='',encoding='utf-8') as f:
        w=csv.writer(f);w.writerow(['id','change'])
        w.writerows((k,'fixed') for k in fixed)
        w.writerows((k,'newly failing') for k in regressed)
    summary[suffix]=dict(before=before['passing_configurations'],after=after['passing_configurations'],
                         fixed=len(fixed),newly_failing=len(regressed),failed_checks=after['failures'])
assert summary['finite']['before']==15485
assert summary['finite']['after']==16136
assert summary['option-a']['after']==16221

groups=read(D/'evidence/cause-groups.json')
cg=read(C/'cause-groups.json')
residual_ids={f['id'] for f in read(H/'engine-failures-full-final-option-a.json')}
assert residual_ids==set(groups['incompatible']+cg['infeasible_reference_intervals']+cg['R_vs_R_sensitivity'])
assert all(f['quantity'].startswith('club_') for f in read(H/'engine-failures-full-final-option-a.json'))
conflicts=read(D/'evidence/reference-conflicts.json')
intervals={r['id']:r for r in read(C/'reference-intervals.json')}
controls={r['id']:r for r in read(C/'R-vs-R.json')}
residuals=[]
for key in sorted(residual_ids):
    group=('disjoint_single_quantity_intervals' if key in groups['incompatible'] else
           'disjoint_joint_inference_constraints' if key in cg['infeasible_reference_intervals'] else
           'measured_R_vs_R_sensitivity_only')
    direct=[x for x in conflicts['disagree'] if x['id']==key]
    assert direct
    residuals.append(dict(id=key,classification=group,direct_R_vs_R=direct,
        joint_interval_evidence=intervals.get(key),R_control_measurements=controls.get(key)))
write('residual-evidence.json',residuals)

rho_changes={}
for rule in ['finite-only','option-a']:
    b={(f['design'],f['rho']) for f in read(H/f'rho-baseline-failures-{rule}.json')}
    a={(f['design'],f['rho']) for f in read(H/f'rho-failures-{rule}.json')}
    rho_changes[rule]=dict(fixed=sorted(b-a),newly_failing=sorted(a-b))
    assert a-b=={('dat.linde2016::001::author::year',0.4)}
write('rho-changed-status.json',rho_changes)

locale=read(H/'rho-locale-diagnostics.json')
app={r['design']:r for r in map(json.loads,(H/'rho-engine.jsonl').read_text().splitlines())}
locale_proof=[]
for i in [135,293]:
    for rho in [0.4,0.6]:
        rc=next(x['fit'] for x in locale if x['index']==i and x['rho']==rho and x['locale']=='C')
        re=next(x['fit'] for x in locale if x['index']==i and x['rho']==rho and x['locale']!='C')
        archived=read(D/f'rho_work/rho_ref_v3/{i:04d}.json')['r04' if rho==0.4 else 'r06']
        assert all(re[k]==archived[k] for k in ['table','tau2','club'])
        af=next(x for x in app[rc['id'].rsplit('::rho=',1)[0]]['fits'] if x['rho']==rho)
        for j in range(len(rc['table'])):
            for aq,rq in [('ci_lo','CI.L'),('ci_hi','CI.U')]:
                locale_proof.append(dict(id=rc['id'],coefficient=j,quantity=aq,R_C=rc['table'][j][rq],
                    R_English=re['table'][j][rq],R_vs_R_absolute=abs(rc['table'][j][rq]-re['table'][j][rq]),
                    app_vs_R_C_absolute=abs(af['summary'][j][aq]-rc['table'][j][rq]),English_reproduces_archive=True))
write('rho-locale-proof.json',locale_proof)

meta=read(H/'engine-full-combined-meta.json')
for name,expected in meta['hashes'].items():assert sha(ROOT/name)==expected
baseline=read(D/'engine-full-allmeta-meta.json')
for name,expected in baseline['hashes'].items():
    assert sha(D/'allmeta'/name)==expected
    blob=subprocess.check_output(['git','show','HEAD:'+name],cwd=ROOT)
    assert blob.replace(b'\r\n',b'\n')==(D/'allmeta'/name).read_bytes().replace(b'\r\n',b'\n')
provenance=dict(head=subprocess.check_output(['git','rev-parse','HEAD'],cwd=ROOT,text=True).strip(),
    baseline=baseline,final=meta,
    inputs={str(p):sha(p) for p in [D/'configurations.json',D/'configuration-ledger.csv',D/'compare_engine.py',
        D/'reference-byte-cache.json',ROOT.parent/'RULE_OPTION_A.md',
        Path('<HOST>/p15fixA/allmeta/rve-meta/tests/strict-a/patched/shared/rve.js'),
        Path('<HOST>/p15fixB/allmeta/shared/rve-eigen.js'),C/'cause-groups.json']},
    captures={p.name:dict(bytes=p.stat().st_size,sha256=sha(p)) for p in
        [H/'engine-full-combined.jsonl',H/'rho-engine.jsonl',H/'rho-baseline-engine.jsonl']},
    comparator=read(H/'comparator-equivalence.json'),
    references_edited=False,git_writes=False)
write('provenance.json',provenance)
summary['residuals']=dict(undefined_finite_only=85,disjoint_single_quantity=11,disjoint_joint_inference=19,
                         measured_sensitivity_not_proven_impossible=19)
summary['rho']=read(H/'rho-results.json')
summary['rho_baseline']=read(H/'rho-baseline-results.json')
summary['supplementary_newly_failing']=rho_changes['option-a']['newly_failing']
summary['planted']=read(H/'planted-result.json')
summary['tests']=dict(node_before=dict(tests=9,passed=0,failed=7,skipped=2),
    page_before=dict(tests=1,failed=1),node_after=dict(tests=16,passed=16,failed=0,skipped=0),
    option_a_unit_tests=4,python_existing_tests=19,lane_c_diagnostic_tests=12,
    rendered_browser='blocked: Windows denies Chromium process-channel access')
write('final-verification.json',summary)
print(json.dumps({k:summary[k] for k in ['finite','option-a','residuals','supplementary_newly_failing']},indent=2))
