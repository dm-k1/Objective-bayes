## =====================================================================
##  Figures 1 and 2 of docs/1_why_a_choice.md, and the checks printed for it
##  and for appendix B (figures 3-6, for the three priors and the
##  derivations, are made by R/make_figures_from_validation.R)
##  Every figure is a simulation compared with a formula, so each claim in
##  the docs can be checked by running this file. The three priors keep the
##  colours of the motivating simulation: flat partial r blue, flat R orange, flat
##  R-squared green.
##  Run from the project folder: Rscript R/make_figures.R
## =====================================================================
library(ggplot2)
library(flatcor) # remotes::install_github("dm-k1/flatcor")
prior_shape <- utils::getFromNamespace("prior_shape", "flatcor") # the shape a of each prior

figure_folder <- file.path("docs", "figures")
save_doc_figure <- function(figure, name, width = 8, height = 4.5) {
  ggsave(file.path(figure_folder, paste0(name, ".png")), figure,
    width = width, height = height, dpi = 150
  )
  invisible(figure)
}
theme_set(theme_minimal(base_size = 12))
prior_colours <- c(`flat partial r` = "#0072B2", `flat R` = "#D55E00", `flat R-squared` = "#009E73")
prior_names <- c(
  `flat partial r` = "flat_partial_r",
  `flat R` = "flat_r",
  `flat R-squared` = "flat_r_squared"
)
set.seed(2026)
number_of_draws <- 200000


## ---- 1. One predictor: flat on r, seen on the effect-size scale ---------
## r flat from -1 to 1. The effect in noise units is f = r / sqrt(1 - r^2)
## (Cohen's f with a sign). Formula: 0.5 * (1 + f^2)^(-3/2). With one
## predictor flat partial r and flat R are both this prior; flat R-squared
## (r^2 flat) is the curve |f| / (1 + f^2)^2, which is zero at f = 0.
correlation_draws <- runif(number_of_draws, min = -1, max = 1)
signed_f_draws <- correlation_draws / sqrt(1 - correlation_draws^2)
f_values <- seq(-4, 4, by = 0.01)
shown_draws <- signed_f_draws[abs(signed_f_draws) < 4]

curves_one_predictor <- rbind(
  data.frame(
    f = f_values, density = 0.5 * (1 + f_values^2)^(-3 / 2),
    prior = "flat on r (formula)"
  ),
  data.frame(
    f = f_values, density = abs(f_values) / (1 + f_values^2)^2,
    prior = "flat on r^2 (formula)"
  ),
  data.frame(
    f = f_values, density = dcauchy(f_values, location = 0, scale = sqrt(2) / 4),
    prior = "JZS default: Cauchy, scale 0.354"
  )
)

save_doc_figure(
  ggplot() +
    geom_histogram(aes(x = shown_draws, y = after_stat(density) * mean(abs(signed_f_draws) < 4)),
      breaks = seq(-4, 4, by = 0.1), fill = "grey85", colour = "white"
    ) +
    geom_line(data = curves_one_predictor, aes(f, density, colour = prior), linewidth = 1) +
    scale_colour_manual(values = c(
      "flat on r (formula)" = "black",
      "flat on r^2 (formula)" = "#009E73",
      "JZS default: Cauchy, scale 0.354" = "grey50"
    )) +
    labs(
      x = "effect in noise units (f, signed)", y = "prior density", colour = NULL,
      title = "One predictor: a flat correlation is a heavy-tailed curve on the effect scale",
      subtitle = paste(
        "grey bars: 200,000 simulated flat correlations, transformed;",
        "nobody chose its width"
      )
    ) +
    theme(legend.position = "bottom"),
  "1_one_predictor"
)


## ---- 2. What each prior claims about the total as k grows ----------------
## Implied R-squared before any data, as predictors are added (uncorrelated
## predictors). Points: the median of draws from each prior's recipe
## (draw_coefficients_from_prior()); lines: the formula, the median of
## Beta(a, 1), 0.5^(1/a).
##  - flat partial r: a = k/2, the claim grows with k
##  - flat R: a = 1/2, and flat R-squared: a = 1, the same claim for every k
##  - JZS default (reference): Zellner-Siow, f^2 = scale^2 * chi2_k / chi2_1
numbers_of_predictors <- c(1, 2, 3, 5, 10, 20, 30)
drift_draws <- 50000
implied_r_squared <- do.call(rbind, lapply(numbers_of_predictors, function(k) {
  from_recipe <- sapply(prior_names, function(prior) {
    draws <- draw_coefficients_from_prior(drift_draws, diag(k), prior = prior)
    f_squared <- rowSums(draws^2)
    median(f_squared / (1 + f_squared))
  })
  jzs_f_squared <- (sqrt(2) / 4)^2 * rchisq(drift_draws, df = k) / rchisq(drift_draws, df = 1)
  data.frame(
    number_of_predictors = k,
    prior = c(names(prior_names), "JZS default (scale 0.354)"),
    simulated = c(from_recipe, median(jzs_f_squared / (1 + jzs_f_squared))),
    formula = c(0.5^(1 / sapply(prior_names, prior_shape, number_of_predictors = k)), NA)
  )
}))
print(implied_r_squared)

save_doc_figure(
  ggplot(implied_r_squared, aes(number_of_predictors, colour = prior)) +
    geom_line(aes(y = formula), linewidth = 1, na.rm = TRUE) +
    geom_line(
      data = subset(implied_r_squared, is.na(formula)), aes(y = simulated),
      linewidth = 1, linetype = "dashed"
    ) +
    geom_point(aes(y = simulated), size = 2) +
    scale_x_continuous(breaks = numbers_of_predictors) +
    scale_y_continuous(limits = c(0, 1)) +
    scale_colour_manual(values = c(prior_colours, "JZS default (scale 0.354)" = "grey50")) +
    labs(
      x = "number of predictors (k)", y = "median implied R-squared, before any data",
      colour = NULL,
      title = "Flat partial r claims more explained variance with every predictor",
      subtitle = paste(
        "flat R and flat R-squared keep the same claim for every k;",
        "points: draws, lines: Beta(a, 1)"
      )
    ) +
    theme(legend.position = "bottom"),
  "2_drift"
)


## ---- Check printed for doc 1 (step 3 of the share derivation) --------------
## One predictor's share of the total, z_1^2 / sum(z^2) for a uniform direction,
## against Beta(1/2, (k - 1)/2): 40,000 directions per k
set.seed(3)
for (k in c(2, 3, 5, 10)) {
  z <- matrix(rnorm(40000 * k), ncol = k)
  share <- z[, 1]^2 / rowSums(z^2)
  cat(sprintf(
    "share of the total, k = %2d: KS distance %.4f, mean %.3f (1/k = %.3f)\n", k,
    suppressWarnings(ks.test(share, "pbeta", 1 / 2, (k - 1) / 2)$statistic),
    mean(share), 1 / k
  ))
}

## ---- Check printed for appendix B (Barnard et al.'s prior) -------
## The marginally uniform prior of Barnard, McCulloch & Meng (2000): the
## correlations of an inverse-Wishart(identity, dimension + 1). Each single
## correlation is flat (their result); that R^2 of y on the k predictors is
## then Beta(k/2, 1) is checked here, 40,000 draws per k
set.seed(5)
for (k in c(1, 3, 8)) {
  dimension <- k + 1
  draws <- replicate(40000, {
    correlations <- cov2cor(solve(rWishart(1, dimension + 1, diag(dimension))[, , 1]))
    c(correlations[1, 2], 1 - 1 / solve(correlations)[1, 1])
  })
  cat(sprintf(
    "inverse-Wishart, k = %d: one correlation vs flat KS %.4f; R^2 vs Beta(k/2, 1) KS %.4f\n", k,
    suppressWarnings(ks.test(draws[1, ], "punif", -1, 1)$statistic),
    suppressWarnings(ks.test(draws[2, ], "pbeta", k / 2, 1)$statistic)
  ))
}
