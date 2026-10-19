.libPaths(c(normalizePath('../re/Rlib_dta'),normalizePath('Rlib'),Sys.getenv('EXTRA_R_LIB'),.libPaths()))
source('json17.R')
packages<-c('metafor','metadat','meta','robumeta','clubSandwich','jsonlite')
write_json17(list(R=R.version.string,platform=R.version[['platform',exact=TRUE]],host='local Windows host; no offload',packages=setNames(lapply(packages,function(p)as.character(packageVersion(p))),packages),pinned_library_first=identical(.libPaths()[1],normalizePath('../re/Rlib_dta',winslash='/')),scratch_R_LIBS_has_metafor=file.exists(file.path(Sys.getenv('R_LIBS'),'metafor'))),'environment.json')
