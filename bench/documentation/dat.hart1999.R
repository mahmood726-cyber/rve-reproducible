### Name: dat.hart1999
### Title: Studies on the Effectiveness of Warfarin for Preventing Strokes
### Aliases: dat.hart1999
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.hart1999
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log incidence rate ratios and corresponding sampling variances
##D dat <- escalc(measure="IRR", x1i=x1i, x2i=x2i, t1i=t1i, t2i=t2i, data=dat)
##D dat
##D 
##D ### meta-analysis of log incidence rate ratios using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### average incidence rate ratio with 95% CI
##D predict(res, transf=exp)
##D 
##D ### forest plot with extra annotations
##D par(mar=c(5,4,1,2))
##D forest(res, xlim=c(-11, 5), at=log(c(0.05, 0.25, 1, 4)), atransf=exp,
##D        slab=paste0(study, " (", year, ")"),
##D        ilab=cbind(paste(x1i, "/", t1i, sep=" "),
##D                   paste(x2i, "/", t2i, sep=" ")),
##D        ilab.xpos=c(-6.5,-4), cex=0.85, header="Study (Year)")
##D op <- par(cex=0.85, font=2)
##D text(c(-6.5,-4), 8.5, c("Warfarin", "Control"))
##D text(c(-6.5,-4), 7.5, c("Strokes / PT", "Strokes / PT"))
##D segments(x0=-8, y0=8, x1=-2.75, y1=8)
##D par(op)
##D 
##D ### meta-analysis of incidence rate differences using a random-effects model
##D res <- rma(measure="IRD", x1i=x1i, x2i=x2i, t1i=t1i, t2i=t2i, data=dat)
##D res
## End(Not run)



