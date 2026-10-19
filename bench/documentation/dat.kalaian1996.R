### Name: dat.kalaian1996
### Title: Studies on the Effectiveness of Coaching for the SAT
### Aliases: dat.kalaian1996
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.kalaian1996
head(dat, 12)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### check ranges
##D range(dat$yi[dat$outcome == "verbal"]) # -0.35 to 0.74 according to page 230
##D range(dat$yi[dat$outcome == "math"])   # -0.53 to 0.60 according to page 231
##D 
##D ### comparing this with Figure 1 in the paper reveals some discrepancies
##D par(mfrow=c(1,2), mar=c(5,5,1,3.4))
##D plot(log(dat$hrs[dat$outcome == "verbal"]), dat$yi[dat$outcome == "verbal"],
##D      pch=19, col=rgb(0,0,0,0.4), xlab="Log(Coaching Hours)", ylab="Effect Size (verbal)",
##D      xlim=c(1,6), ylim=c(-0.5,1), xaxs="i", yaxs="i")
##D abline(h=c(-0.5,0,0.5), lty="dotted")
##D abline(v=log(c(5,18)),  lty="dotted")
##D plot(log(dat$hrs[dat$outcome == "math"]), dat$yi[dat$outcome == "math"],
##D      pch=19, col=rgb(0,0,0,0.4), xlab="Log(Coaching Hours)", ylab="Effect Size (math)",
##D      xlim=c(1,6), ylim=c(-1.0,1), xaxs="i", yaxs="i")
##D abline(h=c(-0.5,0,0.5), lty="dotted")
##D abline(v=log(c(5,18)),  lty="dotted")
##D 
##D ### construct variance-covariance matrix assuming rho = 0.66 for effect sizes
##D ### corresponding to the 'verbal' and 'math' outcome types
##D V <- vcalc(vi, cluster=study, type=outcome, data=dat, rho=0.66)
##D 
##D ### fit multivariate random-effects model
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome,
##D               random = ~ outcome | study, struct="UN",
##D               data=dat, digits=3)
##D res
##D 
##D ### test whether the effect differs for the math and verbal subtest
##D anova(res, X=c(1,-1))
##D 
##D ### log-transform and mean center the hours of coaching variable
##D dat$loghrs <- log(dat$hrs) - mean(log(dat$hrs), na.rm=TRUE)
##D 
##D ### fit multivariate model with log(hrs) as moderator
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome + outcome:loghrs,
##D               random = ~ outcome | study, struct="UN",
##D               data=dat, digits=3)
##D res
##D 
##D ### fit model with tau2 = 0 for outcome verbal (which also constrains rho = 0)
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome + outcome:loghrs,
##D               random = ~ outcome | study, struct="UN", tau2=c(NA,0),
##D               data=dat, digits=3)
##D res
## End(Not run)



