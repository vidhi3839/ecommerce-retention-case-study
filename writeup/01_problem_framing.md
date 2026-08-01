# Problem Framing

## Problem Statement

Users move through a defined purchase funnel — page view → item view → add to
cart → begin checkout → purchase — and a significant share drop off before
completing a purchase. This analysis identifies the step in the funnel where
drop-off is largest, whether that drop-off is concentrated in specific
segments (device, traffic source/acquisition channel, geography), and
diagnoses the most likely product-level cause. The output is a specific,
testable product recommendation — validated through a designed A/B test —
aimed at improving conversion at the identified step, rather than a general
observation about funnel shape.

## Why This Framing

Considered an alternative framing centered on repeat purchase rate / retention
cohorts. Rejected it for this dataset specifically: cohort-based retention
analysis needs enough users to survive from a first purchase through to a
second purchase across multiple weeks, which is a much smaller and riskier
slice of a sample dataset than session-level funnel behavior. Funnel analysis
produces statistically meaningful drop-off rates from a much shorter time
window and larger event volume, while still exercising the same core skills:
segmentation, SQL aggregation, statistical testing, and experiment design.
Chose the framing with lower data risk without giving up analytical depth.

## Primary Metric

**Funnel-step conversion rate**

Definition: Of sessions that reach step N in the funnel (page_view → 
view_item → add_to_cart → begin_checkout → purchase), what percentage reach
step N+1? Reported both as step-over-step rates and as overall
session-to-purchase rate.

Scoping decisions:
- **Session-level, not user-level.** A funnel is a within-session behavior
  question. A user who abandons on one visit and purchases on a later visit
  is a return-visit pattern, not funnel drop-off, and is out of scope here.
- **Strict step order required.** A session must hit funnel steps in
  sequence to count as progressing. Will cross-check against an any-order
  definition in Phase 2/3 and flag in the writeup if the two diverge
  meaningfully.

## Guardrail / Secondary Metrics

1. **Average Order Value (AOV)** — guards against conversion gains that come
   from smaller, lower-margin transactions (e.g. if removing checkout steps
   also removes an upsell opportunity).
2. **Checkout abandonment rate** (reached begin_checkout, never reached
   purchase) — leading indicator. Confirmed via Phase 2 data-quality query
   (`00_data_quality_check.sql`, part 2) that no refund/return events exist
   in this dataset, ruling out "refund rate" as a usable guardrail. Checkout
   abandonment rate replaces it as the metric most directly tied to the
   diagnosis: 54.5% of users who ever start checkout never complete a
   purchase within the dataset's 3-month window (see
   `05_repeat_purchase_behavior.sql`).
3. **Session duration** — stability guardrail. A conversion spike paired
   with collapsing session duration on checkout pages would suggest users
   are rushing through without reading key information (e.g. shipping,
   returns), a risk that wouldn't show up in conversion rate alone.
4. **New vs. returning user split of the drop-off** — required segmentation
   cut, not a guardrail metric. Needed to distinguish a UX/trust problem
   (concentrated in first-time visitors) from a functional friction problem
   (concentrated in returning visitors), since these imply different
   product fixes.

## Known Data Limitations

- Funnel-defining events (what counts as begin_checkout vs. a page view of
  the checkout page) depend on how the site's own GA4 implementation tagged
  events, which is not auditable from the sample data alone.
- Before trusting funnel numbers, validated event counts and confirmed
  timestamps are strictly increasing within each user session as a basic
  sanity check (see `sql/06_data_quality_check.sql`).
- "New user" is defined at the session level (`ga_session_number = 1`), not
  lifetime level — a user could have visited before the dataset's 3-month
  window began and still register as "new" here. Findings about new-user
  behavior should be read as "first observed session in this window," not
  "first-ever visit."

## Planned Output

1. Funnel query with step-over-step drop-off %
2. Segmentation by device, traffic source, geography
3. Diagnosis: which step + which segment shows the largest, most actionable
   drop-off
4. One specific product recommendation tied to that finding
5. A/B test design to validate the recommendation, using the real baseline
   conversion rate from this analysis as the power-analysis input