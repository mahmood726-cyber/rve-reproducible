### Name: dat.hannum2020
### Title: Studies Comparing Objective and Subjective Olfactory Loss in
###   COVID-19 Patients
### Aliases: dat.hannum2020
### Keywords: datasets

### ** Examples

# copy data into 'dat' and examine data
dat <- dat.hannum2020
dat

## Not run: 
##D # load metafor package
##D library(metafor)
##D 
##D # compute effect size
##D dat <- escalc(measure="PR", xi=xi, ni=ni, data=dat)
##D 
##D # split data into objective and subjective datasets
##D dat_split <- split(dat, dat$objectivity)
##D dat_objective <- dat_split[["Objective"]]
##D dat_subjective <- dat_split[["Subjective"]]
##D 
##D # random-effects model all studies
##D res_all <- rma(yi, vi, data=dat)
##D print(res_all, digits=2)
##D 
##D # random-effects model objective
##D res_objective <- rma(yi, vi, data=dat_objective)
##D print(res_objective, digits=2)
##D 
##D # random-effects model subjective
##D res_subjective <- rma(yi, vi, data=dat_subjective)
##D print(res_subjective, digits=2)
## End(Not run)



