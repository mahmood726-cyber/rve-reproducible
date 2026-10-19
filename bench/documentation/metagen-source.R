function (TE, seTE, studlab, data = NULL, subset = NULL, exclude = NULL, 
    cluster = NULL, rho = 0, cycles = NULL, weights = NULL, weights.common = weights, 
    weights.random = weights, sm = "", method.ci = if (missing(df)) "z" else "t", 
    level = gs("level"), common = gs("common"), random = gs("random") | 
        !is.null(tau.preset), overall = common | random, overall.hetstat = if (is.null(gs("overall.hetstat"))) common | 
        random else gs("overall.hetstat"), prediction = gs("prediction") | 
        !missing(method.predict), method.tau = gs("method.tau"), 
    method.tau.ci = gs("method.tau.ci"), level.hetstat = gs("level.hetstat"), 
    tau.preset = NULL, TE.tau = NULL, tau.common = gs("tau.common"), 
    detail.tau = NULL, method.I2 = gs("method.I2"), level.ma = gs("level.ma"), 
    method.common.ci = gs("method.common.ci"), method.random.ci = gs("method.random.ci"), 
    adhoc.hakn.ci = gs("adhoc.hakn.ci"), level.predict = gs("level.predict"), 
    method.predict = gs("method.predict"), adhoc.hakn.pi = gs("adhoc.hakn.pi"), 
    seed.predict = NULL, null.effect = 0, method.bias = gs("method.bias"), 
    n.e = NULL, n.c = NULL, pval, df, lower, upper, level.ci = 0.95, 
    median, q1, q3, min, max, method.mean = "Luo", method.sd = "Shi", 
    approx.TE, approx.seTE, transf = gs("transf") & missing(func.transf), 
    backtransf = gs("backtransf") | !missing(func.backtransf), 
    func.transf, func.backtransf, args.transf, args.backtransf, 
    pscale = 1, irscale = 1, irunit = "person-years", text.common = gs("text.common"), 
    text.random = gs("text.random"), text.predict = gs("text.predict"), 
    text.w.common = gs("text.w.common"), text.w.random = gs("text.w.random"), 
    title = gs("title"), complab = gs("complab"), outclab = "", 
    label.e = gs("label.e"), label.c = gs("label.c"), label.left = gs("label.left"), 
    label.right = gs("label.right"), col.label.left = gs("col.label.left"), 
    col.label.right = gs("col.label.right"), subgroup, subgroup.name = NULL, 
    print.subgroup.name = gs("print.subgroup.name"), sep.subgroup = gs("sep.subgroup"), 
    test.subgroup = gs("test.subgroup"), prediction.subgroup = gs("prediction.subgroup"), 
    seed.predict.subgroup = NULL, byvar, id, adhoc.hakn, keepdata = gs("keepdata"), 
    keeprma = gs("keeprma"), warn = gs("warn"), warn.deprecated = gs("warn.deprecated"), 
    control = NULL, ...) 
{
    missing.studlab <- missing(studlab)
    missing.sm <- missing(sm)
    missing.subgroup <- missing(subgroup)
    missing.overall <- missing(overall)
    missing.overall.hetstat <- missing(overall.hetstat)
    missing.test.subgroup <- missing(test.subgroup)
    missing.label.e <- missing(label.e)
    missing.label.c <- missing(label.c)
    missing.complab <- missing(complab)
    missing.adhoc.hakn.pi <- missing(adhoc.hakn.pi)
    missing.method.tau <- missing(method.tau)
    missing.tau.common <- missing(tau.common)
    avail.detail.tau <- !missing(detail.tau) & !is.null(detail.tau)
    missing.method.predict <- missing(method.predict)
    missing.func.transf <- missing(func.transf)
    missing.args.transf <- missing(args.transf)
    missing.func.backtransf <- missing(func.backtransf)
    missing.args.backtransf <- missing(args.backtransf)
    sm <- replaceNULL(sm, "")
    sm <- setchar(sm, unique(c(gs("sm4bin"), gs("sm4cont"), gs("sm4cor"), 
        gs("sm4inc"), gs("sm4mean"), gs("sm4prop"), gs("sm4rate"), 
        "")), stop.at.error = FALSE, return.NULL = FALSE, nchar.equal = TRUE)
    method.ci <- setchar(method.ci, gs("ci4cont"))
    method.mean <- setchar(method.mean, c("Luo", "Wan", "Cai", 
        "QE-McGrath", "BC-McGrath"))
    method.sd <- setchar(method.sd, c("Shi", "Wan", "Cai", "QE-McGrath", 
        "BC-McGrath"))
    if (method.mean %in% c("Cai", "QE-McGrath", "BC-McGrath")) 
        is_installed_package("estmeansd", argument = "method.mean", 
            value = method.mean)
    if (method.sd %in% c("Cai", "QE-McGrath", "BC-McGrath")) 
        is_installed_package("estmeansd", argument = "method.sd", 
            value = method.sd)
    chklevel(level)
    if (length(method.common.ci) != 1) 
        stop("Argument 'method.common.ci' must be of length 1.", 
            call. = FALSE)
    method.common.ci <- setchar(method.common.ci, gs("meth4common.ci"))
    method.tau <- setchar(method.tau, gs("meth4tau"))
    tau.common <- replaceNULL(tau.common, FALSE)
    chklogical(tau.common)
    method.I2 <- setchar(method.I2, gs("meth4i2"))
    chklogical(prediction)
    chklevel(level.predict)
    chknumeric(rho, min = -1, max = 1)
    method.predict <- setchar(method.predict, gs("meth4pi"))
    method.tau <- set_method_tau(method.tau, missing.method.tau, 
        method.predict, missing.method.predict)
    method.predict <- set_method_predict(method.predict, missing.method.predict, 
        method.tau, missing.method.tau)
    if (any(method.predict == "NNF")) 
        is_installed_package("pimeta", argument = "method.predict", 
            value = "NNF")
    adhoc.hakn.pi <- setchar(replaceNA(adhoc.hakn.pi, ""), gs("adhoc4hakn.pi"))
    if (!is.null(seed.predict)) 
        chknumeric(seed.predict, length = 1)
    chknumeric(null.effect, length = 1)
    chklogical(transf)
    chklogical(backtransf)
    avail.func.transf <- !missing.func.transf && !is.null(func.transf)
    avail.args.transf <- !missing.args.transf && !is.null(args.transf)
    avail.func.backtransf <- !missing.func.backtransf && !is.null(func.backtransf)
    avail.args.backtransf <- !missing.args.backtransf && !is.null(args.backtransf)
    if (avail.func.transf) {
        chkfunc(func.transf)
        if (is.function(func.transf)) 
            func.transf <- deparse(substitute(func.transf))
    }
    else func.transf <- NULL
    if (avail.args.transf) 
        chklist(args.transf)
    else args.transf <- NULL
    if (avail.func.backtransf) {
        chkfunc(func.backtransf)
        if (is.function(func.backtransf)) 
            func.backtransf <- deparse(substitute(func.backtransf))
    }
    else func.backtransf <- NULL
    if (avail.args.backtransf) 
        chklist(args.backtransf)
    else args.backtransf <- NULL
    if (is.null(func.transf) & !is.null(args.transf)) {
        warning("Argument 'args.transf' ignored as argument ", 
            "'func.transf' is ", if (!avail.func.transf) 
                "missing."
            else "NULL.", call. = FALSE)
        args.transf <- NULL
    }
    if (is.null(func.backtransf) & !is.null(args.backtransf)) {
        warning("Argument 'args.backtransf' ignored as argument ", 
            "'func.backtransf' is ", if (!avail.func.backtransf) 
                "missing."
            else "NULL.", call. = FALSE)
        args.backtransf <- NULL
    }
    if (!is.null(func.transf) & is.null(func.backtransf)) {
        if (func.transf == "log" & is.null(args.transf)) 
            func.backtransf <- "exp"
        else if (func.transf == "cor2z" & is.null(args.transf)) 
            func.backtransf <- "z2cor"
        else if (func.transf == "p2logit" & is.null(args.transf)) 
            func.backtransf <- "logit2p"
        else if (func.transf == "p2asin" & is.null(args.transf)) 
            func.backtransf <- "asin2p"
        else if (func.transf == "VE2logVR" & is.null(args.transf)) 
            func.backtransf <- "logVR2VE"
        else stop("Argument 'func.backtransf' must be specified.", 
            call. = FALSE)
    }
    missing.pscale <- missing(pscale)
    chknumeric(pscale, length = 1)
    if (!backtransf & pscale != 1) {
        if (!missing.pscale) 
            warning("Argument 'pscale' set to 1 as argument 'backtransf' is FALSE.", 
                call. = FALSE)
        pscale <- 1
    }
    missing.irscale <- missing(irscale)
    chknumeric(irscale, length = 1)
    if (!backtransf & irscale != 1) {
        if (!missing.irscale) 
            warning("Argument 'irscale' set to 1 as argument 'backtransf' is FALSE.", 
                call. = FALSE)
        irscale <- 1
    }
    if (!is.null(text.common)) 
        chkchar(text.common, length = 1)
    if (!is.null(text.random)) 
        chkchar(text.random)
    if (!is.null(text.predict)) 
        chkchar(text.predict)
    if (!is.null(text.w.common)) 
        chkchar(text.w.common, length = 1)
    if (!is.null(text.w.random)) 
        chkchar(text.w.random, length = 1)
    chkchar(label.e, length = 1)
    chkchar(label.c, length = 1)
    chklogical(keepdata)
    chklogical(keeprma)
    fun <- "metagen"
    chklogical(warn)
    args <- list(...)
    chklogical(warn.deprecated)
    level.ma <- deprecated(level.ma, missing(level.ma), args, 
        "level.comb", warn.deprecated)
    chklevel(level.ma)
    missing.common <- missing(common)
    common <- deprecated(common, missing.common, args, "comb.fixed", 
        warn.deprecated)
    common <- deprecated(common, missing.common, args, "fixed", 
        warn.deprecated)
    chklogical(common)
    random <- deprecated(random, missing(random), args, "comb.random", 
        warn.deprecated)
    chklogical(random)
    method.random.ci <- deprecated(method.random.ci, missing(method.random.ci), 
        args, "hakn", warn.deprecated)
    if (is.logical(method.random.ci)) 
        if (method.random.ci) 
            method.random.ci <- "HK"
        else method.random.ci <- "classic"
    method.random.ci <- setchar(method.random.ci, gs("meth4random.ci"))
    missing.adhoc.hakn.ci <- missing(adhoc.hakn.ci)
    adhoc.hakn.ci <- deprecated2(adhoc.hakn.ci, missing.adhoc.hakn.ci, 
        adhoc.hakn, missing(adhoc.hakn), warn.deprecated)
    adhoc.hakn.ci <- setchar(replaceNA(adhoc.hakn.ci, ""), gs("adhoc4hakn.ci"))
    missing.subgroup.name <- missing(subgroup.name)
    subgroup.name <- deprecated(subgroup.name, missing.subgroup.name, 
        args, "bylab", warn.deprecated)
    print.subgroup.name <- deprecated(print.subgroup.name, missing(print.subgroup.name), 
        args, "print.byvar", warn.deprecated)
    print.subgroup.name <- replaceNULL(print.subgroup.name, gs("print.subgroup.name"))
    chklogical(print.subgroup.name)
    sep.subgroup <- deprecated(sep.subgroup, missing(sep.subgroup), 
        args, "byseparator", warn.deprecated)
    if (!is.null(sep.subgroup)) 
        chkchar(sep.subgroup, length = 1)
    chklogical(overall)
    chklogical(overall.hetstat)
    nulldata <- is.null(data)
    sfsp <- sys.frame(sys.parent())
    mc <- match.call()
    if (nulldata) {
        data <- sfsp
        data.pairwise <- FALSE
    }
    else data.pairwise <- inherits(data, "pairwise")
    missing.byvar <- missing(byvar)
    byvar <- catch("byvar", mc, data, sfsp)
    missing.TE <- missing(TE)
    missing.seTE <- missing(seTE)
    missing.median <- missing(median)
    missing.lower <- missing(lower)
    missing.upper <- missing(upper)
    if (missing.TE & missing.median & (missing.lower | missing.upper)) 
        stop("Treatment estimates missing. ", "Provide either argument 'TE' or 'median', ", 
            "or arguments 'lower' and 'upper'.", call. = FALSE)
    TE <- catch("TE", mc, data, sfsp)
    avail.TE <- !(missing.TE || is.null(TE))
    if (inherits(TE, "pairwise")) {
        is.pairwise <- TRUE
        txt.ignore <- "as first argument is a pairwise object"
        warn_ignore_input(sm, !missing.sm, txt.ignore)
        warn_ignore_input(seTE, !missing.seTE, txt.ignore)
        warn_ignore_input(studlab, !missing.studlab, txt.ignore)
        sm <- attr(TE, "sm")
        reference.group <- attr(TE, "reference.group")
        if (is.null(attr(TE, "varnames"))) 
            seTE <- TE$seTE
        else seTE <- TE[[attr(TE, "varnames")[2]]]
        missing.sm <- FALSE
        missing.seTE <- FALSE
        missing.studlab <- FALSE
        studlab <- TE$studlab
        treat1 <- TE$treat1
        treat2 <- TE$treat2
        if (!is.null(TE$n1)) 
            n.e <- TE$n1
        else n.e <- NULL
        if (!is.null(TE$n2)) 
            n.c <- TE$n2
        else n.c <- NULL
        pairdata <- TE
        data <- TE
        nulldata <- FALSE
        if (is.null(attr(TE, "varnames"))) 
            TE <- TE$TE
        else TE <- TE[[attr(TE, "varnames")[1]]]
        avail.TE <- !is.null(TE)
        wo <- treat1 == reference.group
        if (any(wo)) {
            TE[wo] <- -TE[wo]
            ttreat1 <- treat1
            treat1[wo] <- treat2[wo]
            treat2[wo] <- ttreat1[wo]
            if (!is.null(n.e) & !is.null(n.c)) {
                tn.e <- n.e
                n.e[wo] <- n.c[wo]
                n.c[wo] <- tn.e[wo]
            }
        }
        if (missing.subgroup) {
            subgroup <- paste(treat1, treat2, sep = " vs ")
            if (length(unique(subgroup)) == 1) {
                if (missing.complab) 
                  complab <- unique(subgroup)
                if (missing.label.e) 
                  label.e <- unique(treat1)
                if (missing.label.c) 
                  label.c <- unique(treat2)
                subgroup <- NULL
            }
            else {
                if (missing.overall) 
                  overall <- FALSE
                if (missing.overall.hetstat) 
                  overall.hetstat <- FALSE
                if (missing.test.subgroup) 
                  test.subgroup <- FALSE
            }
        }
        else subgroup <- catch("subgroup", mc, data, sfsp)
    }
    else {
        is.pairwise <- FALSE
        if (missing.sm) 
            if (!is.null(data) && !is.null(attr(data, "sm"))) 
                sm <- attr(data, "sm")
            else sm <- ""
        seTE <- catch("seTE", mc, data, sfsp)
        studlab <- catch("studlab", mc, data, sfsp)
        subgroup <- catch("subgroup", mc, data, sfsp)
        subgroup <- deprecated2(subgroup, missing.subgroup, byvar, 
            missing.byvar, warn.deprecated)
        if (!missing(n.e)) 
            n.e <- catch("n.e", mc, data, sfsp)
        if (!missing(n.c)) 
            n.c <- catch("n.c", mc, data, sfsp)
    }
    method.bias <- setmethodbias(method.bias)
    by <- !is.null(subgroup)
    median <- catch("median", mc, data, sfsp)
    lower <- catch("lower", mc, data, sfsp)
    upper <- catch("upper", mc, data, sfsp)
    avail.median <- !(missing.median || is.null(median))
    avail.lower <- !(missing.lower || is.null(lower))
    avail.upper <- !(missing.upper || is.null(upper))
    if (!avail.TE & !avail.median & (!avail.lower | !avail.upper)) 
        stop("Treatment estimates missing. ", "Provide either argument 'TE' or 'median', ", 
            "or arguments 'lower' and 'upper'.", call. = FALSE)
    TE.orig <- NULL
    lower.orig <- NULL
    upper.orig <- NULL
    if (!transf) {
        if (avail.TE) {
            TE.orig <- TE
            TE <- transf(TE, sm, func.transf, args.transf)
        }
        if (avail.lower) {
            lower.orig <- lower
            lower <- transf(lower, sm, func.transf, args.transf)
        }
        if (avail.upper) {
            upper.orig <- upper
            upper <- transf(upper, sm, func.transf, args.transf)
        }
        if (sm == "VE" && avail.lower & avail.upper) {
            tmp.l <- lower
            lower <- upper
            upper <- tmp.l
            tmp.l <- lower.orig
            lower.orig <- upper.orig
            upper.orig <- tmp.l
        }
    }
    missing.cluster <- missing(cluster)
    cluster <- catch("cluster", mc, data, sfsp)
    missing.id <- missing(id)
    id <- catch("id", mc, data, sfsp)
    cluster <- deprecated2(cluster, missing.cluster, id, missing.id, 
        warn.deprecated)
    with.cluster <- !is.null(cluster)
    if (with.cluster) 
        idx <- seq_along(cluster)
    missing.cycles <- missing(cycles)
    cycles <- catch("cycles", mc, data, sfsp)
    with.cycles <- !is.null(cycles)
    if (!missing(weights)) 
        weights <- catch("weights", mc, data, sfsp)
    if (!missing(weights.common)) 
        weights.common <- catch("weights.common", mc, data, sfsp)
    if (!missing(weights.random)) 
        weights.random <- catch("weights.random", mc, data, sfsp)
    if (!is.null(weights) & is.null(weights.common)) 
        weights.common <- weights
    if (!is.null(weights) & is.null(weights.random)) 
        weights.random <- weights
    usw.common <- !is.null(weights.common)
    usw.random <- !is.null(weights.random)
    if (usw.common) 
        chknumeric(weights.common, min = 0)
    if (usw.random) 
        chknumeric(weights.random, min = 0)
    if (with.cycles) {
        chknumeric(cycles, min = 1)
        if (method.ci != "z") 
            method.ci <- "z"
    }
    if (with.cluster & with.cycles) 
        stop("Arguments 'cluster' (multi-level model) and 'cycles' (n-of-1 trials)", 
            " cannot be used together.", call. = FALSE)
    missing.method.tau.ci <- missing(method.tau.ci)
    k.All <- if (avail.TE) 
        length(TE)
    else if (avail.median) 
        length(median)
    else if (avail.lower) 
        length(lower)
    else if (avail.upper) 
        length(upper)
    else NA
    if (!avail.TE) 
        TE <- rep_len(NA, k.All)
    if (missing.seTE) 
        seTE <- rep_len(NA, k.All)
    studlab <- setstudlab(studlab, k.All)
    subset <- catch("subset", mc, data, sfsp)
    missing.subset <- is.null(subset)
    exclude <- catch("exclude", mc, data, sfsp)
    missing.exclude <- is.null(exclude)
    missing.pval <- missing(pval)
    pval <- catch("pval", mc, data, sfsp)
    avail.pval <- !(missing.pval || is.null(pval))
    missing.df <- missing(df)
    df <- catch("df", mc, data, sfsp)
    avail.df <- !(missing.df || is.null(df))
    if (!missing(level.ci)) 
        level.ci <- catch("level.ci", mc, data, sfsp)
    missing.q1 <- missing(q1)
    q1 <- catch("q1", mc, data, sfsp)
    avail.q1 <- !(missing.q1 || is.null(q1))
    missing.q3 <- missing(q3)
    q3 <- catch("q3", mc, data, sfsp)
    avail.q3 <- !(missing.q3 || is.null(q3))
    missing.min <- missing(min)
    min <- catch("min", mc, data, sfsp)
    avail.min <- !(missing.min || is.null(min))
    missing.max <- missing(max)
    max <- catch("max", mc, data, sfsp)
    avail.max <- !(missing.max || is.null(max))
    missing.approx.TE <- missing(approx.TE)
    approx.TE <- catch("approx.TE", mc, data, sfsp)
    avail.approx.TE <- !(missing.approx.TE || is.null(approx.TE))
    missing.approx.seTE <- missing(approx.seTE)
    approx.seTE <- catch("approx.seTE", mc, data, sfsp)
    avail.approx.seTE <- !(missing.approx.seTE || is.null(approx.seTE))
    missing.text.random <- missing(text.random)
    arg <- if (avail.TE) 
        "TE"
    else "median"
    chklength(seTE, k.All, arg)
    chklength(studlab, k.All, arg)
    if (by) {
        chklength(subgroup, k.All, arg)
        chklogical(test.subgroup)
        chklogical(prediction.subgroup)
    }
    if (!by & tau.common) {
        warning("Value for argument 'tau.common' set to FALSE as ", 
            "argument 'subgroup' is missing.", call. = FALSE)
        tau.common <- FALSE
    }
    if (by & !tau.common & !is.null(tau.preset)) {
        warning("Argument 'tau.common' set to TRUE as ", "argument tau.preset is not NULL.", 
            call. = FALSE)
        tau.common <- TRUE
    }
    if (usw.common) {
        if (length(weights.common) == 1) 
            weights.common <- rep(weights.common, k.All)
        else chklength(weights.common, k.All, arg)
    }
    if (usw.random) {
        if (length(weights.random) == 1) 
            weights.random <- rep(weights.random, k.All)
        else chklength(weights.random, k.All, arg)
    }
    if (!is.null(n.e)) 
        chklength(n.e, k.All, arg)
    if (!is.null(n.c)) 
        chklength(n.c, k.All, arg)
    if (with.cluster) 
        chklength(cluster, k.All, arg)
    if (avail.approx.TE) {
        if (length(approx.TE) == 1) 
            rep_len(approx.TE, k.All)
        else chklength(approx.TE, k.All, arg)
        approx.TE <- setchar(approx.TE, c("", "ci", "iqr.range", 
            "iqr", "range"))
    }
    if (avail.approx.seTE) {
        if (length(approx.seTE) == 1) 
            rep_len(approx.seTE, k.All)
        else chklength(approx.seTE, k.All, arg)
        approx.seTE <- setchar(approx.seTE, c("", "pval", "ci", 
            "iqr.range", "iqr", "range"))
    }
    if (avail.pval) 
        chklength(pval, k.All, arg)
    if (avail.df) 
        chklength(df, k.All, arg)
    if (avail.lower) 
        chklength(lower, k.All, arg)
    if (avail.upper) 
        chklength(upper, k.All, arg)
    if (length(level.ci) == 1) 
        level.ci <- rep_len(level.ci, k.All)
    else if (!is.null(level.ci)) 
        chklength(level.ci, k.All, arg)
    if (avail.median) 
        chklength(median, k.All, arg)
    if (avail.q1) 
        chklength(q1, k.All, arg)
    if (avail.q3) 
        chklength(q3, k.All, arg)
    if (avail.min) 
        chklength(min, k.All, arg)
    if (avail.max) 
        chklength(max, k.All, arg)
    if (with.cycles) 
        chklength(cycles, k.All, arg)
    if (!missing.subset) 
        if ((is.logical(subset) & (sum(subset) > k.All)) || (length(subset) > 
            k.All)) 
            stop("Length of argument 'subset' is larger than number of studies.")
    if (!missing.exclude) {
        if ((is.logical(exclude) & (sum(exclude) > k.All)) || 
            (length(exclude) > k.All)) 
            stop("Length of argument 'exclude' is larger than number of studies.")
        exclude2 <- rep(FALSE, k.All)
        exclude2[exclude] <- TRUE
        exclude <- exclude2
    }
    else exclude <- rep(FALSE, k.All)
    if (keepdata) {
        if (inherits(data, "meta")) {
            data <- data$data
            if (isCol(data, ".subset")) 
                data <- data[data$.subset, ]
        }
        else if (nulldata & !is.pairwise) 
            data <- data.frame(.studlab = studlab)
        else if (nulldata & is.pairwise) {
            data <- pairdata
            data$.studlab <- studlab
        }
        else data$.studlab <- studlab
        data$.TE <- TE
        data$.seTE <- seTE
        if (by) 
            data$.subgroup <- subgroup
        if (!missing.subset) {
            if (length(subset) == dim(data)[1]) 
                data$.subset <- subset
            else {
                data$.subset <- FALSE
                data$.subset[subset] <- TRUE
            }
        }
        if (!missing.exclude) 
            data$.exclude <- exclude
        if (with.cluster) {
            data$.id <- data$.cluster <- cluster
            data$.idx <- idx
        }
        if (with.cycles) 
            data$.cycles <- cycles
        if (usw.common) 
            data$.weights.common <- weights.common
        if (usw.random) 
            data$.weights.random <- weights.random
        if (avail.pval) 
            data$.pval <- pval
        if (avail.df) 
            data$.df <- df
        if (avail.lower) 
            data$.lower <- lower
        if (avail.upper) 
            data$.upper <- upper
        if (avail.lower | avail.upper) 
            data$.level.ci <- level.ci
        if (avail.median) 
            data$.median <- median
        if (avail.q1) 
            data$.q1 <- q1
        if (avail.q3) 
            data$.q3 <- q3
        if (avail.min) 
            data$.min <- min
        if (avail.max) 
            data$.max <- max
        if (avail.approx.TE) 
            data$.approx.TE <- approx.TE
        if (avail.approx.seTE) 
            data$.approx.seTE <- approx.seTE
        if (!is.null(n.e)) 
            data$.n.e <- n.e
        if (!is.null(n.c)) 
            data$.n.c <- n.c
        if (!is.null(TE.orig)) 
            data$.TE.orig <- TE.orig
        if (!is.null(lower.orig)) 
            data$.lower.orig <- lower.orig
        if (!is.null(upper.orig)) 
            data$.upper.orig <- upper.orig
    }
    if (!missing.subset) {
        TE <- TE[subset]
        seTE <- seTE[subset]
        studlab <- studlab[subset]
        exclude <- exclude[subset]
        if (with.cluster) {
            cluster <- cluster[subset]
            idx <- idx[subset]
        }
        if (with.cycles) 
            cycles <- cycles[subset]
        if (by) 
            subgroup <- subgroup[subset]
        if (!is.null(n.e)) 
            n.e <- n.e[subset]
        if (!is.null(n.c)) 
            n.c <- n.c[subset]
        if (avail.pval) 
            pval <- pval[subset]
        if (avail.df) 
            df <- df[subset]
        if (avail.lower) 
            lower <- lower[subset]
        if (avail.upper) 
            upper <- upper[subset]
        level.ci <- level.ci[subset]
        if (avail.median) 
            median <- median[subset]
        if (avail.q1) 
            q1 <- q1[subset]
        if (avail.q3) 
            q3 <- q3[subset]
        if (avail.min) 
            min <- min[subset]
        if (avail.max) 
            max <- max[subset]
        if (avail.approx.TE) 
            approx.TE <- approx.TE[subset]
        if (avail.approx.seTE) 
            approx.seTE <- approx.seTE[subset]
    }
    if (missing.subgroup & is.pairwise & by) {
        if (length(unique(subgroup)) == 1) {
            by <- FALSE
            if (missing.complab) 
                complab <- unique(subgroup)
            subgroup <- NULL
            if (keepdata) 
                data$.subgroup <- NULL
            if (missing.overall) 
                overall <- TRUE
            if (missing.overall.hetstat) 
                overall.hetstat <- TRUE
        }
    }
    k.all <- length(TE)
    if (k.all == 0) 
        stop("No studies to combine in meta-analysis.")
    if (k.all == 1) {
        common <- FALSE
        random <- FALSE
        method.random.ci <- "classic"
        adhoc.hakn.ci <- ""
        prediction <- FALSE
        method.predict <- "V"
        adhoc.hakn.pi <- ""
        overall <- FALSE
        overall.hetstat <- FALSE
    }
    chknumeric(TE)
    chknumeric(seTE, 0)
    if (!with.cycles) {
        if (!avail.approx.seTE) {
            approx.seTE <- rep_len("", length(TE))
            sel.NA <- is.na(seTE)
            if (any(sel.NA) & avail.lower & avail.upper) {
                j <- sel.NA & !is.na(lower) & !is.na(upper)
                approx.seTE[j] <- "ci"
                if (!avail.df) 
                  seTE[j] <- TE.seTE.ci(lower[j], upper[j], level.ci[j])$seTE
                else seTE[j] <- TE.seTE.ci(lower[j], upper[j], 
                  level.ci[j], df[j])$seTE
            }
            sel.NA <- is.na(seTE)
            if (any(sel.NA) & avail.pval) {
                j <- sel.NA & !is.na(TE) & !is.na(pval)
                approx.seTE[j] <- "pval"
                if (!avail.df) 
                  seTE[j] <- seTE.pval(TE[j], pval[j])$seTE
                else seTE[j] <- seTE.pval(TE[j], pval[j], df[j])$seTE
            }
            sel.NA <- is.na(seTE)
            if (any(sel.NA) & avail.median & avail.q1 & avail.q3 & 
                avail.min & avail.max & !(is.null(n.e) & is.null(n.c))) {
                j <- sel.NA & !is.na(median) & !is.na(q1) & !is.na(q3) & 
                  !is.na(min) & !is.na(max)
                approx.seTE[j] <- "iqr.range"
                if (is.null(n.c)) 
                  seTE[j] <- mean_sd_iqr_range(n.e[j], median[j], 
                    q1[j], q3[j], min[j], max[j], method.sd = method.sd)$se
                else if (is.null(n.e)) 
                  seTE[j] <- mean_sd_iqr_range(n.c[j], median[j], 
                    q1[j], q3[j], min[j], max[j], method.sd = method.sd)$se
                else seTE[j] <- mean_sd_iqr_range(n.e[j] + n.c[j], 
                  median[j], q1[j], q3[j], min[j], max[j], method.sd = method.sd)$se
            }
            sel.NA <- is.na(seTE)
            if (any(sel.NA) & avail.median & avail.q1 & avail.q3 & 
                !(is.null(n.e) & is.null(n.c))) {
                j <- sel.NA & !is.na(median) & !is.na(q1) & !is.na(q3)
                approx.seTE[j] <- "iqr"
                if (is.null(n.c)) 
                  seTE[j] <- mean_sd_iqr(n.e[j], median[j], q1[j], 
                    q3[j])$se
                else if (is.null(n.e)) 
                  seTE[j] <- mean_sd_iqr(n.c[j], median[j], q1[j], 
                    q3[j])$se
                else seTE[j] <- mean_sd_iqr(n.e[j] + n.c[j], 
                  median[j], q1[j], q3[j])$se
            }
            sel.NA <- is.na(seTE)
            if (any(sel.NA) & avail.median & avail.min & avail.max & 
                !(is.null(n.e) & is.null(n.c))) {
                j <- sel.NA & !is.na(median) & !is.na(min) & 
                  !is.na(max)
                approx.seTE[j] <- "range"
                if (is.null(n.c)) 
                  seTE[j] <- mean_sd_range(n.e[j], median[j], 
                    min[j], max[j])$se
                else if (is.null(n.e)) 
                  seTE[j] <- mean_sd_range(n.c[j], median[j], 
                    min[j], max[j])$se
                else seTE[j] <- mean_sd_range(n.e[j] + n.c[j], 
                  median[j], min[j], max[j])$se
            }
        }
        else {
            j <- 0
            for (i in approx.seTE) {
                j <- j + 1
                if (i == "ci") {
                  if (!avail.df) 
                    seTE[j] <- TE.seTE.ci(lower[j], upper[j], 
                      level.ci[j])$seTE
                  else seTE[j] <- TE.seTE.ci(lower[j], upper[j], 
                    level.ci[j], df[j])$seTE
                }
                else if (i == "pval") {
                  if (!avail.df) 
                    seTE[j] <- seTE.pval(TE[j], pval[j])$seTE
                  else seTE[j] <- seTE.pval(TE[j], pval[j], df[j])$seTE
                }
                else if (i == "iqr.range") {
                  if (is.null(n.e) & is.null(n.c)) 
                    stop("Sample size needed if argument 'approx.seTE' = \"iqr\".", 
                      call. = FALSE)
                  else if (is.null(n.c)) 
                    seTE[j] <- mean_sd_iqr_range(n.e[j], median[j], 
                      q1[j], q3[j], min[j], max[j], method.sd = method.sd)$se
                  else if (is.null(n.e)) 
                    seTE[j] <- mean_sd_iqr_range(n.c[j], median[j], 
                      q1[j], q3[j], min[j], max[j], method.sd = method.sd)$se
                  else seTE[j] <- mean_sd_iqr_range(n.e[j] + 
                    n.c[j], median[j], q1[j], q3[j], min[j], 
                    max[j], method.sd = method.sd)$se
                }
                else if (i == "iqr") {
                  if (is.null(n.e) & is.null(n.c)) 
                    stop("Sample size needed if argument 'approx.seTE' = \"iqr\".", 
                      call. = FALSE)
                  else if (is.null(n.c)) 
                    seTE[j] <- mean_sd_iqr(n.e[j], median[j], 
                      q1[j], q3[j])$se
                  else if (is.null(n.e)) 
                    seTE[j] <- mean_sd_iqr(n.c[j], median[j], 
                      q1[j], q3[j])$se
                  else seTE[j] <- mean_sd_iqr(n.e[j] + n.c[j], 
                    median[j], q1[j], q3[j])$se
                }
                else if (i == "range") {
                  if (is.null(n.e) & is.null(n.c)) 
                    stop("Sample size needed if argument 'approx.seTE' = \"range\".", 
                      call. = FALSE)
                  else if (is.null(n.c)) 
                    seTE[j] <- mean_sd_range(n.e[j], median[j], 
                      min[j], max[j])$se
                  else if (is.null(n.e)) 
                    seTE[j] <- mean_sd_range(n.c[j], median[j], 
                      min[j], max[j])$se
                  else seTE[j] <- mean_sd_range(n.e[j] + n.c[j], 
                    median[j], min[j], max[j])$se
                }
            }
        }
    }
    if (!with.cycles) {
        if (!avail.approx.TE) {
            approx.TE <- rep_len("", length(TE))
            sel.NA <- is.na(TE)
            if (any(sel.NA) & avail.lower & avail.upper) {
                j <- sel.NA & !is.na(lower) & !is.na(upper)
                approx.TE[j] <- "ci"
                TE[j] <- TE.seTE.ci(lower[j], upper[j], level.ci[j])$TE
            }
            sel.NA <- is.na(TE)
            if (any(sel.NA) & avail.median & avail.q1 & avail.q3 & 
                avail.min & avail.max & !(is.null(n.e) & is.null(n.c))) {
                j <- sel.NA & !is.na(median) & !is.na(q1) & !is.na(q3) & 
                  !is.na(min) & !is.na(max)
                approx.TE[j] <- "iqr.range"
                if (is.null(n.c)) 
                  TE[j] <- mean_sd_iqr_range(n.e[j], median[j], 
                    q1[j], q3[j], min[j], max[j], method.mean)$mean
                else if (is.null(n.e)) 
                  TE[j] <- mean_sd_iqr_range(n.c[j], median[j], 
                    q1[j], q3[j], min[j], max[j], method.mean)$mean
                else TE[j] <- mean_sd_iqr_range(n.e[j] + n.c[j], 
                  median[j], q1[j], q3[j], min[j], max[j], method.mean)$mean
            }
            sel.NA <- is.na(TE)
            if (any(sel.NA) & avail.median & avail.q1 & avail.q3 & 
                !(is.null(n.e) & is.null(n.c))) {
                j <- sel.NA & !is.na(median) & !is.na(q1) & !is.na(q3)
                approx.TE[j] <- "iqr"
                if (is.null(n.c)) 
                  TE[j] <- mean_sd_iqr(n.e[j], median[j], q1[j], 
                    q3[j], method.mean)$mean
                else if (is.null(n.e)) 
                  TE[j] <- mean_sd_iqr(n.c[j], median[j], q1[j], 
                    q3[j], method.mean)$mean
                else TE[j] <- mean_sd_iqr(n.e[j] + n.c[j], median[j], 
                  q1[j], q3[j], method.mean)$mean
            }
            sel.NA <- is.na(TE)
            if (any(sel.NA) & avail.median & avail.min & avail.max & 
                !(is.null(n.e) & is.null(n.c))) {
                j <- sel.NA & !is.na(median) & !is.na(min) & 
                  !is.na(max)
                approx.TE[j] <- "range"
                if (is.null(n.c)) 
                  TE[j] <- mean_sd_range(n.e[j], median[j], min[j], 
                    max[j], method.mean)$mean
                else if (is.null(n.e)) 
                  TE[j] <- mean_sd_range(n.c[j], median[j], min[j], 
                    max[j], method.mean)$mean
                else TE[j] <- mean_sd_range(n.e[j] + n.c[j], 
                  median[j], min[j], max[j], method.mean)$mean
            }
        }
        else {
            j <- 0
            for (i in approx.TE) {
                j <- j + 1
                if (i == "ci") 
                  TE[j] <- TE.seTE.ci(lower[j], upper[j], level.ci[j])$TE
                else if (i == "iqr.range") 
                  if (is.null(n.e) & is.null(n.c)) 
                    stop("Sample size needed if argument 'approx.TE' = \"iqr.range\".", 
                      call. = FALSE)
                  else if (is.null(n.c)) 
                    TE[j] <- mean_sd_iqr_range(n.e[j], median[j], 
                      q1[j], q3[j], min[j], max[j], method.mean)$mean
                  else if (is.null(n.e)) 
                    TE[j] <- mean_sd_iqr_range(n.c[j], median[j], 
                      q1[j], q3[j], min[j], max[j], method.mean)$mean
                  else TE[j] <- mean_sd_iqr_range(n.e[j] + n.c[j], 
                    median[j], q1[j], q3[j], min[j], max[j], 
                    method.mean)$mean
                else if (i == "iqr") {
                  if (is.null(n.e) & is.null(n.c)) 
                    stop("Sample size needed if argument 'approx.TE' = \"iqr\".", 
                      call. = FALSE)
                  else if (is.null(n.c)) 
                    TE[j] <- mean_sd_iqr(n.e[j], median[j], q1[j], 
                      q3[j], method.mean)$mean
                  else if (is.null(n.e)) 
                    TE[j] <- mean_sd_iqr(n.c[j], median[j], q1[j], 
                      q3[j], method.mean)$mean
                  else TE[j] <- mean_sd_iqr(n.e[j] + n.c[j], 
                    median[j], q1[j], q3[j], method.mean)$mean
                }
                else if (i == "range") {
                  cat(paste0("Use 'range' for study", j, "\n"))
                  if (is.null(n.e) & is.null(n.c)) 
                    stop("Sample size needed if argument 'approx.TE' = \"range\".", 
                      call. = FALSE)
                  else if (is.null(n.c)) 
                    TE[j] <- mean_sd_range(n.e[j], median[j], 
                      min[j], max[j], method.mean)$mean
                  else if (is.null(n.e)) 
                    TE[j] <- mean_sd_range(n.c[j], median[j], 
                      min[j], max[j], method.mean)$mean
                  else TE[j] <- mean_sd_range(n.e[j] + n.c[j], 
                    median[j], min[j], max[j], method.mean)$mean
                }
            }
        }
    }
    if (keepdata) {
        if (!isCol(data, ".subset")) {
            data$.TE <- TE
            data$.seTE <- seTE
            if (!avail.approx.TE & any(approx.TE != "")) 
                data$.approx.TE <- approx.TE
            if (!avail.approx.seTE & any(approx.seTE != "")) 
                data$.approx.seTE <- approx.seTE
        }
        else {
            data$.TE[data$.subset] <- TE
            data$.seTE[data$.subset] <- seTE
            if (!avail.approx.TE & any(approx.TE != "")) {
                data$.approx.TE <- ""
                data$.approx.TE[data$.subset] <- approx.TE
            }
            if (!avail.approx.seTE & any(approx.seTE != "")) {
                data$.approx.seTE <- ""
                data$.approx.seTE[data$.subset] <- approx.seTE
            }
        }
    }
    TE <- int2num(TE)
    seTE <- int2num(seTE)
    if (any(seTE[!is.na(seTE)] <= 0)) {
        if (warn & !with.cycles) 
            warning("Zero values in seTE replaced by NAs.", call. = FALSE)
        seTE[!is.na(seTE) & seTE == 0] <- NA
    }
    tau2.calc <- NA
    three.level <- FALSE
    sel.ni <- !is.infinite(TE) & !is.infinite(seTE)
    if (with.cluster && length(unique(cluster[sel.ni])) != length(cluster[sel.ni])) 
        three.level <- TRUE
    if (is.null(method.tau.ci)) 
        if (three.level) 
            method.tau.ci <- "PL"
        else if (method.tau == "DL") 
            method.tau.ci <- "J"
        else method.tau.ci <- "QP"
    method.tau.ci <- setchar(method.tau.ci, gs("meth4tau.ci"))
    if (!three.level & method.tau.ci == "PL") {
        if (method.tau == "DL") 
            method.tau.ci <- "J"
        else method.tau.ci <- "QP"
    }
    chklevel(level.hetstat)
    if (three.level) {
        chkmlm(method.tau, missing.method.tau, method.predict)
        common <- FALSE
        if (!(method.tau %in% c("REML", "ML"))) 
            method.tau <- "REML"
    }
    if (by) {
        chkmiss(subgroup)
        if (missing.subgroup.name & is.null(subgroup.name)) {
            if (!missing.subgroup) 
                subgroup.name <- byvarname("subgroup", mc)
            else if (!missing.byvar) 
                subgroup.name <- byvarname("byvar", mc)
        }
    }
    if (!is.null(subgroup.name)) 
        chkchar(subgroup.name, length = 1)
    if (with.cycles) {
        df.n_of_1 <- cycles - 1
        sd.n_of_1 <- sqrt(sum(df.n_of_1 * seTE^2, na.rm = TRUE)/sum(df.n_of_1, 
            na.rm = TRUE))
        seTE <- sd.n_of_1/sqrt(cycles)
        if (keepdata) {
            data$.seTE.orig <- data$.seTE
            if (!isCol(data, ".subset")) 
                data$.seTE <- seTE
            else data$.seTE[data$.subset] <- seTE
        }
    }
    k <- sum(!is.na(TE[!exclude]) & !is.na(seTE[!exclude]))
    if (three.level) {
        cluster.incl <- cluster[!exclude]
        k.study <- length(unique(cluster.incl[!is.na(TE[!exclude]) & 
            !is.na(seTE[!exclude])]))
    }
    else k.study <- k
    seTE.hakn.ci <- seTE.hakn.adhoc.ci <- seTE.hakn.pi <- seTE.hakn.adhoc.pi <- seTE.kero <- NA
    pi <- list(seTE = NA, lower = NA, upper = NA, df = NA)
    df.random <- df.predict <- df.hakn <- df.hakn.ci <- df.hakn.pi <- df.kero <- NA
    if (k == 0) {
        TE.common <- seTE.common <- lower.common <- upper.common <- statistic.common <- pval.common <- NA
        w.common <- rep(0, k.all)
        TE.random <- seTE.random <- lower.random <- upper.random <- statistic.random <- pval.random <- NA
        seTE.classic <- seTE.random
        w.random <- rep(0, k.all)
        seTE.predict <- df.predict <- lower.predict <- upper.predict <- seTE.hakn.pi <- seTE.hakn.adhoc.pi <- NA
        hc <- list(tau2 = NA, se.tau2 = NA, lower.tau2 = NA, 
            upper.tau2 = NA, tau = NA, lower.tau = NA, upper.tau = NA, 
            method.tau.ci = "", level = NA, sign.lower.tau = "", 
            sign.upper.tau = "", Q = NA, df.Q = NA, pval.Q = NA, 
            H = NA, lower.H = NA, upper.H = NA, I2 = NA, lower.I2 = NA, 
            upper.I2 = NA, Q.resid = NA, df.Q.resid = NA, pval.Q.resid = NA, 
            H.resid = NA, lower.H.resid = NA, upper.H.resid = NA, 
            I2.resid = NA, lower.I2.resid = NA, upper.I2.resid = NA)
    }
    else {
        if (k == 1) {
            method.random.ci <- ifelse(method.random.ci %in% 
                c("HK", "KR"), "classic", method.random.ci)
            method.predict <- ifelse(method.predict %in% c("HK", 
                "KR"), "V", method.predict)
            adhoc.hakn.ci <- ""
            adhoc.hakn.pi <- ""
        }
        hc <- hetcalc(TE[!exclude], seTE[!exclude], method.tau, 
            method.tau.ci, TE.tau, method.I2, level.hetstat, 
            control = control, cluster = cluster[!exclude], rho = rho)
        if (by & tau.common) 
            hcc <- hetcalc(TE[!exclude], seTE[!exclude], method.tau, 
                method.tau.ci, TE.tau, method.I2, level.hetstat, 
                subgroup = subgroup, control = control, cluster = cluster[!exclude], 
                rho = rho)
        if (!three.level) {
            if (is.null(tau.preset)) 
                tau2.calc <- if (is.na(sum(hc$tau2))) 
                  0
                else sum(hc$tau2)
            else {
                tau2.calc <- tau.preset^2
                hc$tau2 <- tau.preset^2
                hc$se.tau2 <- hc$lower.tau2 <- hc$upper.tau2 <- NA
                hc$tau <- tau.preset
                hc$lower.tau <- hc$upper.tau <- NA
                hc$method.tau.ci <- ""
                hc$sign.lower.tau <- ""
                hc$sign.upper.tau <- ""
            }
            if (!usw.common) {
                w.common <- 1/seTE^2
                w.common[is.na(w.common) | is.na(TE) | exclude] <- 0
                TE.common <- weighted.mean(TE, w.common, na.rm = TRUE)
                if (method.common.ci == "classic") {
                  seTE.common <- sqrt(1/sum(w.common, na.rm = TRUE))
                }
                else if (method.common.ci == "IVhet") {
                  seTE.common <- sqrt(sum((w.common/(sum(w.common)))^2 * 
                    (seTE^2 + tau2.calc)))
                }
                else seTE.common <- NA
                ci.c <- ci(TE.common, seTE.common, level = level.ma, 
                  null.effect = null.effect)
                statistic.common <- ci.c$statistic
                pval.common <- ci.c$p
                lower.common <- ci.c$lower
                upper.common <- ci.c$upper
            }
            else {
                sel.4 <- !is.na(TE) & !is.na(seTE) & !exclude
                m4.usw.c <- runUSW(list(yi = TE[sel.4], sei = seTE[sel.4], 
                  weights = weights.common[sel.4]), method.tau = "FE", 
                  method.random.ci = NULL, level = level.ma, 
                  control = control)
                res.usw.c <- extrUSW(m4.usw.c, "FE", null.effect)
                w.common <- res.usw.c$w.common
                TE.common <- res.usw.c$TE.common
                seTE.common <- res.usw.c$seTE.common
                lower.common <- res.usw.c$lower.common
                upper.common <- res.usw.c$upper.common
                statistic.common <- res.usw.c$statistic.common
                pval.common <- res.usw.c$pval.common
                if (length(m4.usw.c) == 1) 
                  m4.usw.c <- m4.usw.c[[1]]
            }
            if (!usw.random) {
                w.random <- 1/(seTE^2 + tau2.calc)
                w.random[is.na(w.random) | is.na(TE) | exclude] <- 0
                TE.random <- weighted.mean(TE, w.random, na.rm = TRUE)
                seTE.random <- sqrt(1/sum(w.random, na.rm = TRUE))
                seTE.classic <- seTE.random
                kr <- kenwardroger(w.random)
                seTE.kero <- kr$se
                df.kero <- kr$df
                if (any(method.random.ci == "KR") | any(method.predict == 
                  "KR")) {
                  if (is.nan(seTE.kero) | is.nan(df.kero)) {
                    method.random.ci[method.random.ci == "KR"] <- "classic-KR"
                    method.predict[method.predict == "KR"] <- "V-KR"
                  }
                }
                df.hakn <- k - 1
                q <- 1/(k - 1) * sum(w.random * (TE - TE.random)^2, 
                  na.rm = TRUE)
                seTE.hakn.ci <- seTE.hakn.adhoc.ci <- seTE.hakn.pi <- seTE.hakn.adhoc.pi <- sqrt(q/sum(w.random))
                ci.r <- as.data.frame(ci(1, NA, level = 0.99999))
                if (length(adhoc.hakn.ci) == 1) {
                  adhoc.hakn.ci <- ifelse(method.random.ci == 
                    "HK", adhoc.hakn.ci, "")
                }
                else if (length(adhoc.hakn.ci) == sum(method.random.ci == 
                  "HK")) {
                  adho <- rep("", length(method.random.ci))
                  adho[method.random.ci == "HK"] <- adhoc.hakn.ci
                  adhoc.hakn.ci <- adho
                }
                else if (length(method.random.ci) == 1 && method.random.ci == 
                  "HK") {
                  method.random.ci <- rep("HK", length(adhoc.hakn.ci))
                }
                else if (length(adhoc.hakn.ci) != length(method.random.ci)) 
                  stop("Argument 'adhoc.hakn.ci' must be of same length as ", 
                    "'method.random.ci' or number of meta-analyses with ", 
                    "Hartung-Knapp method", call. = FALSE)
                seTE.hakn.adhoc.ci <- rep(seTE.hakn.adhoc.ci, 
                  length(method.random.ci))
                df.hakn.ci <- rep(df.hakn, length(method.random.ci))
                for (i in seq_along(method.random.ci)) {
                  if (method.random.ci[i] %in% c("classic", "classic-KR")) {
                    ci.r.i <- ci(TE.random, seTE.classic, level = level.ma, 
                      null.effect = null.effect)
                    seTE.hakn.adhoc.ci[i] <- NA
                  }
                  else if (method.random.ci[i] == "HK") {
                    if (adhoc.hakn.ci[i] == "se") {
                      if (q < 1) 
                        seTE.hakn.adhoc.ci[i] <- seTE.classic
                    }
                    else if (adhoc.hakn.ci[i] == "ci") {
                      ci.hk <- ci(TE.random, seTE.hakn.ci, level = level.ma, 
                        df = df.hakn.ci[i])
                      ci.re <- ci(TE.random, seTE.classic, level = level.ma)
                      width.hk <- ci.hk$upper - ci.hk$lower
                      width.re <- ci.re$upper - ci.re$lower
                      if (width.hk < width.re) {
                        seTE.hakn.adhoc.ci[i] <- seTE.classic
                        df.hakn.ci[i] <- NA
                      }
                    }
                    else if (adhoc.hakn.ci[i] == "IQWiG6") {
                      ci.hk <- ci(TE.random, seTE.hakn.ci, level = level.ma, 
                        df = df.hakn.ci[i])
                      m.dl <- metagen(TE, seTE, method.tau = "DL", 
                        method.tau.ci = "", method.random.ci = "classic")
                      ci.dl <- ci(m.dl$TE.random, m.dl$seTE.classic, 
                        level = level.ma)
                      width.hk <- ci.hk$upper - ci.hk$lower
                      width.dl <- ci.dl$upper - ci.dl$lower
                      if (width.hk < width.dl) 
                        seTE.hakn.adhoc.ci[i] <- seTE.classic
                    }
                    ci.r.i <- ci(TE.random, seTE.hakn.adhoc.ci[i], 
                      level = level.ma, df = df.hakn.ci[i], null.effect = null.effect)
                  }
                  else if (method.random.ci[i] == "KR") {
                    ci.r.i <- ci(TE.random, seTE.kero, level = level.ma, 
                      df = df.kero, null.effect = null.effect)
                  }
                  ci.r <- rbind(ci.r, as.data.frame(ci.r.i))
                }
                ci.r <- ci.r[-1, ]
                seTE.random <- ci.r$seTE
                lower.random <- ci.r$lower
                upper.random <- ci.r$upper
                df.random <- ci.r$df
                statistic.random <- ci.r$statistic
                pval.random <- ci.r$p
                if (missing.text.random || (length(text.random) == 
                  1 & length(method.random.ci) > 1)) {
                  text.random <- ifelse(method.random.ci == "classic", 
                    text.random, ifelse(method.random.ci %in% 
                      c("KR", "classic-KR"), paste0(text.random, 
                      " (", method.random.ci, ")"), paste0(text.random, 
                      " (HK")))
                  text.random <- paste0(text.random, ifelse(method.random.ci != 
                    "HK", "", ifelse(adhoc.hakn.ci == "", ")", 
                    paste0("-", toupper(substring(adhoc.hakn.ci, 
                      1, 2)), ")"))))
                }
                pi <- data.frame()
                if (length(adhoc.hakn.pi) == 1) {
                  adhoc.hakn.pi <- ifelse(method.predict == "HK", 
                    adhoc.hakn.pi, "")
                }
                else if (length(adhoc.hakn.pi) == sum(method.predict == 
                  "HK")) {
                  adho <- rep("", length(method.predict))
                  adho[method.predict == "HK"] <- adhoc.hakn.pi
                  adhoc.hakn.pi <- adho
                }
                else if (length(method.predict) == 1 && method.predict == 
                  "HK") {
                  method.predict <- rep("HK", length(adhoc.hakn.pi))
                }
                else if (length(adhoc.hakn.pi) != length(method.predict)) {
                  stop("Argument 'adhoc.hakn.pi' must be of same length as ", 
                    "'method.predict' or number of prediction intervals using ", 
                    "Hartung-Knapp method", call. = FALSE)
                }
                seTE.hakn.adhoc.pi <- rep(seTE.hakn.adhoc.pi, 
                  length(method.predict))
                df.hakn.pi <- rep(df.hakn, length(method.predict))
                for (i in seq_along(method.predict)) {
                  if (method.predict[i] == "HK" && df.hakn.pi[i] >= 
                    1) {
                    if (adhoc.hakn.pi[i] == "se") {
                      if (q < 1) 
                        seTE.hakn.adhoc.pi[i] <- seTE.classic
                    }
                    pi.i <- ci(TE.random, sqrt(seTE.hakn.adhoc.pi[i]^2 + 
                      tau2.calc), level = level.predict, df = df.hakn.pi[i])
                  }
                  else if (method.predict[i] == "HK-PR" && df.hakn.pi[i] >= 
                    2) {
                    if (adhoc.hakn.pi[i] == "se") {
                      if (q < 1) 
                        seTE.hakn.adhoc.pi[i] <- seTE.classic
                    }
                    pi.i <- ci(TE.random, sqrt(seTE.hakn.adhoc.pi[i]^2 + 
                      tau2.calc), level = level.predict, df = df.hakn.pi[i] - 
                      1)
                  }
                  else if (method.predict[i] %in% c("V", "V-KR") & 
                    k > 1) {
                    pi.i <- ci(TE.random, sqrt(seTE.classic^2 + 
                      tau2.calc), level.predict, k - 1)
                  }
                  else if (method.predict[i] %in% c("HTS", "HTS-KR") & 
                    k > 2) {
                    pi.i <- ci(TE.random, sqrt(seTE.classic^2 + 
                      tau2.calc), level.predict, k - 2)
                  }
                  else if (method.predict[i] == "KR" & df.kero > 
                    0) {
                    pi.i <- ci(TE.random, sqrt(seTE.kero^2 + 
                      tau2.calc), level.predict, df.kero)
                  }
                  else if (method.predict[i] == "KR-PR" & df.kero > 
                    1) {
                    pi.i <- ci(TE.random, sqrt(seTE.kero^2 + 
                      tau2.calc), level.predict, df.kero - 1)
                  }
                  else if (method.predict[i] == "PR" & df.kero > 
                    0) {
                    pi.i <- ci(TE.random, sqrt(seTE.kero^2 + 
                      tau2.calc), level.predict, df.kero - 1)
                  }
                  else if (method.predict[i] == "NNF") {
                    res.pima <- pimeta::pima(TE[!exclude], seTE[!exclude], 
                      method = "boot", alpha = 1 - level.predict, 
                      seed = seed.predict)
                    pi.i <- as.data.frame(ci(1, NA, level = level.predict))
                    pi.i$seTE <- NA
                    pi.i$lower <- res.pima$lpi
                    pi.i$upper <- res.pima$upi
                    pi.i$df <- res.pima$nup
                  }
                  else if (method.predict[i] == "S") 
                    pi.i <- ci(TE.random, sqrt(seTE.classic^2 + 
                      tau2.calc), level.predict)
                  else if (method.predict[i] == "KR") 
                    pi.i <- ci(TE.random, NA, level.predict, 
                      df.kero - 1)
                  else if (method.predict[i] == "V") 
                    pi.i <- ci(TE.random, NA, level.predict, 
                      k - 1)
                  else if (method.predict[i] == "HTS") 
                    pi.i <- ci(TE.random, NA, level.predict, 
                      k - 2)
                  else pi.i <- ci(TE.random, NA, level.predict)
                  pi <- rbind(pi, as.data.frame(pi.i))
                }
                seTE.predict <- pi$seTE
                lower.predict <- pi$lower
                upper.predict <- pi$upper
                df.predict <- pi$df
            }
            else {
                if ((!missing.adhoc.hakn.ci && any(adhoc.hakn.ci != 
                  "")) | (!missing.adhoc.hakn.pi && any(adhoc.hakn.pi != 
                  ""))) {
                  warning("Ad hoc variance correction not implemented ", 
                    "for user-specified weights.", call. = FALSE)
                  adhoc.hakn.ci[adhoc.hakn.ci != ""] <- ""
                  adhoc.hakn.pi[adhoc.hakn.pi != ""] <- ""
                }
                sel.4 <- !is.na(TE) & !is.na(seTE) & !exclude
                m4.usw.r <- runUSW(list(yi = TE[sel.4], sei = seTE[sel.4], 
                  weights = weights.random[sel.4]), method.tau = method.tau, 
                  method.random.ci = method.random.ci, level = level.ma, 
                  control = control)
                res.usw.r <- extrUSW(m4.usw.r, method.tau, null.effect, 
                  k, length(TE), sel.4, method.random.ci, method.predict, 
                  level.ma, level.predict)
                w.random <- res.usw.r$w.random
                tau2.calc <- sum(res.usw.r$tau2)
                if (is.na(tau2.calc)) 
                  tau2.calc <- 0
                TE.random <- res.usw.r$TE.random
                seTE.random <- res.usw.r$seTE.random
                lower.random <- res.usw.r$lower.random
                upper.random <- res.usw.r$upper.random
                statistic.random <- res.usw.r$statistic.random
                pval.random <- res.usw.r$pval.random
                seTE.classic <- m4.usw.r[[1]]$se
                df.random <- df.hakn <- ifelse(method.random.ci == 
                  "HK", k - 1, NA)
                if (missing(text.random) || (length(text.random) == 
                  1 & length(method.random.ci) > 1)) 
                  text.random <- ifelse(method.random.ci == "classic", 
                    text.random, ifelse(method.random.ci == "HK", 
                      paste0(text.random, " (T)"), ""))
                seTE.predict <- res.usw.r$seTE.predict
                lower.predict <- res.usw.r$lower.predict
                upper.predict <- res.usw.r$upper.predict
                df.predict <- res.usw.r$df.predict
                if (length(m4.usw.r) == 1) 
                  m4.usw.r <- m4.usw.r[[1]]
            }
        }
        else {
            if (common) {
                if (!missing.common & common) 
                  warning(gs("text.common"), " not calculated for three-level model.", 
                    call. = FALSE)
                common <- FALSE
            }
            w.common <- rep_len(NA, length(seTE))
            TE.common <- seTE.common <- lower.common <- upper.common <- statistic.common <- pval.common <- NA
            if ((!missing.adhoc.hakn.ci && any(adhoc.hakn.ci != 
                "")) | (!missing.adhoc.hakn.pi && any(adhoc.hakn.pi != 
                ""))) {
                warning("Ad hoc variance correction not implemented ", 
                  "for three-level model.", call. = FALSE)
                adhoc.hakn.ci[adhoc.hakn.ci != ""] <- ""
                adhoc.hakn.pi[adhoc.hakn.pi != ""] <- ""
            }
            sel.4 <- !is.na(TE) & !is.na(seTE) & !exclude
            list.mlm <- list(yi = TE[sel.4], V = vcalc(vi = seTE[sel.4]^2, 
                cluster = cluster[sel.4], obs = idx[sel.4], rho = rho))
            m4 <- runMLM(c(list.mlm, list(data = data.frame(cluster = cluster[sel.4], 
                idx = idx[sel.4]))), method.tau = method.tau, 
                method.random.ci = method.random.ci, level = level.ma, 
                control = control)
            res.mlm <- extrMLM(m4, k, length(TE), sel.4, method.random.ci, 
                method.predict, level.ma, level.predict, null.effect)
            w.random <- res.mlm$w.random
            tau2.calc <- sum(res.mlm$tau2)
            if (is.na(tau2.calc)) 
                tau2.calc <- 0
            TE.random <- res.mlm$TE.random
            seTE.random <- res.mlm$seTE.random
            lower.random <- res.mlm$lower.random
            upper.random <- res.mlm$upper.random
            statistic.random <- res.mlm$statistic.random
            pval.random <- res.mlm$pval.random
            seTE.classic <- m4[[1]]$se
            df.random <- df.hakn <- ifelse(method.random.ci == 
                "HK", k - 1, NA)
            if (missing(text.random) || (length(text.random) == 
                1 & length(method.random.ci) > 1)) 
                text.random <- ifelse(method.random.ci == "classic", 
                  text.random, ifelse(method.random.ci == "HK", 
                    paste0(text.random, " (T)"), ""))
            seTE.predict <- res.mlm$seTE.predict
            lower.predict <- res.mlm$lower.predict
            upper.predict <- res.mlm$upper.predict
            df.predict <- res.mlm$df.predict
            if (length(m4) == 1) 
                m4 <- m4[[1]]
        }
    }
    if (missing(text.predict) || (length(text.predict) == 1 & 
        length(method.predict) > 1)) {
        if (length(method.predict) > 1) {
            text.predict <- paste0(text.predict, " (", method.predict)
            text.predict <- paste0(text.predict, ifelse(method.predict != 
                "HK", ")", ifelse(adhoc.hakn.pi == "", ")", paste0("-", 
                toupper(adhoc.hakn.pi), ")"))))
        }
    }
    if (length(tau2.calc) == 1) 
        Rbres <- Rb(seTE[!is.na(seTE)], seTE.classic, tau2.calc, 
            hc$Q, hc$df.Q, level.ma)
    else Rbres <- list(TE = NA, lower = NA, upper = NA)
    if (!avail.detail.tau) {
        if (k != k.study) 
            detail.tau <- c("between cluster", "within cluster")
        else detail.tau <- ""
    }
    ci.study <- ci(TE, seTE, level = level, df = if (!is.null(method.ci) && 
        method.ci == "t") 
        df
    else NULL, null.effect = null.effect)
    if (avail.lower) 
        ci.study$lower[!is.na(lower)] <- lower[!is.na(lower)]
    if (avail.upper) 
        ci.study$upper[!is.na(upper)] <- upper[!is.na(upper)]
    if (length(lower.random) > 1) {
        methci <- paste(method.random.ci, toupper(substring(adhoc.hakn.ci, 
            1, 2)), sep = "-")
        methci <- gsub("-$", "", methci)
        if (length(TE.random) == 1) 
            TE.random <- rep(TE.random, length(lower.random))
        if (length(seTE.random) == 1) 
            seTE.random <- rep(seTE.random, length(lower.random))
        names(TE.random) <- names(seTE.random) <- names(statistic.random) <- names(pval.random) <- names(df.random) <- names(lower.random) <- names(upper.random) <- methci
        if (!three.level & !usw.random) 
            names(adhoc.hakn.ci) <- names(df.hakn.ci) <- names(seTE.hakn.adhoc.ci) <- methci
    }
    if (length(lower.predict) > 1) {
        methpi <- paste(method.predict, toupper(substring(adhoc.hakn.pi, 
            1, 2)), sep = "-")
        methpi <- gsub("-$", "", methpi)
        names(seTE.predict) <- names(df.predict) <- names(lower.predict) <- names(upper.predict) <- methpi
        if (!three.level & !usw.random) 
            names(adhoc.hakn.pi) <- names(df.hakn.pi) <- names(seTE.hakn.adhoc.pi) <- methpi
    }
    res <- list(studlab = studlab, sm = sm, null.effect = null.effect, 
        TE = TE, seTE = seTE, statistic = ci.study$statistic, 
        pval = ci.study$p, df = if (!is.null(method.ci) && method.ci == 
            "t") df else rep_len(NA, length(TE)), level = level, 
        lower = ci.study$lower, upper = ci.study$upper, three.level = three.level, 
        cluster = cluster, rho = rho, k = k, k.study = k.study, 
        k.all = k.all, k.TE = sum(!is.na(TE)), cycles = cycles, 
        sd.n_of_1 = if (with.cycles) sd.n_of_1 else NULL, overall = overall, 
        overall.hetstat = overall.hetstat, common = common, random = random, 
        prediction = prediction, transf = transf, backtransf = backtransf, 
        func.transf = func.transf, func.backtransf = func.backtransf, 
        args.transf = args.transf, args.backtransf = args.backtransf, 
        method = "Inverse", method.random = "Inverse", w.common = w.common, 
        TE.common = TE.common, seTE.common = seTE.common, statistic.common = statistic.common, 
        pval.common = pval.common, level.ma = level.ma, method.common.ci = method.common.ci, 
        lower.common = lower.common, upper.common = upper.common, 
        w.random = w.random, TE.random = TE.random, seTE.random = seTE.random, 
        statistic.random = statistic.random, pval.random = pval.random, 
        method.random.ci = method.random.ci, df.random = df.random, 
        lower.random = lower.random, upper.random = upper.random, 
        seTE.classic = seTE.classic, weights.common = weights.common, 
        weights.random = weights.random, adhoc.hakn.ci = adhoc.hakn.ci, 
        df.hakn.ci = if (any(method.random.ci == "HK")) df.hakn.ci else NA, 
        seTE.hakn.ci = seTE.hakn.ci, seTE.hakn.adhoc.ci = seTE.hakn.adhoc.ci, 
        df.kero = if (any(method.random.ci == "KR") | any(method.predict == 
            "KR")) df.kero else NA, seTE.kero = seTE.kero, method.predict = method.predict, 
        adhoc.hakn.pi = adhoc.hakn.pi, df.hakn.pi = if (any(method.predict == 
            "HK")) df.hakn.pi else NA, seTE.predict = seTE.predict, 
        df.predict = df.predict, level.predict = level.predict, 
        lower.predict = lower.predict, upper.predict = upper.predict, 
        seTE.hakn.pi = seTE.hakn.pi, seTE.hakn.adhoc.pi = seTE.hakn.adhoc.pi, 
        Q = hc$Q, df.Q = hc$df.Q, pval.Q = hc$pval.Q, method.tau = method.tau, 
        control = control, method.tau.ci = hc$method.tau.ci, 
        level.hetstat = level.hetstat, tau2 = hc$tau2, se.tau2 = hc$se.tau2, 
        lower.tau2 = hc$lower.tau2, upper.tau2 = hc$upper.tau2, 
        tau = hc$tau, lower.tau = hc$lower.tau, upper.tau = hc$upper.tau, 
        tau.preset = tau.preset, TE.tau = if (!missing(TE.tau) & 
            method.tau == "DL") TE.tau else NULL, detail.tau = detail.tau, 
        sign.lower.tau = hc$sign.lower.tau, sign.upper.tau = hc$sign.upper.tau, 
        method.I2 = method.I2, H = hc$H, lower.H = hc$lower.H, 
        upper.H = hc$upper.H, I2 = hc$I2, lower.I2 = hc$lower.I2, 
        upper.I2 = hc$upper.I2, Rb = Rbres$TE, lower.Rb = Rbres$lower, 
        upper.Rb = Rbres$upper, method.bias = method.bias, text.common = text.common, 
        text.random = text.random, text.predict = text.predict, 
        text.w.common = text.w.common, text.w.random = text.w.random, 
        title = title, complab = complab, outclab = outclab, 
        label.e = label.e, label.c = label.c, label.left = label.left, 
        label.right = label.right, col.label.left = replaceNULL(col.label.left, 
            "black"), col.label.right = replaceNULL(col.label.right, 
            "black"), keepdata = keepdata, data = if (keepdata) data else NULL, 
        subset = if (keepdata) subset else NULL, exclude = if (!missing.exclude) exclude else NULL, 
        n.e = n.e, n.c = n.c, pscale = pscale, irscale = irscale, 
        irunit = irunit, method.ci = method.ci, method.mean = method.mean, 
        approx.TE = if (all(approx.TE == "")) NULL else approx.TE, 
        approx.seTE = if (all(approx.seTE == "")) NULL else approx.seTE, 
        seed.predict = seed.predict, pairwise = is.pairwise, 
        warn = warn, call = match.call(), version = packageDescription("meta")$Version, 
        tau2.calc = tau2.calc, rma.usw.c = if (usw.common & keeprma) m4.usw.c else NULL, 
        rma.usw.r = if (usw.random & keeprma) m4.usw.r else NULL, 
        rma.three.level = if (three.level & keeprma) m4 else NULL, 
        zval = ci.study$statistic, hakn = any(method.random.ci == 
            "HK"), zval.common = statistic.common, zval.random = statistic.random)
    if (is.pairwise | data.pairwise) {
        res$pairwise <- TRUE
        res$k.study <- length(unique(res$studlab[!is.na(res$TE)]))
    }
    class(res) <- c(fun, "meta")
    if (avail.lower | avail.upper) 
        res$level.ci <- level.ci
    if (by) {
        res$subgroup <- subgroup
        res$subgroup.name <- subgroup.name
        res$tau.common <- tau.common
        res$print.subgroup.name <- print.subgroup.name
        res$sep.subgroup <- sep.subgroup
        res$test.subgroup <- test.subgroup
        res$prediction.subgroup <- prediction.subgroup
        if (!tau.common) {
            res <- c(res, subgroup(res, seed = seed.predict.subgroup))
            if (res$three.level) 
                res <- setNA3(res)
        }
        else if (!is.null(tau.preset)) 
            res <- c(res, subgroup(res, tau.preset, seed = seed.predict.subgroup))
        else {
            if (three.level) 
                res <- c(res, subgroup(res, NULL, factor(res$subgroup, 
                  bylevs(res$subgroup))))
            else res <- c(res, subgroup(res, hcc$tau.resid, seed = seed.predict.subgroup))
        }
        if (tau.common && is.null(tau.preset)) 
            res <- addHet(res, hcc)
        else {
            res$tau2.resid <- res$lower.tau2.resid <- res$upper.tau2.resid <- NA
            res$tau.resid <- res$lower.tau.resid <- res$upper.tau.resid <- NA
            res$Q.resid <- res$df.Q.resid <- res$pval.Q.resid <- NA
            res$H.resid <- res$lower.H.resid <- res$upper.H.resid <- NA
            res$I2.resid <- res$lower.I2.resid <- res$upper.I2.resid <- NA
        }
        res$event.e.w <- NULL
        res$event.c.w <- NULL
        res$event.w <- NULL
        res$n.w <- NULL
        res$time.e.w <- NULL
        res$time.c.w <- NULL
        res <- setNAwithin(res, res$three.level)
    }
    if (length(res$tau2) > 1) 
        names(res$tau2) <- res$detail.tau
    if (length(res$tau) > 1) 
        names(res$tau) <- res$detail.tau
    if (length(res$tau2.resid) > 1) 
        names(res$tau2.resid) <- res$detail.tau
    if (length(res$tau.resid) > 1) 
        names(res$tau.resid) <- res$detail.tau
    res$method.predict <- ifelse(is.na(res$lower.predict) & is.na(res$upper.predict), 
        "", res$method.predict)
    res$df.predict <- ifelse(is.na(res$lower.predict) & is.na(res$upper.predict), 
        NA, res$df.predict)
    res$adhoc.hakn.pi <- ifelse(is.na(res$lower.predict) & is.na(res$upper.predict), 
        "", res$adhoc.hakn.pi)
    res <- backward(res)
    class(res) <- c(fun, "meta")
    res
}
