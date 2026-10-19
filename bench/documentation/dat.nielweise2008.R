### Name: dat.nielweise2008
### Title: Studies on Anti-Infective-Treated Central Venous Catheters for
###   Prevention of Catheter-Related Bloodstream Infections
### Aliases: dat.nielweise2008
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.nielweise2008
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### standard (inverse-variance) random-effects model
##D res <- rma(measure="IRR", x1i=x1i, t1i=t1i, x2i=x2i, t2i=t2i, data=dat)
##D print(res, digits=3)
##D predict(res, transf=exp, digits=2)
##D 
##D ### random-effects conditional Poisson model
##D res <- rma.glmm(measure="IRR", x1i=x1i, t1i=t1i, x2i=x2i, t2i=t2i, data=dat, model="CM.EL")
##D print(res, digits=3)
##D predict(res, transf=exp, digits=2)
## End(Not run)



