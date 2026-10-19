### Name: dat.laopaiboon2015
### Title: Studies on the Effectiveness of Azithromycin for Treating Lower
###   Respiratory Tract Infections
### Aliases: dat.laopaiboon2015
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.laopaiboon2015
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### analysis using the Mantel-Haenszel method
##D rma.mh(measure="RR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, digits=3)
##D 
##D ### calculate log risk ratios and corresponding sampling variances
##D dat <- escalc(measure="RR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat)
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### average risk ratio with 95% CI
##D predict(res, transf=exp)
## End(Not run)



