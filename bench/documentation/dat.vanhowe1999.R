### Name: dat.vanhowe1999
### Title: Studies on the Association between Circumcision and HIV
###   Infection
### Aliases: dat.vanhowe1999
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.vanhowe1999
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### naive pooling by summing up the counts within categories and then
##D ### computing the odds ratios and corresponding confidence intervals
##D cat1 <- with(dat[dat$category=="high-risk group",],
##D    escalc(measure="OR", ai=sum(non.pos), bi=sum(non.neg), ci=sum(cir.pos), di=sum(cir.neg)))
##D cat2 <- with(dat[dat$category=="partner study",],
##D    escalc(measure="OR", ai=sum(non.pos), bi=sum(non.neg), ci=sum(cir.pos), di=sum(cir.neg)))
##D cat3 <- with(dat[dat$category=="population survey",],
##D    escalc(measure="OR", ai=sum(non.pos), bi=sum(non.neg), ci=sum(cir.pos), di=sum(cir.neg)))
##D summary(cat1, transf=exp, digits=2)
##D summary(cat2, transf=exp, digits=2)
##D summary(cat3, transf=exp, digits=2)
##D 
##D ### naive pooling across all studies
##D all <- escalc(measure="OR", ai=sum(dat$non.pos), bi=sum(dat$non.neg),
##D                             ci=sum(dat$cir.pos), di=sum(dat$cir.neg))
##D summary(all, transf=exp, digits=2)
##D 
##D ### calculate log odds ratios and corresponding sampling variances
##D dat <- escalc(measure="OR", ai=non.pos, bi=non.neg, ci=cir.pos, di=cir.neg, data=dat)
##D dat
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat, method="DL")
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### random-effects model within subgroups
##D res <- rma(yi, vi, data=dat, method="DL", subset=category=="high-risk group")
##D predict(res, transf=exp, digits=2)
##D res <- rma(yi, vi, data=dat, method="DL", subset=category=="partner study")
##D predict(res, transf=exp, digits=2)
##D res <- rma(yi, vi, data=dat, method="DL", subset=category=="population survey")
##D predict(res, transf=exp, digits=2)
## End(Not run)



