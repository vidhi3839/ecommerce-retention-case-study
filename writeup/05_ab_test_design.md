# Phase 5: A/B Test Design

## Hypothesis
Adding guest checkout, trust signals, and a post-purchase account prompt
to the checkout flow will increase checkout-to-purchase rate among new
users, compared to the current flow.

Null hypothesis (H0): There is no difference in checkout-to-purchase rate
between the new checkout flow and the current flow for new users.
Alternative hypothesis (H1): The new checkout flow increases
checkout-to-purchase rate for new users.

## Primary Metric
Checkout-to-purchase rate, new-user sessions only. Real baseline: 41.24%
(from Phase 2 analysis, `01c_funnel_by_user_type.sql`).

## Guardrail Metrics
- Average order value (new users) — guards against the new flow
  attracting lower-intent, lower-value purchases.
- Post-purchase account creation rate — new metric specific to this
  test. Validates the Phase 4 mitigation (moving account creation to
  after purchase) actually preserves a path into the higher-value
  returning-user segment, rather than just assuming it does.
- Overall session-to-purchase rate (new users) — stability check to
  confirm no negative impact on earlier funnel steps.

## Power Analysis
Two-proportion z-test, alpha = 0.05 (two-sided), power = 80%, baseline
= 41.24% (real data, not assumed). Sample size required scales strongly
with the minimum detectable effect (MDE):

| MDE (absolute) | New rate to detect | Sample size per arm | Total sample | Est. duration* |
|---|---|---|---|---|
| 3 pts | 44.24% | 4,268 | 8,536 | ~347 days |
| 5 pts | 46.24% | 1,544 | 3,088 | ~125 days |
| 7 pts | 48.24% | 791 | 1,582 | ~64 days |
| 10 pts | 51.24% | 390 | 780 | ~32 days |

*Duration estimated against actual new-user checkout-start volume:
2,260 new-user sessions reached begin_checkout over the 92-day dataset
window (~24.6 checkout-starts/day).

**Selected: 7-point MDE (41.24% -> 48.24%, ~17% relative lift), ~9-week
test duration.** Chosen as the smallest effect size detectable within a
reasonable test window, given real new-user checkout traffic. Smaller
MDEs (3-5 pts) would require 4-12 months of runtime, which is not
practical for a single test cycle.

## Significance Level and Duration
- Significance level (alpha): 0.05, two-sided
- Power: 80%
- MDE: 7 percentage points absolute
- Sample size: ~791 new-user checkout-starts per arm (~1,582 total)
- Estimated duration: ~9 weeks
- Randomization unit: session, new-user sessions only, randomized at
  first checkout entry

## Decision Criteria
- **Ship**: primary metric shows statistically significant improvement
  (p < 0.05) AND no statistically significant AOV regression AND
  post-purchase account creation rate exceeds 15%.
- **No-ship**: primary metric does not reach significance by 9 weeks,
  or any guardrail regresses significantly even if the primary metric
  improves.
- **Extend**: primary metric trend is directionally positive but has
  not yet reached significance at the planned end date — do not stop
  early on a promising but non-significant trend.

## Simulation Note
A simulated two-arm z-test (assumed 7-point effect size, not observed
data) was run to validate test mechanics ahead of a real rollout. See
`notebooks/phase5_ab_simulation.ipynb`. Simulation output: z = 3.434,
p = 0.0006, confirming the test design correctly detects a 7-point
effect at the planned sample size (n=791/arm). All simulated numbers
are labeled as such and are not derived from the GA4 dataset.