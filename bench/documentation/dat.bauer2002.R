### Name: dat.bauer2002
### Title: Studies on OM-89 (Uro-Vaxom) in Urinary Tract Infections
### Aliases: dat.bauer2002
### Keywords: datasets

### ** Examples

dat.bauer2002

## Not run: 
##D library(metafor)
##D library(bayesmeta)
##D 
##D # analyze based on plain probabilities as effect sizes
##D wmw.prob <- escalc(measure="CLES",
##D                    yi = wmwstat, sei = stderr,
##D                    ni = n.total, slab = study,
##D                    data = dat.bauer2002)
##D 
##D # perform a random-effects meta-analysis
##D ma01 <- rma.uni(wmw.prob, method="PM", test="adhoc")
##D 
##D # show forest plot
##D forest(ma01, addpred=TRUE, predstyle="bar",
##D        refline=0.5, main="dat.bauer2002 (probabilities)")
##D 
##D 
##D # analyze based on log-odds (logits) as effect sizes
##D wmw.logit <- escalc(measure="PLO",
##D                     yi   = log(wmwstat / (1-wmwstat)),
##D                     sei  = stderr / (wmwstat*(1-wmwstat)),
##D                     ni   = n.total, slab = study,
##D                     data = dat.bauer2002)
##D 
##D # perform a random-effects meta-analysis
##D ma02 <- rma.uni(wmw.logit, method="PM", test="adhoc")
##D 
##D # show forest plot (back-transformed to probabilities)
##D forest(ma02, addpred=TRUE, predstyle="bar",
##D        transf=transf.ilogit,
##D        header=c("study", "CLES [95 percent CI]"),
##D        xlab="common language effect size",
##D        refline=0.5, main="dat.bauer2002 (log-odds)")
##D 
##D # show forest plot (in terms of log-odds)
##D forest(ma02, addpred=TRUE, predstyle="bar",
##D        header=c("study", "logit(CLES) [95 percent CI]"),
##D        xlab="logit(common language effect size)",
##D        refline=0.0, main="dat.bauer2002 (log-odds)")
##D 
##D # perform Bayesian meta-analsis
##D # (using a half-normal prior for the (logit-WMW) effect heterogeneity
##D #  and a Normal(0.0, 1.814) prior for the overall mean logit;
##D #  the overall mean prior (with variance (pi/sqrt(3))^2)
##D #  roughly corresponds to a uniform prior in probability)
##D ma03 <- bayesmeta(wmw.logit,
##D                   tau.prior = function(t){dhalfnormal(t,scale=0.5)},
##D                   mu.prior = c(0.0, 1.814))
##D forestplot(ma03, title = "dat.bauer2002 (log-odds)",
##D            xlab = "logit(CLES)",
##D            txt_gp = fpTxtGp(ticks = gpar(cex=1), xlab = gpar(cex=1)))
## End(Not run)



