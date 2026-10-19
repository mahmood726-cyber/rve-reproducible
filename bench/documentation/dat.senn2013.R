### Name: dat.senn2013
### Title: Studies on the Effectiveness of Glucose-Lowering Agents
### Aliases: dat.senn2013
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.senn2013
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### create network graph ('igraph' package must be installed)
##D library(igraph, warn.conflicts=FALSE)
##D pairs <- data.frame(do.call(rbind,
##D    sapply(split(dat$treatment, dat$study), function(x) t(combn(x,2)))), stringsAsFactors=FALSE)
##D pairs$X1 <- factor(pairs$X1, levels=sort(unique(dat$treatment)))
##D pairs$X2 <- factor(pairs$X2, levels=sort(unique(dat$treatment)))
##D tab <- table(pairs[,1], pairs[,2])
##D tab # adjacency matrix
##D g <- graph_from_adjacency_matrix(tab, mode = "plus", weighted=TRUE, diag=FALSE)
##D plot(g, edge.curved=FALSE, edge.width=E(g)$weight, layout=layout_as_star(g, center="placebo"),
##D      vertex.size=45, vertex.color="lightgray", vertex.label.color="black", vertex.label.font=2)
##D 
##D ### table of studies versus treatments examined
##D print(addmargins(table(dat$study, dat$treatment)), zero.print="")
##D 
##D ### table of frequencies with which treatment pairs were studied
##D print(as.table(crossprod(table(dat$study, dat$treatment))), zero.print="")
##D 
##D ### add means and sampling variances of the means to the dataset
##D dat <- escalc(measure="MN", mi=mi, sdi=sdi, ni=ni, data=dat)
##D 
##D ### turn treatment variable into factor and set reference level
##D dat$treatment <- relevel(factor(dat$treatment), ref="placebo")
##D 
##D ### add a space before each level (this makes the output a bit more legible)
##D levels(dat$treatment) <- paste0(" ", levels(dat$treatment))
##D 
##D ### network meta-analysis using an arm-based fixed-effects model with fixed study effects
##D res.fe <- rma.mv(yi, vi, mods = ~ 0 + study + treatment, data=dat, slab=paste0(study, treatment))
##D res.fe
##D 
##D ### test if treatment factor as a whole is significant
##D anova(res.fe, btt="treatment")
##D 
##D ### forest plot of the contrast estimates (treatments versus placebos)
##D forest(tail(coef(res.fe), 9), tail(diag(vcov(res.fe)), 9), slab=levels(dat$treatment)[-1],
##D        xlim=c(-2.5, 1.5), alim=c(-1.5, 0.5), psize=1, xlab="Estimate", header="Treatment")
##D 
##D ### weight matrix for the estimation of the fixed effects (leaving out the study effects)
##D w <- t(tail(vcov(res.fe) %*% t(model.matrix(res.fe)) %*% weights(res.fe, type="matrix"), 9))
##D rownames(w) <- res.fe$slab
##D 
##D ### create shade plot for the diabetes network with placebo as the reference treatment
##D ### negative values in blue shades, positive values in red shades
##D cols <- colorRampPalette(c("blue", "gray95", "red"))(9)
##D heatmap(w, Rowv=NA, Colv=NA, scale="none", margins=c(6,11), col=cols,
##D         cexRow=.7, cexCol=1, labCol=levels(dat$treatment)[-1])
##D 
##D ### network meta-analysis using an arm-based random-effects model with fixed study effects
##D ### by setting rho=1/2, tau^2 reflects the amount of heterogeneity for all treatment comparisons
##D res.re <- rma.mv(yi, vi, mods = ~ 0 + study + treatment, random = ~ treatment | study, rho=1/2,
##D                  data=dat, slab=paste0(study, treatment))
##D res.re
##D 
##D ### test if treatment factor as a whole is significant
##D anova(res.re, btt="treatment")
##D 
##D ### forest plot of the contrast estimates (treatments versus placebos)
##D forest(tail(coef(res.re), 9), tail(diag(vcov(res.re)), 9), slab=levels(dat$treatment)[-1],
##D        xlim=c(-2.5, 1.5), alim=c(-1.5, 0.5), psize=1, xlab="Estimate", header="Treatment")
##D 
##D ### compute the contribution of each study to the overall Q-test value
##D qi <- sort(by((resid(res.fe) / sqrt(dat$vi))^2, dat$study, sum))
##D 
##D ### check that the values add up
##D sum(qi)
##D res.fe$QE
##D 
##D ### plot the values
##D s <- length(qi)
##D par(mar=c(5,10,2,1))
##D plot(qi, 1:s, pch=19, xaxt="n", yaxt="n", xlim=c(0,40), xlab="Chi-Square Contribution", ylab="")
##D axis(side=1)
##D axis(side=2, at=1:s, labels=names(qi), las=1, tcl=0)
##D segments(rep(0,s), 1:s, qi, 1:s)
##D 
##D ############################################################################
##D 
##D ### restructure dataset to a contrast-based format
##D dat <- dat.senn2013[c(1,4:2,5:6)] # reorder variables first
##D dat <- to.wide(dat, study="study", grp="treatment", ref="placebo", grpvars=4:6)
##D dat
##D 
##D ### calculate mean difference and corresponding sampling variance for each treatment comparison
##D dat <- escalc(measure="MD", m1i=mi.1, sd1i=sdi.1, n1i=ni.1,
##D                             m2i=mi.2, sd2i=sdi.2, n2i=ni.2, data=dat)
##D dat
##D 
##D ### calculate the variance-covariance matrix of the mean differences for the multitreatment studies
##D calc.v <- function(x) {
##D    v <- matrix(x$sdi.2[1]^2 / x$ni.2[1], nrow=nrow(x), ncol=nrow(x))
##D    diag(v) <- x$vi
##D    v
##D }
##D V <- bldiag(lapply(split(dat, dat$study), calc.v))
##D 
##D ### add contrast matrix to dataset
##D dat <- contrmat(dat, grp1="treatment.1", grp2="treatment.2")
##D dat
##D 
##D ### network meta-analysis using a contrast-based random-effects model
##D ### by setting rho=1/2, tau^2 reflects the amount of heterogeneity for all treatment comparisons
##D ### the treatment left out (placebo) becomes the reference level for the treatment comparisons
##D res <- rma.mv(yi, V, mods = ~ 0 + acarbose + benfluorex + metformin + miglitol + pioglitazone +
##D                               rosiglitazone + sitagliptin + sulfonylurea + vildagliptin,
##D               random = ~ comp | study, rho=1/2, data=dat)
##D res
##D 
##D ### forest plot of the contrast estimates (treatments versus placebos)
##D forest(coef(res), diag(vcov(res)), slab=names(coef(res)), order="obs",
##D        xlim=c(-3.0, 2.5), alim=c(-1.5, 0.5), psize=1, xlab="Estimate", header="Treatment")
##D 
##D ### estimate all pairwise differences between treatments
##D contr <- data.frame(t(combn(names(coef(res)), 2)))
##D contr <- contrmat(contr, "X1", "X2", last="vildagliptin")
##D rownames(contr) <- paste(contr$X1, "-", contr$X2)
##D contr <- as.matrix(contr[-c(1:2)])
##D sav <- predict(res, newmods=contr)
##D sav[["slab"]] <- rownames(contr)
##D sav
##D 
##D ### fit random inconsistency effects model (see Law et al., 2016)
##D inc <- rma.mv(yi, V, mods = ~ 0 + acarbose + benfluorex + metformin + miglitol + pioglitazone +
##D                               rosiglitazone + sitagliptin + sulfonylurea + vildagliptin,
##D               random = list(~ comp | study, ~ comp | design), rho=1/2, phi=1/2, data=dat)
##D inc
##D 
##D ############################################################################
##D 
##D ### compute P-scores (see Rücker & Schwarzer, 2015)
##D contr <- data.frame(t(combn(c(names(coef(res)),"placebo"), 2))) # add 'placebo' to contrast matrix
##D contr <- contrmat(contr, "X1", "X2", last="placebo", append=FALSE)
##D b <- c(coef(res),0) # add 0 for 'placebo' (the reference treatment)
##D vb <- bldiag(vcov(res),0) # add 0 row/column for 'placebo' (the reference treatment)
##D pvals <- apply(contr, 1, function(x) pnorm((x%*%b) / sqrt(t(x)%*%vb%*%x)))
##D tab <- vec2mat(pvals, corr=FALSE)
##D tab[upper.tri(tab)] <- t((1 - tab)[upper.tri(tab)])
##D rownames(tab) <- colnames(tab) <- colnames(contr)
##D round(tab, 2) # like Table 2 in the article
##D cbind(pscore=round(sort(apply(tab, 1, mean, na.rm=TRUE), decreasing=TRUE), 3))
##D 
##D # note: the values are slightly different from the ones given in Table 3 of Rücker and
##D # Schwarzer (2015) since model 'res' above is fitted using REML estimation while the
##D # results shown in the article are based on the 'netmeta' package, which uses a DL-type
##D # estimator for the amount of heterogeneity by default
##D 
##D ############################################################################
## End(Not run)



