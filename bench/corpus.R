.libPaths(c(Sys.getenv('R_LIBS_USER'),.libPaths()))
exact <- function(x) {
 if(is.call(x)) {
  if(as.character(x[[1]])[1] %in% c("<-","=","<<-") && is.call(x[[2]]) && identical(x[[2]][[1]],as.name("$"))) {
   lhs <- x[[2]]
   x[[2]] <- as.call(list(as.name("[["),exact(lhs[[2]]),as.character(lhs[[3]])))
   x[[3]] <- exact(x[[3]])
   return(x)
  }
  if(identical(x[[1]],as.name('$'))) return(as.call(list(as.name('[['),exact(x[[2]]),as.character(x[[3]]),exact=TRUE)))
  for(i in seq_along(x)) if(!identical(x[[i]],quote(expr=))) x[i] <- list(exact(x[[i]]))
 } else if(is.expression(x)) for(i in seq_along(x)) x[i] <- list(exact(x[[i]]))
 x
}

.libPaths(c(.libPaths(), Sys.getenv("EXTRA_R_LIB")))
suppressPackageStartupMessages(library(metafor))
suppressPackageStartupMessages(library(metadat))
suppressPackageStartupMessages(library(meta))
options(warn = 1)
source("json17.R")
source('supplemental-exact.R')
datasets <- sort(unique(data(package = "metadat")[["results", exact = TRUE]][, "Item"]))
corpus <- list()
ledger <- list()
attempts <- list()
current <- ""
source_expr <- ""
source("metadata.R")
add <- function(d, definition) {
    if (!is.data.frame(d) || !all(c("yi", "vi") %in% names(d))) 
        return(invisible(NULL))
    if (!is.numeric(d[["yi", exact = TRUE]]) || !is.numeric(d[["vi", exact = TRUE]])) 
        return(invisible(NULL))
    good <- is.finite(d[["yi", exact = TRUE]]) & is.finite(d[["vi", exact = TRUE]]) & d[["vi", exact = TRUE]] > 0
    k <- sum(good)
    reason <- if (k < 2) 
        "fewer than 2 finite effects with positive variance"
    else "eligible"
    attempts[[length(attempts) + 1]] <<- list(dataset = current, definition = definition, k = k, omitted = which(!good), reason = reason)
    if (k < 2) 
        return(invisible(NULL))
    te <- unname(d[["yi", exact = TRUE]][good])
    se <- unname(sqrt(d[["vi", exact = TRUE]][good]))
    same <- vapply(corpus, function(x) identical(x[["dataset", exact = TRUE]], current) && identical(x[["te", exact = TRUE]], te) && identical(x[["se", exact = TRUE]], se), logical(1))
    if (any(same)) {
        j <- which(same)[1]
        corpus[[j]][["aliases"]] <<- unique(c(corpus[[j]][["aliases", exact = TRUE]], definition))
        return(invisible(NULL))
    }
    key <- paste(current, sprintf("%03d", sum(vapply(corpus, function(x) x[["dataset", exact = TRUE]] == current, logical(1))) + 1), sep = "::")
    corpus[[length(corpus) + 1]] <<- list(id = key, dataset = current, definition = definition, k = k, metadata = metadata_for(d, good, definition), source_rows = which(good), omitted_rows = which(!good), te = te, se = se)
    invisible(NULL)
}
capture_es <- function(...) {
    cl <- match.call(expand.dots = TRUE)
    cl[[1]] <- quote(metafor::escalc)
    z <- eval(cl, parent.frame())
    yn <- attr(z, "yi.names")
    vn <- attr(z, "vi.names")
    if (length(yn) && length(vn)) 
        { z[["yi"]] <- z[[tail(yn, 1), exact=TRUE]]; z[["vi"]] <- z[[tail(vn, 1), exact=TRUE]]; add(z, source_expr) }
    else add(z, source_expr)
    z
}
capture_meta <- function(...) {
    cl <- match.call(expand.dots = TRUE)
    fn <- as.character(cl[[1]])
    cl[[1]] <- as.call(list(as.name("::"), as.name("meta"), as.name(fn)))
    cl[["method.tau"]] <- "DL"
    cl[["method.tau.ci"]] <- ""
    if (fn %in% c("metabin", "metaprop")) 
        cl[["method"]] <- "Inverse"
    z <- eval(cl, parent.frame())
    out <- data.frame(yi = z[["TE", exact = TRUE]], vi = z[["seTE", exact = TRUE]]^2)
    if (!is.null(cl[["studlab", exact=TRUE]]) && length(z[["studlab", exact=TRUE]])==nrow(out))
        attr(out,"audit_metadata") <- data.frame(studlab=z[["studlab",exact=TRUE]])
    add(out, source_expr)
    z
}
capture_pairwise <- function(...) {
    cl <- match.call(expand.dots = TRUE)
    cl[[1]] <- quote(meta::pairwise)
    z <- eval(cl, parent.frame())
    out <- data.frame(yi = z[["TE", exact = TRUE]], vi = z[["seTE", exact = TRUE]]^2)
    if (is.data.frame(z) && nrow(z)==nrow(out) && !is.null(cl[["studlab",exact=TRUE]])) attr(out,"audit_metadata") <- z
    add(out, source_expr)
    z
}
capture_rma <- function(...) {
    cl <- match.call(expand.dots = TRUE)
    fn <- as.character(cl[[1]])
    aa <- as.list(cl)[-1]
    nn <- names(aa)
    if (is.null(nn)) 
        nn <- rep("", length(aa))
    pos <- which(nn == "")
    if (length(pos) > 0) 
        nn[pos] <- c("yi", "vi")[seq_along(pos)]
    names(aa) <- nn
    aa <- aa[names(aa) %in% setdiff(names(formals(metafor::escalc)), c("subset", "include"))]
    if (is.null(aa[["measure", exact = TRUE]])) 
        aa[["measure"]] <- if (fn == "rma.peto") 
            "PETO"
        else if (fn == "rma.mh") 
            "OR"
        else "GEN"
    cl <- as.call(c(list(quote(metafor::escalc)), aa))
    z <- eval(cl, parent.frame())
    add(z, source_expr)
    z
}
for (nm in datasets) {
    meta::settings.meta("reset")
    current <- nm
    errors <- list()
    e <- new.env(parent = globalenv())
    data(list = nm, package = "metadat", envir = e)
    d <- e[[nm]]
    raw_data <- d
    add(d, "stored yi/vi")
    e[["escalc"]] <- capture_es
    e[["rma"]] <- capture_rma
    e[["rma.uni"]] <- capture_rma
    e[["rma.mh"]] <- capture_rma
    e[["rma.peto"]] <- capture_rma
    for (fn in c("metagen", "metabin", "metacont", "metaprop")) e[[fn]] <- capture_meta
    e[["pairwise"]] <- capture_pairwise
    f <- file.path("documentation", paste0(nm, ".R"))
    if (file.exists(f)) {
        txt <- sub("^##D ?", "", readLines(f, warn = FALSE))
        exprs <- tryCatch(parse(text = txt), error = function(ex) {
            errors[[length(errors) + 1]] <<- conditionMessage(ex)
            expression()
        })
        for (ex in exprs) {
            source_expr <- paste(deparse(ex, width.cutoff = 500), collapse = " ")
            if (any(all.names(ex) %in% c("rma.mv", "rma.glmm", "bayesmeta", "jags", "stan", "plot", "forest", "funnel", "predict", "anova", "summary", "print", "library", "require", "install.packages", "download.file", "url", "source", "setwd", "write", "save", "sink", "pdf", "png", "par", "system", "netmeta", "netmetabin", "netcomb", "netbind", "rankogram", "update", "function", "regplot", "robust", "cumul"))) 
                next
            if (!(is.call(ex) && (as.character(ex[[1]])[1] %in% c("<-", "=", "escalc", "rma", "rma.uni", "rma.mh", "rma.peto", "metagen", "metabin", "metacont", "metaprop", "pairwise", "settings.meta")))) 
                next
            tryCatch(withCallingHandlers(eval(exact(ex), e), warning = function(w) {
                errors[[length(errors) + 1]] <<- paste("warning", source_expr, conditionMessage(w))
                invokeRestart("muffleWarning")
            }), error = function(er) {
                errors[[length(errors) + 1]] <<- paste(source_expr, conditionMessage(er))
            })
        }
    }
    if (nm == "dat.bakdash2021") 
        add(data.frame(yi = d[["es.z", exact = TRUE]], vi = d[["vi.z", exact = TRUE]]), "stored Fisher z: es.z / vi.z")
    if (nm == "dat.maire2019") 
        { z <- data.frame(yi = d[["dat", exact = TRUE]][["s1", exact = TRUE]], vi = d[["dat", exact = TRUE]][["vars1", exact = TRUE]]); attr(z,"audit_metadata") <- d[["dat",exact=TRUE]]; add(z, "stored slope s1 / vars1; marginal numerical check ignoring spatial correlation") }
    if (nm == "dat.ishak2007") 
        for (i in 1:4) add(data.frame(yi = d[[paste0("y", i, "i")]], vi = d[[paste0("v", i, "i")]]), paste("stored occasion", i))
    if (nm == "dat.lopez2019" && exists("dat", e, inherits = FALSE)) 
        add(e[["dat", exact = TRUE]], "documented to.wide contrast: diff1-diff2 / se1^2+se2^2")
    if (nm == "dat.craft2003") 
        add(metafor::escalc(measure = "ZCOR", ri = d[["ri", exact = TRUE]], ni = d[["ni", exact = TRUE]]), "Fisher z correlations: ri / ni; escalc ZCOR")
    if (nm %in% c("dat.roever2022", "dat.ursino2021")) 
        add(metafor::escalc(measure = "PLO", xi = d[["events", exact = TRUE]], ni = d[["total", exact = TRUE]]), "logit arm event proportions: events / total; escalc PLO")
    if (nm == "dat.hartmannboyce2018") 
        add(metafor::escalc(measure = "RR", ai = d[["x.nrt", exact = TRUE]], n1i = d[["n.nrt", exact = TRUE]], ci = d[["x.ctrl", exact = TRUE]], n2i = d[["n.ctrl", exact = TRUE]]), "documented log RR: x.nrt/n.nrt vs x.ctrl/n.ctrl")
    if (nm == "dat.yusuf1985") 
        add(metafor::escalc(measure = "PETO", ai = d[["ai", exact = TRUE]], n1i = d[["n1i", exact = TRUE]], ci = d[["ci", exact = TRUE]], n2i = d[["n2i", exact = TRUE]]), "documented Peto log OR; complete dataset without subgroup loop")
    if (nm == "dat.huber2000") {
        studies <- split(d, d[["study", exact = TRUE]])
        z <- do.call(rbind, lapply(studies, function(s) {
            a <- s[["recurrences", exact = TRUE]][s[["treatment", exact = TRUE]] == "Uro-Vaxom"]
            b <- s[["recurrences", exact = TRUE]][s[["treatment", exact = TRUE]] == "Placebo"]
            metafor::escalc(measure = "MD", m1i = mean(a), sd1i = sd(a), n1i = length(a), m2i = mean(b), sd2i = sd(b), n2i = length(b))
        }))
        z[["study"]] <- names(studies)
        add(z, "IPD recurrence mean difference: Uro-Vaxom minus Placebo; escalc MD from group means, SDs and sizes")
    }
    supplement(d,nm,add)
    n <- sum(vapply(corpus, function(x) x[["dataset", exact = TRUE]] == nm, logical(1)))
    ledger[[nm]] <- list(dataset = nm, status = if (n > 0) "used" else "excluded", configurations = n, columns = names(d), reason = if (n > 0) "stored or documented effect-size definition" else "no successful eligible stored/documented effect-size construction; see preparation messages", preparation_messages = errors)
    if (nm == "dat.metap") 
        ledger[[nm]][["reason"]] <- "p-value collections; no effect sizes with sampling variances or raw outcome summaries for escalc"
}
write_json17(corpus, "corpus.json")
write_json17(ledger, "coverage.json")
write_json17(attempts, "construction-attempts.json")
cat(length(datasets), "datasets enumerated;", length(corpus), "configurations;", sum(vapply(ledger, function(x) x[["status", exact = TRUE]] == "used", logical(1))), "datasets used\n")

saveRDS(corpus,'corpus.rds')
