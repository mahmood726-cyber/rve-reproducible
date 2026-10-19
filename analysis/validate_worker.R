# validate.R worker: fresh robumeta::robu + clubSandwich::coef_test fits for one partition of the configurations.
# validate.R sources this file in each of <= 2 PSOCK workers and calls run_partition(work, w, W).
# Configuration i (1-based, configuration-ledger order) belongs to worker ((i - 1) %% W) + 1.
# Each result is written with the R2 writer (bench/json17.R) to <work>/reference/<i>.json; nothing is read from
# the archived references.
run_partition <- function(work, w, W, every = NA_integer_) {
  lib <- Sys.getenv('R_LIBS_USER'); if (nzchar(lib)) .libPaths(c(lib, .libPaths()))
  # Locale C for ALL categories, as in the R2 reference run (r2-environment: locale C). LC_COLLATE alone is not
  # enough: robu sorts cluster labels, and non-ASCII labels sort by their native translation, which depends on
  # LC_CTYPE (shown on dat.linde2016 configurations 15560/15600/15680: last-bit differences under a UTF-8 LC_CTYPE).
  invisible(Sys.setlocale('LC_ALL', 'C'))
  suppressPackageStartupMessages({library(jsonlite); library(robumeta); library(clubSandwich)})
  env <- new.env()
  sys.source(file.path(work, 'json17.R'), envir = env); sys.source(file.path(work, 'reference_core.R'), envir = env)
  cs <- fromJSON(file.path(work, 'configurations.json'), simplifyVector = FALSE)
  idx <- which((seq_along(cs) - 1L) %% W == w - 1L)
  if (!is.na(every)) idx <- idx[idx %% every == 0L]  # used only by the sampled preflight, never by validate.R
  cs <- cs[idx]; invisible(gc())
  t0 <- Sys.time()
  for (k in seq_along(idx)) {
    res <- env$reference_one(cs[[k]])
    env$write_json17(res, file.path(work, 'reference', sprintf('%06d.json', idx[k])))
    cs[k] <- list(NULL)
    if (k %% 500 == 0) cat(sprintf('worker %d: %d/%d (%.0f s)\n', w, k, length(idx), as.numeric(difftime(Sys.time(), t0, units = 'secs'))))
  }
  cat(sprintf('worker %d finished %d configurations in %.0f s\n', w, length(idx), as.numeric(difftime(Sys.time(), t0, units = 'secs'))))
  length(idx)
}
