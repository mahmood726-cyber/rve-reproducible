### Name: dat.assink2016
### Title: Studies on the Association between Recidivism and Mental Health
### Aliases: dat.assink2016
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.assink2016
head(dat, 9)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### fit multilevel model
##D res <- rma.mv(yi, vi, random = ~ 1 | study/esid, data=dat)
##D res
##D 
##D ### use cluster-robust inference methods
##D robust(res, cluster=study, clubSandwich=TRUE)
##D 
##D ### LRTs for the variance components
##D res0 <- rma.mv(yi, vi, random = ~ 1 | study/esid, data=dat, sigma2=c(0,NA))
##D anova(res0, res)
##D res0 <- rma.mv(yi, vi, random = ~ 1 | study/esid, data=dat, sigma2=c(NA,0))
##D anova(res0, res)
##D 
##D ### examine some potential moderators via meta-regression
##D rma.mv(yi, vi, mods = ~ pubstatus, random = ~ 1 | study/esid, data=dat)
##D rma.mv(yi, vi, mods = ~ year, random = ~ 1 | study/esid, data=dat)
##D dat$deltype <- relevel(factor(dat$deltype), ref="general")
##D rma.mv(yi, vi, mods = ~ deltype, random = ~ 1 | study/esid, data=dat)
##D rma.mv(yi, vi, mods = ~ year + deltype, random = ~ 1 | study/esid, data=dat)
##D 
##D ### assume that the effect sizes within studies are correlated with rho=0.6
##D V <- vcalc(vi, cluster=study, obs=esid, data=dat, rho=0.6)
##D round(V[dat$study %in% c(1,2), dat$study %in% c(1,2)], 4)
##D 
##D ### fit multilevel model using this approximate V matrix
##D res <- rma.mv(yi, V, random = ~ 1 | study/esid, data=dat)
##D res
##D 
##D ### use cluster-robust inference methods
##D robust(res, cluster=study, clubSandwich=TRUE)
##D 
##D ### use a correlation of 0.7 for effect sizes corresponding to the same type of
##D ### delinquent behavior and a correlation of 0.5 for effect sizes corresponding
##D ### to different types of delinquent behavior
##D V <- vcalc(vi, cluster=study, type=deltype, obs=esid, data=dat, rho=c(0.7, 0.5))
##D 
##D ### fit multilevel model using this approximate V matrix
##D res <- rma.mv(yi, V, random = ~ 1 | study/esid, data=dat)
##D res
##D 
##D ### use cluster-robust inference methods
##D robust(res, cluster=study, clubSandwich=TRUE)
## End(Not run)



