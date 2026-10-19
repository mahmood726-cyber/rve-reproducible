### Name: dat.linde2005
### Title: Studies on the Effectiveness of St. John's Wort for Treating
###   Depression
### Aliases: dat.linde2005
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.linde2005
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### remove studies with no response information and study with no responses in either group
##D dat <- dat[-c(5,6,26),]
##D 
##D ### calculate log risk ratios and corresponding sampling variances
##D dat <- escalc(measure="RR", ai=ai, ci=ci, n1i=n1i, n2i=n2i, data=dat)
##D head(dat)
##D 
##D ### meta-analysis of the log risk ratios using a random-effects model
##D res <- rma(yi, vi, data=dat, method="DL")
##D res
##D 
##D ### mixed-effects meta-regression model with stratification variable
##D res <- rma(yi, vi, mods = ~ 0 + factor(group), data=dat, method="DL")
##D res
##D 
##D ### predicted average risk ratio for each level of the stratification variable
##D predict(res, newmods=diag(4), transf=exp, digits=2)
## End(Not run)



