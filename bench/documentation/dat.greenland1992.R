### Name: dat.greenland1992
### Title: Case-Control Studies on the Impact of Alcohol Consumption on
###   Breast Cancer Risk
### Aliases: dat.greenland1992
### Keywords: datasets

### ** Examples

### Show first 6 rows of the dataset
head(dat.greenland1992)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Inverse variance method
##D mg <- metagen(b, SE, data = dat.greenland1992,
##D   studlab = paste(author, year), sm = "RR",
##D   random = FALSE, overall.hetstat = FALSE,
##D   backtransf = FALSE)
##D 
##D ### Overall result
##D print(mg, digits = 5)
##D 
##D ### Standard error for common effect estimate
##D round(mg$seTE.common, 5)
## End(Not run)



