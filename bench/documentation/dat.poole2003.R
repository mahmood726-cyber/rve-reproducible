### Name: dat.poole2003
### Title: Trials on Mucolytic Agents in Chronic Bronchitis or Chronic
###   Obstructive Pulmonary Disease
### Aliases: dat.poole2003
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.poole2003, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use RevMan 5 settings
##D oldset <- settings.meta("RevMan5",
##D   digits.I2 = 2, digits.tau = 3, digits.sd = 2)
##D 
##D ### Conduct random effects meta-analysis
##D m <- metacont(Ne, Me, Se, Nc, Mc, Sc, data = dat.poole2003,
##D   studlab = paste(author, year), common = FALSE,
##D   subgroup = duration,
##D   subgroup.name = "Duration", sep.subgroup = ": ",
##D   label.e = "Mucolytic agent",
##D   label.c = "Placebo",
##D   label.left = "Favours mucolytic agent",
##D   label.right = "Favours placebo",
##D   col.label.left = "green", col.label.right = "red")
##D 
##D ### Forest plot
##D forest(m, xlim = c(-0.5, 0.2),
##D   xlab = paste0("Difference in mean number of\n",
##D     "acute exacerbations per month"))
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



