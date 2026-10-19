### Name: dat.moura2021
### Title: Studies on Assortative Mating
### Aliases: dat.moura2021
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.moura2021$dat
head(dat)

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
##D tree <- dat.moura2021$tree
##D 
##D ### turn tree into an ultrametric one
##D tree <- compute.brlen(tree)
##D 
##D ### compute phylogenetic correlation matrix
##D A <- vcv(tree, corr=TRUE)
##D 
##D ### make copy of the species.id variable
##D dat$species.id.phy <- dat$species.id
##D 
##D ### fit multilevel phylogenetic meta-analytic model
##D res <- rma.mv(yi, vi,
##D    random = list(~ 1 | study.id, ~ 1 | effect.size.id, ~ 1 | species.id, ~ 1 | species.id.phy),
##D    R=list(species.id.phy=A), data=dat)
##D res
##D 
##D ### examine if spatial and/or temporal pooling of data tends to yield larger correlations
##D res <- rma.mv(yi, vi,
##D    mods = ~ spatially.pooled * temporally.pooled,
##D    random = list(~ 1 | study.id, ~ 1 | effect.size.id, ~ 1 | species.id, ~ 1 | species.id.phy),
##D    R=list(species.id.phy=A), data=dat)
##D res
##D 
##D ### estimated average correlation without pooling, when pooling spatially,
##D ### when pooling temporally, and when pooling spatially and temporally
##D predict(res, newmods = rbind(c(0,0,0),c(1,0,0),c(0,1,0),c(1,1,1)), transf=transf.ztor, digits=2)
## End(Not run)



