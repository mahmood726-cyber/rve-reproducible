### Name: dat.dong2013
### Title: Studies on Safety of Inhaled Medications for Chronic Obstructive
###   Pulmonary Disease
### Aliases: dat.dong2013
### Keywords: datasets

### ** Examples

### Show first 6 rows / 3 studies of the dataset
head(dat.dong2013)

## Not run: 
##D ### Load netmeta package
##D suppressPackageStartupMessages(library(netmeta))
##D 
##D ### Print odds ratios and confidence limits with two digits
##D oldset <- settings.meta(digits = 2)
##D 
##D ### Change appearance of confidence intervals
##D cilayout("(", "-")
##D 
##D ### Transform data from long arm-based format to contrast-based
##D ### format. Argument 'sm' has to be used for odds ratio as summary
##D ### measure; by default the risk ratio is used in the metabin function
##D ### called internally.
##D pw <- pairwise(treatment, death, randomized, studlab = id,
##D   data = dat.dong2013, sm = "OR")
##D 
##D ### Calculated log odds ratios (TE) and standard errors (seTE)
##D pw[1:3, 1:9]
##D 
##D ### Conduct Mantel-Haenszel network meta-analysis (NMA)
##D net <- netmetabin(pw, ref = "plac")
##D 
##D ### Network graph
##D netgraph(net, seq = "optimal", col = "black", plastic = FALSE,
##D   points = TRUE, pch = 21, cex.points = 3, col.points = "black",
##D   bg.points = "gray", thickness = "se.fixed",
##D   number.of.studies = TRUE)
##D 
##D ### Show results for Mantel-Haenszel NMA
##D net
##D forest(net)
##D 
##D ### League table with network estimates in lower triangle and direct
##D ### estimates in upper triangle
##D netleague(net)
##D 
##D ### Assess inconsistency
##D print(netsplit(net), show = "both", ci = TRUE, overall = FALSE,
##D   nchar.trts = 6)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



