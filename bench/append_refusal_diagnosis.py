from pathlib import Path
import json, collections
p=Path('STRICT_DIAGNOSIS.md')
d=json.loads(Path('strict-diagnosis.json').read_text(encoding='utf-8'))['patched']
pairs=collections.Counter((c['app_reason'],c['reference_reason']) for c in d['cases'] if c['category']=='refusal reason disagreement')
lines=['\n## Refusal source diagnosis\n', 'reference.R calls robu before its audit m<=p and rank guards. The R2 engine attempts the initial normal-equation solve before its m<=p guard; the guard still precedes CR2 eigen calculations. Consequently, a design failing both conditions can yield a different first refusal. The observed pairs below remain strict failures; the audit does not reorder R errors or waive them.\n', '| App refusal | R refusal | Cases |', '|---|---|---:|']
lines += [f'| {a} | {r} | {n} |' for (a,r),n in pairs.items()]
lines += ['\nAccepted-by-app / refused-by-R cases (unresolved):\n']
lines += [f"- `{c['id']}`: R reports `{c['reference_reason']}`." for c in d['cases'] if c['category']=='acceptance/refusal disagreement']
lines += ['\nThe R2 trace (r2-complex-trace.json) shows that tiny asymmetries send R into its nonsymmetric eigensolver; tiny imaginary eigenvalues then cause robu to fail its real-valued cutoff comparison. The engine uses a symmetric eigensolver. Remaining cases are retained as failures, with no case-specific refusal heuristic.\n']
text=p.read_text(encoding='utf-8').split('\n## Refusal source diagnosis')[0]
p.write_text(text+'\n'.join(lines),encoding='utf-8')
print('Refusal source diagnosis:',sum(pairs.values()),'reason mismatches and',sum(c['category']=='acceptance/refusal disagreement' for c in d['cases']),'status mismatches retained')
