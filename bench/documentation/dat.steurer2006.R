### Name: dat.steurer2006
### Title: Trials on Single-Agent Purine Analogues for the Treatment of
###   Chronic Lymphocytic Leukaemia
### Aliases: dat.steurer2006
### Keywords: datasets

### ** Examples

### Show dataset
dat.steurer2006

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use RevMan 5 settings
##D oldset <- settings.meta("RevMan5")
##D 
##D ### Conduct common effect meta-analysis
##D m1 <- metagen(lnHR, selnHR, data = dat.steurer2006,
##D   studlab = paste(author, year),
##D   sm = "HR", random = FALSE, n.e = Ne, n.c = Nc)
##D m1
##D 
##D ### Same analysis using lower and upper confidence limits
##D m2 <- metagen(HR, lower = lowHR, upper = uppHR,
##D   data = dat.steurer2006, transf = FALSE,
##D   studlab = paste(author, year),
##D   sm = "HR", random = FALSE, n.e = Ne, n.c = Nc)
##D m2
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



