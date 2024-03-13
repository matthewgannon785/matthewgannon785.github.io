setwd("C:/Users/matth/Documents/Advanced Bayesian")
library(readr)
library(bayesrules)
library(rstanarm)
library(bayesplot)
library(tidybayes)
library(broom.mixed)
library(dplyr)
library(ggplot2)
library(gridExtra)
library(grid)
library(AER)

bikes <- read_csv("bikes.csv")

theta_0 <- 5; sigma2 <- 9
mu_0 <- 6; kappa_0 <- 1/2
mu_1 <- 4; kappa_1 <- 1/2
myorange <- rgb(255,170,102, max = 255, alpha = 125)
myblue <- rgb(0, 0, 255, max = 255, alpha = 125)
xx <- seq(-5, 15, length = 1001)
n0 <- dnorm(xx, mean = mu_0, sd = sqrt(sigma2/ kappa_0))
n1 <- dnorm(xx, mean = mu_1, sd = sqrt(sigma2 / kappa_1))
# theta|H_0 curve
plot(xx, n0, col = "blue", lwd = 2, type = "l", axes = FALSE, xlab = "", ylab = "")
polygon(c(5, max(xx), xx[xx <= 5]), c(0, 0, n0[xx <= 5]), col = myblue) 
# c_0
lines(xx, n1, col = "orange", lwd = 2) 
# theta|H_1 curve
polygon(c(xx[xx >= 5], max(xx), 30), c(n1[xx >= 5], 0, 0), col = myorange) 
# c_1
abline(v = theta_0, lty = 2, col = "gray")
axis(1, at = c(min(xx), mu_1, theta_0, mu_0, max(xx)), labels = c(min(xx), 
expression(paste(mu[1], "= 4")), 
expression(paste(theta[0], " = 5")),
expression(paste(mu[0], " = 6")), max(xx)))
text(6, 0.05, expression(paste(N(mu[0], sigma^2/kappa[0]))))
text(6, 0.03, expression(paste(kappa[0], " = 1/2")))
text(4, 0.05, expression(paste(N(mu[1], sigma^2/kappa[1]))))
text(4, 0.03, expression(paste(kappa[1], " = 1/2")))

x <- bikes$temp
xbar <- mean(x); n <- length(x)
theta_0 <- 5; sigma2 <- 9
mu_0 <- 6; kappa_0 <- 1/2
mu_1 <- 4; kappa_1 <- 1/2
c_0 <- pnorm(theta_0, mean = mu_0, sd = sqrt(sigma2 / kappa_0))
c_1 <- pnorm(theta_0, mean = mu_1, sd = sqrt(sigma2 / kappa_1), lower.tail = FALSE)
p_data_H0 <- function(theta) { # p(data, H0)
dnorm(xbar, mean = theta, sd = sqrt(sigma2 * (1/n + 1 / (kappa_0)))) / c_0 *
dnorm(theta, mean = mu_0, sd = sqrt(sigma2 / kappa_0)) }
p_data_H1 <- function(theta) { # p(data, H1)
dnorm(xbar, mean = theta, sd = sqrt(sigma2 * (1/n + 1 / (kappa_1)))) / c_1 *
dnorm(theta, mean = mu_1, sd = sqrt(sigma2 / kappa_1)) }
p_data_given_H0 <- integrate(p_data_H0, theta_0, Inf)$value # p(data | H0)
p_data_given_H1 <- integrate(p_data_H1, -Inf, theta_0)$value # p(data | H1)
BF_10 <- p_data_given_H1 / p_data_given_H0
BF_10

Clontarf_Model_prior1 <- stan_glm(Clontarf ~ Grove_Road + Richmond_Street,
data = bikes,family = poisson, 
# same as poisson(link = "log")
prior_intercept = normal(0, 2.5), 
# prior for beta_0
prior = normal(0, 2.5, autoscale = TRUE), 
# to tune other priors
chains = 4, iter = 5000*2, seed = 8566, prior_PD = TRUE)

Clontarf_Model1 <- update(Clontarf_Model_prior1, prior_PD = FALSE)

dispersiontest(Clontarf_Model1)

Clontarf_Model_prior <- stan_glm(Clontarf ~ Grove_Road + Richmond_Street,
data = bikes,family = neg_binomial_2, 
# same as poisson(link = "log")
prior_intercept = normal(0, 2.5), 
# prior for beta_0
prior = normal(0, 2.5, autoscale = TRUE), 
prior_aux = exponential(1, autoscale = TRUE),
# to tune other priors
chains = 4, iter = 5000*2, seed = 8566, prior_PD = TRUE)

Clontarf_Model_prior$prior.info$prior$adjusted_scale
Clontarf_Model <- update(Clontarf_Model_prior, prior_PD = FALSE)

tidy(Clontarf_Model, conf.int = TRUE, conf.level = 0.95)

mcmc_trace(Clontarf_Model)

mcmc_dens_overlay(Clontarf_Model)


pp_check(Clontarf_Model)

negbin_predictions_Clontarf <- posterior_predict(Clontarf_Model, 
                                                  newdata = bikes)

p1 <- ppc_intervals(bikes$Clontarf, 
                    yrep = negbin_predictions_Clontarf,
                    x = bikes$Grove_Road,
                    prob = 0.5, prob_outer = 0.95, 
                    # 50% and 95% posterior credible intervals
                    facet_args = list(scales = "fixed"))

p2 <- ppc_intervals(bikes$Clontarf, 
                    yrep = negbin_predictions_Clontarf,
                    x = bikes$Richmond_Street,
                    prob = 0.5, prob_outer = 0.95, 
                    # 50% and 95% posterior credible intervals
                    facet_args = list(scales = "fixed"))

plot <- grid.arrange(p1,
  p2,
  nrow = 1,
  top = "PPC Intervals for Grove Road and Richmond Street",
  bottom = textGrob(
    "95% posterior credible intervals",
    gp = gpar(fontface = 3, fontsize = 9),
    hjust = 1,
    x = 1
  )
)

negbin_cv_Clontarf <- prediction_summary_cv(model = Clontarf_Model, 
                                    data = bikes, k = 10)
negbn_cv_Clontarf$cv

Cycling_Weather_Model_prior <- stan_glm(Clontarf ~ Grove_Road + 
Richmond_Street + rain + temp + wdsp + vis + clamt,
data = bikes,family = neg_binomial_2, 
# same as poisson(link = "log")
prior_intercept = normal(0, 3), 
# prior for beta_0
prior = normal(0, 3, autoscale = TRUE), 
prior_aux = exponential(1, autoscale = TRUE),
# to tune other priors
chains = 4, iter = 5000*2, seed = 8566, prior_PD = TRUE)

Cycling_Weather_Model_prior$prior.info
Cycling_Weather_Model <- update(Cycling_Weather_Model_prior, prior_PD = FALSE)
tidy(Cycling_Weather_Model, conf.int = TRUE, conf.level = 0.95)

negbin_predictions_Cycling_Weather <- posterior_predict(Cycling_Weather_Model, 
                                                 newdata = bikes)

ppc_intervals_grouped(bikes$Clontarf, 
                    yrep = negbin_predictions_Cycling_Weather,
                    x = bikes$temp,
                    group = bikes$clamt,
                    prob = 0.5, prob_outer = 0.95, 
                    # 50% and 95% posterior credible intervals
                    facet_args = list(scales = "fixed"))

# Part 4

Day_Hour_Model_prior <- stan_glm(Clontarf ~ Day + Hour,
                                        data = bikes,family = neg_binomial_2, 
                                        # same as poisson(link = "log")
                                        prior_intercept = normal(0, 3), 
                                        # prior for beta_0
                                        prior = normal(0, 3, autoscale = TRUE), 
                                        prior_aux = exponential(1, autoscale = TRUE),
                                        # to tune other priors
                                        chains = 4, iter = 5000*2, seed = 8566, prior_PD = TRUE)

Day_Hour_Model_prior$prior.info
Day_Hour_Model <- update(Day_Hour_Model_prior, prior_PD = FALSE)
tidy(Day_Hour_Model, conf.int = TRUE, conf.level = 0.95)

negbin_predictions_Day_Hour <- posterior_predict(Day_Hour_Model, newdata = bikes)

p3 <- ppc_intervals_grouped(bikes$Clontarf, 
                      yrep = negbin_predictions_Day_Hour,
                      x = bikes$Hour,
                      group = bikes$Day,
                      prob = 0.5, prob_outer = 0.95, 
                      # 50% and 95% posterior credible intervals
                      facet_args = list(scales = "fixed"))



# End
loo_1 <- loo(Clontarf_Model) 
loo_2 <- loo(Cycling_Weather_Model) 
loo_3 <- loo(Day_Hour_Model)

Comparison <- loo_compare(loo_1, loo_2, loo_3)


save(Clontarf_Model,file="Clontarf_Model.Rdata")
save(Clontarf_Model_prior,file="Clontarf_Model_prior.Rdata")
save(Clontarf_Model1,file="Clontarf_Model1.Rdata")
save(Clontarf_Model_prior1,file="Clontarf_Model_prior1.Rdata")
save(Cycling_Weather_Model,file="Cycling_Weather_Model.Rdata")
save(Cycling_Weather_Model_prior,file="Cycling_Weather_Model_prior.Rdata")
save(Day_Hour_Model,file="Day_Hour_Model.Rdata")
save(Day_Hour_Model_prior,file="Day_Hour_Model_prior.Rdata")

save(Comparison,file="Comparison.Rdata")

load(file="Clontarf_Model.Rdata")
load(file="Clontarf_Model_prior.Rdata")
load(file="Cycling_Weather_Model.Rdata")
load(file="Cycling_Weather_Model_prior.Rdata")
load(file="Day_Hour_Model.Rdata")
load(file="Day_Hour_Model_prior.Rdata")

load(file="Comparison.Rdata")
Comparison

negbin_predictions_Day_Hour

save(negbin_predictions_Day_Hour,file="negbin_predictions_Day_Hour.Rdata")
save(p2,file="p2.Rdata")

save(plot,file="plot.Rdata")
plot

gc()

library(BayesFactor)

bf <- regressionBF(Clontarf ~ Grove_Road + Richmond_Street + 
                     rain + temp + wdsp + vis + clamt + Hour, data = bikes)

bf_vs_best <- head(bf) / max(bf)
plot(bf_vs_best)

prediction_summary(model = Clontarf_Model, data = bikes)
prediction_summary(model = Cycling_Weather_Model, data = bikes)
prediction_summary(model = Day_Hour_Model, data = bikes)



?pp_check


