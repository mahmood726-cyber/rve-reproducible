### Name: dat.molloy2014
### Title: Studies on the Relationship between Conscientiousness and
###   Medication Adherence
### Aliases: dat.molloy2014
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.molloy2014
dat[-c(5:6)]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate r-to-z transformed correlations and corresponding sampling variances
##D dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dat, slab=paste(authors, year, sep=", "))
##D dat[-c(5:6)]
##D 
##D ### meta-analysis of the transformed correlations using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### average correlation with 95% CI
##D predict(res, digits=3, transf=transf.ztor)
##D 
##D ### forest plot
##D forest(res, addpred=TRUE, xlim=c(-1.6,1.6), atransf=transf.ztor,
##D        at=transf.rtoz(seq(-0.4, 0.6, by=0.2)), digits=c(2,1), cex=0.9,
##D        header="Author(s), Year")
##D 
##D ### funnel plot
##D funnel(res)
## End(Not run)



