## Objective 

- Use **weekly data from 2023** as training, and **predict the number of cases in the first week of 2024**.  
- To enable prediction for 2024W01, we let the expected cases depend on the **previous week’s wastewater signal** (lag of 1 week).  
  This way, the wastewater level from 2023W52 can be used to predict cases in 2024W01.  

---

## Minimal statistical model (no splines or weekday effects)

- **Observation distribution**: Negative Binomial (allows overdispersion)  

$$
Y_t \sim \text{NegBinomial}_2(\mu_t, \phi)
$$

- **Link function** (commonly used for count data):  

$$
\log \mu_t = \alpha + \beta \ \log(\text{WW}_{t-1} + \varepsilon)
$$

### Explanation of terms

- $\(Y_t\)$: weekly cases at time $\(t\)$  
- $\(\text{WW}_{t-1}\)$: wastewater measurement from the previous week (e.g., *copies_per_person_per_day*)   
- $\(\alpha, \beta\)$: alpha is basic number of cases and Beta is the strength of relationship between wastewaster and case
- $\(\phi\)$: dispersion parameter, where $\(\phi \to \infty\)$ approaches Poisson  
- $\(\varepsilon\)$: small constant to avoid $\(\log 0\)$, e.g., $\(10^{-3}\)$  
