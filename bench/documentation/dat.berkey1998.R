### Name: dat.berkey1998
### Title: Studies on Treatments for Periodontal Disease
### Aliases: dat.berkey1998 dat.berkey1998r
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.berkey1998
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### construct block diagonal var-cov matrix of the observed outcomes based on variables v1i and v2i
##D V <- vcalc(vi=1, cluster=author, rvars=c(v1i, v2i), data=dat)
##D 
##D ### fit multiple outcomes (meta-regression) model (with REML estimation)
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome, random = ~ outcome | trial, struct="UN", data=dat)
##D print(res, digits=3)
##D 
##D ### test/estimate difference between the two outcomes
##D anova(res, X=c(1,-1))
##D 
##D ### fit model including publication year as moderator for both outcomes (with ML estimation)
##D res <- rma.mv(yi, V, mods = ~ 0 + outcome + outcome:I(year - 1983),
##D               random = ~ outcome | trial, struct="UN", data=dat, method="ML")
##D print(res, digits=3)
## End(Not run)



