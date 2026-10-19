### Name: dat.gibson2002
### Title: Studies on the Effectiveness of Self-Management Education and
###   Regular Medical Review for Adults with Asthma
### Aliases: dat.gibson2002
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.gibson2002
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### compute standardized mean differences and corresponding sampling variances
##D dat <- escalc(measure="SMD", m1i=m1i, sd1i=sd1i, n1i=n1i, m2i=m2i, sd2i=sd2i, n2i=n2i, data=dat)
##D dat
##D 
##D ### fit an equal-effects model to the standardized mean differences (as in Gibson et al., 2002)
##D res <- rma(yi, vi, data=dat, method="EE")
##D print(res, digits=2)
##D 
##D ### compute log risk ratios and corresponding sampling variances
##D dat <- escalc(measure="RR", ai=ai, bi=bi, ci=ci, di=di, data=dat)
##D dat
##D 
##D ### fit an equal-effects model to the log risk ratios
##D res <- rma(yi, vi, data=dat, method="EE")
##D print(res, digits=2)
##D predict(res, transf=exp, digits=2)
##D 
##D ### note: Gibson et al. (2002) used the Mantel-Haenszel method for their analysis
##D rma.mh(measure="RR", ai=ai, bi=bi, ci=ci, di=di, data=dat, digits=2)
##D 
##D ### compute standardized mean differences where possible and otherwise probit transformed
##D ### risk differences (which also provide estimates of the standardized mean differences)
##D dat <- escalc(measure="SMD", m1i=m1i, sd1i=sd1i, n1i=n1i,
##D                              m2i=m2i, sd2i=sd2i, n2i=n2i, data=dat, add.measure=TRUE)
##D dat <- escalc(measure="PBIT", ai=ai, bi=bi, ci=ci, di=di, data=dat, replace=FALSE, add.measure=TRUE)
##D dat
##D 
##D ### fit a random-effects model to these estimates
##D res <- rma(yi, vi, data=dat)
##D print(res, digits=2)
##D 
##D ### meta-regression model examining if there are systematic differences based on the
##D ### type of measure used (there are only 2 studies where measure="PBIT", so this isn't
##D ### very conclusive here, but shown for illustration purposes)
##D res <- rma(yi, vi, mods = ~ measure, data=dat)
##D print(res, digits=2)
##D predict(res, newmods=1, digits=2)
## End(Not run)



