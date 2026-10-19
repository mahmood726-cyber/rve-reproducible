### Name: dat.hasselblad1998
### Title: Studies on the Effectiveness of Counseling for Smoking Cessation
### Aliases: dat.hasselblad1998
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.hasselblad1998
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### create network graph ('igraph' package must be installed)
##D library(igraph, warn.conflicts=FALSE)
##D pairs <- data.frame(do.call(rbind,
##D    sapply(split(dat$trt, dat$study), function(x) t(combn(x,2)))), stringsAsFactors=FALSE)
##D lvls <- c("no_contact", "self_help", "ind_counseling", "grp_counseling")
##D pairs$X1 <- factor(pairs$X1, levels=lvls)
##D pairs$X2 <- factor(pairs$X2, levels=lvls)
##D tab <- table(pairs[,1], pairs[,2])
##D tab # adjacency matrix
##D g <- graph_from_adjacency_matrix(tab, mode = "plus", weighted=TRUE, diag=FALSE)
##D vertex_attr(g, "name") <- c("No Contact", "Self-Help",
##D                             "Individual\nCounseling", "Group\nCounseling")
##D plot(g, edge.curved=FALSE, edge.width=E(g)$weight, layout=layout_on_grid,
##D      vertex.size=45, vertex.color="lightgray", vertex.label.color="black", vertex.label.font=2)
##D 
##D ### calculate log odds for each study arm
##D dat <- escalc(measure="PLO", xi=xi, ni=ni, add=1/2, to="all", data=dat)
##D dat
##D 
##D ### convert trt variable to factor with desired ordering of levels
##D dat$trt <- factor(dat$trt, levels=c("no_contact", "self_help", "ind_counseling", "grp_counseling"))
##D 
##D ### add a space before each level (this makes the output a bit more legible)
##D levels(dat$trt) <- paste0(" ", levels(dat$trt))
##D 
##D ### network meta-analysis using an arm-based model with fixed study effects
##D ### by setting rho=1/2, tau^2 reflects the amount of heterogeneity for all treatment comparisons
##D res <- rma.mv(yi, vi, mods = ~ 0 + factor(study) + trt,
##D               random = ~ trt | study, rho=1/2, data=dat, btt="trt")
##D res
##D 
##D ### all pairwise odds ratios of interventions versus no contact
##D predict(res, newmods=cbind(matrix(0, nrow=3, ncol=24), diag(3)),
##D         intercept=FALSE, transf=exp, digits=2)
##D 
##D ### all pairwise odds ratios comparing interventions (ic vs sh, gc vs sh, and gc vs ic)
##D predict(res, newmods=cbind(matrix(0, nrow=3, ncol=24), rbind(c(-1,1,0), c(-1,0,1), c(0,-1,1))),
##D         intercept=FALSE, transf=exp, digits=2)
##D 
##D ### forest plot of ORs of interventions versus no contact
##D forest(c(0,res$beta[25:27]), sei=c(0,res$se[25:27]), psize=1, xlim=c(-3,4), digits=c(2,1), efac=2,
##D        slab=c("No Contact", "Self-Help", "Individual Counseling", "Group Counseling"),
##D        atransf=exp, at=log(c(0.5, 1, 2, 4, 8)), xlab="Odds Ratio for Intervention vs. No Contact",
##D        header=c("Intervention", "Odds Ratio [95% CI]"))
##D 
##D ############################################################################
##D 
##D ### restructure dataset to a contrast-based format
##D dat <- to.wide(dat.hasselblad1998, study="study", grp="trt", ref="no_contact", grpvars=6:7)
##D 
##D ### calculate log odds ratios for each treatment comparison
##D dat <- escalc(measure="OR", ai=xi.1, n1i=ni.1,
##D                             ci=xi.2, n2i=ni.2, add=1/2, to="all", data=dat)
##D dat
##D 
##D ### calculate the variance-covariance matrix of the log odds ratios for multitreatment studies
##D ### see Gleser & Olkin (2009), equation (19.11), for the covariance equation
##D calc.v <- function(x) {
##D    v <- matrix(1/(x$xi.2[1] + 1/2) + 1/(x$ni.2[1] - x$xi.2[1] + 1/2), nrow=nrow(x), ncol=nrow(x))
##D    diag(v) <- x$vi
##D    v
##D }
##D V <- bldiag(lapply(split(dat, dat$study), calc.v))
##D 
##D ### add contrast matrix to dataset
##D dat <- contrmat(dat, grp1="trt.1", grp2="trt.2")
##D dat
##D 
##D ### network meta-analysis using a contrast-based random-effects model
##D ### by setting rho=1/2, tau^2 reflects the amount of heterogeneity for all treatment comparisons
##D res <- rma.mv(yi, V, mods = ~ 0 + self_help + ind_counseling + grp_counseling,
##D               random = ~ comp | study, rho=1/2, data=dat)
##D res
##D 
##D ### predicted odds ratios of interventions versus no contact
##D predict(res, newmods=diag(3), transf=exp, digits=2)
##D 
##D ### fit random inconsistency effects model (see Law et al., 2016)
##D res <- rma.mv(yi, V, mods = ~ 0 + self_help + ind_counseling + grp_counseling,
##D               random = list(~ comp | study, ~ comp | design), rho=1/2, phi=1/2, data=dat)
##D res
## End(Not run)



