### Name: dat.huber2000
### Title: Individual Participant Data (IPD) from Five Studies on Uro-Vaxom
###   in Urinary Tract Infections
### Aliases: dat.huber2000
### Keywords: datasets

### ** Examples

# show data
head(dat.huber2000)
str(dat.huber2000)
summary(dat.huber2000)
table(dat.huber2000[,1:2])
table(dat.huber2000[,c(2,3,1)])

# compute WMW statistics for all 5 studies
wmw <- tapply(dat.huber2000, dat.huber2000$study,
              function(x){wilcox.test(x$recurrences[x$treatment=="Placebo"],
                                      x$recurrences[x$treatment=="Uro-Vaxom"])$statistic},
              simplify=TRUE)
wmw

# determine treatment group sizes
patients <- table(dat.huber2000[,1:2])
patients

# convert WMW statistics into estimated probability of superiority
# ("common language effect size")
prob <- wmw / (patients[,1]*patients[,2])
round(prob, 3)



