data {
  int<lower=1> N;              // 训练周数
  int<lower=0> y[N];           // 每周病例数
  vector[N] x;                 // 自变量：log(WW_{t-1} + eps)
  real x_new;                  // 用于预测 2024W01 的自变量：log(WW_{last} + eps)
}

parameters {
  real alpha;                  // 截距
  real beta;                   // 废水的弹性系数（log-log 斜率）
  real<lower=0> phi;          // 负二项离散参数（phi 越大越接近 Poisson）
}

transformed parameters {
  vector[N] mu;               // 每周病例均值（正数）
  mu = exp(alpha + beta * x);
}

model {
  // just take easy, but how can I know what prior distribution should I used.
  alpha ~ normal(0, 5);
  beta  ~ normal(0, 2);
  phi   ~ exponential(1);     // 也可用 gamma(0.01, 0.01) 更“平坦”

  // —— 观测模型：NB（mean–dispersion 参数化）——
  y ~ neg_binomial_2(mu, phi);
}

generated quantities {
  real mu_new;                // 2024W01 mean prediction
  int y_pred;                 // 2024W01 one time prediction posterior
  mu_new = exp(alpha + beta * x_new);
  y_pred = neg_binomial_2_rng(mu_new, phi);
}


