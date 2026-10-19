### Name: dat.moore1998
### Title: Trials on Non-Steroidal Anti-Inflammatory Drugs in Acute Pain
### Aliases: dat.moore1998
### Keywords: datasets

### ** Examples

### Show first five studies
head(dat.moore1998, 5)

## Not run: 
##D ### Load meta package
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### Conduct meta-analysis
##D m <- metabin(Ee, Ne, Ec, Nc, data = dat.moore1998,
##D   sm = "OR", studlab = id,
##D   label.e = "NSAIDS", label.c = "Placebo")
##D 
##D ### Funnel plot
##D fun <- funnel(m, type = "contour",
##D   random = FALSE, pch = 16)
##D legend(0.25, 1.25, bty = "n",
##D   legend = fun$text.contour, fill = fun$col.contour)
## End(Not run)



