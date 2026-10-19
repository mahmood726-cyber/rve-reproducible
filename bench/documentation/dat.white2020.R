### Name: dat.white2020
### Title: Studies on the Relationship between Sexual Signal Expression and
###   Individual Quality
### Aliases: dat.white2020
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.white2020
head(dat, 10)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate r-to-z transformed correlations and corresponding sampling variances
##D dat <- escalc(measure="ZCOR", ri=r, ni=n, data=dat)
##D 
##D ### fit multilevel meta-analytic model
##D res <- rma.mv(yi, vi, random = list(~ 1 | study_id, ~ 1 | obs), data=dat)
##D res
## End(Not run)



