### Name: dat.bartos2023
### Title: Results of 350,757 Coin Flips to Examine Same-Side Bias
### Aliases: dat.bartos2023
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.bartos2023
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### compute proportions and the corresponding sampling variances
##D dat <- escalc(measure="PR", xi=same, ni=flips, data=dat, slab=person)
##D dat
##D 
##D ### compute confidence intervals for the individual proportions (as in Table 1)
##D summary(dat, digits=3)[c(1,6:8,13,14)]
##D 
##D ### compute a confidence interval based on the column totals
##D summary(escalc(measure="PR", xi=sum(dat$same), ni=sum(dat$flips)), digits=3)
##D 
##D ### this is the same as meta-analyzing the proportions directly using an equal-effects
##D ### model and also computing the sampling variances under the assumption that the true
##D ### proportions are homogeneous
##D rma(measure="PR", xi=same, ni=flips, vtype="AV", method="EE", data=dat, digits=3)
##D 
##D ### fit a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### profile likelihood confidence interval for tau^2
##D confint(res, type="PL")
##D 
##D ### forest plot
##D forest(res, refline=0.5, xlim=c(0.38,0.72), digits=c(3,2), efac=c(0,1))
##D 
##D ### funnel plot
##D funnel(res, xlim=c(0.45,0.6), ylim=c(0,0.02))
##D 
##D ### fit a random-effects model excluding those with same-side proportions larger than 0.53
##D res <- rma(yi, vi, data=dat, subset=yi<=0.53)
##D res
##D confint(res, type="PL")
##D 
##D ### fit a binomial-normal model
##D res <- rma.glmm(measure="PLO", xi=same, ni=flips, data=dat)
##D res
##D predict(res, transf=plogis)
##D 
##D ### conduct a meta-analysis for the proportions of heads (to examine heads-tails bias)
##D dat <- escalc(measure="PR", xi=hdiff+hsame, ni=flips, data=dat)
##D res <- rma(yi, vi, data=dat)
##D res
##D confint(res, type="PL")
##D 
##D ### restructure the dataset for a bivariate meta-analysis of same-side and heads proportions
##D dat <- dat.bartos2023
##D dat <- dat[rep(1:nrow(dat), each=2),]
##D rownames(dat) <- NULL
##D dat$outcome <- c("heads", "same")
##D dat <- escalc(measure="PR", xi=hsame+hdiff, ni=flips, data=dat, include=outcome=="heads")
##D dat <- escalc(measure="PR", xi=hsame+tsame, ni=flips, data=dat, include=outcome=="same")
##D dat
##D 
##D ### construct the 2x2 variance-covariance matrix of the proportions within persons
##D dat$cov <- with(dat, (hsame/flips * (1-hsame/flips) - hsame/flips * tsame/flips -
##D                       hsame/flips * hdiff/flips - hdiff/flips * tsame/flips) / flips)
##D V <- lapply(split(dat, dat$person), \(x) matrix(c(x$vi[1], x$cov, x$vi[2]), nrow=2))
##D 
##D ### fit bivariate meta-analysis model
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome, random = ~ outcome | person, struct="UN", data=dat)
##D res
##D 
##D ### create plot with confidence ellipses ('ellipse' package must be installed)
##D library(ellipse)
##D plot(NA, xlim=c(0.45,0.62), ylim=c(0.45,0.62), bty="l", xlab="Pr(heads)", ylab="Pr(same)")
##D abline(h=0.5, lty="dotted")
##D abline(v=0.5, lty="dotted")
##D # add confidence ellipses for persons
##D invisible(tapply(dat, dat$person, \(x) {
##D    xy <- ellipse(matrix(c(x$vi[1],x$cov,x$vi[2]), nrow=2), centre=x$yi, level=0.95)
##D    lines(xy[,1],xy[,2], col="gray80")
##D }))
##D # add the points
##D invisible(tapply(dat, dat$person, \(x) points(x$yi[1], x$yi[2], pch=21, bg="gray80", cex=1.5)))
##D # add the 95% PI ellipsis based on the model
##D xy <- ellipse(res$G, centre=coef(res), level=0.95)
##D lines(xy[,1],xy[,2], col="gray30", lwd=3, lty="dotted")
##D # add the 95% CI ellipsis based on the model
##D xy <- ellipse(vcov(res), centre=coef(res), level=0.95)
##D lines(xy[,1],xy[,2], col="gray30", lwd=3)
##D # add the point for the pooled effects
##D points(coef(res)[1], coef(res)[2], pch=21, bg="gray40", cex=2)
## End(Not run)



