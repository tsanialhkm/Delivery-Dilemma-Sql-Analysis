# The Delivery Dilemma

### E-Commerce Delivery Performance and Operational Prioritization

A SQL-based business analysis of late deliveries using real, anonymized Olist transactions. The project examines the size of the delivery problem, regional trade-offs, process durations, and the evidence needed before selecting an operational intervention.

**Tools:** SQLite · SQLTools · VS Code  
**Scope:** Orders purchased from January through June 2018  
**Decision:** Prioritize targeted investigation before committing to a large-scale operational change

## Executive summary

Of **40,270 eligible delivered orders**, **3,477 arrived after their estimated delivery date**, a late rate of **8.63%**. Among late orders, **47.25% arrived more than seven calendar days after the promised date**.

Regional analysis revealed an important prioritization trade-off. Ceará (CE) and Alagoas (AL) had late rates of approximately 25%, making them candidates for a reliability-focused investigation. However, Rio de Janeiro (RJ) and São Paulo (SP) together accounted for **45.84% of all late orders**, despite SP's much lower late rate.

In the subset with complete, chronologically consistent process timestamps, the largest difference between late and on-time orders occurred between carrier handover and customer receipt: **29.81 versus 8.38 days on average**. This identifies an interval for further investigation, not proof that a carrier caused the delays.

The recommendation is to investigate the selected regions and obtain tracking, carrier, route, failure-reason, and cost data before choosing a limited pilot. No intervention was implemented, and no savings, uplift, or causal effect is claimed.

## Business context

Ponte Commerce is a fictional marketplace used to frame this educational case. Its simulated stakeholders disagree about whether delivery problems require tighter seller controls, changes to logistics operations, or more realistic delivery estimates.

The underlying records are real Olist data. The company name, stakeholder statements, and decision request are simulated; they do not describe an actual consulting engagement with Olist.

### Business questions

1. How should lateness and the eligible population be defined?
2. How should incomplete records and inconsistent timestamps be treated?
3. How frequent and severe are late deliveries?
4. Which regions merit attention when rate, volume, and severity are considered together?
5. Which process interval warrants further investigation?
6. What can customer reviews indicate, and what are the limits of that evidence?
7. What action can be recommended without overstating the available evidence?

## Data and analytical scope

Source: [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce), published by Olist and collaborators, covering transactions from 2016–2018.

The case database retains nine source tables and **99,441 orders**. The main analysis uses:

| Table | Analytical role | Grain considerations |
|---|---|---|
| `orders` | Status, promised date, and recorded process timestamps | One order per row in the supplied database |
| `customers` | Destination state | Join using `customer_id`; `customer_unique_id` identifies customers across purchases |
| `order_reviews` | Review scores and response timestamps | More than one review can exist for an order |

Other supplied tables cover items, sellers, products, payments, geolocation, and category translation. They were not required for the reported baseline and process findings.

Purchase timestamp determines inclusion: `>= '2018-01-01'` and `< '2018-07-01'`. Delivery outcomes are evaluated retrospectively using the available history. This is **not** a snapshot of what was known on June 30, 2018.

## KPI definitions

| Metric | Definition |
|---|---|
| Eligible order | Order purchased in scope, with status `delivered` and parseable actual and estimated delivery dates |
| Late order | Actual delivery calendar date is later than estimated delivery calendar date |
| Late rate | Late eligible orders ÷ all eligible orders × 100 |
| Late days | Actual delivery date minus estimated delivery date, in calendar days |
| Average late days | Mean late days among late orders only |
| Regional late contribution | Late orders in a state ÷ all late orders × 100 |

Delivery on the estimated calendar date is classified as on time, even if the actual timestamp is later than midnight. This is an explicit date-level interpretation of the delivery promise, not a verified contractual SLA.

Comparing actual delivery time against the average promised lead time would answer a different question and is not used to classify lateness.

## Findings

### 1. Delivery baseline and severity

| Measure | Result |
|---|---:|
| Eligible delivered orders | 40,270 |
| On-time orders | 36,793 |
| Late orders | 3,477 |
| Late rate | 8.63% |

| Days late | Orders | Share of late orders |
|---|---:|---:|
| 1–3 | 886 | 25.48% |
| 4–7 | 948 | 27.26% |
| More than 7 | 1,643 | 47.25% |

Nearly half of the late orders fell into the most severe bucket. This supports examining severity alongside the overall late rate. Displayed percentages may not sum to exactly 100% because of rounding.

### 2. Regional prioritization

Selected states illustrate the trade-off between service reliability and absolute impact:

| State | Eligible orders | Late orders | Late rate | Average late days |
|---|---:|---:|---:|---:|
| CE | 494 | 120 | 24.29% | 14.68 |
| AL | 160 | 40 | 25.00% | 8.18 |
| RJ | 4,923 | 812 | 16.49% | 14.95 |
| SP | 17,453 | 782 | 4.48% | 8.86 |

**Proposed investigation candidates: CE and AL**, reflecting a reliability-first objective. This is not a claim that they offer the highest financial return or the largest possible reduction in late-order counts. CE also has a more severe average delay than AL.

RJ and SP remain important under a volume-first objective: their combined 1,594 late orders represent 45.84% of the total. A universal late-rate threshold would overlook substantial absolute impact in SP.

Acre (AC) recorded only one late order out of 20 eligible orders. Its 31-day average lateness therefore describes one event, not a well-established recurring pattern. The event merits attention, but does not by itself justify a regional intervention.

### 3. Process-duration comparison

This analysis requires complete, parseable timestamps in the order purchase → approval → carrier handover → customer receipt sequence.

| Process interval | On-time orders | Late orders | Difference in displayed means |
|---|---:|---:|---:|
| Purchase → approval | 0.39 days | 0.47 days | +0.08 days |
| Approval → carrier | 2.57 days | 4.45 days | +1.88 days |
| Carrier → customer | 8.38 days | 29.81 days | +21.43 days |

The sample includes **36,186 on-time** and **3,466 late orders**, totaling **39,652**. These are pooled results across all states, not CE/AL-specific findings.

The carrier-to-customer interval is the main candidate for investigation. It can include transport, hub processing, failed delivery attempts, and recording issues. Route characteristics and the delivery promise may also affect the comparison. Because groups are defined by the final delivery outcome, longer elapsed time is descriptive evidence, not an independent causal test.

### 4. Customer reviews: exploratory evidence only

The initial analysis found lower average review scores in more severely delayed groups. However, validation identified **16 late orders with two reviews** and **68 late orders without a review**.

A direct `LEFT JOIN` produced **3,493 rows from 3,477 late orders**. The initial score averages were therefore weighted by review rows, not equally by order. There was also no on-time comparison group or completed review-timing analysis.

**Review findings are not treated as final evidence of customer impact and are not used to justify the intervention.** A revised one-review-per-order method has been proposed, but its output was not included in the reviewed results. Follow-up work should report review coverage, include on-time orders, document the selection rule, and distinguish responses before and after receipt. Even then, an observed relationship would not establish causality.

## Data quality and reconciliation

| Step | Orders | Treatment |
|---|---:|---|
| Purchased in scope, all statuses | 41,187 | Starting population |
| Status other than delivered | 914 | Excluded from delivered-only KPI; not assumed on time or erroneous |
| Delivered | 40,273 | Candidate delivered population |
| Delivered with missing actual delivery date | 3 | Excluded because lateness cannot be calculated |
| Eligible for delivery KPI | 40,270 | Baseline denominator |
| Approval recorded after carrier handover | 618 | Excluded from the complete-sequence process comparison only |
| Eligible for process comparison | 39,652 | Separate, stricter denominator |

The 618 process exclusions comprise **607 on-time and 11 late orders**, explaining the change from 3,477 baseline late orders to 3,466 in the process analysis. Records were filtered for the relevant calculation, not deleted from the source.

Validation also confirmed that the customer join preserves the baseline count, and that late-order totals reconcile across the baseline, detailed late-order list, severity buckets, and state results.

Using exact timestamps rather than calendar dates would classify 531 additional baseline orders as late because they arrived on the estimated date after midnight. This demonstrates why an explicit metric definition is necessary.

## Recommendation and decision boundaries

**Proceed with targeted operational investigation. Do not yet commit to a carrier replacement, seller penalty, or network-wide change.**

1. Confirm whether the pooled process pattern also appears within CE and AL, including its consistency by month.
2. Ask Operations for carrier/service identifiers, origin–destination routes, package tracking events, failed-attempt reasons, and investigation/intervention costs.
3. Select a limited pilot only after that evidence identifies an actionable issue.

| Option to evaluate | Evidence needed before selection | Main risk | How to evaluate success |
|---|---|---|---|
| Proactive escalation of packages at risk of missing the promise | Tracking availability, actionable stagnation signals, owner and capacity | More handling cost without faster delivery | Lower late rate and >7-day late share, with handling cost tracked |
| Route-specific delivery-estimate recalibration | Actual transit distribution, promise history, and customer-facing estimate rules | A better late KPI without faster delivery; possible conversion loss | Promise accuracy alongside actual delivery duration and conversion |
| Continue monitoring while collecting evidence | Defined owner, questions, and review checkpoint | Delaying useful action | Resolve specified evidence gaps and revisit the pilot decision |

Targets such as a late rate below 10% or 5% are **proposals**, not validated forecasts or established company SLAs. Operational feasibility and costs must be assessed before setting a commitment.

A pilot should define its eligible population, owner, observation period, comparison group where feasible, and decision rules in advance. A simple before/after change alone would not isolate the intervention from seasonality or changes in order mix.

## Limitations

- The late rate applies to delivered orders with usable dates, not all purchases. Non-delivered and canceled orders require separate service metrics.
- Estimated delivery dates are interpreted at calendar-date level; historical promise revisions are unavailable.
- Averages may be sensitive to extreme values. Median and tail-duration checks remain follow-up work.
- Process results exclude inconsistent sequences and may not represent the excluded orders.
- No carrier identifier, detailed tracking, internal cost, margin, or randomized intervention data is available in the case database.
- No causal impact, financial return, or implemented improvement has been demonstrated.

## Reproduce the analysis

1. Open the project folder in VS Code.
2. Connect SQLTools with its SQLite driver to `data/ponte_case_003.db`.
3. Open `sql/02_my_analysis.sql` and run one selected statement at a time.
4. Match the relevant outputs to the findings above. The file also contains early exploratory queries that are not used as final KPI definitions.

The reviewed `review_pack_v2.zip` contains query copies, result exports, and a review summary. Inside that archive:

| Evidence | Query / result ID |
|---|---|
| Delivery baseline | Original 017 |
| Late-order detail | Original 018 |
| Severity | Original 019 |
| Regional analysis | Original 020 |
| Process durations | Original 021 |
| Exploratory review calculation | Original 023 |
| Status and missing-date reconciliation | Diagnostic 024 |
| Process exclusions | Diagnostic 025 |
| Customer join validation | Diagnostic 026 |
| Review multiplicity | Diagnostic 027 |
| Date versus timestamp comparison | Diagnostic 028 |

Query and result numbers correspond within the archive. Diagnostics are separately labeled and were added with Codex assistance; they do not replace the original queries. The revised review-selection proposal is not claimed as an executed result.

Supporting case files include `START_HERE.md`, `DATA_DICTIONARY.md`, and the SQL files under `sql/`. The investigation and closure templates are working documents, not additional evidence of completed analysis.

## Skills applied and lessons learned

- SQL joins, CTEs, conditional aggregation, window averages, and date functions.
- KPI definition, denominator validation, and population reconciliation.
- Regional segmentation using frequency, volume, and severity.
- Process-duration analysis and cautious attribution.
- Recognition of one-to-many joins and review coverage limitations.
- Business recommendations that separate verified findings, hypotheses, and proposed actions.

This is a mentored portfolio project by **Tsani Fauzan Alhakim**. AI assistance was used for SQL guidance, validation/export diagnostics, and documentation. Business recommendations describe a simulated decision, not a measured client outcome.

## Source and attribution

Data: **Olist, Brazilian E-Commerce Public Dataset by Olist**.  
Official dataset: https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce  
Data license: [CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/).

The SQLite case adaptation retains the source records, shortens table names, converts blank fields to SQL NULL, types numeric measures, and adds indexes. Preserve source attribution and the applicable license when redistributing derived data; this README does not grant commercial-use permission.

Portfolio: https://tsanialhkm.github.io
