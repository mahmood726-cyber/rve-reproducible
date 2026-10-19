### Name: dat.colditz1994
### Title: Studies on the Effectiveness of the BCG Vaccine Against
###   Tuberculosis
### Aliases: dat.colditz1994
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.colditz1994
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log risk ratios and corresponding sampling variances
##D dat <- escalc(measure="RR", ai=tpos, bi=tneg,
##D                             ci=cpos, di=cneg, data=dat,
##D                             slab=paste0(author, ", ", year))
##D dat
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### average risk ratio with 95% CI
##D predict(res, transf=exp)
##D 
##D ### mixed-effects model with absolute latitude and publication year as moderators
##D res <- rma(yi, vi, mods = ~ ablat + year, data=dat)
##D res
##D 
##D ### predicted average risk ratios for 10-60 degrees absolute latitude
##D ### holding the publication year constant at 1970
##D predict(res, newmods=cbind(seq(from=10, to=60, by=10), 1970), transf=exp)
##D 
##D ### note: the interpretation of the results is difficult because absolute
##D ### latitude and publication year are strongly correlated (the more recent
##D ### studies were conducted closer to the equator)
##D plot(ablat ~ year, data=dat, pch=19, xlab="Publication Year", ylab="Absolute Lattitude")
##D cor(dat$ablat, dat$year)
## End(Not run)



