### Name: dat.bakdash2021
### Title: Dataset on Situation Awareness and Task Performance Associations
### Aliases: dat.bakdash2021
### Keywords: datasets

### ** Examples

### copy data into 'dat' and examine data
dat <- dat.bakdash2021
head(dat[c(1,2,6,8:12)])

## Not run: 
##D #start.time <- Sys.time()
##D 
##D ### load metafor
##D library(metafor)
##D 
##D ### multilevel meta-analytic model to get the overall pooled effect
##D res.overall <- rma.mv(es.z, vi.z, mods = ~ 1,
##D                       random = ~ 1 | SampleID / Outcome,
##D                       data = dat,
##D                       test = "t")
##D res.overall
##D 
##D ### get prediction interval
##D predict(res.overall)
##D 
##D ### cluster-robust variance estimation (CRVE) / cluster-robust inference
##D res.overall.crve <- robust(res.overall, cluster = SampleID)
##D res.overall.crve
##D 
##D ### get prediction interval
##D res.overall.crve.pred <- predict(res.overall.crve)
##D res.overall.crve.pred
##D 
##D ### multilevel meta-analytic model for SA measures
##D res.sa <-  rma.mv(es.z, vi.z, mods = ~ 0 + SA.measure.type,
##D                   random = ~ 1 | SampleID / Outcome,
##D                   data = dat,
##D                   test = "t")
##D res.sa
##D 
##D ### cluster-robust variance estimation (CRVE) / cluster-robust inference
##D res.sa.crve <- robust(res.sa, cluster = SampleID)
##D res.sa.crve
##D 
##D ### profile likelihood plots
##D par(mfrow=c(2,1))
##D profile(res.sa.crve, progbar = FALSE)
##D 
##D ### format and combine output of meta-analytic models for the forest plot
##D all.z        <- c(res.sa.crve$beta,            # SA measures
##D                   res.overall.crve$beta,       # pooled effect for confidence interval (CI)
##D                   res.overall.crve$beta)       # pooled effect for prediction interval (PI)
##D 
##D all.ci.lower <- c(res.sa.crve$ci.lb,           # SA measures
##D                   res.overall.crve.pred$ci.lb, # pooled effect, lower CI
##D                   res.overall.crve.pred$pi.lb) # pooled effect, lower PI
##D 
##D all.ci.upper <- c(res.sa.crve$ci.ub,           # SA measures
##D                   res.overall.crve.pred$ci.ub, # pooled effect, upper CI
##D                   res.overall.crve.pred$pi.ub) # pooled effect, upper PI
##D 
##D ### note: there is no p-value for the PI
##D all.pvals  <- c(res.sa.crve$pval, res.overall.crve$pval)
##D all.labels <- c(sort(unique(dat$SA.measure.type)), "Overall", "95% Prediction Interval")
##D 
##D ### function to round p-values for the forest plot
##D pvals.round <- function(input) {
##D   input <- ifelse(input < 0.001, "< 0.001",
##D            ifelse(input < 0.01, "< 0.01",
##D            ifelse(input < 0.05 & input >= 0.045, "< 0.05",
##D            ifelse(round(input, 2) == 1.00, "0.99",
##D            sprintf("%.2f", round(input, 2))))))}
##D 
##D all.pvals.rounded <- pvals.round(all.pvals)
##D 
##D ### forest plot
##D plot.vals <- data.frame(all.labels, all.z, all.ci.lower, all.ci.upper)
##D 
##D par(mfrow=c(1,1), cex = 1.05)
##D forest(plot.vals$all.z,
##D        ci.lb = plot.vals$all.ci.lower,
##D        ci.ub = plot.vals$all.ci.upper,
##D        slab  = plot.vals$all.labels,
##D        psize = 1,
##D        efac = 0, xlim = c(-1.8, 2.5), clim = c(-1, 1),
##D        transf = transf.ztor, # transform z to r
##D        at = seq(-0.5, 1, by = 0.25),
##D        xlab = expression("Correlation Coefficient"~"("*italic('r')*")"),
##D        main = "\n\n\nSA Measures",
##D        ilab = c(all.pvals.rounded, ""), ilab.xpos = 2.45, ilab.pos = 2.5,
##D        digits = 2, refline = 0, annotate = FALSE, header = FALSE)
##D 
##D ### keep trailing zero using sprintf
##D output <- cbind(sprintf("%.2f", round(transf.ztor(plot.vals$all.z), 2)),
##D                 sprintf("%.2f", round(transf.ztor(plot.vals$all.ci.lower), 2)),
##D                 sprintf("%.2f", round(transf.ztor(plot.vals$all.ci.upper), 2)))
##D 
##D ### alignment kludge
##D annotext <- apply(output, 1, function(x) {paste0("  ", x[1], " [", x[2],", ", x[3], "]")})
##D text( 1.05, 12:1, annotext, pos = 4, cex = 1.05)
##D text(-1.475, 14.00, "SA Measure", cex = 1.05)
##D text( 2.30,  14.00, substitute(paste(italic('p-value'))), cex = 1.05)
##D text( 1.55,  14.00, "Correlation [95% CI]", cex = 1.05)
##D abline(h = 2.5)
##D 
##D ### black polygon for overall mean CIs
##D addpoly(all.z[11], ci.lb = all.ci.lower[11], ci.ub = all.ci.upper[11],
##D         rows = 2, annotate = FALSE, efac = 1.5, transf = transf.ztor)
##D 
##D ### white polygon for PI
##D addpoly(all.z[12], ci.lb = all.ci.lower[12], ci.ub = all.ci.upper[12],
##D         rows = 1, col = "white", border = "black",
##D         annotate = FALSE, efac = 1.5, transf = transf.ztor)
##D 
##D par(mfrow=c(1,1), cex = 1) # reset graph parameters to default
##D 
##D ### confidence intervals for the variance components
##D re.CI.variances <- confint(res.overall)
##D re.CI.variances
##D 
##D sigma1.z <- data.frame(re.CI.variances[[1]]["random"])
##D sigma2.z <- data.frame(re.CI.variances[[2]]["random"])
##D 
##D ### fit model using alternative multivariate parameterization
##D res.overall.alt <- rma.mv(es.z, vi.z, mods = ~ 1,
##D                           random = ~ factor(Outcome) | factor(SampleID),
##D                           data = dat,
##D                           test = "t")
##D 
##D ### confidence intervals for the total amount of heterogeneity variance component
##D res.overall.alt.tau <- confint(res.overall.alt, tau2=1)$random
##D 
##D ### I^2: http://www.metafor-project.org/doku.php/tips:i2_multilevel_multivariate
##D W <- diag(1/dat$vi.z)
##D X <- model.matrix(res.overall)
##D P <- W - W %*% X %*% solve(t(X) %*% W %*% X) %*% t(X) %*% W
##D 
##D ### I^2 (variance due to heterogeneity): 61%
##D I2 <- 100 * res.overall.alt$tau2 /
##D       (res.overall.alt$tau2 + (res.overall$k-res.overall$p)/sum(diag(P)))
##D I2
##D 
##D ### 95% CI for I^2 using uncertainty around tau^2
##D I2.CI.lb <- 100 * res.overall.alt.tau[1,2] /
##D             (res.overall.alt.tau[1,2] + (res.overall$k-res.overall$p)/sum(diag(P)))
##D I2.CI.lb
##D 
##D I2.CI.ub <- 100 * res.overall.alt.tau[1,3] /
##D             (res.overall.alt.tau[1,3] + (res.overall$k-res.overall$p)/sum(diag(P)))
##D I2.CI.ub
##D 
##D ### total amount of heterogeneity (tau)
##D sqrt(res.overall.alt$tau2)
##D 
##D ### heterogeneity table
##D table.heterogeneity <- data.frame(matrix(ncol = 3, nrow = 4))
##D colnames(table.heterogeneity) <- c("Parameter Value",
##D                                    "Lower 95% CI",
##D                                    "Upper 95% CI")
##D rownames(table.heterogeneity) <- c("Tau (Total)",
##D                                    "Tau1 (Between paper)",
##D                                    "Tau2 (Within paper)",
##D                                    "I2 (%)")
##D 
##D table.heterogeneity[1,] <- res.overall.alt.tau[2,]
##D table.heterogeneity[2,] <- sigma1.z[2,]
##D table.heterogeneity[3,] <- sigma2.z[2,]
##D table.heterogeneity[4,] <- c(I2, I2.CI.lb, I2.CI.ub)
##D 
##D round(table.heterogeneity, 2)
##D 
##D #end.time <- Sys.time()
##D #end.time - start.time
## End(Not run)



