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
  filter(year(week_end_date) == 2023, !is.na(x))

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






