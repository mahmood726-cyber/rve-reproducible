### Name: dat.riley2003
### Title: Studies on MYC-N as a Prognostic Marker for Neuroblastoma
### Aliases: dat.riley2003
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.riley2003
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### random-effects model analysis for outcome DFS
##D res <- rma(yi, sei=sei, data=dat, subset=(outcome == "DFS"), method="DL")
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### random-effects model analysis for outcome OS
##D res <- rma(yi, sei=sei, data=dat, subset=(outcome == "OS"), method="DL")
##D res
##D predict(res, transf=exp, digits=2)
## End(Not run)



