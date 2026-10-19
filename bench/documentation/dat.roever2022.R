### Name: dat.roever2022
### Title: Irinotecan / S-1 Toxicity Dataset
### Aliases: dat.roever2022
### Keywords: datasets

### ** Examples

# show (some) data
head(dat.roever2022, n=10)

## Not run: 
##D # illustrate data
##D plot(NA, xlim=range(dat.roever2022$dose), ylim=0:1,
##D      xlab="dose (mg / m²)", ylab="proportion",
##D      main="dat.roever2022 (Irinotecan / S-1 data)")
##D studylab <- unique(dat.roever2022$study)
##D colvec <- rainbow(length(studylab))
##D for (i in 1:length(studylab)) {
##D   idx <- (dat.roever2022$study == studylab[i])
##D   lines(dat.roever2022[idx,"dose"],
##D         dat.roever2022[idx,"events"] / dat.roever2022[idx,"total"],
##D         col=colvec[i], type="b")
##D }
##D legend("topleft", studylab, col=colvec, pch=15)
## End(Not run)



