### Name: dat.dorn2007
### Title: Studies on Complementary and Alternative Medicine for Irritable
###   Bowel Syndrome
### Aliases: dat.dorn2007
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.dorn2007
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log risk ratios and corresponding sampling variances
##D dat <- escalc(measure="RR", ai=x.a, n1i=n.a, ci=x.p, n2i=n.p, data=dat)
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat, digits=2, method="DL")
##D res
##D 
##D ### estimated average risk ratio
##D predict(res, transf=exp)
##D 
##D ### funnel plot with study 5 highlighted in red
##D funnel(res, atransf=exp, at=log(c(0.1, 0.2, 0.5, 1, 2, 5, 10)),
##D        ylim=c(0,1), steps=6, las=1, col=ifelse(id == 5, "red", "black"))
##D 
##D ### change log risk ratio for study 5
##D dat$yi[5] <- -0.44
##D 
##D ### results are now more in line with what is reported in the paper
##D ### (although the CI in the paper is not wide enough)
##D res <- rma(yi, vi, data=dat, digits=2, method="DL")
##D predict(res, transf=exp)
##D 
##D ### funnel plot with study 5 highlighted in red
##D funnel(res, atransf=exp, at=log(c(0.1, 0.2, 0.5, 1, 2, 5, 10)),
##D        ylim=c(0,1), steps=6, las=1, col=ifelse(id == 5, "red", "black"))
## End(Not run)



