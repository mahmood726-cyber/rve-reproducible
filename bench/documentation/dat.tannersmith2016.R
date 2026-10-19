### Name: dat.tannersmith2016
### Title: Studies on the Relationship between School Motivation and
###   Criminal Behavior
### Aliases: dat.tannersmith2016
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.tannersmith2016
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### compute mean age variables within studies
##D dat$aget1 <- ave(dat$aget1, dat$studyid)
##D dat$aget2 <- ave(dat$aget2, dat$studyid)
##D 
##D ### construct an effect size identifier variable
##D dat$esid <- 1:nrow(dat)
##D 
##D ### construct an approximate var-cov matrix assuming a correlation of 0.8
##D ### for multiple coefficients arising from the same study
##D V <- vcalc(vi, cluster=studyid, obs=esid, rho=0.8, data=dat)
##D 
##D ### fit a multivariate random-effects model using the approximate var-cov matrix V
##D res <- rma.mv(yi, V, random = ~ esid | studyid, data=dat)
##D res
##D 
##D ### use cluster-robust inference methods
##D robust(res, cluster=studyid, clubSandwich=TRUE)
##D 
##D ### note: the results obtained above and below are slightly different compared
##D ### to those given by Tanner-Smith et al. (2016) since the approach illustrated
##D ### here makes use a multivariate random-effects model for the 'working model'
##D ### before applying the cluster-robust inference methods, while the results given
##D ### in the paper are based on a somewhat simpler working model
##D 
##D ### examine the main effects of the age variables
##D res <- rma.mv(yi, V, mods = ~ aget1 + aget2,
##D               random = ~ 1 | studyid/esid, data=dat)
##D robust(res, cluster=studyid, clubSandwich=TRUE)
##D 
##D ### also examine their interaction
##D res <- rma.mv(yi, V, mods = ~ aget1 * aget2,
##D               random = ~ 1 | studyid/esid, data=dat)
##D robust(res, cluster=studyid, clubSandwich=TRUE)
##D 
##D ### add the sexmix factor to the model
##D res <- rma.mv(yi, V, mods = ~ aget1 * aget2 + sexmix,
##D               random = ~ 1 | studyid/esid, data=dat)
##D robust(res, cluster=studyid, clubSandwich=TRUE)
## End(Not run)



