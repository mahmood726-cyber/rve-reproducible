### Name: dat.bassler2004
### Title: Studies on Ketotifen Alone or as Additional Medication for
###   Long-Term Control of Asthma and Wheeze in Children
### Aliases: dat.bassler2004
### Keywords: datasets

### ** Examples

### Show full data set
dat.bassler2004

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Use DerSimonian-Laird estimator (which was the default in meta in the year 2015).
##D ### Furthermore, print meta-analysis results with two digits.
##D oldset <- settings.meta(method.tau = "DL", digits = 2)
##D 
##D ### Calculate experimental and control event rates
##D with(dat.bassler2004, summary(Ee / Ne))
##D with(dat.bassler2004, summary(Ec / Nc))
##D 
##D ### Conduct meta-analysis using the inverse variance method
##D mb3 <- metabin(Ee, Ne, Ec, Nc, method = "I",
##D                data = dat.bassler2004, studlab = study)
##D mb3
##D 
##D ### Conduct subgroup analysis comparing trials with adequate blinding
##D ### to trials with inadequate or unclear blinding
##D mb3s <- update(mb3, subgroup = blind, print.subgroup.name = FALSE)
##D mb3s
##D 
##D ### Conduct subgroup analysis assuming common between-study variance in subgroups
##D mb3s.c <- update(mb3s, tau.common = TRUE)
##D mb3s.c
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



