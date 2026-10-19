### Name: dat.maire2019
### Title: Studies on Temporal Trends in Fish Community Structures in
###   French Rivers
### Aliases: dat.maire2019
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.maire2019$dat
dat[-10]

### copy distance matrix into 'dmat' and examine first 5 rows/columns
dmat <- dat.maire2019$dmat
dmat[1:5,1:5]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### fit a standard random-effects model ignoring spatial correlation
##D res1 <- rma.mv(s1, vars1, random = ~ 1 | site_station, data=dat)
##D res1
##D 
##D ### fit model allowing for spatial correlation
##D res2 <- rma.mv(s1, vars1, random = ~ site_station | const, struct="SPGAU",
##D                data=dat, dist=list(dmat), control=list(rho.init=10))
##D res2
##D 
##D ### add random effects for sites and stations within sites
##D res3 <- rma.mv(s1, vars1, random = list(~ 1 | site/station, ~ site_station | const), struct="SPGAU",
##D                data=dat, dist=list(dmat), control=list(rho.init=10))
##D res3
##D 
##D ### likelihood ratio tests comparing the models
##D anova(res1, res2)
##D anova(res2, res3)
##D 
##D ### profile likelihood plots for model res2
##D profile(res2, cline=TRUE)
##D 
##D ### effective range (river-km for which the spatial correlation is >= 0.05)
##D sqrt(3) * res2$rho
##D 
##D ### note: it was necessary to adjust the starting value for rho in models
##D ### res2 and res3 so that the optimizer does not get stuck in a local maximum
##D profile(res2, rho=1, xlim=c(0,200), steps=100)
## End(Not run)



