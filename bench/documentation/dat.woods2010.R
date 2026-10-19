### Name: dat.woods2010
### Title: Studies on Treatments for Chronic Obstructive Pulmonary Disease
### Aliases: dat.woods2010
### Keywords: datasets

### ** Examples

### Show full dataset
dat.woods2010

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
##D pw <- pairwise(treatment, event = r, n = N,
##D   studlab = author, data = dat.woods2010, sm = "OR")
##D pw
##D 
##D ### Conduct network meta-analysis
##D net <- netmeta(pw)
##D net
##D 
##D ### Show forest plot
##D forest(net, ref = "Placebo", drop = TRUE,
##D   leftlabs = "Contrast to Placebo")
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



