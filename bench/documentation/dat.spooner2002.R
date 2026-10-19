### Name: dat.spooner2002
### Title: Studies on Nedocromil Sodium for Preventing Exercise-Induced
###   Bronchoconstriction
### Aliases: dat.spooner2002
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.spooner2002, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use settings from RevMan5
##D oldset <- settings.meta("RevMan5")
##D 
##D ### Conduct random effects meta-analysis with age subgroups
##D mc1 <- metacont(Ne, Me, Se, Nc, Mc, Sc,
##D                 data = dat.spooner2002, studlab = paste(author, year),
##D                 subgroup = agegroup, print.subgroup.name = FALSE,
##D                 label.e = "Nedocromil sodium", label.c = "Placebo",
##D                 common = FALSE)
##D mc1
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



