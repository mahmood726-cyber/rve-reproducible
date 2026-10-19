### Name: dat.damico2009
### Title: Studies on Topical plus Systemic Antibiotics to Prevent
###   Respiratory Tract Infections
### Aliases: dat.damico2009
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.damico2009
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis of the (log) odds ratios using the Mantel-Haenszel method
##D rma.mh(measure="OR", ai=xt, n1i=nt, ci=xc, n2i=nc, data=dat, digits=2)
##D 
##D ### calculate log odds ratios and corresponding sampling variances
##D dat <- escalc(measure="OR", ai=xt, n1i=nt, ci=xc, n2i=nc, data=dat)
##D 
##D ### meta-analysis using a random-effects model
##D res <- rma(yi, vi, data=dat, method="DL")
##D res
##D predict(res, transf=exp, digits=2)
## End(Not run)



