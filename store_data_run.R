library(readr)
library(dplyr)
library(lubridate)

# 1) read data
ww <- read_csv("ww_site.csv")       # expect cols：week_end_date, SampleLocation, copies_per_person_per_day
cases <- read_csv("cases_site.csv") # expect cols：week_end_date, SampleLocation, cases

# 2) select one site
site_id <- "AU_Rosedale"
ww_site <- ww %>% filter(SampleLocation == site_id)
cases_site <- cases %>% filter(SampleLocation == site_id)

# 3) combine and sort by week
dat <- ww_site %>%
  select(week_end_date, ww = copies_per_person_per_day) %>%
  inner_join(
    cases_site %>% select(week_end_date, y = cases),
    by = "week_end_date"
  ) %>%
  mutate(week_end_date = ymd(week_end_date)) %>%
  arrange(week_end_date)

# 4)construct "last week wastewater" as independent variable(delay one week), take log
eps <- 1e-3
dat <- dat %>%
  mutate(ww_lag1 = lag(ww, 1),
         x = log(ww_lag1 + eps)) %>%
  # train 2023 and delete first week since no delay
  filter(year(week_end_date) == 2023, !is.na(x)) #create dataframe and delete NA value

# 5) contrust the data for stan
stan_data <- list(
  N = nrow(dat),      # week number
  y = dat$y,          # case vector (length n)
  x = dat$x,          # explain variable（log(last week WW+eps)）
  eps = eps
)

# prepare for 2024 week 1 #
# need the last week of wastewater value for prediction
last_row <- ww_site %>% mutate(week_end_date = ymd(week_end_date)) %>% arrange(week_end_date) %>% tail(1)
x_new <- log(last_row$copies_per_person_per_day + eps)

stan_newdata <- list(
  x_new = as.array(x_new)  # y_pred of generated quantities in Stan
)


## Run stan

library(rstan)

rstan_options(auto_write = TRUE)
options(mc.cores = parallel::detectCores())

# 1) stan model
mod <- stan_model("nb_minimal.stan")

# 2) combine data（在你上一步的脚本里已准备好 stan_data 和 x_new）
stan_data2 <- within(stan_data, { x_new <- as.numeric(stan_newdata$x_new) })

# 3) sampling
fit <- sampling(
  mod, data = stan_data2,
  iter = 2000, warmup = 1000, chains = 4, seed = 123
)

print(fit, pars = c("alpha","beta","phi","mu_new","y_pred"), probs = c(0.025, 0.5, 0.975))

# 4) 2024W01 posterior 
post <- rstan::extract(fit)
mu_new_draws <- post$mu_new         # the contious mean of posterior sample
y_pred_draws <- post$y_pred         # discrete cases of posterior sample

# point estimate and interval
pred_median <- median(y_pred_draws)
pred_ci <- quantile(y_pred_draws, c(0.025, 0.975))
cat("2024W01 predict median）=", pred_median,
    "  95% interval=[", pred_ci[1], ", ", pred_ci[2], "]\n")



