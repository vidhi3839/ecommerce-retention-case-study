# Phase 3: Statistical Validation

## Significance Tests

**New vs. Returning Users — Conversion Rate**
Chi-square: 3164.23, p < 0.000001. Highly significant. New users convert
at 0.68% (95% CI: 0.65%–0.71%); returning users convert at 3.10% (95% CI:
2.99%–3.21%) — non-overlapping intervals confirm this is a real, large
effect, not sampling noise.

**New vs. Returning Users — Average Order Value**
Order value distribution is right-skewed for both groups (mean > median,
long tail up to $904 new / $1,530 returning), so Mann-Whitney U was used
instead of a t-test. Result: p = 0.000003, statistically significant.
Median AOV: $50 (new) vs. $55 (returning). Returning users spend more
per order in addition to converting more often.

**Device (Mobile vs. Desktop)**
Chi-square: 3.79, p = 0.051. Not significant at the conventional 5%
threshold, though borderline. Given the practical gap between segments
is under 2 percentage points even before this test, device is not
treated as a meaningful driver of the funnel diagnosis.

**Geography (20 countries)**
Chi-square: 22.37, p = 0.266, dof = 19. Not significant. Cleanly rules
out geography as a driver — consistent with the flat rates observed in
Phase 2.

## Updated Diagnosis Inputs
- New vs. returning user status is the only segment variable that is
  both statistically significant and practically large.
- The gap holds on two separate metrics: conversion rate (4.6x) and
  order value (Mann-Whitney confirmed, ~10% higher median for
  returning users).
- Device and geography are statistically ruled out; no further
  segmentation work needed on these dimensions.

## Visualizations Produced
- `funnel_chart.png` — session counts by funnel step
- `new_vs_returning_chart.png` — conversion rate comparison
- `aov_distribution.png` — order value distribution by user type