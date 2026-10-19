### Name: dat.mccurdy2020
### Title: Studies on the Generation Effect
### Aliases: dat.mccurdy2020
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.mccurdy2020
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### fit multilevel mixed-effects meta-regression model
##D res <- rma.mv(yi, vi, mods = ~ condition,
##D               random = list(~ 1 | article/experiment/sample/id, ~ 1 | pairing),
##D               data=dat, sparse=TRUE, digits=3)
##D res
##D 
##D ### proportion of total amount of heterogeneity due to each component
##D data.frame(source=res$s.names, sigma2=round(res$sigma2, 3),
##D    prop=round(res$sigma2 / sum(res$sigma2), 2))
##D 
##D ### apply cluster-robust inference methods
##D sav <- robust(res, cluster=article, clubSandwich=TRUE)
##D sav
##D 
##D ### estimated average recall rate in read and generate conditions
##D predict(sav, newmods = c(0,1), digits=3)
## End(Not run)



