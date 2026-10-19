### Name: dat.frank2008
### Title: Studies on the Association Between the CASP8 -652 6N del
###   Promoter Polymorphism and Breast Cancer Risk
### Aliases: dat.frank2008
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.frank2008
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log odds ratios comparing ins/del versus ins/ins
##D dat <- escalc(measure="OR", ai=bc.ins.del, bi=bc.ins.ins,
##D                             ci=ct.ins.del, di=ct.ins.ins, data=dat)
##D 
##D ### fit random-effects model and get the pooled odds ratio (with 95% CI)
##D res <- rma(yi, vi, data=dat)
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### calculate log odds ratios comparing del/del versus ins/ins
##D dat <- escalc(measure="OR", ai=bc.del.del, bi=bc.ins.ins,
##D                             ci=ct.del.del, di=ct.ins.ins, data=dat)
##D 
##D ### fit random-effects model and get the pooled odds ratio (with 95% CI)
##D res <- rma(yi, vi, data=dat)
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### calculate log odds ratios comparing ins/del+del/del versus ins/ins
##D dat <- escalc(measure="OR", ai=bc.ins.del+bc.del.del, bi=bc.ins.ins,
##D                             ci=ct.ins.del+ct.del.del, di=ct.ins.ins, data=dat)
##D 
##D ### fit random-effects model and get the pooled odds ratio (with 95% CI)
##D res <- rma(yi, vi, data=dat)
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ############################################################################
##D 
##D ### compute the relative excess heterozygosity in the controls
##D dat <- escalc(measure="REH", ai=ct.ins.ins, bi=ct.ins.del, ci=ct.del.del,
##D               slab=study, data=dat)
##D 
##D ### fit random-effects model and get the pooled REH value (with 90% CI)
##D res <- rma(yi, vi, data=dat, level=90)
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### draw forest plot
##D forest(res, atransf=exp, xlim=c(-1.4,1.4), at=log(c(0.5,5/7,1,7/5,2)))
##D segments(log(5/7), -2, log(5/7), res$k+1, lty="dotted")
##D segments(log(7/5), -2, log(7/5), res$k+1, lty="dotted")
## End(Not run)



