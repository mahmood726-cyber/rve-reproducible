### Name: dat.li2007
### Title: Studies on the Effectiveness of Intravenous Magnesium in Acute
###   Myocardial Infarction
### Aliases: dat.li2007
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.li2007
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analysis of all trials except ISIS-4
##D res <- rma(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, method="EE", subset=-14)
##D print(res, digits=2)
##D predict(res, transf=exp, digits=2)
##D 
##D ### meta-analysis of all trials including ISIS-4
##D res <- rma(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, method="EE")
##D print(res, digits=2)
##D predict(res, transf=exp, digits=2)
##D 
##D ### contour-enhanced funnel plot centered at 0
##D funnel(res, refline=0, level=c(90, 95, 99), shade=c("white", "gray", "darkgray"))
## End(Not run)



