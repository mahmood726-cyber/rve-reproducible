### Name: dat.bornmann2007
### Title: Studies on Gender Differences in Grant and Fellowship Awards
### Aliases: dat.bornmann2007
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.bornmann2007
head(dat, 16)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log odds ratios and corresponding sampling variances
##D dat <- escalc(measure="OR", ai=waward, n1i=wtotal, ci=maward, n2i=mtotal, data=dat)
##D 
##D ### fit multilevel meta-analysis model
##D res <- rma.mv(yi, vi, random = ~ 1 | study/obs, data=dat)
##D res
##D 
##D ### estimated average odds ratio (with 95% CI/PI)
##D predict(res, transf=exp, digits=2)
##D 
##D ### test for a difference between fellowship and grant applications
##D res <- rma.mv(yi, vi, mods = ~ type, random = ~ 1 | study/obs, data=dat)
##D res
##D predict(res, newmods=0:1, transf=exp, digits=2)
## End(Not run)



