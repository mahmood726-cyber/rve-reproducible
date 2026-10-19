### Name: dat.knapp2017
### Title: Studies on Differences in Planning Performance in Schizophrenia
###   Patients versus Healthy Controls
### Aliases: dat.knapp2017
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.knapp2017
dat[-c(1:2)]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### fit a standard random-effects model ignoring the issues described above
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### fit a multilevel model with random effects for studies and comparisons within studies
##D ### (but this ignored the correlation in the sampling errors)
##D res <- rma.mv(yi, vi, random = ~ 1 | study/comp, data=dat)
##D res
##D 
##D ### create variable that indicates the task and difficulty combination as increasing integers
##D dat$task.diff <- unlist(lapply(split(dat, dat$study), function(x) {
##D    task.int <- as.integer(factor(x$task))
##D    diff.int <- as.integer(factor(x$difficulty))
##D    diff.int[is.na(diff.int)] <- 1
##D    paste0(task.int, ".", diff.int)}))
##D 
##D ### construct correlation matrix for two tasks with four different difficulties where the
##D ### correlation is 0.4 for different difficulties of the same task, 0.7 for the same
##D ### difficulty of different tasks, and 0.28 for different difficulties of different tasks
##D R <- matrix(0.4, nrow=8, ncol=8)
##D R[5:8,1:4] <- R[1:4,5:8] <- 0.28
##D diag(R[1:4,5:8]) <- 0.7
##D diag(R[5:8,1:4]) <- 0.7
##D diag(R) <- 1
##D rownames(R) <- colnames(R) <- paste0(rep(1:2, each=4), ".", 1:4)
##D R
##D 
##D ### construct an approximate V matrix accounting for the use of shared groups and
##D ### for correlations among tasks/difficulties as specified in the R matrix above
##D V <- vcalc(vi, cluster=study, grp1=group1, grp2=group2, w1=n_sz, w2=n_hc,
##D            obs=task.diff, rho=R, data=dat)
##D 
##D ### correlation matrix for study 3 with four patient groups and a single control group
##D round(cov2cor(V[dat$study == 3, dat$study == 3]), 2)
##D 
##D ### correlation matrix for study 6 with two tasks with four difficulties
##D cov2cor(V[dat$study == 6, dat$study == 6])
##D 
##D ### correlation matrix for study 24 with two independent groups
##D cov2cor(V[dat$study == 24, dat$study == 24])
##D 
##D ### correlation matrix for study 29 with three independent groups
##D cov2cor(V[dat$study == 29, dat$study == 29])
##D 
##D ### fit multilevel model as above, but now use this V matrix in the model
##D res <- rma.mv(yi, V, random = ~ 1 | study/comp, data=dat)
##D res
##D predict(res, digits=2)
##D 
##D ### use cluster-robust inference methods based on this model
##D robust(res, cluster=study)
##D 
##D ### use methods from the clubSandwich package
##D robust(res, cluster=study, clubSandwich=TRUE)
##D 
##D ### examine if task difficulty is a potential moderator of the effect
##D res <- rma.mv(yi, V, mods = ~ difficulty, random = ~ 1 | study/comp, data=dat)
##D res
##D sav <- robust(res, cluster=study)
##D sav
##D sav <- robust(res, cluster=study, clubSandwich=TRUE)
##D sav
##D 
##D ### draw bubble plot
##D regplot(sav, xlab="Task Difficulty", ylab="Standardized Mean Difference", las=1, digits=1, bty="l")
## End(Not run)



