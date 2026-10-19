### Name: dat.kearon1998
### Title: Studies on the Accuracy of Venous Ultrasonography for the
###   Diagnosis of Deep Venous Thrombosis
### Aliases: dat.kearon1998
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.kearon1998
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate diagnostic log odds ratios and corresponding sampling variances
##D dat <- escalc(measure="OR", ai=tp, n1i=np, ci=nn-tn, n2i=nn, data=dat, add=1/2, to="all")
##D head(dat)
##D 
##D ### fit random-effects model for the symptomatic patients
##D res <- rma(yi, vi, data=dat, subset=patients=="symptomatic")
##D res
##D 
##D ### fit random-effects model for the asymptomatic patients
##D res <- rma(yi, vi, data=dat, subset=patients=="asymptomatic")
##D res
##D 
##D ### estimated average diagnostic odds ratio (with 95% CI)
##D predict(res, transf=exp, digits=2)
##D 
##D ### regression test for funnel plot asymmetry using SE as predictor
##D reg <- regtest(res, model="lm")
##D reg
##D 
##D ### corresponding funnel plot
##D funnel(res, atransf=exp, xlim=c(0,7), at=log(c(1,10,100,1000)), ylim=c(0,1.5), steps=4)
##D ys <- seq(0, 2, length=100)
##D lines(coef(reg$fit)[1] + coef(reg$fit)[2]*ys, ys, lwd=2, lty=3)
##D 
##D ### regression test for funnel plot asymmetry using total sample size as predictor
##D reg <- regtest(res, model="lm", predictor="ni")
##D reg
##D 
##D ### corresponding funnel plot
##D funnel(res, yaxis="ni", atransf=exp, xlim=c(0,7), at=log(c(1,10,100,1000)), ylim=c(0,300), steps=4)
##D ys <- seq(0, 300, length=100)
##D lines(coef(reg$fit)[1] + coef(reg$fit)[2]*ys, ys, lwd=2, lty=3)
##D 
##D ### regression test for funnel plot asymmetry using 1/sqrt(ESS) as predictor (Deeks et al., 2005)
##D dat$invessi <- 1/(4*dat$np) + 1/(4*dat$nn)
##D tmp <- rma(yi, invessi, data=dat, subset=patients=="asymptomatic")
##D reg <- regtest(tmp, model="lm")
##D reg
##D 
##D ### corresponding funnel plot
##D funnel(tmp, atransf=exp, xlim=c(0,7), at=log(c(1,10,100,1000)), ylim=c(0,0.15), steps=4,
##D        refline=coef(res), level=0, ylab="1/root(ess)")
##D ys <- seq(0, 0.2, length=100)
##D lines(coef(reg$fit)[1] + coef(reg$fit)[2]*ys, ys, lwd=2, lty=3)
##D 
##D ### convert data to long format
##D dat <- to.long(measure="OR", ai=tp, n1i=np, ci=tn, n2i=nn,
##D                data=dat.kearon1998, subset=patients=="asymptomatic", append=FALSE)
##D dat$group <- factor(dat$group, levels=c(1,2), labels=c("sensitivity", "specificity"))
##D dat
##D 
##D ### calculate logit-transformed sensitivities
##D dat <- escalc(measure="PLO", xi=out1, mi=out2, data=dat, add=1/2, to="all",
##D               include=group=="sensitivity")
##D dat
##D 
##D ### calculate logit-transformed specificities
##D dat <- escalc(measure="PLO", xi=out1, mi=out2, data=dat, add=1/2, to="all",
##D               include=group=="specificity")
##D dat
##D 
##D ### bivariate random-effects model for logit sensitivity and specificity
##D res <- rma.mv(yi, vi, mods = ~ 0 + group, random = ~ group | study, struct="UN", data=dat)
##D res
##D 
##D ### estimated average sensitivity and specificity based on the model
##D predict(res, newmods = rbind(c(1,0),c(0,1)), transf=transf.ilogit, tau2.levels=c(1,2), digits=2)
##D 
##D ### estimated average diagnostic odds ratio based on the model
##D predict(res, newmods = c(1,1), transf=exp, digits=2)
## End(Not run)



