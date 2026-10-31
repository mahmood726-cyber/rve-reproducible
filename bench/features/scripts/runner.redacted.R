# Sources ONE generated script unchanged in a fresh Rscript session, then records its objects.
.libPaths(c('<HOST>/p101115/Rlib', .libPaths()))
args <- commandArgs(TRUE); script <- args[1]; out <- args[2]
source('<HOST>/p101115/rveup/json17.R')
e <- new.env()
res <- tryCatch({
  source(script, local = e, echo = FALSE)
  tab <- e$fit$reg_table
  cols <- setdiff(names(e$d), 'cluster')
  list(status = 'ok', table = unname(lapply(seq_len(nrow(tab)), function(j) as.list(tab[j, ]))),
       tau2 = as.numeric(e$fit$mod_info$tau.sq), club = as.data.frame(e$ct),
       data = lapply(e$d[cols], as.numeric), cluster = as.character(e$d$cluster),
       r_version = R.version.string, robumeta = as.character(packageVersion('robumeta')), clubSandwich = as.character(packageVersion('clubSandwich')))
}, error = function(err) list(status = 'error', message = conditionMessage(err)))
write_json17(res, out)
