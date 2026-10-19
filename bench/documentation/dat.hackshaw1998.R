### Name: dat.hackshaw1998
### Title: Studies on the Risk of Lung Cancer in Women Exposed to
###   Environmental Tobacco Smoke
### Aliases: dat.hackshaw1998
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.hackshaw1998
head(dat, 10)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### random-effects model using the log odds ratios
##D res <- rma(yi, vi, data=dat, method="DL")
##D res
##D 
##D ### estimated average odds ratio with CI (and prediction interval)
##D predict(res, transf=exp, digits=2)
##D 
##D ### illustrate how the log odds ratios and corresponding sampling variances
##D ### can be back-calculated based on the reported odds ratios and CI bounds
##D dat$yi <- NULL
##D dat$vi <- NULL
##D dat <- data.frame(dat)
##D head(dat, 10)
##D dat <- conv.wald(out=or, ci.lb=or.lb, ci.ub=or.ub, data=dat, transf=log)
##D head(dat, 10)
## End(Not run)



