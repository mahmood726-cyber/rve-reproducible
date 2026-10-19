### Name: dat.fine1993
### Title: Studies on Radiation Therapy with or without Adjuvant
###   Chemotherapy in Patients with Malignant Gliomas
### Aliases: dat.fine1993
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.fine1993
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log(ORs) and sampling variances for each time point
##D dat <- escalc(measure="OR", ai=e1i, n1i=nei, ci=c1i, n2i=nci, data=dat, var.names=c("y1i","v1i"))
##D dat <- escalc(measure="OR", ai=e2i, n1i=nei, ci=c2i, n2i=nci, data=dat, var.names=c("y2i","v2i"))
##D dat <- escalc(measure="OR", ai=e3i, n1i=nei, ci=c3i, n2i=nci, data=dat, var.names=c("y3i","v3i"))
##D dat <- escalc(measure="OR", ai=e4i, n1i=nei, ci=c4i, n2i=nci, data=dat, var.names=c("y4i","v4i"))
##D 
##D ### calculate the covariances (equations in Appendix of Trikalinos & Olkin, 2012)
##D dat$v12i <- with(dat, nei / (e1i * (nei - e2i)) + nci / (c1i * (nci - c2i)))
##D dat$v13i <- with(dat, nei / (e1i * (nei - e3i)) + nci / (c1i * (nci - c3i)))
##D dat$v14i <- with(dat, nei / (e1i * (nei - e4i)) + nci / (c1i * (nci - c4i)))
##D dat$v23i <- with(dat, nei / (e2i * (nei - e3i)) + nci / (c2i * (nci - c3i)))
##D dat$v24i <- with(dat, nei / (e2i * (nei - e4i)) + nci / (c2i * (nci - c4i)))
##D dat$v34i <- with(dat, nei / (e3i * (nei - e4i)) + nci / (c3i * (nci - c4i)))
##D 
##D ### create dataset in long format
##D dat.long <- data.frame(study=rep(1:nrow(dat), each=4), time=1:4,
##D                        yi=c(t(dat[c("y1i","y2i","y3i","y4i")])),
##D                        vi=c(t(dat[c("v1i","v2i","v3i","v4i")])))
##D 
##D ### var-cov matrices of the studies
##D V <- lapply(split(dat, dat$study),
##D             function(x) matrix(c( x$v1i, x$v12i, x$v13i, x$v14i,
##D                                  x$v12i,  x$v2i, x$v23i, x$v24i,
##D                                  x$v13i, x$v23i,  x$v3i, x$v34i,
##D                                  x$v14i, x$v24i, x$v34i,  x$v4i), nrow=4, ncol=4, byrow=TRUE))
##D 
##D ### remove rows for the missing time points in study 17
##D dat.long <- na.omit(dat.long)
##D 
##D ### remove corresponding rows/columns from var-cov matrix
##D V[[17]] <- V[[17]][c(2,4),c(2,4)]
##D 
##D ### make a copy of V
##D Vc <- V
##D 
##D ### replace any (near) singular var-cov matrices with ridge corrected versions
##D repl.Vi <- function(Vi) {
##D    res <- eigen(Vi)
##D    if (any(res$values <= 0.08)) {
##D       round(res$vectors %*% diag(res$values + 0.08) %*% t(res$vectors), 12)
##D    } else {
##D       Vi
##D    }
##D }
##D Vc <- lapply(Vc, repl.Vi)
##D 
##D ### do not correct var-cov matrix of study 17
##D Vc[[17]] <- V[[17]]
##D 
##D ### construct block diagonal matrix
##D Vc <- bldiag(Vc)
##D 
##D ### multivariate fixed-effects model
##D res <- rma.mv(yi, Vc, mods = ~ 0 + factor(time), method="FE", data=dat.long)
##D print(res, digits=3)
##D 
##D ### multivariate random-effects model with heteroscedastic AR(1) structure for the true effects
##D res <- rma.mv(yi, Vc, mods = ~ 0 + factor(time), random = ~ time | study,
##D               struct="HAR", data=dat.long, control=list(optimizer="hjk"))
##D print(res, digits=3)
##D 
##D ### profile the variance components
##D par(mfrow=c(2,2))
##D profile(res, tau2=1, xlim=c(  0, 0.2))
##D profile(res, tau2=2, xlim=c(  0, 0.2))
##D profile(res, tau2=3, xlim=c(  0, 0.2))
##D profile(res, tau2=4, xlim=c(0.1, 0.3))
##D 
##D ### profile the autocorrelation coefficient
##D par(mfrow=c(1,1))
##D profile(res, rho=1)
## End(Not run)



