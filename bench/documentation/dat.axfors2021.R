### Name: dat.axfors2021
### Title: Mortality Outcomes with Hydroxychloroquine and Chloroquine in
###   COVID-19 from an International Collaborative Meta-Analysis of
###   Randomized Trials
### Aliases: dat.axfors2021
### Keywords: datasets

### ** Examples

# copy data into 'dat' and examine data
dat <- dat.axfors2021
dat

## Not run: 
##D # load metafor package
##D library(metafor)
##D 
##D # calculate log odds ratios and corresponding sampling variances
##D dat <- escalc(measure="OR", ai=hcq_arm_event, n1i=hcq_arm_total,
##D                             ci=control_arm_event, n2i=control_arm_total, data=dat)
##D 
##D # meta-analysis Hydroxychloroquine
##D res_hcq <- rma(yi, vi, subset=(hcq_cq=="hcq"), slab = id, data=dat)
##D print(res_hcq, digits=2)
##D 
##D # meta-analysis Chloroquine
##D res_cq <- rma(yi, vi, subset=(hcq_cq=="cq"), slab = id, data=dat)
##D print(res_cq, digits=2)
## End(Not run)



