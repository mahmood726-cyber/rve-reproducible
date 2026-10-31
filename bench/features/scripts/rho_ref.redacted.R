.libPaths(c('<HOST>/p101115/Rlib', .libPaths()))
library(jsonlite); library(robumeta); library(clubSandwich)
setwd('<HOST>/p101115/rveup'); source('json17.R'); dir.create('rho_ref', showWarnings=FALSE)
args <- commandArgs(TRUE); a <- as.integer(args[1]); b <- as.integer(args[2])
S <- fromJSON('rho_sample.json', simplifyVector=FALSE); b <- min(b, length(S))
for (i in a:b) {
  s <- S[[i]]; path <- file.path('rho_ref', sprintf('%04d.json', i)); if (file.exists(path)) next
  rows <- s$rows
  d<-data.frame(yi=vapply(rows,function(r)r[['yi',exact=TRUE]],0.0),vi=vapply(rows,function(r)r[['vi',exact=TRUE]],0.0),cl=vapply(rows,function(r)r[['cluster',exact=TRUE]],''))
  X<-do.call(rbind,lapply(rows,function(r)unlist(r[['X',exact=TRUE]]))); p<-ncol(X); m<-length(unique(d$cl))
  if(p>1)d[['x']]<-X[,2]; f<-if(p==1)yi~1 else yi~x
  one <- function(rho) tryCatch({
    rr<-robu(f,data=d,studynum=cl,var.eff.size=vi,modelweights='CORR',rho=rho,small=TRUE)
    if(m<=p)stop('m<=p: insufficient clusters for inference (audit domain guard)')
    if(qr(X)$rank<p)stop('rank deficient design')
    tab<-rr$reg_table; cb<-tryCatch(as.data.frame(coef_test(rr,vcov='CR2',test='Satterthwaite')),error=function(e)list(error=conditionMessage(e)))
    list(status='ok',table=unname(lapply(seq_len(nrow(tab)),function(j)as.list(tab[j,]))),tau2=as.numeric(rr$mod_info$tau.sq),club=cb)
  }, error=function(e) list(status='refused',reason=conditionMessage(e)))
  sens <- tryCatch({ rr<-robu(f,data=d,studynum=cl,var.eff.size=vi,modelweights='CORR',rho=0.8,small=TRUE); sv<-sensitivity(rr); invisible(NULL)
    lapply(seq_len(nrow(sv)), function(j) as.list(sv[j,]))}, error=function(e) list(error=conditionMessage(e)))
  write_json17(list(design=s$design, r04=one(0.4), r06=one(0.6), sens=sens), path)
  if (i %% 25 == 0) cat(i, format(Sys.time()), '\n')
}
cat('DONE', a, b, '\n')
