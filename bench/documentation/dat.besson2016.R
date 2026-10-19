### Name: dat.besson2016
### Title: Dataset on How Maternal Diet Impacts Copying Styles in Rodents
### Aliases: dat.besson2016
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.besson2016
head(dat)

## Not run: 
##D ### load metafor
##D library(metafor)
##D 
##D ### compute SD from SE
##D dat$sd_c <- with(dat, con_se * sqrt(con_n))
##D dat$sd_e <- with(dat, exp_se * sqrt(exp_n))
##D 
##D ### compute standardized mean differences and corresponding sampling variances
##D dat <- escalc(measure="SMD", m1i=exp_mean, m2i=con_mean, sd1i=sd_e, sd2i=sd_c,
##D               n1i=exp_n, n2i=con_n, data=dat, add.measure=TRUE)
##D 
##D ### fit model
##D mod1 <- rma.mv(yi ~ 1, V = vi, random = list(~ 1 | study_ID, ~ 1 | comp_ID), data = dat)
##D mod1
## End(Not run)



