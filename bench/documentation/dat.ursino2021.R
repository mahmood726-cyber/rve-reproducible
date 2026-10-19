### Name: dat.ursino2021
### Title: Sorafenib Toxicity Dataset
### Aliases: dat.ursino2021
### Keywords: datasets

### ** Examples

# show (some) data
head(dat.ursino2021, n=15)

## Not run: 
##D # illustrate data
##D plot(NA, xlim=range(dat.ursino2021$dose), ylim=0:1,
##D      xlab="dose (mg)", ylab="proportion",
##D      main="dat.ursino2021 (Sorafenib data)")
##D studylab <- unique(dat.ursino2021$study)
##D colvec <- rainbow(length(studylab))
##D for (i in 1:length(studylab)) {
##D   idx <- (dat.ursino2021$study == studylab[i])
##D   lines(dat.ursino2021[idx,"dose"],
##D         dat.ursino2021[idx,"events"] / dat.ursino2021[idx,"total"],
##D         col=colvec[i], type="b")
##D }
##D legend("topleft", studylab, col=colvec, pch=15)
## End(Not run)



