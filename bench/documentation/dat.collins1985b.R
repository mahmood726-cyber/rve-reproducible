### Name: dat.collins1985b
### Title: Studies on the Effects of Diuretics in Pregnancy
### Aliases: dat.collins1985b
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.collins1985b
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate (log) odds ratio and sampling variance
##D dat <- escalc(measure="OR", n1i=pre.nti, n2i=pre.nci, ai=pre.xti, ci=pre.xci, data=dat)
##D summary(dat, digits=2, transf=exp)
##D 
##D ### meta-analysis using Peto's method for any form of pre-eclampsia
##D rma.peto(n1i=pre.nti, n2i=pre.nci, ai=pre.xti, ci=pre.xci, data=dat, digits=2)
##D 
##D ### meta-analysis including only studies where oedema was not a diagnostic criterion
##D rma.peto(n1i=pre.nti, n2i=pre.nci, ai=pre.xti, ci=pre.xci, data=dat, digits=2, subset=(oedema==0))
##D 
##D ### meta-analyses of mortality outcomes (perinatal deaths, stillbirths, and neonatal deaths)
##D rma.peto(n1i=fup.nti, n2i=fup.nci, ai=ped.xti, ci=ped.xci, data=dat, digits=2)
##D rma.peto(n1i=fup.nti, n2i=fup.nci, ai=stb.xti, ci=stb.xci, data=dat, digits=2)
##D rma.peto(n1i=fup.nti, n2i=fup.nci, ai=ned.xti, ci=ned.xci, data=dat, digits=2)
## End(Not run)



