### Name: dat.bourassa1996
### Title: Studies on the Association between Handedness and Eye-Dominance
### Aliases: dat.bourassa1996
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.bourassa1996
head(dat, 10)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### calculate log(OR) and corresponding sampling variance with 1/2 correction
##D dat <- escalc(measure="OR", ai=lh.le, bi=lh.re, ci=rh.le, di=rh.re, data=dat, add=1/2, to="all")
##D head(dat, 10)
##D 
##D ### overall association between handedness and eyedness
##D res <- rma(yi, vi, data=dat, subset=sex=="combined")
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### multilevel model to account for heterogeneity at the study and sample levels
##D res <- rma.mv(yi, vi, random = ~ 1 | study/sample, data=dat, subset=sex=="combined")
##D res
##D predict(res, transf=exp, digits=2)
##D 
##D ### restructure the dataset to keep only the male/female data when it is reported
##D ### separately and the combined data when this is the only data reported
##D dat <- lapply(split(dat, dat$sample), function(x) {
##D    if (nrow(x) == 3L) {
##D       x[-which(x$sex == "combined"),]
##D    } else {
##D       x
##D    }
##D })
##D dat <- do.call(rbind, dat)
##D rownames(dat) <- NULL
##D dat
##D 
##D ### multilevel model to account for heterogeneity at the study, sample, and subgroup levels
##D res <- rma.mv(yi, vi, random = ~ 1 | study/sample/sex, data=dat)
##D res
##D predict(res, transf=exp, digits=2)
## End(Not run)



