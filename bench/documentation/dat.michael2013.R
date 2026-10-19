### Name: dat.michael2013
### Title: The Non-Persuasive Power of a Brain Image
### Aliases: dat.michael2013
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.michael2013
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### Data prep
##D # yi and vi are already provided, but here's how you would use escalc() to obtain
##D # a raw-mean difference and its variance.
##D # Note the measure parameter is "MD" for 'raw mean difference'
##D dat <- metafor::escalc(
##D   measure = "MD",
##D   m1i = Brain_m,
##D   m2i = No_brain_m,
##D   sd1i = Brain_s,
##D   sd2i = No_brain_s,
##D   n1i = Brain_n,
##D   n2i = No_brain_n,
##D   data = dat
##D )
##D 
##D ### meta-analysis using a random-effects model of the raw mean differences
##D res <- rma(yi, vi, data=dat)
##D print(res, digits=2)
##D 
##D ### examine if Included_Critique is a potential moderator
##D res <- rma(yi, vi, mods = ~ Included_Critique, data=dat)
##D print(res, digits=2)
## End(Not run)



