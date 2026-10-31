# Lane reference.R core, run on THIS host for two configurations, to separate host effects from script effects.
.libPaths(c('<HOST>/p101115/Rlib', .libPaths()))
library(jsonlite); library(robumeta); library(clubSandwich)
setwd('<HOST>/p101115/rveup'); source('json17.R')
cs <- fromJSON('host_check.json', simplifyVector=FALSE)
for (c in cs) {
  rows <- c$rows
  d<-data.frame(yi=vapply(rows,function(r)r[['yi',exact=TRUE]],0.0),vi=vapply(rows,function(r)r[['vi',exact=TRUE]],0.0),cl=vapply(rows,function(r)r[['cluster',exact=TRUE]],''))
  X<-do.call(rbind,lapply(rows,function(r)unlist(r[['X',exact=TRUE]])))
  d[['x']]<-X[,2]
  rr<-robu(yi~x,data=d,studynum=cl,var.eff.size=vi,modelweights='CORR',rho=c$rho,small=TRUE)
  tab<-rr$reg_table; cb<-as.data.frame(coef_test(rr,vcov='CR2',test='Satterthwaite'))
  write_json17(list(id=c$id,status='ok',table=unname(lapply(seq_len(nrow(tab)),function(j)as.list(tab[j,]))),tau2=as.numeric(rr$mod_info$tau.sq),club=cb),paste0('host_check_',c$name,'.json'))
}
cat(R.version.string, '\n'); print(extSoftVersion()); print(La_library()); print(sessionInfo()$BLAS)
