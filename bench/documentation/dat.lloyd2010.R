### Name: dat.lloyd2010
### Title: Studies on Anti-TNF-alpha Inhibitors in Rheumatoid Arthritis
### Aliases: dat.lloyd2010
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.lloyd2010, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Only consider studies providing data for both outcomes
##D lloyd5 <- subset(dat.lloyd2010, !is.na(mean.haq) & !is.na(mean.das))
##D 
##D ### Univariate meta-analysis of the DAS-28 outcome
##D m.das <- metagen(mean.das,
##D   lower = lower.das, upper = upper.das,
##D   data = lloyd5, sm = "MD",
##D   studlab = paste(author, year),
##D   random = FALSE)
##D 
##D ### Univariate meta-analysis of the HAQ outcome
##D m.haq <- metagen(mean.haq,
##D   lower = lower.haq, upper = upper.haq,
##D   data = lloyd5, sm = "MD",
##D   studlab = paste(author, year),
##D   random = FALSE)
##D 
##D ### Forest plots
##D forest(m.das, test.overall = TRUE, hetstat = FALSE,
##D   digits.TE = 2, digits.se = 2)
##D forest(m.haq, test.overall = TRUE, hetstat = FALSE,
##D   digits.TE = 2, digits.se = 2)
## End(Not run)



