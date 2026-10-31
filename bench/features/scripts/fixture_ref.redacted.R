# Independent, hand-written reference fits for the three multi-predictor fixtures.
.libPaths(c('<HOST>/p101115/Rlib', .libPaths()))
library(jsonlite); library(robumeta); library(clubSandwich)
setwd('<HOST>/p101115/rveup'); source('json17.R')
fx <- fromJSON('fixtures.json', simplifyVector = FALSE)
for (f in fx) {
  rows <- f$rows
  dd <- data.frame(y = vapply(rows, function(r) r$yi, 0.0), v = vapply(rows, function(r) r$vi, 0.0), s = vapply(rows, function(r) r$cluster, ''))
  X <- do.call(rbind, lapply(rows, function(r) unlist(r$X)))
  for (j in 2:ncol(X)) dd[[paste0('p', j - 1)]] <- X[, j]
  fo <- as.formula(paste('y ~', paste(paste0('p', 1:(ncol(X) - 1)), collapse = ' + ')))
  rr <- robu(fo, data = dd, studynum = s, var.eff.size = v, modelweights = 'CORR', rho = 0.8, small = TRUE)
  tab <- rr$reg_table
  cb <- as.data.frame(coef_test(rr, vcov = 'CR2', test = 'Satterthwaite'))
  write_json17(list(name = f$name, status = 'ok', table = unname(lapply(seq_len(nrow(tab)), function(j) as.list(tab[j, ]))), tau2 = as.numeric(rr$mod_info$tau.sq), club = cb), paste0('fixture_ref_', f$name, '.json'))
}
cat('fixtures done\n')
