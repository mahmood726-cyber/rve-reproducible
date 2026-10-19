### Name: dat.feng2019
### Title: Studies on the Prevalence of Depression After Myocardial
###   Infarction
### Aliases: dat.feng2019
### Keywords: datasets

### ** Examples

### Show results of first six studies
head(dat.feng2019)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Conduct random effects meta-analysis
##D mp1 <- metaprop(depr, n, data = dat.feng2019,
##D   studlab = paste(author, year),
##D   common = FALSE, prediction = TRUE)
##D 
##D ### Create forest plot
##D forest(mp1, digits = 3, xlim = c(0, 1),
##D   print.pval.Q = FALSE, details = TRUE)
## End(Not run)



