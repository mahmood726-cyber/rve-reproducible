# Post-preregistration reproducibility fix: explicit cluster-ordering locale.
print(Sys.setlocale("LC_COLLATE", "English_United States.utf8"))
print(Sys.setlocale("LC_CTYPE", "English_United States.utf8"))
stopifnot(Sys.getlocale("LC_COLLATE") == "English_United States.utf8",
          Sys.getlocale("LC_CTYPE") == "English_United States.utf8")
cat("LOCALE", Sys.getlocale(), "\n")
stopifnot(as.character(getRversion()) == "4.6.0")
cat("R", as.character(getRversion()), "\n")
expected <- c(robumeta='2.1', clubSandwich='0.7.0', jsonlite='2.0.0')
for (pkg in names(expected)) { v <- as.character(packageVersion(pkg)); cat(pkg, v, '\n'); stopifnot(v == expected[[pkg]]) }

library(jsonlite); library(robumeta); library(clubSandwich)
source('json17.R'); dir.create('rho_ref_v3', showWarnings=FALSE)
args <- commandArgs(TRUE); a <- as.integer(args[1]); b <- as.integer(args[2])
S <- fromJSON('rho_sample.json', simplifyVector=FALSE); b <- min(b, length(S))
for (i in a:b) {
  s <- S[[i]]; path <- file.path('rho_ref_v3', sprintf('%04d.json', i)); if (file.exists(path)) next
  rows <- s$rows
  d<-data.frame(yi=vapply(rows,function(r)r[['yi',exact=TRUE]],0.0),vi=vapply(rows,function(r)r[['vi',exact=TRUE]],0.0),cl=vapply(rows,function(r)r[['cluster',exact=TRUE]],''))
  X<-do.call(rbind,lapply(rows,function(r)unlist(r[['X',exact=TRUE]]))); p<-ncol(X); m<-length(unique(d$cl))
  cat('DESIGN', i, 'clusters', m, format(Sys.time()), '\n'); flush.console()
  if(m > 200) { cat('SKIP', i, m, 'not computable by robumeta on a 16 GB machine\n'); next }
  # Check available physical memory before every eligible large design.
  if(m >= 100) {
    mem <- system2('python', c('memory_check.py', as.character(i), as.character(m)), stdout=TRUE)
    cat(mem, sep='\n'); stopifnot(is.null(attr(mem, 'status')))
  }
  if(p>1)d[['x']]<-X[,2]; f<-if(p==1)yi~1 else yi~x
  one <- function(rho) tryCatch({
    rr<-eval(bquote(robu(.(f),data=d,studynum=cl,var.eff.size=vi,modelweights='CORR',rho=rho,small=TRUE)))
    if(m<=p)stop('m<=p: insufficient clusters for inference (audit domain guard)')
    if(qr(X)$rank<p)stop('rank deficient design')
    tab<-rr$reg_table; cb<-tryCatch(as.data.frame(coef_test(rr,vcov='CR2',test='Satterthwaite')),error=function(e)list(error=conditionMessage(e)))
    list(status='ok',table=unname(lapply(seq_len(nrow(tab)),function(j)as.list(tab[j,]))),tau2=as.numeric(rr$mod_info$tau.sq),club=cb)
  }, error=function(e) list(status='refused',reason=conditionMessage(e)))
  sens <- tryCatch({ rr<-eval(bquote(robu(.(f),data=d,studynum=cl,var.eff.size=vi,modelweights='CORR',rho=0.8,small=TRUE))); sv<-sensitivity(rr); invisible(NULL)
    lapply(seq_len(nrow(sv)), function(j) as.list(sv[j,]))}, error=function(e) list(error=conditionMessage(e)))
  write_json17(list(design=s$design, r04=one(0.4), r06=one(0.6), sens=sens, locale=Sys.getlocale()), paste0(path, '.tmp'))
  stopifnot(file.rename(paste0(path, '.tmp'), path))
  cat('CHECKPOINT', i, format(Sys.time()), '\n'); flush.console(); gc()
  if (i %% 25 == 0) cat(i, format(Sys.time()), '\n')
}
cat('DONE', a, b, '\n')
