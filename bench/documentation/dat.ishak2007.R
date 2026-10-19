### Name: dat.ishak2007
### Title: Studies on Deep-Brain Stimulation in Patients with Parkinson's
###   disease
### Aliases: dat.ishak2007
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.ishak2007
head(dat, 5)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### create long format dataset
##D dat <- reshape(dat, direction="long", idvar="study", v.names=c("yi","vi"),
##D                varying=list(c(2,4,6,8), c(3,5,7,9)))
##D dat <- dat[order(study, time),]
##D 
##D ### remove missing measurement occasions from dat
##D dat <- dat[!is.na(yi),]
##D rownames(dat) <- NULL
##D head(dat, 8)
##D 
##D ### construct the full (block diagonal) V matrix with an AR(1) structure
##D ### assuming an autocorrelation of 0.97 as estimated by Ishak et al. (2007)
##D V <- vcalc(vi, cluster=study, time1=time, phi=0.97, data=dat)
##D 
##D ### plot data
##D with(dat, interaction.plot(time, study, yi, type="b", pch=19, lty="solid", xaxt="n",
##D           legend=FALSE, xlab="Time Point", ylab="Mean Difference", bty="l"))
##D axis(side=1, at=1:4, lab=c("1 (3 months)", "2 (6 months)", "3 (12 months)", "4 (12+ months)"))
##D 
##D ### multivariate model with heteroscedastic AR(1) structure for the true effects
##D res <- rma.mv(yi, V, mods = ~ 0 + factor(time), random = ~ time | study,
##D               struct = "HAR", data = dat)
##D print(res, digits=2)
## End(Not run)



