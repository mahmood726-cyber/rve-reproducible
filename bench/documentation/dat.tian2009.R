### Name: dat.tian2009
### Title: Studies on the Effect of Rosiglitazone on the Risk of Myocardial
###   Infarction and Death from Cardiovascular Causes
### Aliases: dat.tian2009
### Keywords: datasets

### ** Examples

### Show first 6 rows / 3 trials of the dataset
head(dat.tian2009)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Print odds ratios and confidence limits with two digits and define
##D ### labels shown in forest plots
##D oldset <- settings.meta(digits = 2,
##D   label.e = "Rosiglitazone", label.c = "Control",
##D   label.left = "Favors rosiglitazome",
##D   label.right = "Favors control")
##D 
##D ### Transform data from long arm-based format to contrast-based
##D ### format. Argument 'sm' has to be used for odds ratio as summary
##D ### measure; by default the risk ratio is used in the metabin function
##D ### called internally.
##D pw <- pairwise(treat = group, event = deaths, n = n, studlab = study,
##D   data = dat.tian2009, sm = "OR", varnames = c("lnOR", "selnOR"))
##D 
##D ### Fit the inverse variance model
##D mod_iv <- metabin(pw,
##D   text.common = "IV method (common)",
##D   text.random = "IV method (random)")
##D 
##D ### Fit the Mantel-Haenszel model
##D mod_mh <- update(mod_iv, method = "MH", random = FALSE,
##D   method.incr = gs("method.incr"),
##D   text.common = "MH method")
##D 
##D ### Fit the Peto model
##D mod_peto <- update(mod_mh, method = "Peto",
##D   text.common = "Peto method")
##D 
##D ### Fit generalized linear mixed models (GLMM)
##D mod_glmm <- update(mod_mh, method = "glmm", model = "CM.AL",
##D   random = TRUE,
##D   text.common = "GLMM (common)",
##D   text.random = "GLMM (random)")
##D 
##D if (requireNamespace("brglm2", quietly = TRUE)) {
##D ### Fit the logistic regression model with penalized likelihood (LRP)
##D mod_plma <- update(mod_glmm, method = "LRP",
##D   text.common = "LRP method (common)",
##D   text.random = "LRP method (random)")
##D 
##D ### Fit the logistic regression model after excluding double zero studies
##D mod_plma1 <- metabin(event1, n1, event2, n2, studlab = study,
##D   data = subset(pw, !is.na(lnOR)), sm = "OR", method = "LRP",
##D   text.common = "LRP method, exclude zeros (common)",
##D   text.random = "LRP method, exclude zeros (random)")
##D }
##D 
##D ### Create forest plot with all results
##D mm <- metaadd(mod_iv, data = mod_mh)
##D mm <- metaadd(mm, data = mod_peto)
##D mm <- metaadd(mm, data = mod_glmm)
##D 
##D if (requireNamespace("brglm2", quietly = TRUE)) {
##D mm <- metaadd(mm, data = mod_plma)
##D mm <- metaadd(mm, data = mod_plma1)
##D }
##D 
##D fname <- tempfile(pattern = "forest", fileext = ".pdf")
##D forest(mm, hetstat = FALSE, file = fname, width = 10, rows.gr = 1)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



