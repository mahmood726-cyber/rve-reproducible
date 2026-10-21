# Exposure scan for review N1 (round 2): R 4.6.0 as.character(<double>) and
# as.factor() partition, per vector, for the ID shapes in the reviewer's table.
# Rscript exposure_scan.R exposure.tsv
args <- commandArgs(trailingOnly = TRUE); out <- args[[1]]
set.seed(20261021)
ulps <- function(x, k) {
  b <- as.integer(writeBin(x, raw(), size = 8, endian = 'little'))
  lo <- sum(b[1:4] * 256^(0:3)) + k; hi <- sum(b[5:8] * 256^(0:3))
  hi <- hi + floor(lo / 2^32); lo <- lo %% 2^32
  readBin(as.raw(c(lo %/% 256^(0:3) %% 256, hi %/% 256^(0:3) %% 256)), 'double', size = 8, endian = 'little')
}
con <- file(out, 'w')
emit <- function(family, vid, x) {
  writeLines(paste(family, vid, sprintf('%.17g', x), as.character(x), as.integer(as.factor(x)), sep = '\t'), con)
}
# 1. individual values (each family is also one vector)
emit('random doubles 1e-12..1e12', 1, 10^runif(100000, -12, 12) * sample(c(-1, 1), 100000, TRUE))
emit('2-dp decimals', 1, round(runif(100000, -1000, 1000), 2))
emit('integers <= 1e6', 1, as.numeric(sample.int(1e6, 100000, TRUE)))
# 2. vectors of 20
for (v in 1:1500) {
  emit('ints 1..999', v, as.numeric(sample.int(999, 20, TRUE)))
  emit('years 1980..2026', v, as.numeric(sample(1980:2026, 20, TRUE)))
  emit('3-dp decimals', v, round(runif(20, 0, 100), 3))
  emit('doubles +-1e9', v, runif(20, -1e9, 1e9))
}
# 3. 10^p + 0..99, 200 vectors of 100 drawn with replacement
for (p in 10:17) for (v in 1:200) emit(sprintf('10^%d + 0..99', p), v, 10^p + sample(0:99, 100, TRUE))
# 4. ULP neighbours (-3..3) of random 15-17 significant-digit bases
for (b in c(1e-9, 1e-3, 1, 1e3, 1e9)) for (v in 1:2000) {
  base <- signif(b * runif(1, 1, 10), sample(15:17, 1))
  emit(sprintf('ULP +-3 at %g', b), v, vapply(-3:3, function(k) ulps(base, k), 0))
}
# 5. extra: 16-significant-digit dyadic ties, and epoch-microsecond stamps
for (v in 1:500) {
  j <- sample(0:22, 1); lo <- ceiling(1e15 / 5^j); hi <- min(floor((1e16 - 1) / 5^j), 2^53 - 1)
  if (lo > hi) next
  t <- round(runif(20, lo, hi)); t <- t + (t %% 2 == 0)
  emit('16-digit ties t/2^j', v, sample(c(-1, 1), 20, TRUE) * t / 2^j)
}
for (v in 1:500) emit('epoch microseconds ~1.76e15', v, 1.76e15 + round(runif(20, 0, 1e9)))
close(con)
