from pathlib import Path
import shutil
for f in ['corpus.R','metadata.R','json17.R','supplemental-exact.R']:
    shutil.copyfile(Path('../codex16')/f,f)
shutil.copytree('../codex16/documentation','documentation',dirs_exist_ok=True)
p=Path('metadata.R'); s=p.read_text(); a=s.index('  categorical <-'); b=s.index('\n }\n list(mapping=',a)
s=s[:a]+'''  scalar <- is.numeric(x)||is.factor(x)||is.character(x)||is.logical(x)
  if(scalar) {
   vals[[nm]] <- list(type=if(is.numeric(x)) 'numeric' else 'text',values=unname(if(is.factor(x)) as.character(x) else x))
   decisions[[nm]] <- 'retained for cluster and numeric predictor eligibility ledger'
  } else decisions[[nm]] <- 'structured non-scalar column'
'''+s[b:]; p.write_text(s,encoding='utf-8')
