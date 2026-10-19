### Name: dat.konstantopoulos2011
### Title: Studies on the Effects of Modified School Calendars on Student
###   Achievement
### Aliases: dat.konstantopoulos2011
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.konstantopoulos2011
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### fit random-effects model
##D res <- rma(yi, vi, data=dat)
##D print(res, digits=3)
##D 
##D ### fit random-effects model using rma.mv()
##D res <- rma.mv(yi, vi, random = ~ 1 | study, data=dat)
##D print(res, digits=3)
##D 
##D ### fit multilevel random-effects model
##D res.ml <- rma.mv(yi, vi, random = ~ 1 | district/school, data=dat)
##D print(res.ml, digits=3)
##D 
##D ### profile variance components
##D profile(res.ml, progbar=FALSE)
##D 
##D ### fit multivariate parameterization of the model
##D res.mv <- rma.mv(yi, vi, random = ~ school | district, data=dat)
##D print(res.mv, digits=3)
##D 
##D ### tau^2 = sum of the two variance components from the multilevel model
##D round(sum(res.ml$sigma2), digits=3)
##D 
##D ### rho = intraclass correlation coefficient based on the multilevel model
##D round(res.ml$sigma2[1] / sum(res.ml$sigma2), digits=3)
## End(Not run)



