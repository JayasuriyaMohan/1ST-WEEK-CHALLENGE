A.CUSTOMER NODE EXPLORATION

1.How many unique nodes are there on the Data Bank system?

select count(distinct node_id) from customer_nodes;

2.What is the number of nodes per region?
select c.region_id,count( c.node_id), r.region_name from customer_nodes c
join regions r
on c.region_id=r.region_id
group by c.region_id
order by c.region_id
;

3.How many customers are allocated to each region?
select c.region_id,count( distinct c.customer_id), r.region_name from customer_nodes c
join regions r
on c.region_id=r.region_id
group by c.region_id
order by c.region_id
;

4.How many days on average are customers reallocated to a different node?

select avg(datediff(end_date,start_date)) from customer_nodes
WHERE end_date!='9999-12-31';


5.What is the median, 80th and 95th percentile for 
this same reallocation days metric for each region?

with rel as (select region_id,(datediff(end_date,start_date)) as reallocationdays
from customer_nodes
WHERE end_date!='9999-12-31'
order by region_id),
 per as 
(select *,
percent_rank() over (partition by region_id order by reallocationdays)*100 as per
from rel)

select * from per 
where per>95
group by region_id;

B.CUSTOMER TRANSACTION

1.What is the unique count and total amount for each transaction type?

select txn_type,count(txn_type),sum(txn_amount) from customer_transactions
group by txn_type;

select txn_type,count(txn_type),sum(txn_amount) from customer_transactions
group by txn_type;

2.What is the average total historical deposit counts and amounts for all customers?

select customer_id, count(txn_type),sum(txn_amount) from customer_transactions
where txn_type = 'deposit'
group by customer_id
order by customer_id
;

3.For each month - how many Data Bank customers make more than 1 deposit and 
either 1 purchase or 1 withdrawal in a single month?

 
 with count_ as (SELECT customer_id,
    COUNT(customer_id) AS Totalcustomer, month(txn_date) as mon,
    COUNT( IF(txn_type = 'deposit',
            customer_id,
            NULL)) AS dep,
    COUNT( IF(txn_type = 'withdrawal',
            customer_id,
            NULL)) AS withd,
    COUNT( IF(txn_type = 'purchase',
            customer_id,
            NULL)) AS pur
FROM
    customer_transactions
    group by month(txn_date),customer_id   )
    
    select count(totalcustomer),mon from count_
    where dep >1 and (withd >=1 or pur >=1)
        group by mon
        
	
        
4.What is the closing balance for each customer at the end of the month?
    
   with cte as( SELECT customer_id, txn_amount,
 COUNT(customer_id) AS Totalcustomer, month(txn_date) as mon,
    sum( IF(txn_type = 'deposit',
            txn_amount,
            NULL)) AS dep,
    sum( IF(txn_type = 'withdrawal',
            txn_amount,
            NULL))AS withd,
   sum( IF(txn_type = 'purchase',
            txn_amount,
            NULL)) AS pur
FROM
    customer_transactions
    group by month(txn_date),customer_id
    order by customer_id ),
    
    t2 as
(    
  select customer_id,mon,
  case
  when withd is null then 0
  else withd
  end as withd,
  case
  when dep is null then 0 
  else dep
  end as dep,
  case 
  when pur is null then 0
  else pur
  end as pur from cte
    group by customer_id, mon
    order by customer_id   )
    
    select customer_id,mon,dep-(withd+pur) as total_amount from t2
    
   5. What is the percentage of customers who increase their closing balance by more than 5%?
    
   with cte as( SELECT customer_id, txn_amount,
 COUNT(customer_id) AS Totalcustomer, month(txn_date) as mon,
    sum( IF(txn_type = 'deposit',
            txn_amount,
            NULL)) AS dep,
    sum( IF(txn_type = 'withdrawal',
            txn_amount,
            NULL))AS withd,
   sum( IF(txn_type = 'purchase',
            txn_amount,
            NULL)) AS pur
FROM
    customer_transactions
    group by month(txn_date),customer_id
    order by customer_id ),
    
    t2 as
(    
  select customer_id,
  case
  when withd is null then 0
  else withd
  end as withd,
  case
  when dep is null then 0 
  else dep
  end as dep,
  case 
  when pur is null then 0
  else pur
  end as pur from cte
    group by customer_id, mon
    order by customer_id    ),
    t3 as 
    
   ( select customer_id,dep-(withd+pur) as total_amount,0.05*(dep-(withd+pur)) as per
    
    from t2),
    
    t4 as 
    
   ( select customer_id, total_amount,per,
    lead(total_amount) over (partition by customer_id) as le

    from t3),
    
    
    t5 as
    
   ( select customer_id, total_amount,le+per as ler
    from t4)
    
    select 
    count(distinct customer_id)/count(case
    when total_amount< ler then 1
    else 0
    end ) 
    from t5
    
   -------------------------------------------------------------------------------- 
    
 WITH transaction_amt_cte AS
  (SELECT *,
          month(txn_date) AS txn_month,
          SUM(CASE
                  WHEN txn_type="deposit" THEN txn_amount
                  ELSE -txn_amount
              END) AS net_transaction_amt
   FROM customer_transactions
   GROUP BY customer_id,
            txn_date
   ORDER BY customer_id,
            txn_date),
      running_customer_balance_cte AS
  (SELECT customer_id,
          txn_date,
          txn_month,
          txn_type,
          txn_amount,
          sum(net_transaction_amt) over(PARTITION BY customer_id
                                        ORDER BY txn_month ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_customer_balance
   FROM transaction_amt_cte)
SELECT *
FROM running_customer_balance_cte;

 WITH transaction_amt_cte AS
  (SELECT *,
          month(txn_date) AS txn_month,
          SUM(CASE
                  WHEN txn_type="deposit" THEN txn_amount
                  ELSE -txn_amount
              END) AS net_transaction_amt
   FROM customer_transactions
   GROUP BY customer_id,
            txn_date
   ORDER BY customer_id,
            txn_date),
      running_customer_balance_cte AS
  (SELECT customer_id,
          txn_date,
          txn_month,
          txn_type,
          txn_amount,
          sum(net_transaction_amt) over(PARTITION BY customer_id
                                        ORDER BY txn_month ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW) AS running_customer_balance
   FROM transaction_amt_cte),
      month_end_balance_cte AS
  (SELECT *,
          last_value(running_customer_balance) over(PARTITION BY customer_id, txn_month
                                                    ORDER BY txn_month) AS month_end_balance
   FROM running_customer_balance_cte
   GROUP BY customer_id,
            txn_month)
SELECT customer_id,
       txn_month,
       month_end_balance
FROM month_end_balance_cte;
    
    
    with t1 as (select customer_id, month(txn_date) as tax_mon,txn_type,
    (case when txn_type='deposit' then txn_amount
    else -txn_amount
    end )as txn_amount from customer_transactions),
    
    t2 as 
    
 (select customer_id,tax_mon,txn_type,
sum(txn_amount) over(partition by customer_id order by tax_mon ROWS BETWEEN UNBOUNDED preceding AND CURRENT ROW )as x
 from t1
 group by customer_id)
 
 select *,
 last_value(x) over (partition by tax_mon,customer_id order by tax_mon  )as lastvalue
 from t2
 group by customer_id,tax_mon;
 
 
 
    
    