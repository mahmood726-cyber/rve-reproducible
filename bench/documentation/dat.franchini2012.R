### Name: dat.franchini2012
### Title: Studies on Dopamine Agonists to Reduce "Off-Time" in Patients
###   with Advanced Parkinson Disease
### Aliases: dat.franchini2012
### Keywords: datasets

### ** Examples

### Show results from first three studies; third study is a three-arm
### study
head(dat.franchini2012, 3)

## Not run: 
##D ### Load netmeta package
##D suppressPackageStartupMessages(library(netmeta))
##D 
##D ### Print mean differences with two digits
##D oldset <- settings.meta(digits = 2)
##D 
##D ### Transform data from wide arm-based format to contrast-based
##D ### format. Argument 'sm' must not be provided as the mean difference
##D ### is the default in R function metacont() called internally.
##D pw <- pairwise(list(Treatment1, Treatment2, Treatment3),
##D   n = list(n1, n2, n3),
##D   mean = list(y1, y2, y3),
##D   sd = list(sd1, sd2, sd3),
##D   data = dat.franchini2012, studlab = Study, sm = "MD")
##D 
##D ### Show calculated mean differences (TE) for first three studies
##D pw[1:5, c(3:7, 10, 1)]
##D 
##D ### Conduct network meta-analysis
##D net <- netmeta(pw)
##D net
##D 
##D ### Draw network graph
##D netgraph(net, points = TRUE, cex.points = 3, cex = 1.5,
##D   plastic = TRUE, thickness = "se.fixed",
##D   iterate = TRUE, start = "eigen")
##D 
##D ### Use previous settings
##D settings.meta(oldset)
## End(Not run)



