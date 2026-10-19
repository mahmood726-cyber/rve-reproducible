# Gate functions used by validate.R; analysis/test_gate.R proves each one can fail.

check_versions <- function(actual, expected) {
  bad <- names(expected)[is.na(actual[names(expected)]) | actual[names(expected)] != expected]
  if (length(bad)) stop('Wrong versions: ', paste(sprintf('%s=%s (need %s)', bad, actual[bad], expected[bad]), collapse = '; '))
  invisible(TRUE)
}

# Every pinned file must exist with its SHA-256, and no unpinned source file may be present.
check_inventory <- function(root, pins, excluded = '^(outputs/|\\.validate-work/|\\.git/|results/validate-run\\.json$|SOURCE_SHA256\\.json$)') {
  bad <- character()
  for (p in names(pins)) {
    f <- file.path(root, p)
    if (!file.exists(f)) bad <- c(bad, paste('missing:', p))
    else if (!identical(digest::digest(file = f, algo = 'sha256', serialize = FALSE), unname(pins[[p]]))) bad <- c(bad, paste('SHA-256 mismatch:', p))
  }
  present <- list.files(root, recursive = TRUE, all.files = TRUE, no.. = TRUE)
  present <- present[!grepl(excluded, present) & !grepl('(^|/)__pycache__/', present)]
  extra <- setdiff(present, names(pins))
  if (length(extra)) bad <- c(bad, paste('unpinned file:', extra))
  if (length(bad)) stop('Input inventory check failed:\n  ', paste(head(bad, 50), collapse = '\n  '))
  invisible(length(pins))
}

# Fresh references: exactly one file per configuration, in ledger order, keyed by the configuration id.
check_coverage <- function(refdir, ids) {
  files <- sort(list.files(refdir, pattern = '\\.json$'))
  want <- sprintf('%06d.json', seq_along(ids))
  if (!identical(files, want)) stop(sprintf('Coverage: %d reference files for %d configurations (missing %d, extra %d)',
                                             length(files), length(ids), length(setdiff(want, files)), length(setdiff(files, want))))
  got <- vapply(want, function(f) jsonlite::fromJSON(file.path(refdir, f), simplifyVector = FALSE)[['id']], '')
  if (anyDuplicated(got)) stop('Coverage: duplicate configuration ids in fresh references')
  if (!identical(unname(got), ids)) stop('Coverage: fresh reference ids differ from the configuration ledger')
  invisible(length(ids))
}

# Per-quantity checks/passes and totals must equal the expected values exactly (no extra or missing quantity).
compare_counts <- function(label, fresh, expected) {
  bad <- character()
  qf <- names(fresh$quantities); qe <- names(expected$quantities)
  for (q in setdiff(qe, qf)) bad <- c(bad, sprintf('%s: quantity %s missing', label, q))
  for (q in setdiff(qf, qe)) bad <- c(bad, sprintf('%s: unexpected quantity %s', label, q))
  for (q in intersect(qe, qf)) for (k in c('checks', 'passes')) {
    a <- fresh$quantities[[q]][[k]]; e <- expected$quantities[[q]][[k]]
    if (!identical(as.numeric(a), as.numeric(e))) bad <- c(bad, sprintf('%s %s %s: fresh %s, expected %s', label, q, k, a, e))
  }
  for (k in c('checks', 'passes')) if (!identical(as.numeric(fresh[[k]]), as.numeric(expected[[k]])))
    bad <- c(bad, sprintf('%s total %s: fresh %s, expected %s', label, k, fresh[[k]], expected[[k]]))
  bad
}

# The failing (configuration, quantity) multiset, as a SHA-256 over sorted "id<TAB>quantity" lines.
failure_digest <- function(failures) {
  lines <- sort(vapply(failures, function(f) paste0(f$id, '\t', f$quantity), ''), method = 'radix')
  list(sha256 = digest::digest(charToRaw(enc2utf8(paste0(paste(lines, collapse = '\n'), '\n'))), algo = 'sha256', serialize = FALSE),
       checks = length(lines), configurations = length(unique(vapply(failures, function(f) f$id, ''))))
}
