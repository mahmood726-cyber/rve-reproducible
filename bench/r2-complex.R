.libPaths(c(normalizePath('../re/Rlib_dta'),normalizePath('Rlib'),Sys.getenv('EXTRA_R_LIB'),.libPaths()))
library(jsonlite);source('json17.R')
f<-robumeta::robu
scope<-new.env(parent=environment(f))
scope$eigen<-function(x,...) {
 e<-base::eigen(x,...)
 if(!isSymmetric(x)) records[[length(records)+1]]<<-list(n=nrow(x),asym=max(abs(x-t(x))),scale=max(abs(x)),complex=is.complex(e$values),maxImag=max(abs(Im(e$values))),minReal=min(Re(e$values)))
 e
}
environment(f)<-scope
cs<-fromJSON('r2-complex-cases.json',simplifyVector=FALSE); out<-list()
for(c in cs) {
 records<-list(); rows<-c[['rows',exact=TRUE]]
 d<-data.frame(yi=sapply(rows,function(r)r$yi),vi=sapply(rows,function(r)r$vi),cl=sapply(rows,function(r)r$cluster),x=sapply(rows,function(r)r$X[[2]]))
 reason<-tryCatch({f(yi~x,data=d,studynum=cl,var.eff.size=vi,rho=c$rho,modelweights='CORR',small=TRUE);'ok'},error=function(e)conditionMessage(e))
 out[[length(out)+1]]<-list(id=c$id,reason=reason,nonsymmetric=records)
 write_json17(out,'r2-complex-trace.json')
}
