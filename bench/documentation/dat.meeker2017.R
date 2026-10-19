### Name: dat.meeker2017
### Title: Baseball Batting Averages
### Aliases: dat.meeker2017
### Keywords: datasets

### ** Examples

dat.meeker2017

## Not run: 
##D library(metafor)
##D library(bayesmeta)
##D 
##D # convert data to an "escalc" object
##D es <- escalc(measure="GEN",
##D              yi=mean, sei=se, slab=team, ni=batters,
##D              data=dat.meeker2017)
##D 
##D # illustrate the plain data
##D forestplot(es, zero=NA, title="baseball batting averages (dat.meeker2017)")
##D 
##D # specify regressor matrix,
##D # distinguishing between AL-C and NL-C divisions
##D Xmat <- cbind("intercept" = 1,
##D               "offset"    = rep(c(0.5, -0.5), each=5))
##D rownames(Xmat) <- rownames(dat.meeker2017)
##D Xmat
##D 
##D # reproduce analysis from Sec.17.2
##D # (using improper uniform priors for all 3 parameters)
##D mreg <- bmr(es, X=Xmat)
##D mreg
##D 
##D # generate a plot similar to Fig.17.2
##D forestplot(mreg,
##D            X.mean=rbind("AL-C" = c(1, 0.5),
##D                         "NL-C" = c(1, -0.5),
##D                         "mu"   = c(1, 0)),
##D            xlab="batting average", zero=NA)
##D 
##D # show more summary stats for some estimates
##D summary(mreg,
##D         X.mean=rbind("AL-C"              = c(1, 0.5),
##D                      "NL-C"              = c(1, -0.5),
##D                      "mean (mu)"         = c(1, 0),
##D                      "difference (beta)" = c(0, 1)))
##D 
##D # show shrinkage estimates
##D t(mreg$theta)
##D 
##D # show trace plot
##D traceplot(mreg,
##D           X=rbind("AL-C" = c(1, 0.5),
##D                   "NL-C" = c(1, -0.5)),
##D           infinity=TRUE, ylab="batting average")
## End(Not run)



