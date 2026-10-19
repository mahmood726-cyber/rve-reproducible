### Name: dat.thompson1999
### Title: Trials on Serum Cholesterin Concentration Lowering and Risk of
###   Ischaemic Heart Disease
### Aliases: dat.thompson1999
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.thompson1999, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Conduct meta-analysis
##D m <- metabin(ihd.exp, ihd.exp + noihd.exp, ihd.cont, ihd.cont + noihd.cont,
##D   data = dat.thompson1999, sm = "OR", method = "Inverse")
##D 
##D ### Thompson & Sharp (1999), Table III
##D ### (1) None
##D metareg(m, cholr, method.tau = "FE")
##D ### (3a) Additive (MM)
##D metareg(m, cholr, method.tau = "DL")
## End(Not run)



