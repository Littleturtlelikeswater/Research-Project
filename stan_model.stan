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
  // —— 弱信息先验（可按需调整）——
  alpha ~ normal(0, 5);
  beta  ~ normal(0, 2);
  phi   ~ exponential(1);     // 也可用 gamma(0.01, 0.01) 更“平坦”

  // —— 观测模型：NB（mean–dispersion 参数化）——
  y ~ neg_binomial_2(mu, phi);
}

generated quantities {
  real mu_new;                // 2024W01 的均值预测
  int y_pred;                 // 2024W01 的单次后验预测（整数）
  mu_new = exp(alpha + beta * x_new);
  y_pred = neg_binomial_2_rng(mu_new, phi);
}



library(rstan)

# 一次性推荐设置（加速编译与采样）
rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 1) 编译 Stan 模型
mod <- stan_model("nb_minimal.stan")

# 2) 组合数据（在你上一步的脚本里已准备好 stan_data 和 x_new）
stan_data2 <- within(stan_data, { x_new <- as.numeric(stan_newdata$x_new) })

# 3) 采样
fit <- sampling(
  mod, data = stan_data2,
  iter = 2000, warmup = 1000, chains = 4, seed = 123
)

print(fit, pars = c("alpha","beta","phi","mu_new","y_pred"), probs = c(0.025, 0.5, 0.975))

# 4) 拿到 2024W01 的后验预测
post <- rstan::extract(fit)
mu_new_draws <- post$mu_new         # 连续均值的后验样本
y_pred_draws <- post$y_pred         # 离散病例数的后验样本

# 点预测与区间
pred_median <- median(y_pred_draws)
pred_ci <- quantile(y_pred_draws, c(0.025, 0.975))
cat("2024W01 预测（中位数）=", pred_median,
    "  95%区间=[", pred_ci[1], ", ", pred_ci[2], "]\n")
