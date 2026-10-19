### Name: dat.higgins2008
### Title: Trials on Haloperidol in Schizophrenia
### Aliases: dat.higgins2008
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.higgins2008, 5)

## Not run: 
##D ### Load metasens package
##D suppressPackageStartupMessages(library(metasens))
##D 
##D ### Print odds ratios and confidence limits with three digits
##D oldset <- settings.meta(digits = 3)
##D 
##D ### Conduct common effect meta-analysis of available data
##D m <- metabin(resp.halo, resp.halo + fail.halo,
##D   resp.plac, resp.plac + fail.plac,
##D   data = dat.higgins2008, studlab = author,
##D   sm = "OR", method = "Inverse", random = FALSE,
##D   label.e = "Haloperidol", label.c = "Placebo",
##D   label.left = "Favours placebo",
##D   label.right = "Favours haloperidol")
##D 
##D ### Best case scenario for haloperidol
##D m.b <- metamiss(m, miss.halo, miss.plac,
##D   method.miss = "b", small.values = "undesirable")
##D 
##D ### Worst case scenario for haloperidol
##D m.w <- metamiss(m, miss.halo, miss.plac,
##D   method.miss = "w", small.values = "undesirable")
##D 
##D ### Forest plot
##D m.sens <- metamerge(m, m.b, text.pooled2 = "Best case scenario")
##D m.sens <- metamerge(m.sens, m.w, text.pooled2 = "Worst case scenario")
##D forest(m.sens)
## End(Not run)



