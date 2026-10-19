### Name: dat.nielweise2007
### Title: Studies on Anti-Infective-Treated Central Venous Catheters for
###   Prevention of Catheter-Related Bloodstream Infections
### Aliases: dat.nielweise2007
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.nielweise2007
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### standard (inverse-variance) random-effects model
##D res <- rma(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, drop00=TRUE)
##D print(res, digits=3)
##D predict(res, transf=exp, digits=2)
##D 
##D ### random-effects conditional logistic model
##D res <- rma.glmm(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, model="CM.EL")
##D print(res, digits=3)
##D predict(res, transf=exp, digits=2)
## End(Not run)



