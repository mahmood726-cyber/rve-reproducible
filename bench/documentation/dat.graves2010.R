### Name: dat.graves2010
### Title: Studies on the Effectiveness of Injected Cholera Vaccines
### Aliases: dat.graves2010
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.graves2010
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### analysis using the Mantel-Haenszel method
##D rma.mh(measure="RR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, digits=2)
## End(Not run)



