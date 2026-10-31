"""Byte controls, lossless comparator transport, and source-integrity checks."""
import ast, hashlib, json, shutil, sys
from pathlib import Path

H = Path(__file__).resolve().parent
E = H / 'evidence'
ARCHIVE = H.parent / 'p15/rveup'
S = json.loads((H / 'rho_sample.json').read_text(encoding='utf-8'))

def leaves(x, path=''):
    if isinstance(x, dict):
        for k,v in x.items(): yield from leaves(v, path + '/' + k)
    elif isinstance(x, list):
        for i,v in enumerate(x): yield from leaves(v, path + '/' + str(i))
    elif isinstance(x, (int,float)) and not isinstance(x,bool): yield path,x

def numeric_bytes(raw):
    return raw.split(b',"r04":',1)[1].split(b',"sens":',1)[0]

def control():
    rows = []
    for i,s in enumerate(S[:311],1):
        if len({r['cluster'] for r in s['rows']}) > 200: continue
        a = (ARCHIVE / f'rho_ref/{i:04d}.json').read_bytes()
        b = (H / f'rho_ref_v3/{i:04d}.json').read_bytes()
        aa,bb = json.loads(a),json.loads(b)
        assert aa['design'] == bb['design'] == s['design']
        av = dict(leaves({k:aa[k] for k in ['r04','r06']}))
        bv = dict(leaves({k:bb[k] for k in ['r04','r06']}))
        assert av.keys() == bv.keys()
        diffs = [dict(quantity=k, absolute=abs(v-bv[k]), relative=abs(v-bv[k])/max(1,abs(v))) for k,v in av.items()]
        rows.append(dict(index=i, design=s['design'], byte_equal=numeric_bytes(a)==numeric_bytes(b), numeric_fields=len(av), max_absolute=max([d['absolute'] for d in diffs],default=0), max_relative=max([d['relative'] for d in diffs],default=0), differences=[d for d in diffs if d['absolute']]))
    out = dict(eligible=len(rows), passes=sum(r['byte_equal'] for r in rows), numeric_fields=sum(r['numeric_fields'] for r in rows), exceptions=[r for r in rows if not r['byte_equal']], rows=rows)
    (E / 'control.json').write_text(json.dumps(out,indent=2))
    msg = f"Archived r04/r06 complete numeric blocks, byte for byte: {out['passes']}/{out['eligible']}; {out['numeric_fields']} numeric fields; exceptions {len(out['exceptions'])}"
    print(msg)
    (E / 'control.log').write_text(msg+'\n')
    with (H / 'RESULT.md').open('a',encoding='utf-8') as f: f.write('\nControl completed: '+msg+'. Design 0001 (317 clusters) excluded. See evidence/control.json for every file and any maximum differences.\n')
    assert out['passes']==out['eligible']==310

def comparator_source():
    source = (ARCHIVE / 'compare_rho.py').read_text(encoding='utf-8')
    # Only I/O locations change; the comparison loop and numerical logic remain verbatim.
    return source.replace('H = Path(__file__).resolve().parent', "H = Path(__file__).resolve().parent / 'compare_inputs'")

def prepare():
    dest = H / 'compare_inputs'
    (dest / 'rho_ref').mkdir(parents=True,exist_ok=True)
    engines = [json.loads(l) for l in (H / 'rho_engine.jsonl').read_text(encoding='utf-8').splitlines() if l.strip()]
    samples, eng, mapping, errors = [],[],[],[]
    restored = 0
    original_incomplete = 0
    strings_checked = 0
    for i,s in enumerate(S,1):
        p = H / f'rho_ref_v3/{i:04d}.json'
        if not p.exists():
            assert len({r['cluster'] for r in s['rows']}) > 200, f'Missing eligible {i}'
            continue
        raw = p.read_bytes()
        prefix,tail = raw.split(b',"sens":',1)
        revised = prefix+b',"sens":'+tail.replace(b'{" ":',b'{"label":').replace(b'," ":',b',"quantity":')
        r = json.loads(revised)
        assert r['design'] == s['design'] == engines[i-1]['design']
        assert 'LC_COLLATE=English_United States.utf8' in r['locale'] and 'LC_CTYPE=English_United States.utf8' in r['locale']
        assert numeric_bytes(raw)==numeric_bytes(revised)
        if isinstance(r['sens'], list):
            raw_pairs=json.loads(raw,object_pairs_hook=lambda pairs:pairs)
            sens_pairs=dict(raw_pairs)['sens']
            for before,after in zip(sens_pairs,r['sens']):
                assert [v for k,v in before]==list(after.values())
                assert len(after)==8 and list(after)[:2]==['label','quantity']
                strings_checked+=6
            original_incomplete += sum(len(row)==7 for row in json.loads(raw)['sens'])
            restored += len(r['sens'])
        else: errors.append(dict(index=i,design=s['design'],known_failure=s['known_failure'],error=r['sens']))
        j=len(samples)+1
        (dest / f'rho_ref/{j:04d}.json').write_bytes(revised)
        samples.append(s); eng.append(engines[i-1]); mapping.append(dict(comparator_index=j, original_index=i, design=s['design']))
    assert len(samples)==442
    (dest / 'rho_sample.json').write_text(json.dumps(samples),encoding='utf-8')
    (dest / 'rho_engine.jsonl').write_text('\n'.join(json.dumps(x) for x in eng)+'\n',encoding='utf-8')
    for name in ['rho_engine_meta.json','PREREG_RHO.md.sha256']: shutil.copyfile(H/name,dest/name)
    (H/'compare_rho.py').write_text(comparator_source(),encoding='utf-8')
    (E/'comparison_index.json').write_text(json.dumps(mapping,indent=2))
    out=dict(references=len(samples),sample=len(S),known_failure_designs=sum(s['known_failure'] for s in samples),sensitivity_errors=errors,original_complete_rows=0,original_incomplete_rows=original_incomplete,normalized_complete_rows=restored,strings_unchanged=strings_checked)
    (E/'coverage.json').write_text(json.dumps(out,indent=2))
    print(f'Coverage {len(samples)}/448; transport complete rows before 0/{original_incomplete}, after {restored}/{restored}; unchanged strings {strings_checked}/{strings_checked}')

def integrity():
    before=json.loads((E/'source_hashes.json').read_text())
    assert all(hashlib.sha256(Path(p).read_bytes()).hexdigest()==v for p,v in before.items())
    assert (H/'PREREG_RHO.md').read_bytes()==(ARCHIVE/'PREREG_RHO.md').read_bytes()
    digest=hashlib.sha256((H/'PREREG_RHO.md').read_bytes()).hexdigest()
    assert digest in (H/'PREREG_RHO.md.sha256').read_text()
    def logic(source):
        tree=ast.parse(source)
        tree.body=[n for n in tree.body if not (isinstance(n,ast.Assign) and isinstance(n.targets[0],ast.Name) and n.targets[0].id in ['H','LANE'])]
        return ast.dump(tree)
    assert logic((H/'compare_rho.py').read_text())==logic((ARCHIVE/'compare_rho.py').read_text())
    msg=f'Supplied source hashes unchanged {len(before)}/{len(before)}; comparator logic unchanged 1/1; prereg hash 1/1'
    (E/'integrity.log').write_text(msg+'\n'); print(msg)

if __name__=='__main__':
    {'control':control,'prepare':prepare,'integrity':integrity}[sys.argv[1]]()
