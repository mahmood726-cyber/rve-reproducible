### Name: dat.baker2009
### Title: Studies on Pharmacologic Treatments for Chronic Obstructive
###   Pulmonary Disease
### Aliases: dat.baker2009
### Keywords: datasets

### ** Examples

### Show first 6 rows of the dataset
head(dat.baker2009)

## Not run: 
##D ### Load netmeta package
##D suppressPackageStartupMessages(library(netmeta))
##D 
##D ### Print odds ratios and confidence limits with two digits
##D oldset <- settings.meta(digits = 2)
##D 
##D ### Transform data from long arm-based format to contrast-based
##D ### format. Argument 'sm' has to be used for odds ratio as summary
##D ### measure; by default the risk ratio is used in the metabin function
##D ### called internally.
##D pw <- pairwise(treatment, exac, total, studlab = paste(study, year),
##D   data = dat.baker2009, sm = "OR")
##D 
##D ### Conduct random effects network meta-analysis (NMA)
##D ### with placebo as reference
##D net <- netmeta(pw, common = FALSE, ref = "plac")
##D 
##D ### Show network graph
##D netgraph(net, seq = "optimal", start = "prcomp",
##D   labels = gsub("+", " +\n", trts, fixed = TRUE),
##D   plastic = TRUE, thickness = "se.fixed", number = TRUE,
##D   points = TRUE, cex.points = 5, col.points = "red",
##D   offset = 0.025)
##D 
##D ### Print and plot results for network meta-analysis
##D net
##D forest(net)
##D 
##D ### Conduct component network meta-analysis (CNMA)
##D cnet <- netcomb(net)
##D cnet
##D 
##D ### Compare results of NMA and additive CNMA
##D nb <- netbind(net, cnet, name = c("Standard NMA", "Additive CNMA"))
##D forest(nb)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



