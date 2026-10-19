### Name: dat.linde2016
### Title: Studies on Antidepressants for the Primary Care Setting
### Aliases: dat.linde2016
### Keywords: datasets

### ** Examples

### Show results of first three studies (first study has three treatment arms)
head(dat.linde2016, 7)

## Not run: 
##D ### Load netmeta package
##D suppressPackageStartupMessages(library(netmeta))
##D 
##D ### Print odds ratios and confidence limits with two digits
##D oldset <- settings.meta(digits = 2)
##D 
##D ### Define order of treatments in printouts and forest plots
##D trts <- c("SSRI", "Face-to-face CBT", "Face-to-face interpsy",
##D   "Face-to-face PST", "Face-to-face CBT + SSRI",
##D   "Face-to-face interpsy + SSRI", "Face-to-face PST + SSRI",
##D   "Face-to-face psychodyn", "Other face-to-face",
##D   "TCA", "SNRI", "NRI", "Low-dose SARI", "NaSSa", "rMAO-A", "Ind drug",
##D   "Hypericum", "Remote CBT", "Self-help CBT", "No contact CBT", "UC",
##D   "Placebo")
##D 
##D ### Use pairwise() to transform data to comparison-based format
##D pw <- pairwise(treat = int,
##D   event = resp, n = n,
##D   studlab = paste(author, year),
##D   data = dat.linde2016,
##D   reference = "plac",
##D   sm = "OR")
##D 
##D ### Conduct random effects network meta-analysis
##D nma <- netmeta(pw, reference.group = "placebo",
##D   seq = trts, common = FALSE)
##D 
##D ### Network graph
##D netgraph(nma, seq = "o")
##D 
##D ### Show results
##D nma
##D forest(nma, xlim = c(0.2, 50))
##D 
##D ### Additive component network meta-analysis with placebo as inactive treatment
##D cnma <- netcomb(nma, inactive = "placebo")
##D cnma
##D forest(cnma, xlim = c(0.2, 50))
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



