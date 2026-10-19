.libPaths(c(normalizePath('../re/Rlib_dta'),normalizePath('Rlib'),Sys.getenv('EXTRA_R_LIB'),.libPaths()))
source('json17.R')
write_json17(list(R=R.version.string,robumeta=as.character(packageVersion('robumeta')),robumeta_path=find.package('robumeta'),clubSandwich=as.character(packageVersion('clubSandwich')),clubSandwich_path=find.package('clubSandwich'),locale=Sys.getlocale()),'r2-environment.json')

writeLines(deparse(base::solve.default),'r2-solve-default-source.txt')
