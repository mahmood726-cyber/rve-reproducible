# Negative tests for analysis/gate.R: every gate must accept the archived truth and reject a planted defect.
# Run from the archive root: Rscript analysis/test_gate.R   (exit status 1 if any test fails)
lib <- Sys.getenv('R_LIBS_USER'); if (nzchar(lib)) .libPaths(c(lib, .libPaths()))
suppressPackageStartupMessages({library(jsonlite); library(digest)})
source('analysis/gate.R')
n_ok <- 0; n <- 0
expect <- function(name, ok) { n <<- n + 1; n_ok <<- n_ok + isTRUE(ok); cat(if (isTRUE(ok)) 'PASS' else 'FAIL', name, '\n') }
errs <- function(expr) inherits(tryCatch(expr, error = function(e) e), 'error')

need <- c(R = '4.6.0', robumeta = '2.1', clubSandwich = '0.7.0', metadat = '1.6.0')
expect('versions: exact versions accepted', !errs(check_versions(need, need)))
expect('versions: wrong robumeta rejected', errs(check_versions(replace(need, 'robumeta', '2.0'), need)))
expect('versions: missing package rejected', errs(check_versions(need[-2], need)))

tmp <- file.path(tempdir(), 'inv'); dir.create(file.path(tmp, 'sub'), recursive = TRUE)
writeLines('a', file.path(tmp, 'a.txt')); writeLines('b', file.path(tmp, 'sub', 'b.txt'))
pins <- list('a.txt' = digest(file = file.path(tmp, 'a.txt'), algo = 'sha256', serialize = FALSE),
             'sub/b.txt' = digest(file = file.path(tmp, 'sub', 'b.txt'), algo = 'sha256', serialize = FALSE))
expect('inventory: intact files accepted', !errs(check_inventory(tmp, pins)))
writeLines('B', file.path(tmp, 'sub', 'b.txt'))
expect('inventory: one changed byte rejected', errs(check_inventory(tmp, pins)))
writeLines('b', file.path(tmp, 'sub', 'b.txt')); writeLines('x', file.path(tmp, 'extra.txt'))
expect('inventory: unpinned extra file rejected', errs(check_inventory(tmp, pins)))
unlink(file.path(tmp, 'extra.txt')); unlink(file.path(tmp, 'a.txt'))
expect('inventory: missing file rejected', errs(check_inventory(tmp, pins)))

ref <- file.path(tempdir(), 'ref'); dir.create(ref)
ids <- c('k1', 'k2', 'k3')
for (i in 1:3) writeLines(sprintf('{"id":"%s","status":"ok"}', ids[i]), file.path(ref, sprintf('%06d.json', i)))
expect('coverage: complete keyed references accepted', !errs(check_coverage(ref, ids)))
writeLines('{"id":"k1","status":"ok"}', file.path(ref, '000002.json'))
expect('coverage: duplicate id rejected', errs(check_coverage(ref, ids)))
writeLines('{"id":"k2","status":"ok"}', file.path(ref, '000002.json')); unlink(file.path(ref, '000003.json'))
expect('coverage: missing configuration rejected', errs(check_coverage(ref, ids)))
writeLines('{"id":"k3","status":"ok"}', file.path(ref, '000003.json')); writeLines('{"id":"k4"}', file.path(ref, '000004.json'))
expect('coverage: extra reference rejected', errs(check_coverage(ref, ids)))

exp <- fromJSON('expected/paper_values.json', simplifyVector = FALSE)
for (v in c('original', 'patched')) {
  res <- fromJSON(sprintf('results/engine/engine-results-%s.json', v), simplifyVector = FALSE)
  expect(sprintf('counts %s: archived engine result accepted', v), length(compare_counts(v, res, exp$variants[[v]])) == 0)
  bad <- res; bad$quantities$se$passes <- bad$quantities$se$passes - 1
  expect(sprintf('counts %s: one per-quantity pass changed rejected', v), length(compare_counts(v, bad, exp$variants[[v]])) > 0)
  bad <- res; bad$quantities$club_df <- NULL
  expect(sprintf('counts %s: missing quantity rejected', v), length(compare_counts(v, bad, exp$variants[[v]])) > 0)
  bad <- res; bad$quantities$extra <- list(checks = 1, passes = 1)
  expect(sprintf('counts %s: extra quantity rejected', v), length(compare_counts(v, bad, exp$variants[[v]])) > 0)
  bad <- res; bad$passes <- bad$passes + 1
  expect(sprintf('counts %s: changed grand total rejected', v), length(compare_counts(v, bad, exp$variants[[v]])) > 0)
}
fl <- fromJSON('results/engine/engine-failures-full-patched.json', simplifyVector = FALSE)
fd <- failure_digest(fl)
expect('failure digest: archived patched failures reproduce the expected digest and 785-type count',
       identical(fd$sha256, exp$variants$patched$failing_id_quantity_pairs_sha256) && fd$configurations == exp$variants$patched$failed_configurations)
expect('failure digest: dropping one failing check is detected', !identical(failure_digest(fl[-1])$sha256, fd$sha256))
fl2 <- fl; fl2[[1]]$quantity <- 'tau2'
expect('failure digest: relabelling one failing check is detected', !identical(failure_digest(fl2)$sha256, fd$sha256))
cat(sprintf('%d/%d gate tests pass\n', n_ok, n))
if (n_ok != n) quit(save = 'no', status = 1)
