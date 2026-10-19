### Name: dat.bonett2010
### Title: Studies on the Reliability of the CES-D Scale
### Aliases: dat.bonett2010
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.bonett2010
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis using the raw alpha values
##D res <- rma(measure="ARAW", ai=ai, mi=mi, ni=ni, data=dat)
##D res
##D 
##D ### meta-analysis using transformed alpha values (using the
##D ### transformation suggested by Hakstian & Whalen, 1976)
##D res <- rma(measure="AHW", ai=ai, mi=mi, ni=ni, data=dat)
##D res
##D predict(res, transf=transf.iahw)
##D 
##D ### meta-analysis using transformed alpha values (using the
##D ### transformation suggested by Bonett, 2002)
##D res <- rma(measure="ABT", ai=ai, mi=mi, ni=ni, data=dat)
##D res
##D predict(res, transf=transf.iabt)
##D 
##D ### forest plot
##D forest(res, slab=source, xlim=c(0,4.5),
##D        atransf=transf.iabt, refline=coef(res))
##D 
##D ### examine whether female/mixed samples yield different alphas (with raw alphas)
##D res <- rma(measure="ARAW", ai=ai, mi=mi, ni=ni, mods = ~ caregivers, data=dat)
##D res
##D predict(res, newmods=c(0,1), digits=2)
## End(Not run)



