### Name: dat.dumouchel1994
### Title: Nitrogen dioxide data set
### Aliases: dat.dumouchel1994
### Keywords: datasets

### ** Examples

# show data:
dat.dumouchel1994

## Not run: 
##D # derive effect sizes (log-ORs):
##D library(metafor)
##D no2 <- escalc(measure="OR", yi=log(or),
##D               sei=(log(upper)-log(lower))/(2*qnorm(0.975)),
##D               slab=study, data=dat.dumouchel1994)
##D summary(no2)
##D 
##D # compute overall meta-analysis:
##D library(bayesmeta)
##D bm01 <- bayesmeta(no2, tau.prior="DuMouchel")
##D 
##D # show results:
##D bm01
##D forestplot(bm01)
##D traceplot(bm01)
##D 
##D # perform meta-regression;
##D # specify regressor matrix:
##D X <- model.matrix( ~ smoke + no2 + gender, data=no2)
##D colnames(X) <- c("intercept", "smoke", "no2", "gender")
##D 
##D # perform regression:
##D bm02 <- bmr(no2, X=X, tau.prior="DuMouchel")
##D 
##D # show results:
##D bm02
##D forestplot(bm02)
##D #forestplot(bm02, xlab="log-OR",
##D #           X.mean=rbind("none"      = c(1,0,0,0),
##D #                        "smoke"     = c(1,1,0,0),
##D #                        "no2"       = c(1,0,1,0),
##D #                        "gender"    = c(1,0,0,1),
##D #                        "all three" = c(1,1,1,1)))
##D traceplot(bm02)
## End(Not run)



