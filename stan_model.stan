data {
  int<lower=1> N;              // trained week number(at least 1)
  int<lower=0> y[N];           // cases for each week (non-negative)
  vector[N] x;                 // independent variable：log(WW_{t-1} + eps)
  real x_new;                  // independent variable for the prediction：log(WW_{last} + eps)
}

parameters {
  real alpha;                  // basic cases 
  real beta;                   // relationship between case and wastewater（log-log）
  real<lower=0> phi;          // negative Binoimal discrete parameter（ become Poisson when phi is bigger）
}

transformed parameters {
  vector[N] mu;               // predicted cases(expectation)
  mu = exp(alpha + beta * x); //formula
}

model {
  // just take easy, but how can I know what prior distribution should I used?
  alpha ~ normal(0, 5);
  beta  ~ normal(0, 2);
  phi   ~ exponential(1);    

  // —— observed model：NB（mean–dispersion）——
  y ~ neg_binomial_2(mu, phi);
}

generated quantities {
  real mu_new;                // 2024W01 mean prediction
  int y_pred;                 // 2024W01 cases number from predicted posterior, might be median
  mu_new = exp(alpha + beta * x_new);
  y_pred = neg_binomial_2_rng(mu_new, phi);
}


