### Name: dat.hartmannboyce2018
### Title: Studies on the Effectiveness of Nicotine Replacement Therapy for
###   Smoking Cessation
### Aliases: dat.hartmannboyce2018
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.hartmannboyce2018
head(dat, 10)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### turn treatment into a factor with the desired ordering
##D dat$treatment <- factor(dat$treatment, levels=unique(dat$treatment))
##D 
##D ### meta-analysis per treatment using the M-H method
##D lapply(split(dat, dat$treatment), function(x)
##D        rma.mh(measure="RR", ai=x.nrt,  n1i=n.nrt,
##D                             ci=x.ctrl, n2i=n.ctrl, data=x, digits=2))
##D 
##D ### all combined
##D rma.mh(measure="RR", ai=x.nrt,  n1i=n.nrt,
##D                      ci=x.ctrl, n2i=n.ctrl, data=dat, digits=2)
## End(Not run)



