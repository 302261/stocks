data {
  int<lower=0> N;
  vector[N] x;
  vector[N] y;
}

parameters {
  real alpha;
  real beta;
  real<lower=0> sigma;

  real x_mu;
  real<lower=0.0001> x_var;
}

transformed parameters {
  real sharpe = sqrt(N) * x_mu / x_var; 
}

model {

  alpha ~ normal(0, 0.1);
  beta ~ normal(0, 3);
  sigma ~ exponential(1);

  y ~ normal(alpha + beta * x, sigma);

  x ~ normal(x_mu, x_var); 

}

