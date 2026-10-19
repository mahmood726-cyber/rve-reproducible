### Name: dat.demir2022
### Title: Studies on the Reliability of the MIBS Scale
### Aliases: dat.demir2022
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.demir2022
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### transform the alpha values using the Bonett (2022) transformation
##D dat <- escalc(measure="ABT", ai=alpha, ni=n, mi=items, data=dat)
##D dat
##D 
##D ### meta-analysis using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### back-transform the results
##D predict(res, transf=transf.iabt, digits=2)
## End(Not run)



