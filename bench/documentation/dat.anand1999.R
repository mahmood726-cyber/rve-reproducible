### Name: dat.anand1999
### Title: Studies on the Effectiveness of Oral Anticoagulants in Patients
###   with Coronary Artery Disease
### Aliases: dat.anand1999
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.anand1999
dat

## Not run: 
##D ### load metafor package
##D library(metafor)
##D 
##D ### High-Intensity OA vs Control
##D rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat,
##D        subset=(intensity=="high" & asp.t==0 & asp.c==0), digits=2)
##D 
##D ### High- or Moderate-Intensity OA vs Aspirin
##D rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat,
##D        subset=(intensity %in% c("high","moderate") & asp.t==0 & asp.c==1), digits=2)
##D 
##D ### Moderate-Intensity OA vs Control
##D rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat,
##D        subset=(intensity=="moderate" & asp.t==0 & asp.c==0), digits=2)
##D 
##D ### High- or Moderate-Intensity OA and Aspirin vs Aspirin
##D rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat,
##D        subset=(intensity %in% c("high","moderate") & asp.t==1 & asp.c==1), digits=2)
##D 
##D ### Low-Intensity OA and Aspirin vs Aspirin
##D rma.mh(measure="OR", ai=ai, n1i=n1i, ci=ci, n2i=n2i, data=dat,
##D        subset=(intensity=="low" & asp.t==1 & asp.c==1), digits=2)
## End(Not run)



