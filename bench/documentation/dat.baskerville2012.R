### Name: dat.baskerville2012
### Title: Studies on the Effectiveness of Practice Facilitation
###   Interventions
### Aliases: dat.baskerville2012
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.baskerville2012
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### random-effects model
##D res <- rma(smd, sei=se, data=dat, method="DL")
##D print(res, digits=2)
##D 
##D ### funnel plot
##D funnel(res, xlab="Standardized Mean Difference", ylim=c(0,0.6))
##D 
##D ### rank and regression tests for funnel plot asymmetry
##D ranktest(res)
##D regtest(res)
##D 
##D ### meta-regression analyses examining various potential moderators
##D rma(smd, sei=se, mods = ~ score, data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ alloconc, data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ blind,    data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ itt,      data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ duration, data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ tailor,   data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ pperf,    data=dat, method="DL")
##D rma(smd, sei=se, mods = ~ I(meetings * hours), data=dat, method="DL")
## End(Not run)



