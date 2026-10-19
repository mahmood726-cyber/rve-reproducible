### Name: dat.crisafulli2020
### Title: Duchenne Muscular Dystrophy (DMD) Prevalence Data
### Aliases: dat.crisafulli2020
### Keywords: datasets

### ** Examples

# show (some) data
head(dat.crisafulli2020)

## Not run: 
##D # compute logarithmic proportions and associated standard errors
##D library(metafor)
##D logp <- escalc(measure="PLN",
##D                xi=cases, ni=total, slab=study,
##D                data=dat.crisafulli2020)
##D 
##D # perform meta-analysis
##D rma01 <- rma.uni(logp)
##D 
##D # show results
##D rma01
##D 
##D # illustrate in a forest plot
##D forest(rma01, xlim=c(-12,-5))
## End(Not run)



