### Name: dat.egger2001
### Title: Studies on the Effectiveness of Intravenous Magnesium in Acute
###   Myocardial Infarction
### Aliases: dat.egger2001
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.egger2001
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis of trials 1-7 using Peto's method (as in Teo et al., 1991)
##D res <- rma.peto(ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, subset=1:7)
##D print(res, digits=2)
##D 
##D ### meta-analysis of trials 1-7 and LIMIT-2 (as in Yusuf et al., 1993)
##D res <- rma.peto(ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, subset=c(1:7,14))
##D print(res, digits=2)
##D 
##D ### meta-analysis of all trials except ISIS-4
##D res <- rma.peto(ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, subset=-16)
##D print(res, digits=2)
##D predict(res, transf=exp, digits=2)
##D 
##D ### meta-analysis of all trials including ISIS-4
##D res <- rma.peto(ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat)
##D print(res, digits=2)
##D predict(res, transf=exp, digits=2)
##D 
##D ### contour-enhanced funnel plot centered at 0
##D funnel(res, refline=0, level=c(90, 95, 99), shade=c("white", "gray", "darkgray"))
## End(Not run)



