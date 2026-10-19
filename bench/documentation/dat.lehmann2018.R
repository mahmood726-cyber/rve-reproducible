### Name: dat.lehmann2018
### Title: The Effect of Red on Perceived Attractiveness
### Aliases: dat.lehmann2018
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.lehmann2018
head(dat)

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### meta-analyses for male and female participants
##D red_romance_malep   <- dat[dat$Gender == "Males", ]
##D red_romance_femalep <- dat[dat$Gender == "Females", ]
##D 
##D res_malep <- rma(yi, vi, data=red_romance_malep, test="knha")
##D res_malep
##D res_femalep <- rma(yi, vi, data=red_romance_femalep, test="knha")
##D res_femalep
## End(Not run)



