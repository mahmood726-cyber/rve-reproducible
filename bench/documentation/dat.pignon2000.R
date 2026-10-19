### Name: dat.pignon2000
### Title: Studies on the Effectiveness of Locoregional Treatment plus
###   Chemotherapy for Head and Neck Squamous-Cell Carcinoma
### Aliases: dat.pignon2000
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.pignon2000
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log hazard ratios and sampling variances
##D dat$yi <- with(dat, OmE/V)
##D dat$vi <- with(dat, 1/V)
##D head(dat)
##D 
##D ### meta-analysis based on all 65 trials
##D res <- rma(yi, vi, data=dat, method="EE", digits=2)
##D res
##D predict(res, transf=exp)
##D 
##D ### only adjuvant trials
##D res <- rma(yi, vi, data=dat, method="EE", subset=grp==1, digits=2)
##D res
##D predict(res, transf=exp)
##D 
##D ### only neoadjuvant trials
##D res <- rma(yi, vi, data=dat, method="EE", subset=grp==2, digits=2)
##D res
##D predict(res, transf=exp)
##D 
##D ### only concomitant trials
##D res <- rma(yi, vi, data=dat, method="EE", subset=grp==3, digits=2)
##D res
##D predict(res, transf=exp)
## End(Not run)



