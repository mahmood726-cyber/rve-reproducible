### Name: dat.nissen2007
### Title: Studies on the Effect of Rosiglitazone on the Risk of Myocardial
###   Infarction and Death from Cardiovascular Causes
### Aliases: dat.nissen2007
### Keywords: datasets

### ** Examples

dat.nissen2007

## Not run: 
##D library(metafor)
##D 
##D ############################################################
##D # reproduce original "Peto" analyses
##D 
##D # infarction
##D ma01 <- rma.peto(ai=treat.infarction, ci=cont.infarction,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma01
##D 
##D # mortality
##D ma02 <- rma.peto(ai=treat.death, ci=cont.death,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma02
##D 
##D ############################################################
##D # reproduce "Fixed, IV (CC)" analyses
##D # from Diamond/Bax/Kaul (2007), Table 1
##D 
##D # infarction
##D ma03 <- rma.uni(measure="OR", method="FE",
##D                 drop00=TRUE,  # (exclude "double-zeroes")
##D                 ai=treat.infarction, ci=cont.infarction,
##D                 n1i=treat.total, n2i=cont.total,
##D                 slab=study, data=dat.nissen2007)
##D ma03
##D 
##D # mortality
##D ma04 <- rma.uni(measure="OR", method="FE",
##D                 drop00=TRUE,  # (exclude "double-zeroes")
##D                 ai=treat.death, ci=cont.death,
##D                 n1i=treat.total, n2i=cont.total,
##D                 slab=study, data=dat.nissen2007)
##D ma04
##D 
##D ############################################################
##D # estimate ORs based on a binomial GLMM
##D # (with *fixed* study effects)
##D # ("model 4" in Jackson et al., 2018)
##D 
##D # infarction
##D ma05 <- rma.glmm(measure="OR", model="UM.FS",
##D                  ai=treat.infarction, ci=cont.infarction,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma05
##D 
##D # mortality
##D ma06 <- rma.glmm(measure="OR", model="UM.FS",
##D                  ai=treat.death, ci=cont.death,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma06
##D 
##D ############################################################
##D # estimate ORs based on binomial GLMM
##D # (with *random* study effects)
##D # ("model 5" in Jackson et al., 2018)
##D 
##D # infarction
##D ma07 <- rma.glmm(measure="OR", model="UM.RS", nAGQ=1,
##D                  ai=treat.infarction, ci=cont.infarction,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma07
##D 
##D # mortality
##D ma08 <- rma.glmm(measure="OR", model="UM.RS", nAGQ=1,
##D                  ai=treat.death, ci=cont.death,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma08
##D 
##D ############################################################
##D # estimate ORs based on hypergeometric model
##D # (model 7 (approx.) in Jackson et al., 2018)
##D 
##D # infarction
##D ma09 <- rma.glmm(measure="OR", model="CM.AL",
##D                  ai=treat.infarction, ci=cont.infarction,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma09
##D 
##D # mortality
##D ma10 <- rma.glmm(measure="OR", model="CM.AL",
##D                  ai=treat.death, ci=cont.death,
##D                  n1i=treat.total, n2i=cont.total,
##D                  slab=study, data=dat.nissen2007)
##D ma10
##D 
##D ############################################################
##D # tabulate estimates and CIs
##D 
##D # log-OR infarction
##D logOR.inf <- rbind("Peto"    =c("OR"=ma01$b, "lower"=ma01$ci.lb, "upper"=ma01$ci.ub),
##D                    "IV-CC"   =c("OR"=ma03$b, "lower"=ma03$ci.lb, "upper"=ma03$ci.ub),
##D                    "M4-UM.FS"=c("OR"=ma05$b, "lower"=ma05$ci.lb, "upper"=ma05$ci.ub),
##D                    "M5-UM.RS"=c("OR"=ma07$b, "lower"=ma07$ci.lb, "upper"=ma07$ci.ub),
##D                    "M7-CM.AL"=c("OR"=ma09$b, "lower"=ma09$ci.lb, "upper"=ma09$ci.ub))
##D 
##D # log-OR mortality
##D logOR.mort <- rbind("Peto"    =c("OR"=ma02$b, "lower"=ma02$ci.lb, "upper"=ma02$ci.ub),
##D                     "IV-CC"   =c("OR"=ma04$b, "lower"=ma04$ci.lb, "upper"=ma04$ci.ub),
##D                     "M4-UM.FS"=c("OR"=ma06$b, "lower"=ma06$ci.lb, "upper"=ma06$ci.ub),
##D                     "M5-UM.RS"=c("OR"=ma08$b, "lower"=ma08$ci.lb, "upper"=ma08$ci.ub),
##D                     "M7-CM.AL"=c("OR"=ma10$b, "lower"=ma10$ci.lb, "upper"=ma10$ci.ub))
##D 
##D # show ORs (infarction)
##D round(exp(logOR.inf), 2)
##D # show ORs (mortality)
##D round(exp(logOR.mort), 2)
## End(Not run)



