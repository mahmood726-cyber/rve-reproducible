### Name: dat.curtis1998
### Title: Studies on the Effects of Elevated CO2 Levels on Woody Plant
###   Mass
### Aliases: dat.curtis1998
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.curtis1998
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate (log transformed) ratios of means and corresponding sampling variances
##D dat <- escalc(measure="ROM", m1i=m1i, sd1i=sd1i, n1i=n1i,
##D                              m2i=m2i, sd2i=sd2i, n2i=n2i, data=dat)
##D head(dat)
##D 
##D ### meta-analysis using a random-effects model
##D res <- rma(yi, vi, method="DL", data=dat)
##D res
##D 
##D ### average ratio of means with 95% CI
##D predict(res, transf=exp, digits=2)
##D 
##D ### meta-analysis for plants grown under nutrient stress
##D res <- rma(yi, vi, method="DL", data=dat, subset=(xtrt=="FERT" & level=="LOW"))
##D predict(res, transf=exp, digits=2)
##D 
##D ### meta-analysis for plants grown under low light conditions
##D res <- rma(yi, vi, method="DL", data=dat, subset=(xtrt=="LIGHT" & level=="LOW"))
##D predict(res, transf=exp, digits=2)
## End(Not run)



