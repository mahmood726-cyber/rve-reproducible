.libPaths(c(normalizePath('../re/Rlib_dta'),normalizePath('Rlib'),Sys.getenv('EXTRA_R_LIB'),.libPaths()))
library(robumeta); library(clubSandwich); library(jsonlite)
for(pkg in c('robumeta','clubSandwich','metadat')) {
 cat('\n',pkg,'\n'); print(data(package=pkg)[['results',exact=TRUE]][,'Item'])
}
out <- list()
for(nm in c('corrdat','hierdat','dropoutPrevention','SATcoaching','oswald2013')) {
 found <- FALSE
 for(pkg in c('robumeta','clubSandwich','metadat')) {
  e <- new.env(); suppressWarnings(data(list=nm,package=pkg,envir=e))
  if(exists(nm,e,inherits=FALSE)) {
   d <- e[[nm]]; cat(nm,pkg,'\n'); print(names(d)); print(head(d,2))
   if(nm=='oswald2013') d<-metafor::escalc(measure='ZCOR',ri=d[['R',exact=TRUE]],ni=d[['N',exact=TRUE]],data=d)
   out[[nm]] <- list(package=pkg,data=d); found <- TRUE; break
  }
 }
 if(!found) out[[nm]] <- list(status='unavailable in installed reference packages')
}
write_json(out,'extra-data.json',digits=NA,na='null',dataframe='columns',auto_unbox=TRUE)
dir.create('documentation',showWarnings=FALSE)
writeLines(deparse(robumeta::robu),'documentation/robu-source.R')
for(pkg in c('robumeta','clubSandwich')) {
 db<-tools::Rd_db(pkg)
 for(nm in names(db)) if(grepl('robu|coef_test|vcovCR.robu|corrdat|hierdat|dropout|SATcoach|oswald',nm)) capture.output(tools::Rd2txt(db[[nm]]),file=file.path('documentation',paste0(pkg,'-',nm,'.txt')))
}
