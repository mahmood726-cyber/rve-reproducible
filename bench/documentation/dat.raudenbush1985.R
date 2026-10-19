### Name: dat.raudenbush1985
### Title: Studies on Assessing the Effects of Teacher Expectations on
###   Pupil IQ
### Aliases: dat.raudenbush1985
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.raudenbush1985
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### random-effects model
##D res <- rma(yi, vi, data = dat)
##D res
##D 
##D ### create weeks variable where values larger than 3 are set to 3
##D dat$weeks.c <- ifelse(dat$weeks > 3, 3, dat$weeks)
##D 
##D ### mixed-effects model with weeks.c variable as moderator
##D res <- rma(yi, vi, mods = ~ weeks.c, data = dat, digits = 3)
##D res
## End(Not run)



