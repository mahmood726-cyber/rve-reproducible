### Name: dat.debruin2009
### Title: Studies on Standard Care Quality and HAART-Adherence
### Aliases: dat.debruin2009
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.debruin2009
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate proportions and corresponding sampling variances
##D dat <- escalc(measure="PR", xi=xi, ni=ni, data=dat)
##D dat
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat)
##D print(res, digits=2)
##D 
##D ### mixed-effects meta-regression model with all predictors/covariates
##D res <- rma(yi, vi, mods = ~ scq + ethnicity + patients + select + sens, data=dat)
##D print(res, digits=3)
##D 
##D ### mixed-effects meta-regression model with scq and ethnicity as predictors/covariates
##D res <- rma(yi, vi, mods = ~ scq + ethnicity, data=dat)
##D print(res, digits=3)
## End(Not run)



