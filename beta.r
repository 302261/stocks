library(gdata)
library(bayesplot)
library(testit)
library(cmdstanr)
library(posterior)

beta_model <- "beta.stan"

# y = \alpha + \beta * x
x <- unlist(read.table("VTI.txt"))
y <- unlist(read.table("QQQ.txt"))

# This is a sanity check that x and y have the
# same length
assert("x and y have the same length", {
  N <- length(x)
  M <- length(y)
  (N == M)
})

X <- diff(log(x))[-1] # Generate returns of x
Y <- diff(log(y))[-1] # Generate returns of y
N <- length(X)

stan_data <- list(
  N = N,
  x = X,
  y = Y
)

mod <- cmdstan_model(beta_model)

# We run the simulation
fit <- mod$sample(
  data = stan_data,
  seed = 123,
  chains = 4,
  parallel_chains = 4,
  refresh = 500 # print update every 500 iters
)

# We start interpreting the simulation

fit$summary(
  variables = NULL,
  posterior::default_summary_measures(),
  extra_quantiles = ~ posterior::quantile2(., probs = c(.0275, .975))
)

fit$summary()

# We see a pretty large sigma for beta. This means that the estimation
# of beta given the data cannot be very reliable.
# One could use a non-Bayesian method but this gives no indication
# as to how reliable the statistical test is or is not.

plot(Y ~ X, pch = 20)

alpha <- fit$draws(variables = "alpha")
beta <- fit$draws(variables = "beta")

for (i in 1:500) {
  abline(alpha[i], beta[i], col = "gray", lty = 1)
}

abline(mean(alpha), mean(beta), col = 6, lw = 2)

# Plot the distribution of sharpe samples

# sharpe_samples <- fit$draws(variables = "sharpe")

# plot(density(sharpe_samples))
