### Name: dat.lee2004
### Title: Studies on Acupoint P6 Stimulation for Preventing Nausea
### Aliases: dat.lee2004
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.lee2004
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis based on log risk ratios
##D res <- rma(measure="RR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat)
##D res
##D predict(res, transf=exp, digits=2)
## End(Not run)



