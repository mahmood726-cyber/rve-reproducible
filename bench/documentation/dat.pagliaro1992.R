### Name: dat.pagliaro1992
### Title: Studies on the Effectiveness of Nonsurgical Treatments in
###   Cirrhosis
### Aliases: dat.pagliaro1992
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.pagliaro1992
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### restructure dataset to a contrast-based format
##D dat.c <- to.wide(dat, study="study", grp="trt", grpvars=3:4)
##D dat.c
##D 
##D ### Mantel-Haenszel results for beta-blockers and sclerotherapy versus control, respectively
##D rma.mh(measure="OR", ai=xi.1, n1i=ni.1, ci=xi.2, n2i=ni.2,
##D        data=dat.c, subset=(trt.1=="beta-blockers"), digits=2)
##D rma.mh(measure="OR", ai=xi.1, n1i=ni.1, ci=xi.2, n2i=ni.2,
##D        data=dat.c, subset=(trt.1=="sclerotherapy"), digits=2)
##D 
##D ### calculate log odds for each study arm
##D dat <- escalc(measure="PLO", xi=xi, ni=ni, data=dat)
##D dat
##D 
##D ### turn treatment variable into factor and set reference level
##D dat$trt <- relevel(factor(dat$trt), ref="control")
##D 
##D ### add a space before each level (this makes the output a bit more legible)
##D levels(dat$trt) <- paste0(" ", levels(dat$trt))
##D 
##D ### network meta-analysis using an arm-based random-effects model with fixed study effects
##D ### (by setting rho=1/2, tau^2 reflects the amount of heterogeneity for all treatment comparisons)
##D res <- rma.mv(yi, vi, mods = ~ 0 + factor(study) + trt, random = ~ trt | study, rho=1/2, data=dat)
##D res
##D 
##D ### average odds ratio comparing beta-blockers and sclerotherapy versus control, respectively
##D predict(res, newmods=c(rep(0,26), 1, 0), transf=exp, digits=2)
##D predict(res, newmods=c(rep(0,26), 0, 1), transf=exp, digits=2)
##D 
##D ### average odds ratio comparing beta-blockers versus sclerotherapy
##D predict(res, newmods=c(rep(0,26), 1, -1), transf=exp, digits=2)
## End(Not run)



