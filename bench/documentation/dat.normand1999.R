### Name: dat.normand1999
### Title: Studies on the Length of Hospital Stay of Stroke Patients
### Aliases: dat.normand1999
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.normand1999
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate mean differences and corresponding sampling variances
##D dat <- escalc(measure="MD", m1i=m1i, sd1i=sd1i, n1i=n1i, m2i=m2i, sd2i=sd2i, n2i=n2i, data=dat)
##D dat
##D 
##D ### meta-analysis of mean differences using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### meta-analysis of standardized mean differences using a random-effects model
##D res <- rma(measure="SMD", m1i=m1i, sd1i=sd1i, n1i=n1i, m2i=m2i, sd2i=sd2i, n2i=n2i,
##D            data=dat, slab=source)
##D res
##D 
##D ### draw forest plot
##D forest(res, xlim=c(-7,5), alim=c(-3,1), header="Study/Source")
##D 
##D ### calculate (log transformed) ratios of means and corresponding sampling variances
##D dat <- escalc(measure="ROM", m1i=m1i, sd1i=sd1i, n1i=n1i, m2i=m2i, sd2i=sd2i, n2i=n2i, data=dat)
##D dat
##D 
##D ### meta-analysis of the (log transformed) ratios of means using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D predict(res, transf=exp, digits=2)
## End(Not run)



