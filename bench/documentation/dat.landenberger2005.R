### Name: dat.landenberger2005
### Title: Studies on the Effectiveness of CBT for Reducing Recidivism
### Aliases: dat.landenberger2005
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.landenberger2005
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log odds ratios (for non-recidivism in CBT vs. control groups) and sampling variances
##D dat <- escalc(measure="OR", ai=n.cbt.non, bi=n.cbt.rec, ci=n.ctrl.non, di=n.ctrl.rec, data=dat)
##D 
##D ### fit random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### estimated average OR and corresponding 95% CI/PI
##D predict(res, transf=exp, digits=2)
##D 
##D ### examine if number of treatment sessions per week is a potential moderator
##D res <- rma(yi, vi, mods = ~ sessions, data=dat)
##D res
##D 
##D ### predicted ORs for 1, 2, 5, or 10 sessions per week
##D predict(res, newmods=c(1,2,5,10), transf=exp, digits=2)
## End(Not run)



