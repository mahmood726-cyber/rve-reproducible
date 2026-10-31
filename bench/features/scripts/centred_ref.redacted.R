# Centred-design R references for the pre-registered set (PREREG_CENTRING.md v2).
# Same robu/coef_test calls and guards as the lane's reference.R; adds kappa(XtWX, exact=TRUE)
# from robu's own fitted weights for the centred and the uncentred design, and echoes parsed X.
.libPaths(c('<HOST>/p101115/Rlib', .libPaths()))
library(jsonlite); library(robumeta); library(clubSandwich)
setwd('<HOST>/p101115/rveup'); source('json17.R')
dir.create('centred_ref', showWarnings=FALSE)
args <- commandArgs(TRUE); a <- as.integer(args[1]); b <- as.integer(args[2])
cs <- fromJSON('centred_configs.json', simplifyVector=FALSE)
b <- min(b, length(cs))
kap <- function(rr) {
  X <- rr[['X.full', exact=TRUE]]; w <- rr[['data.full', exact=TRUE]][['r.weights', exact=TRUE]]
  X <- as.matrix(X[, -1, drop=FALSE]) # drop study column
  XtWX <- crossprod(X, w * X)
  list(kappa=kappa(XtWX, exact=TRUE), kappa_sqrtw_svd=(function(s) (s[1]/s[length(s)])^2)(svd(sqrt(w) * X)$d))
}
fitone <- function(rows, rho) {
  d <- data.frame(yi=vapply(rows,function(r)r[['yi',exact=TRUE]],0.0),vi=vapply(rows,function(r)r[['vi',exact=TRUE]],0.0),cl=vapply(rows,function(r)r[['cluster',exact=TRUE]],''))
  X <- do.call(rbind,lapply(rows,function(r)unlist(r[['X',exact=TRUE]])))
  p <- ncol(X); m <- length(unique(d[['cl',exact=TRUE]]))
  if(p>1) d[['x']] <- X[,2]
  f <- if(p==1) yi~1 else yi~x
  rr <- tryCatch(robu(f,data=d,studynum=cl,var.eff.size=vi,modelweights='CORR',rho=rho,small=TRUE),error=function(e)e)
  list(rr=rr, X=X, d=d, m=m, p=p)
}
for (i in a:b) {
  c <- cs[[i]]; path <- file.path('centred_ref', sprintf('%04d.json', i)); if (file.exists(path)) next
  warnings <- character()
  res <- tryCatch(withCallingHandlers({
    o <- fitone(c[['centred_rows', exact=TRUE]], c[['rho', exact=TRUE]])
    rr <- o$rr
    if (inherits(rr,'error')) stop(conditionMessage(rr))
    if (o$m <= o$p) stop('m<=p: insufficient clusters for inference (audit domain guard)')
    if (qr(o$X)[['rank',exact=TRUE]] < o$p) stop('rank deficient design')
    tab <- rr[['reg_table',exact=TRUE]]
    cb <- tryCatch(as.data.frame(coef_test(rr,vcov='CR2',test='Satterthwaite')),error=function(e)list(error=conditionMessage(e)))
    k <- kap(rr)
    list(id=c[['id',exact=TRUE]], status='ok', table=unname(lapply(seq_len(nrow(tab)),function(j)as.list(tab[j,]))),
         tau2=as.numeric(rr[['mod_info',exact=TRUE]][['tau.sq',exact=TRUE]]), club=cb, m=o$m, p=o$p, n=nrow(o$d),
         kappa=k$kappa, kappa_sqrtw_svd=k$kappa_sqrtw_svd, x_echo=as.numeric(o$X[,ncol(o$X)]))
  }, warning=function(w){warnings<<-c(warnings,conditionMessage(w));invokeRestart('muffleWarning')}),
  error=function(e) list(id=c[['id',exact=TRUE]], status='refused', reason=conditionMessage(e)))
  # Uncentred kappa from robu's own weights (no table needed).
  u <- tryCatch({o2 <- fitone(c[['rows',exact=TRUE]], c[['rho',exact=TRUE]]); if (inherits(o2$rr,'error')) stop(conditionMessage(o2$rr)); kap(o2$rr)}, error=function(e) list(error=conditionMessage(e)))
  res[['uncentred_kappa']] <- u
  res[['warnings']] <- warnings
  write_json17(res, path)
  if (i %% 50 == 0) cat(i, '/', b, format(Sys.time()), '\n')
}
cat('DONE', a, b, format(Sys.time()), '\n')
