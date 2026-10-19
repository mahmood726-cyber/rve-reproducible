### Name: dat.stowe2010
### Title: Studies on Adjuvant Treatments to Levodopa Therapy for Parkinson
###   disease
### Aliases: dat.stowe2010
### Keywords: datasets

### ** Examples

### Show results from three studies (including three-arm study LARGO)
dat.stowe2010[18:20, ]

## Not run: 
##D ### Load netmeta package
##D suppressPackageStartupMessages(library(netmeta))
##D 
##D ### Print mean differences with two digits and standard errors with 3
##D ### digits
##D oldset <- settings.meta(digits = 2, digits.se = 3)
##D 
##D ### Transform data from wide arm-based format to contrast-based
##D ### format. Argument 'sm' must not be provided as the mean difference
##D ### is the default in R function metacont() called internally.
##D pw <- pairwise(treat = list(t1, t2, t3), n = list(n1, n2, n3),
##D   mean = list(y1, y2, y3), sd = list(sd1, sd2, sd3),
##D   studlab = study, data = dat.stowe2010, sm = "MD")
##D 
##D ### Show calculated mean differences (TE) for three studies
##D selstudy <- c("COMTI(E) INT-OZ", "LARGO", "COMTI(E) Nomecomt")
##D subset(pw, studlab %in% selstudy)[, c(3:7, 10, 1)]
##D 
##D ### Conduct random effects network meta-analysis (NMA)
##D ### with placebo as reference
##D net <- netmeta(pw, common = FALSE, ref = "plac")
##D 
##D ### Show network graph
##D netgraph(net, number = TRUE, multiarm = TRUE,
##D   cex = 1.25, offset = 0.025,
##D   cex.number = 1, pos.number.of.studies = 0.3)
##D 
##D ### Print NMA results
##D net
##D 
##D ### Forest plot with NMA results
##D forest(net)
##D 
##D ### Forest plot showing all network estimates of active treatments
##D ### compared with other treatments
##D forest(net, ref = c("C", "D", "M"), baseline = FALSE, drop = TRUE)
##D 
##D ### Treatment ranking using P-scores
##D netrank(net)
##D 
##D ### Rankogram with all ranking probabilities
##D set.seed(1909)
##D ran <- rankogram(net)
##D ran
##D plot(ran)
##D 
##D ### Treatment ranking using SUCRAs
##D netrank(ran)
##D 
##D ### League table showing network and direct estimates
##D netleague(net, seq = netrank(net), ci = FALSE)
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



