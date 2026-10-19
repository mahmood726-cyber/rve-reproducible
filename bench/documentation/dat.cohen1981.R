### Name: dat.cohen1981
### Title: Studies on the Relationship between Course Instructor Ratings
###   and Student Achievement
### Aliases: dat.cohen1981
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.cohen1981
dat[c(1,4,5)]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate r-to-z transformed correlations and corresponding sampling variances
##D dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dat[c(1,4,5)])
##D dat
##D 
##D ### meta-analysis of the transformed correlations using a random-effects model
##D res <- rma(yi, vi, data=dat, digits=2)
##D res
##D 
##D ### predicted average correlation with 95% CI
##D predict(res, transf=transf.ztor)
## End(Not run)



