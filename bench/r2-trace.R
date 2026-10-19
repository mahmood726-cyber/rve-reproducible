.libPaths(c(normalizePath('../re/Rlib_dta'),normalizePath('Rlib'),Sys.getenv('EXTRA_R_LIB'),.libPaths()))
library(jsonlite)
source('json17.R')
cs<-fromJSON('r2-small.json',simplifyVector=FALSE)
f<-robumeta::robu
body(f)<-as.call(c(as.list(body(f))[1],quote(on.exit({
 nms<-c('sumXWX','sumXWy','b','Qe','denom','termA','termB','tau.sq','sumXWX.r','b.r','Q','ImHii','A.MBB','dfs','SE','VR.r')
 vals<-mget(nms,envir=environment(),ifnotfound=list(NULL))
 vals$weights<-data.full$r.weights
 vals$residuals<-data.full$e.r
 write_json17(vals,paste0('r2-trace-',caseindex,'.json'))
})),as.list(body(f))[-1]))
for(caseindex in seq_along(cs)) {
 c<-cs[[caseindex]]; rows<-c[['rows',exact=TRUE]]
 d<-data.frame(yi=sapply(rows,function(r)r$yi),vi=sapply(rows,function(r)r$vi),cl=sapply(rows,function(r)r$cluster),x=sapply(rows,function(r)r$X[[2]]))
 f(yi~x,data=d,studynum=cl,var.eff.size=vi,rho=c$rho,modelweights='CORR',small=TRUE)
}
