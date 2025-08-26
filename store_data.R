library(readr)
library(dplyr)
library(lubridate)

# 1) 读取数据（路径替换为你的实际路径）
ww <- read_csv("ww_site.csv")       # 期望列：week_end_date, SampleLocation, copies_per_person_per_day
cases <- read_csv("cases_site.csv") # 期望列：week_end_date, SampleLocation, cases

# 2) 选择一个站点（如果你只有一个站点，这步可以跳过）
# 举例：把 AU_Rosedale 换成你要建模的具体 SampleLocation
site_id <- "AU_Rosedale"
ww_site <- ww %>% filter(SampleLocation == site_id)
cases_site <- cases %>% filter(SampleLocation == site_id)

# 3) 合并、按周排序
dat <- ww_site %>%
  select(week_end_date, ww = copies_per_person_per_day) %>%
  inner_join(
    cases_site %>% select(week_end_date, y = cases),
    by = "week_end_date"
  ) %>%
  mutate(week_end_date = ymd(week_end_date)) %>%
  arrange(week_end_date)

# 4) 构造 “上一周废水” 作为自变量（滞后1周），并取 log
eps <- 1e-3
dat <- dat %>%
  mutate(ww_lag1 = lag(ww, 1),
         x = log(ww_lag1 + eps)) %>%
  # 2023 作为训练（丢弃第一周因没有滞后）
  filter(year(week_end_date) == 2023, !is.na(x))

# 5) 构造给 Stan 的数据 list
stan_data <- list(
  N = nrow(dat),      # 训练周数
  y = dat$y,          # 病例向量（长度 N）
  x = dat$x,          # 解释变量（log(上周WW+eps)）
  eps = eps
)

# —— 为预测准备 2024W01 —— #
# 需要 2023 最后一周（或 2024W01 前一周）的废水值
last_row <- ww_site %>% mutate(week_end_date = ymd(week_end_date)) %>% arrange(week_end_date) %>% tail(1)
x_new <- log(last_row$copies_per_person_per_day + eps)

stan_newdata <- list(
  x_new = as.array(x_new)  # 用于在 Stan 的 generated quantities 里产生 y_pred
)

# 可选：快速过度离散检查（粗略）
m <- mean(stan_data$y); v <- var(stan_data$y)
cat("训练集均值=", m, " 方差=", v, "  方差/均值=", v/m, "\n")
# 如果 方差/均值 明显 > 1，NB 通常优于 Poisson




