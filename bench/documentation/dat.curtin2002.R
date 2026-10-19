### Name: dat.curtin2002
### Title: Studies on Potassium Supplementation to Reduce Diastolic Blood
###   Pressure
### Aliases: dat.curtin2002
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.curtin2002, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use DerSimonian-Laird estimator (which was the default in meta in the year 2015).
##D ### Furthermore, print meta-analysis results with two digits.
##D oldset <- settings.meta(method.tau = "DL", digits = 2)
##D 
##D ### Conduct meta-analysis
##D mg2 <- metagen(mean, SE, studlab = paste(author, year),
##D                data = dat.curtin2002, sm = "MD")
##D mg2
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



