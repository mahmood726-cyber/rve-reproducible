### Name: dat.lau1992
### Title: Studies on Intravenous Streptokinase for Acute Myocardial
###   Infarction
### Aliases: dat.lau1992
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.lau1992
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis of log odds ratios using the MH method
##D res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, slab=trial)
##D print(res, digits=2)
##D 
##D ### forest plot
##D forest(res, xlim=c(-11,9), atransf=exp, at=log(c(0.01, 0.1, 1, 10, 100)),
##D        ilab=dat$year, ilab.xpos=-7)
##D text(-7, 35, "Year", font=2)
##D 
##D ### cumulative meta-analysis
##D sav <- cumul(res)
##D 
##D ### forest plot of the cumulative results
##D forest(sav, xlim=c(-5,4), atransf=exp, at=log(c(0.1, 0.5, 1, 2, 10)),
##D        ilab=dat$year, ilab.xpos=-3)
##D text(-3, 35, "Year", font=2)
##D id <- c(4, 8, 15, 33) # rows for which the z/p-values should be shown (as in Lau et al., 1992)
##D text(1.1, (res$k:1)[id], paste0("z = ", fmtx(sav$zval[id], digits=2),
##D                                 fmtp(sav$pval[id], pname=", p", equal=TRUE, sep=TRUE, add0=TRUE)))
## End(Not run)



