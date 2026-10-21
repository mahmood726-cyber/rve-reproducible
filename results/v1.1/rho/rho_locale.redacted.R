# Diagnostic R-versus-R control only; never rewrites an archived reference.
stopifnot(as.character(getRversion()) == '4.6.0')
for (p in c('robumeta','clubSandwich','jsonlite')) library(p, character.only=TRUE)
stopifnot(as.character(packageVersion('robumeta'))=='2.1',
          as.character(packageVersion('clubSandwich'))=='0.7.0')
source('<HOST>/p15diag/json17.R')
source('<HOST>/p15diag/reference_core.R')
samples <- fromJSON('<HOST>/p15diag/rho_work/rho_sample.json',simplifyVector=FALSE)
results <- list()
for (i in c(135,293)) for (rho in c(0.4,0.6)) {
  c <- samples[[i]]
  c$id <- paste0(c$design,'::rho=',rho)
  c$rho <- rho
  for (locale in c('C','English_United States.utf8')) {
    stopifnot(Sys.setlocale('LC_COLLATE',locale)==locale,
              Sys.setlocale('LC_CTYPE',locale)==locale)
    results[[length(results)+1]] <- list(index=i,locale=locale,rho=rho,fit=reference_one(c))
  }
}
write_json17(results,'rho-locale-diagnostics.json')
