### Name: dat.hahn2001
### Title: Studies on the Effectiveness of Different Rehydration Solutions
###   for the Prevention of Unscheduled Intravenous Infusion in Children
###   with Diarrhoea
### Aliases: dat.hahn2001
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.hahn2001
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis of (log) odds rations using the Mantel-Haenszel method
##D res <- rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, digits=2, slab=study)
##D res
##D 
##D ### forest plot (also show studies that were excluded from the analysis)
##D options(na.action="na.pass")
##D forest(res, atransf=exp, xlim=c(-11,9), at=log(c(0.01, 0.1, 1, 10, 100)))
##D options(na.action="na.omit")
## End(Not run)



