### Name: dat.lopez2019
### Title: Studies on the Effectiveness of CBT for Depression
### Aliases: dat.lopez2019
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.lopez2019
dat[1:10,1:6]

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
##D plot(g, edge.curved=FALSE, edge.width=E(g)$weight/2,
##D      layout=layout_in_circle(g, order=c("Wait list", "No treatment", "TAU", "Multimedia CBT",
##D                                         "Hybrid CBT", "F2F CBT", "Placebo")),
##D      vertex.size=45, vertex.color="lightgray", vertex.label.color="black", vertex.label.font=2)
##D 
##D ### restructure data into wide format
##D dat <- to.wide(dat, study="study", grp="treatment", ref="TAU",
##D                grpvars=c("diff","se","n"), postfix=c("1","2"))
##D 
##D ### compute contrasts between treatment pairs and corresponding sampling variances
##D dat$yi <- with(dat, diff1 - diff2)
##D dat$vi <- with(dat, se1^2 + se2^2)
##D 
##D ### calculate the variance-covariance matrix for multitreatment studies
##D calc.v <- function(x) {
##D    v <- matrix(x$se2[1]^2, nrow=nrow(x), ncol=nrow(x))
##D    diag(v) <- x$vi
##D    v
##D }
##D V <- bldiag(lapply(split(dat, dat$study), calc.v))
##D 
##D ### add contrast matrix to the dataset
##D dat <- contrmat(dat, grp1="treatment1", grp2="treatment2")
##D 
##D ### network meta-analysis using a contrast-based random-effects model
##D ### by setting rho=1/2, tau^2 reflects the amount of heterogeneity for all treatment comparisons
##D ### the treatment left out (TAU) becomes the reference level for the treatment comparisons
##D res1 <- rma.mv(yi, V, data=dat,
##D          mods = ~ 0 + No.treatment + Wait.list + Placebo + F2F.CBT + Hybrid.CBT + Multimedia.CBT,
##D          random = ~ comp | study, rho=1/2)
##D res1
##D 
##D ### forest plot of the contrast estimates (treatments versus TAU)
##D forest(coef(res1), diag(vcov(res1)), slab=sub(".", " ", names(coef(res1)), fixed=TRUE),
##D        xlim=c(-5,5), alim=c(-3,3), psize=1, header="Treatment",
##D        xlab="Difference in Standardized Mean Change (compared to TAU)")
##D 
##D ### fit random inconsistency effects model (might have to switch optimizer to get convergence)
##D res2 <- rma.mv(yi, V, data=dat,
##D          mods = ~ 0 + No.treatment + Wait.list + Placebo + F2F.CBT + Hybrid.CBT + Multimedia.CBT,
##D          random = list(~ comp | study, ~ comp | design), rho=1/2, phi=1/2,
##D          control=list(optimizer="BFGS"))
##D res2
##D 
##D ### likelihood ratio test comparing the two models
##D anova(res1, res2)
##D 
##D ### collapse the different CBT forms into a single category
##D dat$CBT <- with(dat, ifelse(F2F.CBT + Hybrid.CBT + Multimedia.CBT > 0, 1, 0))
##D 
##D ### fit the model with this treatment indicator
##D res3 <- rma.mv(yi, V, data=dat,
##D          mods = ~ 0 + No.treatment + Wait.list + Placebo + CBT,
##D          random = ~ comp | study, rho=1/2)
##D res3
##D 
##D ### component network meta-analysis (effect of CBT may be larger/smaller depending on
##D ### the presence of various components; leaving out 'mind' and 'act' as in the paper)
##D res4 <- rma.mv(yi, V, data=dat,
##D          mods = ~ 0 + No.treatment + Wait.list + Placebo + CBT +
##D          CBT:(multi + cog + ba + psed + home + prob + soc + relax + goal + final),
##D          random = ~ comp | study, rho=1/2)
##D res4
##D 
##D rownames <- names(coef(res4))
##D rownames <- sub(".", " ", rownames, fixed=TRUE)
##D rownames[5:14] <- c("Multimedia", "Cognitive Techniques", "Behavioral Activiation",
##D                     "Psycheducation", "Homework", "Problem Solving", "Social Skills Training",
##D                     "Relaxation", "Goal Setting", "Final Session")
##D 
##D ### forest plot of the estimates
##D forest(coef(res4), diag(vcov(res4)), slab=rownames,
##D        xlim=c(-5,5), alim=c(-3,3), psize=1, header="Treatment",
##D        xlab="Difference in Standardized Mean Change (compared to TAU)")
##D abline(h=10.5, lty="dashed")
## End(Not run)



