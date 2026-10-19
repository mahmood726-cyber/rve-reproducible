### Name: dat.aloe2013
### Title: Studies on the Association Between Supervision Quality and
###   Various Outcomes in Social, Mental Health, and Child Welfare Workers
### Aliases: dat.aloe2013
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.aloe2013
dat

## Not run: 
##D ### load metafor package
##D suppressPackageStartupMessages(library(metafor))
##D 
##D ### compute the partial correlation coefficients and corresponding sampling variances
##D dat <- escalc(measure="PCOR", ti=tval, ni=n, mi=preds, data=dat)
##D dat
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### mixed-effects meta-regression model examining the relationship between the partial
##D ### correlation coefficients and the number of predictors included in the models
##D res <- rma(yi, vi, mods = ~ preds, data=dat)
##D res
##D 
##D ### compute the r-to-z transformed partial correlation coefficients and their variances
##D dat <- escalc(measure="ZPCOR", ti=tval, ni=n, mi=preds, data=dat)
##D dat
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### back-transformation to the partial correlation scale
##D predict(res, transf=transf.ztor)
##D 
##D ### compute the semi-partial correlation coefficients and their variances
##D dat <- escalc(measure="SPCOR", ti=tval, ni=n, mi=preds, r2i=R2, data=dat)
##D dat
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
## End(Not run)



