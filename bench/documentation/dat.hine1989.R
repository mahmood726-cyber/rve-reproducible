### Name: dat.hine1989
### Title: Studies on Prophylactic Use of Lidocaine After a Heart Attack
### Aliases: dat.hine1989
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.hine1989
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate risk differences and corresponding sampling variances
##D dat <- escalc(measure="RD", n1i=n1i, n2i=n2i, ai=ai, ci=ci, data=dat)
##D dat
##D 
##D ### meta-analysis of risk differences using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
## End(Not run)



