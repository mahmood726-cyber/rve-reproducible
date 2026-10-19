### Name: dat.yusuf1985
### Title: Studies of Beta Blockers During and After Myocardial Infarction
### Aliases: dat.yusuf1985
### Keywords: datasets

### ** Examples

### copy data into 'dat'
dat <- dat.yusuf1985
dat[dat$table == 6,]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### to select a table for the analysis
##D tab <- "6" # either: 6, 9, 10, 11, 12a, 12b
##D 
##D ### to double-check total counts as reported in article
##D apply(dat[dat$table==tab,4:7], 2, sum, na.rm=TRUE)
##D 
##D ### meta-analysis using Peto's one-step method
##D res <- rma.peto(ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat, subset=(table==tab))
##D res
##D predict(res, transf=exp, digits=2)
## End(Not run)



