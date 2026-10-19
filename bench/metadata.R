metadata_for <- function(effects, good, definition) {
 # Prefer columns retained by escalc; never silently align transformed/subset rows.
 columns <- effects
 mapping <- 'columns retained by effect construction'
 if (ncol(columns) <= 2) {
  if (is.data.frame(raw_data) && nrow(raw_data)==nrow(effects) && identical(rownames(raw_data),rownames(effects))) {
   columns <- raw_data
   mapping <- 'full-length source row order; documented recipe, no subset/reorder'
   if (grepl('subset|order\\(|sort\\(|to.wide|pairwise|aggregate|split\\(',definition)) {
    columns <- effects; mapping <- 'metadata unavailable: transformation requires explicit row mapping'
   }
  } else mapping <- 'metadata unavailable: source length or row names differ'
 }
 explicit <- attr(effects,'audit_metadata')
 if(ncol(columns)<=2 && is.data.frame(explicit) && nrow(explicit)==nrow(effects)) {
  columns <- explicit
  mapping <- 'explicit constructor-returned row alignment (pairwise/studlab, nested data, or source aggregation)'
 }
 columns <- columns[good,,drop=FALSE]
 vals <- list(); decisions <- list()
 for (nm in names(columns)) {
  x <- columns[[nm,exact=TRUE]]
  scalar <- is.numeric(x)||is.factor(x)||is.character(x)||is.logical(x)
  if(scalar) {
   vals[[nm]] <- list(type=if(is.numeric(x)) 'numeric' else 'text',values=unname(if(is.factor(x)) as.character(x) else x))
   decisions[[nm]] <- 'retained for cluster and numeric predictor eligibility ledger'
  } else decisions[[nm]] <- 'structured non-scalar column'

 }
 list(mapping=mapping,columns=vals,decisions=decisions)
}
