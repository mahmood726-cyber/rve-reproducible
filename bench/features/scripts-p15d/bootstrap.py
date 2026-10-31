"""Prepare immutable input copies and the lane-local fixed-locale generator."""
import hashlib, json, shutil
from pathlib import Path

H = Path(__file__).resolve().parent
SRC = H.parent / 'p15/rveup'
E = H / 'evidence'
E.mkdir(exist_ok=True)
for name in ['rho_sample.json', 'rho_engine.jsonl', 'rho_engine_meta.json', 'PREREG_RHO.md', 'PREREG_RHO.md.sha256']:
    shutil.copyfile(SRC / name, H / name)
shutil.copyfile(H.parent / 'p15b/json17.R', H / 'json17.R')
source = (H.parent / 'p15b/rho_ref_v2.R').read_text()
header = '''# Post-preregistration reproducibility fix: explicit cluster-ordering locale.
print(Sys.setlocale("LC_COLLATE", "English_United States.utf8"))
print(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
stopifnot(Sys.getlocale("LC_COLLATE") == "English_United States.utf8",
          Sys.getlocale("LC_CTYPE") == "English_United States.utf8")
cat("LOCALE", Sys.getlocale(), "\\n")
stopifnot(as.character(getRversion()) == "4.6.0")
cat("R", as.character(getRversion()), "\\n")
'''
source = header + source.replace('rho_ref_v2', 'rho_ref_v3')
source = source.replace("  if(p>1)", "  cat('DESIGN', i, 'clusters', m, format(Sys.time()), '\\n'); flush.console()\n  if(m > 200) { cat('SKIP', i, m, 'not computable by robumeta on a 16 GB machine\\n'); next }\n  # Check available physical memory before every eligible large design.\n  if(m >= 100) {\n    mem <- system2('python', c('memory_check.py', as.character(i), as.character(m)), stdout=TRUE)\n    cat(mem, sep='\\n'); stopifnot(is.null(attr(mem, 'status')))\n  }\n  if(p>1)")
source = source.replace("write_json17(list(design=s$design, r04=one(0.4), r06=one(0.6), sens=sens), path)", "write_json17(list(design=s$design, r04=one(0.4), r06=one(0.6), sens=sens, locale=Sys.getlocale()), paste0(path, '.tmp'))\n  stopifnot(file.rename(paste0(path, '.tmp'), path))\n  cat('CHECKPOINT', i, format(Sys.time()), '\\n'); flush.console(); gc()")
(H / 'rho_ref_v3.R').write_text(source, encoding='utf-8')
samples = json.loads((H / 'rho_sample.json').read_text(encoding='utf-8'))
skips = [dict(index=i, design=s['design'], clusters=len({r['cluster'] for r in s['rows']}), reason='not computable by robumeta on a 16 GB machine') for i,s in enumerate(samples,1) if len({r['cluster'] for r in s['rows']}) > 200]
(E / 'skipped.json').write_text(json.dumps(skips, indent=2))
paths = list(SRC.glob('rho_ref/*.json')) + [SRC / n for n in ['rho_sample.json', 'rho_engine.jsonl', 'rho_engine_meta.json', 'PREREG_RHO.md', 'PREREG_RHO.md.sha256', 'compare_rho.py']] + [H.parent / 'p15b/rho_ref_v2.R', H.parent / 'p15b/json17.R']
(E / 'source_hashes.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}, indent=2))
(H / 'RESULT.md').write_text('''# P15D fixed-locale rho validation

Root cause: robumeta 2.1 orders clusters using locale-dependent factor levels, as established in ../p15c/ROOT_CAUSE.md. rho_ref_v3.R:1 explicitly fixes and prints LC_COLLATE and LC_CTYPE as English_United States.utf8, asserts R/package versions, and records Sys.getlocale() in every reference. This is a reproducibility fix after the preregistration; the sample, thresholds and comparator are unchanged. The corrected literal-formula sensitivity() call from p15b is retained.

bootstrap.py:1 copies inputs without changing them and records source hashes. rho_ref_v3.R uses the >200-cluster guard before fitting, checks memory for designs with >=100 clusters, and atomically checkpoints each file. Raw sensitivity output is retained, including its duplicate display-column names; a separate lossless transport view will supply unique keys to the unchanged comparator.

Coverage planned: 442/448 designs; six excluded designs are listed in evidence/skipped.json. Design 0312 has 1,653 clusters and its 8*m^3 allocation alone is 36,133,376,616 bytes. All six are recorded as not computable by robumeta on a 16 GB machine under the prescribed resource policy; this is not a fresh allocation-failure claim.

Step 1 prepared; generation and checks pending. Maximum one R process at a time. All writes remain in this lane.
''', encoding='utf-8')
print('Prepared 448 samples; eligible 442/448; skipped 6/448')
