### Name: dat.dagostino1998
### Title: Studies on the Effectiveness of Antihistamines in Reducing
###   Symptoms of the Common Cold
### Aliases: dat.dagostino1998
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.dagostino1998
head(dat, 16)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### compute standardized mean differences and corresponding sampling variances
##D dat <- escalc(measure="SMD", m1i=mt, m2i=mc, sd1i=sdt, sd2i=sdc, n1i=nt, n2i=nc, data=dat,
##D               add.measure=TRUE)
##D 
##D ### compute log odds ratios and corresponding sampling variances
##D dat <- escalc(measure="OR",  ai=xt, ci=xc, n1i=nt, n2i=nc, data=dat,
##D               replace=FALSE, add.measure=TRUE, add=1/2, to="all")
##D 
##D ### inspect data for the first study
##D head(dat, 8)
##D 
##D ### fit a random-effects model for incremental change in runny nose severity at day 1
##D res <- rma(yi, vi, data=dat, subset=outcome=="rnic1")
##D res
##D 
##D ### fit a random-effects model for reaching the goal of therapy for runny nose severity at day 1
##D res <- rma(yi, vi, data=dat, subset=outcome=="rngoal1")
##D res
##D predict(res, transf=exp)
##D 
##D ### construct approximate V matrix assuming a correlation of 0.7 for sampling errors within studies
##D dat$esid <- ave(dat$study, dat$study, FUN=seq)
##D V <- vcalc(vi, cluster=study, obs=esid, rho=0.7, data=dat)
##D 
##D ### fit a model for incremental change in runny nose severity at day 1 and at day 2, allowing for
##D ### correlated sampling errors (no random effects added, since there does not appear to be any
##D ### noteworthy heterogeneity in these data)
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome, data=dat, subset=outcome %in% c("rnic1","rnic2"))
##D res
##D 
##D ### test if there is a difference in effects at day 1 and day 2
##D anova(res, X=c(1,-1))
## End(Not run)



