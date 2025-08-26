# Research-Project
Waste-water COVID-19 surveillance  

## Research Objective

- **Weekly prediction** → Detect outbreak signals.  
- **Monthly prediction** → Analyze long-term trends and validate model robustness.  

My research goal is to **first conduct weekly forecasts** and then **perform monthly forecasts for comparison**, in order to demonstrate the predictive capability of wastewater → cases at different temporal scales.  

# Comparison of Prediction Horizons: Weekly vs. Monthly

## 1. Predicting Weekly Case Numbers

### 👍 Advantages
- **Aligned with wastewater sampling frequency**: Most sites are sampled once or twice per week, making the weekly horizon a natural fit.  
- **Captures rapid changes**: Weekly predictions can reflect sudden rises or drops in community infection levels more quickly.  
- **Supports public health interventions**: Short-term forecasts are useful for operational decisions such as increasing testing sites or implementing temporary restrictions.  

### 👎 Disadvantages
- **High variability**: Weekly case data may be affected by reporting delays, holidays, or daily fluctuations, leading to larger prediction errors.  
- **Lower signal-to-noise ratio**: Short-term noise can mask the underlying trend.  

---

## 2. Predicting Monthly Case Numbers

### 👍 Advantages
- **Smoother trends**: Aggregating four weeks of data reduces noise and produces more stable trends.  
- **Reduced error**: While short-term predictions are more volatile, long-term aggregation averages out random fluctuations.  
- **Useful for long-term insights**: Monthly forecasts are better suited for analyzing variant replacement, seasonality, or long-term transmission dynamics.  

### 👎 Disadvantages
- **Slower response**: Monthly predictions cannot provide timely alerts for sudden outbreaks.  
- **Less actionable for real-time policy**: Public health agencies often need faster forecasts than a one-month lag.  

---

## 3. Recommendation

- **Short-term monitoring and early warning** → Weekly predictions are more practical.  
- **Long-term trend analysis** → Monthly predictions are more stable and informative.  
- For comprehensive analysis, it is advisable to **use both**:  
  - Weekly forecasts to detect outbreaks.  
  - Monthly forecasts to assess broader epidemic trends and validate model robustness.  

