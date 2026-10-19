### Name: dat.karner2014
### Title: Studies on Tiotropium in Patients with COPD
### Aliases: dat.karner2014
### Keywords: datasets

### ** Examples

dat.karner2014

## Not run: 
##D library(metafor)
##D library(bayesmeta)
##D 
##D # compute effect sizes (log odds ratios) from exacerbation count data
##D # (using the "metafor" package's "escalc()" function)
##D karner.exa <- escalc(measure="OR",
##D                      ai=tiotropium.exa, n1i=tiotropium.total,
##D                      ci=placebo.exa,    n2i=placebo.total,
##D                      slab=study, data=dat.karner2014)
##D 
##D # show forest plot
##D forestplot(karner.exa, title="exacerbation",
##D            exponentiate=TRUE, xlog=TRUE,
##D            xlab="odds ratio")
##D 
##D # derive St. George's Respiratory Questionnaire (SGRQ) effect sizes
##D # (change in SGRQ score)
##D karner.sgrq <- escalc(measure="MD",
##D                       yi=sgrq.md, sei=sgrq.se,
##D                       slab=study, data=dat.karner2014,
##D                       subset=is.finite(dat.karner2014$sgrq.md))
##D 
##D # show forest plot
##D forestplot(karner.sgrq, title="SGRQ", xlab="mean difference")
## End(Not run)



