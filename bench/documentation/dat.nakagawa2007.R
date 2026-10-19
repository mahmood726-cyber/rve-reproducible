### Name: dat.nakagawa2007
### Title: Assessing the Function of House Sparrows' Bib Size Using a
###   Flexible Meta-Analysis Method
### Aliases: dat.nakagawa2007
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.nakagawa2007
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate Zr
##D dat <- escalc(measure="ZCOR", ri=Correlation, ni=SampleSize, data=dat)
##D 
##D ### fit meta-analytic model
##D res <- rma.mv(yi, vi, random = ~ 1 | StudyID, data=dat)
##D res
## End(Not run)



