-- Sample schema and fake data for the Clarity spending summary.
-- Mirrors the shape of Clarity's Supabase tables. No real user data.

drop table if exists transactions;
drop table if exists categories;

create table categories (
    category_id   int primary key,
    category_name text not null
);

create table transactions (
    transaction_id serial primary key,
    user_id        int            not null,
    category_id    int            references categories(category_id),
    amount         numeric(10, 2) not null,   -- AUD, from scanned receipts
    purchased_at   date           not null
);

insert into categories values
    (1, 'Groceries'),
    (2, 'Eating out'),
    (3, 'Transport'),
    (4, 'Subscriptions');

insert into transactions (user_id, category_id, amount, purchased_at) values
    (101, 1,  82.40, '2026-08-03'), (101, 1,  64.15, '2026-08-17'),
    (101, 2,  38.00, '2026-08-09'), (101, 3,  50.00, '2026-08-01'),
    (101, 4,  15.99, '2026-08-05'),
    (101, 1,  91.20, '2026-09-04'), (101, 1,  70.35, '2026-09-21'),
    (101, 2,  96.50, '2026-09-12'), (101, 2,  44.00, '2026-09-26'),
    (101, 3,  50.00, '2026-09-01'), (101, 4,  15.99, '2026-09-05'),
    (101, 4,  22.99, '2026-09-18'),
    (102, 1, 120.00, '2026-08-10'), (102, 2,  25.00, '2026-08-15'),
    (102, 1, 110.50, '2026-09-11'), (102, 2,  61.75, '2026-09-20'),
    -- edge case: a receipt the AI scan couldn't categorise
    (102, null, 18.40, '2026-09-23');
