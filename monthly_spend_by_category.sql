-- Monthly spend per user per category, with month-over-month change.
-- Feeds Clarity's overspending alerts: flags a category when spend rises
-- more than 50% on the previous month.

with monthly as (
    select
        t.user_id,
        coalesce(c.category_name, 'Uncategorised')  as category,   -- keep unscanned receipts visible
        date_trunc('month', t.purchased_at)::date    as month,
        sum(t.amount)                                as total_spend,
        count(*)                                     as num_transactions
    from transactions t
    left join categories c on c.category_id = t.category_id         -- left join so nothing drops out
    group by 1, 2, 3
),

with_change as (
    select
        *,
        lag(total_spend) over (
            partition by user_id, category
            order by month
        ) as prev_month_spend
    from monthly
)

select
    user_id,
    category,
    month,
    total_spend,
    num_transactions,
    prev_month_spend,
    total_spend - prev_month_spend                                     as change_aud,
    round(100.0 * (total_spend - prev_month_spend)
          / nullif(prev_month_spend, 0), 1)                            as change_pct,
    (total_spend > 1.5 * prev_month_spend)                             as overspend_alert
from with_change
order by user_id, month, category;


-- Check: category totals must add back to the raw transaction total,
-- so nothing was lost or double-counted in the joins.
select
    (select sum(amount) from transactions)                    as raw_total,
    (select sum(total_spend) from (
        select sum(t.amount) as total_spend
        from transactions t
        left join categories c on c.category_id = t.category_id
        group by t.user_id, c.category_name, date_trunc('month', t.purchased_at)
    ) s)                                                       as summary_total;
