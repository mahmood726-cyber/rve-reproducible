### Name: dat.rivera2025
### Title: Comparison of Two Diagnostic Tests for the Detection of
###   Temporomandibular Disorders
### Aliases: dat.rivera2025
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.rivera2025
dat

## Not run: 
##D suppressPackageStartupMessages(library(meta))
##D 
##D ### sensitivity
##D round(dat$TP / dat$n1, 4)
##D report1 <- metaprop(TP, n1, data=dat, common=TRUE, random=TRUE, studlab=paste(Author, Year))
##D report1
##D summary(report1)
##D forest(report1)
##D 
##D ### specificity
##D round(dat$TN / dat$n2, 4)
##D report2 <- metaprop(TN, n2, data=dat, common=TRUE, random=TRUE, studlab=paste(Author, Year))
##D summary(report2)
##D forest(report2)
##D 
##D ### diagnostic odds ratio
##D report3 <- metabin(TP, n1, n2-TN, n2, data=dat, sm="OR",common=FALSE, random=TRUE,
##D                    studlab=paste(Author, Year), allstudies=TRUE)
##D summary(report3)
## End(Not run)



