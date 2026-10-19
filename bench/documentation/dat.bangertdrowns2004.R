### Name: dat.bangertdrowns2004
### Title: Studies on the Effectiveness of Writing-to-Learn Interventions
### Aliases: dat.bangertdrowns2004
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.bangertdrowns2004
dat[1:10,-13]

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### fit random-effects model
##D res <- rma(yi, vi, data=dat)
##D res
##D 
##D ### some examples of mixed-effects meta-regression models
##D res <- rma(yi, vi, mods = ~ factor(grade), data=dat)
##D res
##D res <- rma(yi, vi, mods = ~ length, data=dat)
##D res
##D res <- rma(yi, vi, mods = ~ info + pers + imag + meta, data=dat)
##D res
## End(Not run)



