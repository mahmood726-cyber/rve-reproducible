### Name: dat.begg1989
### Title: Studies on Bone-Marrow Transplantation versus Chemotherapy for
###   the Treatment of Leukemia
### Aliases: dat.begg1989
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.begg1989
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### turn trt and arms into factors and set reference levels
##D dat$trt  <- relevel(factor(dat$trt), ref="CMO")
##D dat$arms <- relevel(factor(dat$arms), ref="2")
##D 
##D ### create data frame with the treatment differences for the controlled studies
##D dat2 <- data.frame(yi = dat$yi[c(1,3,5,7)] - dat$yi[c(2,4,6,8)],
##D                    vi = dat$vi[c(1,3,5,7)] + dat$vi[c(2,4,6,8)])
##D dat2
##D 
##D ### DerSimonian and Laird method using the treatment differences
##D res <- rma(yi, vi, data=dat2, method="DL", digits=2)
##D res
##D 
##D ### Begg & Pilote (1991) model incorporating the uncontrolled studies
##D res <- rma.mv(yi, vi, mods = ~ trt, random = ~ 1 | study,
##D               data=dat, method="ML", digits=2)
##D res
##D 
##D ### model involving bias terms for the uncontrolled studies
##D res <- rma.mv(yi, vi, mods = ~ trt + trt:arms, random = ~ 1 | study,
##D               data=dat, method="ML", digits=2)
##D res
##D 
##D ### model with a random treatment effect
##D res <- rma.mv(yi, vi, mods = ~ trt, random = list(~ 1 | study, ~ trt | study),
##D               struct="UN", tau2=c(0,NA), rho=0, data=dat, method="ML", digits=2)
##D res
##D 
##D ### model with a random treatment effect, but with equal variances in both arms
##D res <- rma.mv(yi, vi, mods = ~ trt, random = list(~ 1 | study, ~ trt | study),
##D               struct="CS", rho=0, data=dat, method="ML", digits=2)
##D res
## End(Not run)



