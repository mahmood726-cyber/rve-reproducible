### Name: dat.mcdaniel1994
### Title: Studies on the Validity of Employment Interviews
### Aliases: dat.mcdaniel1994
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.mcdaniel1994
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate r-to-z transformed correlations and corresponding sampling variances
##D dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dat)
##D head(dat)
##D 
##D ### meta-analysis of the transformed correlations using a random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### average correlation with 95% CI
##D predict(res, transf=transf.ztor, digits=2)
##D 
##D ### mixed-effects model with interview type as factor
##D ### note: job-related interviews is the reference level
##D res <- rma(yi, vi, mods = ~ factor(type), data=dat)
##D res
##D 
##D ### estimated average correlation for each level of interview type
##D res <- rma(yi, vi, mods = ~ 0 + factor(type), data=dat)
##D predict(res, newmods=diag(3), transf=transf.ztor, digits=2)
##D 
##D ### mixed-effects model with interview structure as factor
##D ### note: structured interviews is the reference level
##D res <- rma(yi, vi, mods = ~ factor(struct), data=dat)
##D res
##D 
##D ### estimated average correlation for each level of interview structure
##D res <- rma(yi, vi, mods = ~ 0 + factor(struct), data=dat)
##D predict(res, newmods=diag(2), transf=transf.ztor, digits=2)
##D 
##D ### note: the interpretation of the results is difficult since all
##D ### situational interviews were structured, almost all psychological
##D ### interviews were unstructured, and actually for the majority of
##D ### the psychological interviews it was unknown whether the interview
##D ### was structured or unstructured
##D table(dat$type, dat$struct, useNA="always")
##D 
##D ### meta-analysis of raw correlations using a random-effects model
##D res <- rma(measure="COR", ri=ri, ni=ni, data=dat.mcdaniel1994)
##D res
## End(Not run)



