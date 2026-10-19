### Name: dat.lim2014
### Title: Studies on the Association Between Maternal Size, Offspring
###   Size, and Number of Offsprings
### Aliases: dat.lim2014
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.lim2014$o_o_unadj
dat[1:14, -c(2:3)]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### load ape package
##D library(ape, warn.conflicts=FALSE)
##D 
##D ### calculate r-to-z transformed correlations and corresponding sampling variances
##D dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dat)
##D 
##D ### copy tree to 'tree'
##D tree <- dat.lim2014$o_o_unadj_tree
##D 
##D ### compute branch lengths
##D tree <- compute.brlen(tree)
##D 
##D ### compute phylogenetic correlation matrix
##D A <- vcv(tree, corr=TRUE)
##D 
##D ### make copy of the species variable
##D dat$species.phy <- dat$species
##D 
##D ### create effect size id variable
##D dat$esid <- 1:nrow(dat)
##D 
##D ### fit multilevel phylogenetic meta-analytic model
##D res <- rma.mv(yi, vi,
##D    random = list(~ 1 | article, ~ 1 | esid, ~ 1 | species, ~ 1 | species.phy),
##D    R=list(species.phy=A), data=dat)
##D res
## End(Not run)



