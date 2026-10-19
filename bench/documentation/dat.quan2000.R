### Name: dat.quan2000
### Title: Studies on Pharmacotherapy for Hypertension
### Aliases: dat.quan2000
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.quan2000, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use RevMan 5 settings
##D oldset <- settings.meta("RevMan5")
##D 
##D ### Conduct meta-analyis with Peto method
##D m <- metabin(Ee, Ne, Ec, Nc, sm = "OR", method = "Peto",
##D   data = dat.quan2000, studlab = study, random = FALSE)
##D m
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



