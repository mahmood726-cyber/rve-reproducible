### Name: dat.craft2003
### Title: Studies on the Relationship between the Competitive State
###   Anxiety Inventory-2 and Sport Performance
### Aliases: dat.craft2003
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.craft2003
head(dat, 18)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### construct dataset and var-cov matrix of the correlations
##D tmp <- rcalc(ri ~ var1 + var2 | study, ni=ni, data=dat)
##D V <- tmp$V
##D dat <- tmp$dat
##D 
##D ### examine data for study 1
##D dat[dat$study == 1,]
##D V[dat$study == 1, dat$study == 1]
##D 
##D ### examine data for study 6
##D dat[dat$study == 6,]
##D V[dat$study == 6, dat$study == 6]
##D 
##D ### examine data for study 17
##D dat[dat$study == 17,]
##D V[dat$study == 17, dat$study == 17]
##D 
##D ### multivariate random-effects model
##D res <- rma.mv(yi, V, mods = ~ 0 + var1.var2, random = ~ var1.var2 | study, struct="UN", data=dat)
##D res
## End(Not run)



