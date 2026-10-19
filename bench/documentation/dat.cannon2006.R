### Name: dat.cannon2006
### Title: Studies on the Effectiveness of Intensive Versus Moderate Statin
###   Therapy for Preventing Coronary Death or Myocardial Infarction
### Aliases: dat.cannon2006
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.cannon2006
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis of log odds ratios using the MH method for endpoint 1
##D res <- rma.mh(measure="OR", ai=ep1t, n1i=nt, ci=ep1c, n2i=nc, data=dat, slab=trial)
##D print(res, digits=2)
##D 
##D ### forest plot
##D forest(res, xlim=c(-.8,0.8), atransf=exp, at=log(c(2/3, 1, 3/2)),
##D        cex=1.2, xlab="Odds Ratio")
##D mtext("(high dose better)", side=1, line=par("mgp")[1]-0.5, at=log(2/3), cex=1.2, font=3)
##D mtext("(standard dose better)", side=1, line=par("mgp")[1]-0.5, at=log(3/2), cex=1.2, font=3)
## End(Not run)



