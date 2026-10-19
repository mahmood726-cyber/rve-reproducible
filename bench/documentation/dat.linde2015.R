### Name: dat.linde2015
### Title: Studies on Classes of Antidepressants for the Primary Care
###   Setting
### Aliases: dat.linde2015
### Keywords: datasets

### ** Examples

### Show results from first three studies (including three-arm study
### Lecrubier 1997)
head(dat.linde2015, 3)

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
##D ### Define order of treatments in printouts
##D trts <- c("TCA", "SSRI", "SNRI", "NRI", "Low-dose SARI",
##D  "NaSSa", "rMAO-A", "Hypericum", "Placebo")
##D 
##D ### Transform data from wide arm-based format to contrast-based format
##D ### (outcome: early response). Argument 'sm' has to be used for odds
##D ### ratio as summary measure; by default the risk ratio is used in the
##D ### metabin function called internally.
##D pw1 <- pairwise(list(treatment1, treatment2, treatment3),
##D   event = list(resp1, resp2, resp3),
##D   n = list(n1, n2, n3),
##D   studlab = id, data = dat.linde2015, sm = "OR")
##D 
##D ### Conduct random effects network meta-analysis for primary outcome
##D ### (early response); small number of early responses is bad (argument
##D ### small.values)
##D net1 <- netmeta(pw1, common = FALSE, reference = "Placebo", seq = trts,
##D   small.values = "undesirable")
##D net1
##D 
##D ### Random effects NMA for early remission
##D pw2 <- pairwise(treat = list(treatment1, treatment2, treatment3),
##D   event = list(remi1, remi2, remi3),
##D   n = list(n1, n2, n3),
##D   studlab = id, data = dat.linde2015, sm = "OR")
##D net2 <- netmeta(pw2, common = FALSE,
##D    seq = trts, ref = "Placebo", small.values = "undesirable")
##D net2
##D 
##D ### Ranking of treatments
##D nr1 <- netrank(net1)
##D nr2 <- netrank(net2)
##D nr1
##D nr2
##D 
##D ### Partial order of treatment rankings (two outcomes)
##D outcomes <- c("Early response", "Early remission")
##D po12 <- netposet(nr1, nr2, outcomes = outcomes)
##D plot(po12)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



