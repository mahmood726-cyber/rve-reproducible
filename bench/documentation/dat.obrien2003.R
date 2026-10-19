### Name: dat.obrien2003
### Title: Studies on the Relationship Between BMI and Risk of Preeclampsia
### Aliases: dat.obrien2003
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.obrien2003
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### restructure the data into a wide format
##D dat2 <- to.wide(dat, study="study", grp="grp", ref=1, grpvars=c("bmi","cases","total"),
##D                 addid=FALSE, adddesign=FALSE, postfix=c(1,2))
##D dat2[1:10, -c(2:3)]
##D 
##D ### calculate log risk ratios and corresponding sampling variances
##D dat2 <- escalc(measure="RR", ai=cases1, n1i=total1, ci=cases2, n2i=total2, data=dat2)
##D dat2[1:10, -c(2:7)]
##D 
##D ### forest plot of the risk ratios
##D dd <- c(0,diff(dat2$study))
##D dd[dd > 0] <- 1
##D rows <- (1:nrow(dat2)) + cumsum(dd)
##D rows <- 1 + max(rows) - rows
##D slabs <- mapply(function(x,y,z) as.expression(bquote(.(x)^.(y)~.(z))),
##D                 dat2$author, dat2$ref, dat2$year)
##D with(dat2, forest(yi, vi, slab=slabs, xlim=c(-7,5.5), cex=0.8,
##D    psize=1, pch=19, efac=0, rows=rows, ylim=c(0,max(rows)+3), yaxs="i",
##D    atransf=exp, at=log(c(0.05,0.1,0.2,0.5,1,2,5,10,20)), ilab=comp, ilab.xpos=-4, ilab.pos=4))
##D text(-4.4, max(rows)+2, "Comparison", font=2, cex=0.8, pos=4)
##D 
##D ### within-study mean center the BMI variable
##D dat$bmicent <- with(dat, bmi - ave(bmi, study))
##D 
##D ### compute the proportion of preeclampsia cases and corresponding sampling variances
##D dat <- escalc(measure="PR", xi=cases, ni=total, data=dat)
##D 
##D ### convert the proportions to percentages (and convert the variances accordingly)
##D dat$yi <- dat$yi*100
##D dat$vi <- dat$vi*100^2
##D dat[1:10, -c(2:3)]
##D 
##D ### fit multilevel meta-regression model to examine the relationship between the
##D ### (centered) BMI variable and the risk of preeclampsia
##D res <- rma.mv(yi, vi, mods = ~ bmicent, random = ~ 1 | study/grp, data=dat)
##D res
##D 
##D ### draw scatterplot with regression line
##D res$slab <- dat$ref
##D regplot(res, xlab=expression("Within-Study Mean Centered BMI"~(kg/m^2)),
##D         ylab="Preeclampsia Prevalence (%)", las=1, bty="l",
##D         at=seq(0,18,by=2), olim=c(0,100), psize=2, bg="gray90",
##D         label=TRUE, offset=0, labsize=0.6)
##D 
##D ### fit model using a random slope for bmicent
##D res <- rma.mv(yi, vi, mods = ~ bmicent, random = ~ bmicent | study, struct="GEN", data=dat)
##D res
##D 
##D ### load rms package
##D library(rms)
##D 
##D ### fit restricted cubic spline model
##D res <- rma.mv(yi, vi, mods = ~ rcs(bmicent, 4), random = ~ 1 | study/grp, data=dat)
##D res
##D 
##D ### get knot positions
##D knots <- attr(rcs(model.matrix(res)[,2], 4), "parms")
##D 
##D ### computed predicted values based on the model
##D xs <- seq(-10, 10, length=1000)
##D sav <- predict(res, newmods=rcspline.eval(xs, knots, inclx=TRUE))
##D 
##D ### draw scatterplot with regression line based on the model
##D tmp <- regplot(res, mod=2, pred=sav,
##D                xvals=xs, xlab=expression("Within-Study Mean Centered BMI"~(kg/m^2)),
##D                ylab="Preeclampsia Prevalence (%)", las=1, bty="l",
##D                at=seq(0,18,by=2), olim=c(0,100), psize=2, bg="gray90",
##D                label=TRUE, offset=0, labsize=0.6)
##D abline(v=knots, lty="dotted")
##D points(tmp)
## End(Not run)



