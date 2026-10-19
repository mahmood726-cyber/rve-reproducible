### Name: dat.chiarito2020
### Title: Studies Investigating the Efficacy of P2Y12-Inhibitors in
###   Atherosclerosis
### Aliases: dat.chiarito2020
### Keywords: datasets

### ** Examples

dat.chiarito2020

## Not run: 
##D library(metafor)
##D library(meta)
##D library(bayesmeta)
##D 
##D # show plain data on stroke
##D dat.chiarito2020[-5, c("study","p2y12.stroke","p2y12.total","aspirin.stroke","aspirin.total")]
##D 
##D # show event rates in both treatment groups
##D cbind.data.frame("study"   = dat.chiarito2020$study,
##D                  "p2y12"   = dat.chiarito2020$p2y12.stroke / dat.chiarito2020$p2y12.total,
##D                  "aspirin" = dat.chiarito2020$aspirin.stroke / dat.chiarito2020$aspirin.total)
##D 
##D # compute effect measures (log-ORs)
##D # (using the "escalc()" function from the "metafor" package)
##D es.stroke <- escalc(measure="OR",
##D                     ai=p2y12.stroke,   n1i=p2y12.total,
##D                     ci=aspirin.stroke, n2i=aspirin.total,
##D                     slab=study, subset=is.finite(p2y12.stroke),
##D                     data=dat.chiarito2020)
##D 
##D # show effect measures (log-ORs)
##D summary(es.stroke)
##D 
##D # show effect measures (ORs und 95 percent CI)
##D cbind("study" = es.stroke$study,
##D       exp(summary(es.stroke)[,c("yi","ci.lb","ci.ub")]))
##D 
##D # show data in a forest plot
##D forestplot(es.stroke, xlab="log-OR")
##D forestplot(es.stroke, expo=TRUE, xlog=TRUE, xlab="odds ratio (OR)")
##D 
##D ############################################################
##D #  meta-analysis (frequentist, "metafor" package)
##D 
##D # using default settings (random-effects model, REML-estimator)
##D rma.uni(es.stroke)
##D 
##D # analysis using Paule-Mandel estimator and HKSJ intervals
##D rma01 <- rma.uni(es.stroke, method="PM", test="knha")
##D 
##D # show results
##D rma01
##D 
##D # illustrate in a forest plot
##D forest(rma01)
##D forest(rma01, atransf=exp)
##D 
##D ############################################################
##D #  meta-analysis (frequentist, "meta" package)
##D 
##D # analogous analysis to above, using the "meta" package
##D meta01 <- metabin(event.e=p2y12.stroke,   n.e=p2y12.total,
##D                   event.c=aspirin.stroke, n.c=aspirin.total,
##D                   studlab=study, data=dat.chiarito2020,
##D                   subset=is.finite(p2y12.stroke),
##D                   sm="OR",
##D                   method.tau="PM",
##D                   method.random.ci="HK", method="Inverse")
##D 
##D meta01
##D summary(meta01)
##D forest(meta01)
##D 
##D ############################################################
##D #  meta-analysis (Bayesian, "bayesmeta" package)
##D 
##D # analysis using default settings (uniform prior for mu und tau)
##D bma01 <- bayesmeta(es.stroke)
##D 
##D # show results
##D bma01
##D 
##D # show forest plots (for log-OR and OR)
##D forestplot(bma01, xlab="log-OR")
##D forestplot(bma01, exponentiate=TRUE, xlog=TRUE, xlab="OR")
## End(Not run)



