### Name: dat.dogliotti2014
### Title: Studies on Antithrombotic Treatments to Prevent Strokes
### Aliases: dat.dogliotti2014
### Keywords: datasets

### ** Examples

### Show first 7 rows / 3 studies of the dataset
head(dat.dogliotti2014, 7)

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
##D pw <- pairwise(treat = treatment, n = total, event = stroke,
##D   studlab = study, data = dat.dogliotti2014, sm = "OR")
##D 
##D ### Print log odds ratios (TE) and standard errors (seTE)
##D head(pw, 5)[, 1:5]
##D 
##D ### Conduct network meta-analysis (NMA) with placebo as reference
##D net <- netmeta(pw, ref = "plac")
##D 
##D ### Details on excluded study
##D selvars <- c("studlab", "event1", "n1", "event2", "n2")
##D subset(pw, studlab == "WASPO, 2007")[, selvars]
##D 
##D ### Show network graph
##D netgraph(net, seq = "optimal", number = TRUE)
##D 
##D ### Conduct Mantel-Haenszel NMA
##D net.mh <- netmetabin(pw, ref = "plac")
##D 
##D ### Compare results of inverse variance and Mantel-Haenszel NMA
##D nb <- netbind(net, net.mh, random = FALSE,
##D   name = c("Inverse variance", "Mantel-Haenszel"))
##D forest(nb, xlim = c(0.15, 2), at = c(0.2, 0.5, 1, 2))
##D 
##D ### Print and plot results for inverse variance NMA
##D net
##D forest(net)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



