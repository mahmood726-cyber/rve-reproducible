### Name: dat.crede2010
### Title: Studies on the Relationship between Class Attendance and Grades
###   in College Students
### Aliases: dat.crede2010
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.crede2010
head(dat, 18)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate r-to-z transformed correlations and corresponding sampling variances
##D dat <- escalc(measure="ZCOR", ri=ri, ni=ni, data=dat)
##D 
##D ############################################################################
##D 
##D ### meta-analysis for the relationship between attendance and grades
##D res <- rma(yi, vi, data=dat, subset=criterion=="grade")
##D res
##D 
##D ### estimated average correlation with 95% CI/PI
##D predict(res, transf=transf.ztor, digits=2)
##D 
##D ### examine if relationship between attendance and grades differs for nonscience/science classes
##D res <- rma(yi, vi, mods = ~ class, data=dat, subset=criterion=="grade")
##D res
##D 
##D ### estimated average correlations for nonscience and science classes
##D predict(res, newmods=c(0,1), transf=transf.ztor, digits=2)
##D 
##D ### examine if relationship between attendance and grades has changed over time
##D res <- rma(yi, vi, mods = ~ year, data=dat, subset=criterion=="grade")
##D res
##D 
##D ############################################################################
##D 
##D ### meta-analysis for the relationship between attendance and GPA
##D res <- rma(yi, vi, data=dat, subset=criterion=="gpa")
##D res
##D 
##D ### estimated average correlation with 95% CI/PI
##D predict(res, transf=transf.ztor, digits=2)
##D 
##D ### examine if relationship between attendance and GPA has changed over time
##D res <- rma(yi, vi, mods = ~ year, data=dat, subset=criterion=="gpa")
##D res
##D 
##D ############################################################################
##D 
##D ### use a multilevel model to examine the relationship between attendance and grades
##D res <- rma.mv(yi, vi, random = ~ 1 | studyid/sampleid, data=dat, subset=criterion=="grade")
##D res
##D predict(res, transf=transf.ztor, digits=2)
##D 
##D ### use a multilevel model to examine the relationship between attendance and gpa
##D res <- rma.mv(yi, vi, random = ~ 1 | studyid/sampleid, data=dat, subset=criterion=="gpa")
##D res
##D predict(res, transf=transf.ztor, digits=2)
## End(Not run)



