# One-command validation of the rve-meta (paper 15) archive. Run from the archive root:
#   Rscript validate.R
# 1. requires R 4.6.0, robumeta 2.1, clubSandwich 0.7.0, metadat 1.6.0, jsonlite and digest;
# 2. SHA-256-checks every archived input (SOURCE_SHA256.json) and refuses unpinned files;
# 3. refits robumeta::robu(CORR, small=TRUE) + clubSandwich::coef_test(CR2, Satterthwaite) FRESH for all
#    configurations with the R2 reference recipe (analysis/reference_core.R = bench/reference.R lines 10-26),
#    partitioned over at most two R workers in a new .validate-work directory (no archived reference is used);
# 4. runs the unmodified R2 strict comparator (bench/compare_engine.py) on the archived original and patched
#    engine captures, and replays the unmodified browser comparator (bench/browser/compare.py) on the archived
#    browser captures, both against the fresh references; tallies the archived browser UI checks;
# 5. prints per-quantity totals and grand totals and exits non-zero on wrong versions, an input mismatch,
#    missing/duplicate coverage, or ANY count that differs from expected/paper_values.json.
# The expected result is the documented strict result, which is NOT full strict agreement (see README.md).
t_start <- Sys.time()
lib <- Sys.getenv('R_LIBS_USER'); if (nzchar(lib)) .libPaths(c(lib, .libPaths()))
if (!file.exists('SOURCE_SHA256.json') || !file.exists('analysis/gate.R')) stop('Run validate.R from the archive root')
fail <- function(...) { message('VALIDATION FAILED: ', ...); quit(save = 'no', status = 1) }
for (p in c('jsonlite', 'digest', 'robumeta', 'clubSandwich', 'metadat'))
  if (!requireNamespace(p, quietly = TRUE)) fail('package ', p, ' is not installed')
suppressPackageStartupMessages({library(jsonlite); library(digest)})
source('analysis/gate.R')
ver <- function(p) as.character(packageVersion(p))
actual <- c(R = as.character(getRversion()), robumeta = ver('robumeta'), clubSandwich = ver('clubSandwich'),
            metadat = ver('metadat'), jsonlite = ver('jsonlite'), digest = ver('digest'))
cat('Library paths:', paste(.libPaths(), collapse = ' | '), '\n'); print(actual)
r <- tryCatch(check_versions(actual, c(R = '4.6.0', robumeta = '2.1', clubSandwich = '0.7.0', metadat = '1.6.0')), error = function(e) e)
if (inherits(r, 'error')) fail(conditionMessage(r))
pins <- fromJSON('SOURCE_SHA256.json', simplifyVector = TRUE)
r <- tryCatch(check_inventory('.', pins), error = function(e) e)
if (inherits(r, 'error')) fail(conditionMessage(r))
cat(sprintf('Input SHA-256 checks PASS (%d files; no unpinned files)\n', length(pins)))
expected <- fromJSON('expected/paper_values.json', simplifyVector = FALSE)

# Python 3 runs the archived comparators unmodified (standard library only), in UTF-8 mode on every host.
Sys.setenv(PYTHONUTF8 = '1')
py_ok <- function(p) nzchar(p) && suppressWarnings(tryCatch(system2(p, c('-c', shQuote('import sys; assert sys.version_info >= (3, 8)')),
                                                                     stdout = FALSE, stderr = FALSE), error = function(e) 1L)) == 0
python <- Sys.getenv('PYTHON')
if (!nzchar(python)) for (cand in c('python', 'py', 'python3')) { w <- unname(Sys.which(cand)); if (py_ok(w)) { python <- w; break } }
if (!py_ok(python)) fail('Python >= 3.8 not found; set PYTHON')
cat('Python:', python, '\n')

work <- file.path(normalizePath('.', winslash = '/'), '.validate-work')
if (file.exists(work)) fail('.validate-work exists; move it aside so that no earlier output can seed this run')
if (system2(python, c('analysis/materialize.py', shQuote(work))) != 0) fail('materialising archived inputs failed')
ids <- read.csv(file.path(work, 'configuration-ledger.csv'), colClasses = 'character', na.strings = character(),
                encoding = 'UTF-8', check.names = FALSE)$id
if (length(ids) != expected$variants$patched$configurations || anyDuplicated(ids)) fail('configuration ledger: wrong length or duplicate ids')

# ---- fresh R references, at most two workers ----
W <- min(2L, max(1L, as.integer(Sys.getenv('VALIDATE_WORKERS', '2'))))
cat(sprintf('Refitting %d configurations fresh with %d R worker(s)...\n', length(ids), W))
t_fit <- Sys.time()
cl <- parallel::makePSOCKcluster(W, outfile = file.path(work, 'workers.log'))
fit <- tryCatch({
  parallel::clusterCall(cl, function(f) source(f), normalizePath('analysis/validate_worker.R'))
  parallel::clusterApply(cl, seq_len(W), function(w, work, W) run_partition(work, w, W), work = work, W = W)
}, error = function(e) e)
parallel::stopCluster(cl)
if (inherits(fit, 'error')) fail('R worker error: ', conditionMessage(fit))
fit_seconds <- as.numeric(difftime(Sys.time(), t_fit, units = 'secs'))
r <- tryCatch(check_coverage(file.path(work, 'reference'), ids), error = function(e) e)
if (inherits(r, 'error')) fail(conditionMessage(r))
cat(sprintf('Fresh references: %d/%d configurations, one each, keys match the ledger (%.0f s)\n', length(ids), length(ids), fit_seconds))
idx <- fromJSON('results/reference/reference-index.json', simplifyVector = TRUE)
fresh_sha <- vapply(idx$file, function(f) digest(file = file.path(work, 'reference', f), algo = 'sha256', serialize = FALSE), '')
identical_refs <- sum(fresh_sha == idx$sha256)
cat(sprintf('Information: %d/%d fresh reference files are byte-identical to the archived R2 references\n', identical_refs, nrow(idx)))

# ---- comparators (unmodified archived scripts) on the fresh references ----
run_py <- function(script, arg) {
  old <- setwd(work); on.exit(setwd(old))
  system2(python, c(script, arg), stdout = TRUE, stderr = TRUE)
}
problems <- character(); summary <- list(); table <- list()
out <- file.path('outputs', 'fresh'); dir.create(out, recursive = TRUE, showWarnings = FALSE)
tally <- function(kind, v, res, exp, failures) {
  problems <<- c(problems, compare_counts(paste(kind, v), res, exp))
  fd <- failure_digest(failures)
  if (!identical(fd$sha256, exp$failing_id_quantity_pairs_sha256)) problems <<- c(problems, sprintf('%s %s: failing (id, quantity) set differs from archive', kind, v))
  if (fd$configurations != exp$failed_configurations) problems <<- c(problems, sprintf('%s %s: %d failing configurations, expected %d', kind, v, fd$configurations, exp$failed_configurations))
  for (q in names(res$quantities)) {
    s <- res$quantities[[q]]
    cat(sprintf('%s %s %s: %d/%d, maximum difference %.17g\n', kind, v, q, s$passes, s$checks, as.numeric(s$max_difference)))
    table[[length(table) + 1]] <<- data.frame(comparison = kind, variant = v, quantity = q, checks = s$checks, passes = s$passes,
                                             max_difference = sprintf('%.17g', as.numeric(s$max_difference)))
  }
  summary[[paste(kind, v)]] <<- list(checks = res$checks, passes = res$passes, failures = res$checks - res$passes,
                                    failed_configurations = fd$configurations, failing_pairs_sha256 = fd$sha256)
}
for (v in c('original', 'patched')) {
  log <- run_py('compare_engine.py', v); cat(log, sep = '\n')
  if (!is.null(attr(log, 'status'))) fail('compare_engine.py ', v, ' exited ', attr(log, 'status'))
  res <- fromJSON(file.path(work, sprintf('engine-results-%s.json', v)), simplifyVector = FALSE)
  file.copy(file.path(work, sprintf('engine-results-%s.json', v)), file.path(out, sprintf('engine-results-%s.json', v)), overwrite = TRUE)
  tally('engine', v, res, expected$variants[[v]], fromJSON(file.path(work, sprintf('engine-failures-full-%s.json', v)), simplifyVector = FALSE))
}
for (v in c('original', 'patched')) {
  log <- run_py('compare.py', v); cat(tail(log, 3), sep = '\n')
  if (!is.null(attr(log, 'status'))) fail('browser compare.py ', v, ' exited ', attr(log, 'status'))
  res <- fromJSON(file.path(work, sprintf('results-%s.json', v)), simplifyVector = FALSE)
  file.copy(file.path(work, sprintf('results-%s.json', v)), file.path(out, sprintf('browser-results-%s.json', v)), overwrite = TRUE)
  tally('browser', v, res, expected$browser[[v]], fromJSON(file.path(work, sprintf('failures-%s.json', v)), simplifyVector = FALSE))
  ui <- fromJSON(file.path('results', 'browser', sprintf('ui-%s.json', v)), simplifyVector = FALSE)
  up <- sum(vapply(ui, function(x) isTRUE(x$pass), TRUE))
  cat(sprintf('browser-ui %s (archived observations): %d/%d checks pass\n', v, up, length(ui)))
  if (up != expected$browser_ui[[v]]$passes || length(ui) != expected$browser_ui[[v]]$checks) problems <- c(problems, sprintf('browser-ui %s: %d/%d, expected %d/%d', v, up, length(ui), expected$browser_ui[[v]]$passes, expected$browser_ui[[v]]$checks))
  summary[[paste('browser-ui', v)]] <- list(checks = length(ui), passes = up)
}
write.csv(do.call(rbind, table), file.path('outputs', 'validate_R_table.csv'), row.names = FALSE)
seconds <- as.numeric(difftime(Sys.time(), t_start, units = 'secs'))
write_json(list(seconds = seconds, fit_seconds = fit_seconds, workers = W, configurations = length(ids),
                fresh_references_byte_identical_to_archive = identical_refs, versions = as.list(actual),
                totals = summary, mismatches = problems, exit_code = if (length(problems)) 1 else 0),
           file.path('outputs', 'validate_runtime.json'), auto_unbox = TRUE, pretty = TRUE, digits = NA)
cat('\n==== Grand totals (fresh R references; strict criterion, unchanged) ====\n')
for (k in names(summary)) { s <- summary[[k]]; cat(sprintf('%s: %d/%d checks pass%s\n', k, s$passes, s$checks,
  if (is.null(s$failed_configurations)) '' else sprintf('; %d failing configurations', s$failed_configurations))) }
if (length(problems)) fail('counts differ from expected/paper_values.json:\n  ', paste(problems, collapse = '\n  '))
cat(sprintf('REPRODUCED: every per-quantity count equals expected/paper_values.json (%.0f s). This is the documented strict result, NOT full strict agreement.\n', seconds))
