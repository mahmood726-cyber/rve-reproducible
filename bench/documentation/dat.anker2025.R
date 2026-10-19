### Name: dat.anker2025
### Title: Cardiology Example Data with Subgroup and Interaction Effects
### Aliases: dat.anker2025
### Keywords: datasets

### ** Examples

# show data
dat.anker2025
## Not run: 
##D library(bayesmeta)
##D 
##D # specify heterogeneity (tau) prior density (half-normal(0.5))
##D HN05 <- function(t){dhalfnormal(t, scale=0.5)}
##D 
##D #######################################
##D #  reproduce primary analysis (Fig.2)
##D es.primary <- escalc(measure="IRR", yi=total.logrr, sei=total.se,
##D                      ni=total.n, slab=study, data=dat.anker2025)
##D bma01 <- bayesmeta(es.primary, tau.prior=HN05)
##D forestplot(bma01, expo=TRUE, xlog=TRUE,
##D            xlab="rate ratio (RR)", title="HF hospitalizations / CV mortality")
##D 
##D ######################################
##D #  reproduce sex interaction analysis
##D #  (Tab.2, Supplementary Fig.4)
##D es.sex <- escalc(measure="GEN", yi=sex.logrrr, sei=sex.se,
##D                  ni=total.n, slab=study, data=dat.anker2025)
##D bma02 <- bayesmeta(es.sex, tau.prior=HN05)
##D forestplot(bma02, expo=TRUE, xlog=TRUE,
##D            xlab="ratio of RRs (RRR)", title="sex interaction (females/males)")
##D 
##D ###########################################
##D #  reproduce male/female subgroup analyses
##D #  (Tab.2, Supplementary Fig.12)
##D es.female <- escalc(measure="IRR", yi=female.logrr, sei=female.se,
##D                     ni=female.n, slab=study, data=dat.anker2025)
##D es.male   <- escalc(measure="IRR", yi=male.logrr, sei=male.se,
##D                     ni=male.n, slab=study, data=dat.anker2025)
##D bma03a <- bayesmeta(es.female, tau.prior=HN05)
##D bma03b <- bayesmeta(es.male, tau.prior=HN05)
##D forestplot(bma03a, expo=TRUE, xlog=TRUE,
##D            xlab="rate ratio (RR)", title="female subgroup")
##D forestplot(bma03b, expo=TRUE, xlog=TRUE,
##D            xlab="rate ratio (RR)", title="male subgroup")
## End(Not run)



