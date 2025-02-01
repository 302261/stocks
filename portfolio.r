library(portfolioBacktest)

# download data from internet
stocks <- stockDataDownload(
  stock_symbols = c("VTI", "KO", "MSFT"),
  from = "2024-01-01", to = "2025-01-01"
)

# define GMVP (with heuristic not to allow shorting)
GMVP_portfolio_fun <- function(dataset, ...) {
  X <- diff(log(dataset$adjusted))[-1] # compute log returns
  Sigma <- cov(X) # compute SCM
  # design GMVP
  w <- solve(Sigma, rep(1, nrow(Sigma)))
  w <- abs(w) / sum(abs(w))
  return(w)
}

# define Markowitz mean-variance portfolio
library(CVXR)
Markowitz_portfolio_fun <- function(dataset, ...) {
  X <- diff(log(dataset$adjusted))[-1] # compute log returns
  mu <- colMeans(X) # compute mean vector
  Sigma <- cov(X) # compute the SCM
  # design mean-variance portfolio
  w <- Variable(nrow(Sigma))
  prob <- Problem(Maximize(t(mu) %*% w - 0.5 * quad_form(w, Sigma)),
    constraints = list(w >= 0, sum(w) == 1)
  )
  result <- solve(prob)
  return(as.vector(result$getValue(w)))
}

portfolios <- list(
  "GMVP"      = GMVP_portfolio_fun,
  "Markowitz" = Markowitz_portfolio_fun
)

#stocks$index <- stocks$open$VTI

bt <- portfolioBacktest(portfolios,
  dataset_list = list(stocks),
  benchmark = c("1/N"),
  execution = "next period",
  rebalance_every = 1,
  optimize_every = 1,
  lookback = 20
)

# We then plot the portfolio

backtestChartDrawdown(bt)

backtestChartCumReturn(bt)

backtestSummary(bt)
