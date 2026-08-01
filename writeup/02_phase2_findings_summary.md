# Phase 2 Findings Summary

## Funnel Overview (corrected)
Total sessions with a page_view: 333,683. Strict step-order funnel:

| Step | Sessions | Conversion from prior step |
|---|---|---|
| page_view | 333,683 | — |
| view_item | 74,563 | 22.35% |
| add_to_cart | 12,349 | 16.56% |
| begin_checkout | 4,221 | 34.18% |
| purchase | 2,176 | 51.55% |

Overall page_view → purchase conversion: 0.65%.

The two steps with the most actionable leakage (late-funnel, high-intent
users) are add_to_cart → begin_checkout (65.8% of cart-adders never start
checkout) and begin_checkout → purchase (48.5% of checkout-starters
abandon). The early-funnel drops (page_view → view_item → add_to_cart)
are treated as expected top-of-funnel browsing behavior, not a problem
to fix.

## Segment Findings

**New vs. returning users — primary signal.**
Returning users convert far better overall (4.22% vs. 0.68%), and the
gap concentrates specifically at checkout: new users convert
checkout-to-purchase at 41.24% vs. 63.44% for returning users. Returning
users are ~27% of sessions but ~63% of all purchases.

**Device (mobile/desktop/tablet) — ruled out.**
Checkout-to-purchase and overall conversion are flat across all three
categories (43–45% and ~1.4–1.5% respectively). No meaningful device
effect observed. To be confirmed statistically in Phase 3 (chi-square).

**Geography — ruled out.**
Conversion rate is flat (roughly 1.2–1.7%) across all countries with
meaningful session volume. Outliers (Indonesia, Japan) have low sample
sizes and are treated as noise pending Phase 3 statistical confirmation.

**Checkout abandonment persistence.**
Of users who ever start checkout, 54.51% never complete a purchase
within the dataset's 3-month window — abandonment appears largely
permanent, not just delayed.

## Data Quality / Methodology Notes
- No refund/return events exist in this dataset — refund rate dropped
  as a guardrail metric in favor of checkout abandonment rate (see
  `01_problem_framing.md`).
- geo.country is NULL in <1% of rows; no `<Other>` placeholder inflation
  observed in top segments.
- An early version of `01_funnel.sql` and `01c_funnel_by_user_type.sql`
  checked each funnel step against the immediately prior event's
  timestamp only, without requiring all earlier steps to have been
  reached in sequence. This allowed step-skipping sessions to inflate
  later-step counts, producing an impossible checkout-to-purchase rate
  of 114.79% in the user-type split. Fixed by chaining each step's
  "reached" flag to require every prior step. All numbers in this
  summary reflect the corrected queries.

## What Carries Forward to Phase 3
- Test new vs. returning conversion difference for statistical
  significance (chi-square)
- Test device and geography differences for statistical significance
  (chi-square) — confirm "ruled out" isn't just eyeballing
  small-percentage gaps
- Pull order value data (not yet touched) for AOV comparison across
  new vs. returning and any segment that survives the significance
  tests (t-test)
- Visualize the funnel (bar or Sankey) and the new-vs-returning gap