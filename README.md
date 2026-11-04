# Clarity: monthly spending summary (SQL)

The SQL behind the monthly spending view in [Clarity](https://clarityapp.company), my AI personal finance app. It turns individual receipt transactions into a monthly total per user per category, compares each month with the one before using a window function, and flags categories where spend jumped by more than 50%. Those flags drive the app's overspending alerts.

## Files

| File | What it does |
| --- | --- |
| `schema_and_sample_data.sql` | Creates the `transactions` and `categories` tables and loads fake sample data (no real users) |
| `monthly_spend_by_category.sql` | The summary query, plus a check that the totals reconcile |

## How the query works

1. **Join and aggregate.** A `LEFT JOIN` from transactions to categories, so a receipt the AI scan couldn't categorise still counts (as "Uncategorised") instead of silently disappearing. Spend is then summed by user, category and month.
2. **Compare to last month.** `LAG()` over each user and category, ordered by month, pulls in the previous month's spend for the change in dollars and percent. `NULLIF` avoids dividing by zero.
3. **Flag overspending.** `overspend_alert` is true when spend is more than 1.5 times the previous month.
4. **Reconcile.** A final check confirms the summary adds back to the raw transaction total, so nothing was lost or double-counted in the join.

## Sample output

| user_id | category | month | total_spend | prev_month_spend | change_pct | overspend_alert |
| --- | --- | --- | --- | --- | --- | --- |
| 101 | Eating out | 2026-09-01 | 140.50 | 38.00 | 269.7 | true |
| 101 | Groceries | 2026-09-01 | 161.55 | 146.55 | 10.2 | false |
| 101 | Subscriptions | 2026-09-01 | 38.98 | 15.99 | 143.8 | true |
| 102 | Uncategorised | 2026-09-01 | 18.40 | | | |

Reconciliation: raw total $977.22 = summary total $977.22.

## Run it

Written for PostgreSQL (Supabase). Paste `schema_and_sample_data.sql` into any Postgres database or the Supabase SQL Editor, then run `monthly_spend_by_category.sql`.
