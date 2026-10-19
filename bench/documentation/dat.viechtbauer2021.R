### Name: dat.viechtbauer2021
### Title: Studies to Illustrate Model Checking Methods
### Aliases: dat.viechtbauer2021
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.viechtbauer2021
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log odds ratios and corresponding sampling variances
##D 
##D dat <- escalc(measure="OR", ai=xTi, n1i=nTi, ci=xCi, n2i=nCi, add=1/2, to="all", data=dat)
##D dat
##D 
##D ### number of studies
##D 
##D k <- nrow(dat)
##D 
##D ### fit models
##D 
##D res.CE <- rma(yi, vi, data=dat, method="CE") # same as method="EE"
##D res.CE
##D 
##D res.RE <- rma(yi, vi, data=dat, method="DL")
##D res.RE
##D 
##D res.MR <- rma(yi, vi, mods = ~ dose, data=dat, method="FE")
##D res.MR
##D 
##D res.ME <- rma(yi, vi, mods = ~ dose, data=dat, method="DL")
##D res.ME
##D 
##D ### forest and bubble plot
##D 
##D par(mar=c(5,4,1,2))
##D 
##D forest(dat$yi, dat$vi, psize=0.8, efac=0, xlim=c(-4,6), ylim=c(-3,23),
##D        cex=1, width=c(5,5,5), xlab="Log Odds Ratio (LnOR)",
##D        header=c("Trial", "LnOR [95% CI]"))
##D addpoly(res.CE, row=-1, mlab="CE Model")
##D addpoly(res.RE, row=-2, mlab="RE Model")
##D abline(h=0)
##D 
##D tmp <- regplot(res.ME, xlim=c(0,250), ylim=c(-1,1.5), predlim=c(0,250), shade=FALSE, digits=1,
##D                xlab="Dosage (mg per day)", psize="seinv", plim=c(NA,5), bty="l", las=1,
##D                lty=c("solid", "dashed"), label=TRUE, labsize=0.8, offset=c(1,0.7))
##D res.sub <- rma(yi, vi, mods = ~ dose, data=dat, method="DL", subset=-6)
##D abline(res.sub, lty="dotted")
##D points(tmp$xi, tmp$yi, pch=21, cex=tmp$psize, col="black", bg="darkgray")
##D 
##D par(mar=c(5,4,4,2))
##D 
##D ### number of standardized deleted residuals larger than +-1.96 in each model
##D 
##D sum(abs(rstudent(res.CE)$z) >= qnorm(0.975))
##D sum(abs(rstudent(res.MR)$z) >= qnorm(0.975))
##D sum(abs(rstudent(res.RE)$z) >= qnorm(0.975))
##D sum(abs(rstudent(res.ME)$z) >= qnorm(0.975))
##D 
##D ### plot of the standardized deleted residuals for the RE and ME models
##D 
##D plot(NA, NA, xlim=c(1,20), ylim=c(-4,4), xlab="Study", ylab="Standardized (Deleted) Residual",
##D      xaxt="n", main="Random-Effects Model", las=1)
##D axis(side=1, at=1:20)
##D abline(h=c(-1.96,1.96), lty="dotted")
##D abline(h=0)
##D points(1:20, rstandard(res.RE)$z, type="o", pch=19, col="gray70")
##D points(1:20, rstudent(res.RE)$z,  type="o", pch=19)
##D legend("top", pch=19, col=c("gray70","black"), lty="solid",
##D        legend=c("Standardized Residuals","Standardized Deleted Residuals"), bty="n")
##D 
##D plot(NA, NA, xlim=c(1,20), ylim=c(-4,4), xlab="Study", ylab="Standardized (Deleted) Residual",
##D      xaxt="n", main="Mixed-Effects Model", las=1)
##D axis(side=1, at=1:20)
##D abline(h=c(-1.96,1.96), lty="dotted")
##D abline(h=0)
##D points(1:20, rstandard(res.ME)$z, type="o", pch=19, col="gray70")
##D points(1:20, rstudent(res.ME)$z,  type="o", pch=19)
##D legend("top", pch=19, col=c("gray70","black"), lty="solid",
##D        legend=c("Standardized Residuals","Standardized Deleted Residuals"), bty="n")
##D 
##D ### Baujat plots
##D 
##D baujat(res.CE, main="Common-Effects Model", xlab="Squared Pearson Residual", ylim=c(0,5), las=1)
##D baujat(res.ME, main="Mixed-Effects Model", ylim=c(0,2), las=1)
##D 
##D ### GOSH plots (skipped because this takes quite some time to run)
##D 
##D if (FALSE) {
##D 
##D res.GOSH.CE <- gosh(res.CE, subsets=10^7)
##D plot(res.GOSH.CE, cex=0.2, out=6, xlim=c(-0.25,1.25), breaks=c(200,100))
##D 
##D res.GOSH.ME <- gosh(res.ME, subsets=10^7)
##D plot(res.GOSH.ME, het="tau2", out=6, breaks=50, adjust=0.6, las=1)
##D 
##D }
##D 
##D ### plot of treatment dosage against the standardized residuals
##D 
##D plot(dat$dose, rstandard(res.ME)$z, pch=19, xlab="Dosage (mg per day)",
##D      ylab="Standardized Residual", xlim=c(0,250), ylim=c(-2.5,2.5), las=1)
##D abline(h=c(-1.96,1.96), lty="dotted", lwd=2)
##D abline(h=0)
##D title("Standardized Residual Plot")
##D text(dat$dose[6], rstandard(res.ME)$z[6], "6", pos=4, offset=0.4)
##D 
##D ### quadratic polynomial model
##D 
##D rma(yi, vi, mods = ~ dose + I(dose^2), data=dat, method="DL")
##D 
##D ### lack-of-fit model
##D 
##D resLOF <- rma(yi, vi, mods = ~ dose + factor(dose), data=dat, method="DL", btt=3:9)
##D resLOF
##D 
##D ### scatter plot to illustrate the lack-of-fit model
##D 
##D regplot(res.ME, xlim=c(0,250), ylim=c(-1.0,1.5), xlab="Dosage (mg per day)", ci=FALSE,
##D         predlim=c(0,250), psize=1, pch=19, col="gray60", digits=1, lwd=1, bty="l", las=1)
##D dosages <- sort(unique(dat$dose))
##D lines(dosages, fitted(resLOF)[match(dosages, dat$dose)], type="o", pch=19, cex=2, lwd=2)
##D points(dat$dose, dat$yi, pch=19, col="gray60")
##D legend("bottomright", legend=c("Linear Model", "Lack-of-Fit Model"), pch=c(NA,19), col="black",
##D        lty="solid", lwd=c(1,2), pt.cex=c(1,2), seg.len=4, bty="n")
##D 
##D ### checking normality of the standardized deleted residuals
##D 
##D qqnorm(res.ME, type="rstudent", main="Standardized Deleted Residuals", pch=19, label="out",
##D        lwd=2, pos=24, ylim=c(-4,3), lty=c("solid", "dotted"), las=1)
##D 
##D ### checking normality of the random effects
##D 
##D sav <- qqnorm(ranef(res.ME)$pred, main="BLUPs of the Random Effects", cex=1, pch=19,
##D               xlim=c(-2.2,2.2), ylim=c(-0.6,0.6), las=1)
##D abline(a=0, b=sd(ranef(res.ME)$pred), lwd=2)
##D text(sav$x[6], sav$y[6], "6", pos=4, offset=0.4)
##D 
##D ### hat values for the CE and RE models
##D 
##D plot(NA, NA, xlim=c(1,20), ylim=c(0,0.21), xaxt="n", las=1, xlab="Study", ylab="Hat Value")
##D axis(1, 1:20, cex.axis=1)
##D points(hatvalues(res.CE), type="o", pch=19, col="gray70")
##D points(hatvalues(res.RE), type="o", pch=19)
##D abline(h=1/20, lty="dotted", lwd=2)
##D title("Hat Values for the CE/RE Models")
##D legend("topright", pch=19, col=c("gray70","black"), lty="solid",
##D        legend=c("Common-Effects Model", "Random-Effects Model"), bty="n")
##D 
##D ### heatmap of the hat matrix for the ME model
##D 
##D cols <- colorRampPalette(c("blue", "white", "red"))(101)
##D h <- hatvalues(res.ME, type="matrix")
##D image(1:nrow(h), 1:ncol(h), t(h[nrow(h):1,]), axes=FALSE,
##D       xlab="Influence of the Observed Effect of Study ...", ylab="On the Fitted Value of Study ...",
##D       col=cols, zlim=c(-max(abs(h)),max(abs(h))))
##D axis(1, 1:20, tick=FALSE)
##D axis(2, 1:20, labels=20:1, las=1, tick=FALSE)
##D abline(h=seq(0.5,20.5,by=1), col="white")
##D abline(v=seq(0.5,20.5,by=1), col="white")
##D points(1:20, 20:1, pch=19, cex=0.4)
##D title("Heatmap for the Mixed-Effects Model")
##D 
##D ### plot of leverages versus standardized residuals for the ME model
##D 
##D plot(hatvalues(res.ME), rstudent(res.ME)$z, pch=19, cex=0.2+3*sqrt(cooks.distance(res.ME)),
##D      las=1, xlab="Leverage (Hat Value)", ylab="Standardized Deleted Residual",
##D      xlim=c(0,0.35), ylim=c(-3.5,2.5))
##D abline(h=c(-1.96,1.96), lty="dotted", lwd=2)
##D abline(h=0, lwd=2)
##D ids <- c(3,6,9)
##D text(hatvalues(res.ME)[ids] + c(0,0.013,0.010), rstudent(res.ME)$z[ids] - c(0.18,0,0), ids)
##D title("Leverage vs. Standardized Deleted Residuals")
##D 
##D ### plot of the Cook's distances for the ME model
##D 
##D plot(1:20, cooks.distance(res.ME), ylim=c(0,1.6), type="o", pch=19, las=1, xaxt="n", yaxt="n",
##D      xlab="Study", ylab="Cook's Distance")
##D axis(1, 1:20, cex.axis=1)
##D axis(2, seq(0,1.6,by=0.4), las=1)
##D title("Cook's Distances")
##D 
##D ### plot of the leave-one-out estimates of tau^2 for the ME model
##D 
##D x <- influence(res.ME)
##D 
##D plot(1:20, x$inf$tau2.del,  ylim=c(0,0.15), type="o", pch=19, las=1, xaxt="n", xlab="Study",
##D      ylab=expression(paste("Estimate of ", tau^2, " without the ", italic(i), "th study")))
##D abline(h=res.ME$tau2, lty="dashed")
##D axis(1, 1:20)
##D title("Residual Heterogeneity Estimates")
##D 
##D ### plot of the covariance ratios for the ME model
##D 
##D plot(1:20, x$inf$cov.r,  ylim=c(0,2.0), type="o", pch=19, las=1, xaxt="n",
##D      xlab="Study", ylab="Covariance Ratio")
##D abline(h=1, lty="dashed")
##D axis(1, 1:20)
##D title("Covariance Ratios")
##D 
##D ### fit mixed-effects model without studies 3 and/or 6
##D 
##D rma(yi, vi, mods = ~ dose, data=dat, method="DL", subset=-3)
##D rma(yi, vi, mods = ~ dose, data=dat, method="DL", subset=-6)
##D rma(yi, vi, mods = ~ dose, data=dat, method="DL", subset=-c(3,6))
## End(Not run)



