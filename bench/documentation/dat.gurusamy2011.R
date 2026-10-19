### Name: dat.gurusamy2011
### Title: Studies on Interventions to Reduce Mortality after Liver
###   Transplantation
### Aliases: dat.gurusamy2011
### Keywords: datasets

### ** Examples

### Show first 6 rows of the dataset
head(dat.gurusamy2011)

### Only study evaluating solvent detergent plasma
subset(dat.gurusamy2011, study == "Williamson 1999")

### Only study evaluating antithrombin III
subset(dat.gurusamy2011, study == "Baudo 1992")

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
##D pw <- pairwise(treatment, death, n, studlab = study,
##D   data = dat.gurusamy2011, sm = "OR")
##D 
##D ### Conduct Mantel-Haenszel network meta-analysis (NMA)
##D net.MH <- netmetabin(pw, ref = "cont")
##D 
##D ### Conduct inverse variance (IV) network meta-analysis
##D net.IV <- netmeta(pw, ref = "cont")
##D 
##D ### Network graph (Mantel-Haenszel NMA)
##D netgraph(net.MH, seq = "optimal", col = "black", plastic = FALSE,
##D   points = TRUE, pch = 21, cex.points = 3, col.points = "black",
##D   bg.points = "gray", thickness = "se.fixed",
##D   number.of.studies = TRUE)
##D 
##D ### Full network graph (based on inverse variance method, including
##D ### study comparing Antithrombin III with Control/Placebo)
##D netgraph(net.IV,
##D   seq = "optimal", col = "black", plastic = FALSE,
##D   points = TRUE, pch = 21, cex.points = 3, col.points = "black",
##D   bg.points = "gray", thickness = "se.fixed",
##D   number.of.studies = TRUE)
##D 
##D ### Compare results for Mantel-Haenszel and IV NMA
##D forest(netbind(net.MH, net.IV,
##D   random = FALSE, name = c("MH NMA", "IV NMA")))
##D 
##D ### Show results for Mantel-Haenszel NMA
##D net.MH
##D forest(net.MH)
##D 
##D ### League table with network estimates in lower triangle and direct
##D ### estimates in upper triangle
##D netleague(net.MH)
##D 
##D ### Assess inconsistency
##D print(netsplit(net.MH), show = "both", ci = TRUE, overall = FALSE,
##D   nchar.trts = 6)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



