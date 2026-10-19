supplement <- function(d, n, capture) {
    if (!is.data.frame(d)) 
        return()
    add <- function(measure, mapping) {
        if (!all(unname(mapping) %in% names(d))) 
            return()
        args <- lapply(mapping, function(col) d[[col]])
        args[["measure"]] <- measure
        args[["data"]] <- d
        v <- tryCatch(do.call(escalc, args), error = function(e) NULL)
        if (!is.null(v)) 
            capture(v, paste("supplement:", measure, paste(names(mapping), mapping, sep = "=", collapse = ", ")))
    }
    for (map in list(c(ai = "ai", n1i = "n1i", ci = "ci", n2i = "n2i"), c(ai = "Ee", n1i = "Ne", ci = "Ec", n2i = "Nc"), c(ai = "xt", n1i = "nt", ci = "xc", n2i = "nc"))) add("RR", map)
    add("ZCOR", c(ri = "ri", ni = "ni"))
    add("SMD", c(m1i = "Me", sd1i = "Se", n1i = "Ne", m2i = "Mc", sd2i = "Sc", n2i = "Nc"))
    add("MD", c(m1i = "Me", sd1i = "Se", n1i = "Ne", m2i = "Mc", sd2i = "Sc", n2i = "Nc"))
    maps <- list(dat.bakdash2021 = c(yi = "es.z", vi = "vi.z"), dat.baskerville2012 = c(yi = "smd", sei = "se"), dat.curtin2002 = c(yi = "mean", sei = "SE"), dat.steurer2006 = c(yi = "lnHR", sei = "selnHR"), dat.thompson1999 = c(yi = "logOR", vi = "varlogOR"))
    if (n %in% names(maps)) 
        add("GEN", maps[[n]])
    if (n == "dat.feng2019") 
        add("PLO", c(xi = "depr", ni = "n"))
    if (n == "dat.greenland1992") 
        add("GEN", c(yi = "b", sei = "SE"))
    if (n == "dat.higgins2008") 
        add("OR", c(ai = "resp.halo", bi = "fail.halo", ci = "resp.plac", di = "fail.plac"))
    if (n == "dat.cannon2006") 
        for (i in 1:6) add("RR", c(ai = paste0("ep", i, "t"), n1i = "nt", ci = paste0("ep", i, "c"), n2i = "nc"))
    if (n == "dat.fine1993") 
        for (i in 1:4) add("RR", c(ai = paste0("e", i, "i"), n1i = "nei", ci = paste0("c", i, "i"), n2i = "nci"))
    if (n == "dat.collins1985a") 
        for (z in c("b", "o", "d")) add("OR", c(ai = paste0(z, ".xti"), n1i = "nti", ci = paste0(z, ".xci"), n2i = "nci"))
    if (n == "dat.nissen2007") 
        for (z in c("infarction", "death")) add("OR", c(ai = paste0("treat.", z), n1i = "treat.total", ci = paste0("cont.", z), n2i = "cont.total"))
    if (n == "dat.chiarito2020") 
        for (z in c("mi", "stroke", "death", "vdeath")) add("RR", c(ai = paste0("p2y12.", z), n1i = "p2y12.total", ci = paste0("aspirin.", z), n2i = "aspirin.total"))
    if (n == "dat.karner2014") {
        for (z in c("exa", "sexa", "hospi", "deaths", "sae", "dropout")) add("OR", c(ai = paste0("tiotropium.", z), n1i = "tiotropium.total", ci = paste0("placebo.", z), n2i = "placebo.total"))
        for (z in c("sgrq", "fev1")) add("GEN", c(yi = paste0(z, ".md"), sei = paste0(z, ".se")))
    }
    if (n %in% c("dat.roever2022", "dat.ursino2021")) 
        add("PLO", c(xi = "events", ni = "total"))
    if (n == "dat.tian2009") 
        for (z in c("deaths", "infarcts")) add("PLO", c(xi = z, ni = "n"))
    if (n == "dat.rivera2025") {
        d[["ncase"]] <- d[["TP", exact = TRUE]] + d[["FN", exact = TRUE]]
        d[["ncontrol"]] <- d[["TN", exact = TRUE]] + d[["FP", exact = TRUE]]
        add("PLO", c(xi = "TP", ni = "ncase"))
        add("PLO", c(xi = "TN", ni = "ncontrol"))
    }
    if (n == "dat.lloyd2010") 
        for (z in c("das", "haq")) {
            d[["yi"]] <- d[[paste0("mean.", z)]]
            d[["vi"]] <- ((d[[paste0("upper.", z)]] - d[[paste0("lower.", z)]])/(2 * qnorm(0.975)))^2
            capture(d, paste("normal 95% CI to variance", z))
        }
}
