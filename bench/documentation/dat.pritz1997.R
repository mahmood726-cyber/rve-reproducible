### Name: dat.pritz1997
### Title: Studies on the Effectiveness of Hyperdynamic Therapy for
###   Treating Cerebral Vasospasm
### Aliases: dat.pritz1997
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.pritz1997
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### computation of "weighted average" in Zhou et al. (1999), Table IV
##D dat <- escalc(measure="PR", xi=xi, ni=ni, data=dat, add=0)
##D theta.hat    <- sum(dat$ni * dat$yi) / sum(dat$ni)
##D se.theta.hat <- sqrt(sum(dat$ni^2 * dat$vi) / sum(dat$ni)^2)
##D ci.lb        <- theta.hat - 1.96 * se.theta.hat
##D ci.ub        <- theta.hat + 1.96 * se.theta.hat
##D round(c(estimate = theta.hat, se = se.theta.hat, ci.lb = ci.lb, ci.ub = ci.ub), 4)
##D 
##D ### this is identical to an equal-effects model with sample size weights
##D rma(yi, vi, weights=ni, method="EE", data=dat)
##D 
##D ### compute sampling variances under the assumption of homogeneity
##D dat <- escalc(measure="PR", xi=xi, ni=ni, data=dat, add=0, vtype="AV")
##D dat
##D 
##D ### fit equal-effects model (same estimate, but SE is slightly different)
##D rma(yi, vi, data=dat, method="EE")
##D 
##D ### under the assumption of homogeneity, the sum of independent binomial
##D ### counts also follows a binomial distribution; this approach yields the same
##D ### estimate and SE as above
##D agg <- escalc(measure="PR", xi=sum(dat$xi), ni=sum(dat$ni))
##D summary(agg)
##D 
##D ### could also compute an 'exact' CI based on the Clopper-Pearson method
##D binom.test(sum(dat$xi), sum(dat$ni))
##D 
##D ### logistic regression model
##D res <- rma.glmm(measure="PLO", xi=xi, ni=ni, data=dat, method="EE")
##D res
##D predict(res, transf=transf.ilogit)
##D 
##D ### the results above suggest that the true proportions may be heterogeneous
##D 
##D ### random-effects model with raw proportions
##D dat <- escalc(measure="PR", xi=xi, ni=ni, data=dat)
##D res <- rma(yi, vi, data=dat)
##D predict(res)
##D 
##D ### random-effects model with logit transformed proportions
##D dat <- escalc(measure="PLO", xi=xi, ni=ni, data=dat)
##D res <- rma(yi, vi, data=dat)
##D predict(res, transf=transf.ilogit)
##D 
##D ### mixed-effects logistic regression model
##D res <- rma.glmm(measure="PLO", xi=xi, ni=ni, data=dat)
##D predict(res, transf=transf.ilogit)
## End(Not run)



