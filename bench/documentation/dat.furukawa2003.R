### Name: dat.furukawa2003
### Title: Studies on Low Dosage Tricyclic Antidepressants for the
###   Treatment of Depression
### Aliases: dat.furukawa2003
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.furukawa2003, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use RevMan5 settings
##D oldset <- settings.meta("RevMan5", digits = 2)
##D 
##D ### Conduct random effects meta-analysis with Hedges' g as effect measure
##D mc2 <- metacont(Ne, Me, Se, Nc, Mc, Sc, common = FALSE,
##D                 data = dat.furukawa2003, sm = "SMD")
##D mc2
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



