### Name: dat.greb2008
### Title: Trials on High-Dose Chemotherapy with Autologous Stem Cell
###   Transplantation in Aggressive Non-Hodgkin Lymphoma
### Aliases: dat.greb2008
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.greb2008, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use RevMan 5 settings
##D oldset <- settings.meta("RevMan5")
##D 
##D ### Conduct common effect meta-analysis with risk ratio as effect measure
##D mb1 <- metabin(Ee, Ne, Ec, Nc,
##D   data = dat.greb2008, studlab = study,
##D   label.e = "High dose", label.c = "Standard",
##D   label.left = "Favours standard chemotherapy",
##D   label.right = "Favours high dose chemotherapy",
##D   col.label.left = "red", col.label.right = "green")
##D mb1
##D 
##D ### Create forest plot
##D forest(mb1)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



