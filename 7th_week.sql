                 High Level Sales Analysis
1.What was the total quantity sold for all products?

Select sum(s.qty), d.product_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
 group by d.product_name;

2.What is the total generated revenue for all products before discounts?

Select sum(s.qty*s.price), d.product_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
where s.discount= 0
 group by d.product_name
 ;

3.What was the total discount amount for all products?

Select sum((s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) as discount_amt, d.product_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
where s.discount!= 0
 group by d.product_name
 
     Transaction Analysis
1.How many unique transactions were there?
select count(distinct txn_id) from sales

2.What is the average unique products purchased in each transaction?
select txn_id,round(avg(distinct prod_id)) from sales
group by txn_id

3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?

with t1 as (select txn_id,(qty*price)-(qty*price*discount*0.01) as discount_amt from sales),
t2 as 

(select txn_id,discount_amt,
percent_rank() over(partition by txn_id order by discount_amt)*100 as per from t1)
select * from t2
where per=25
group by txn_id;

with t1 as (select txn_id,(qty*price)-(qty*price*discount*0.01) as discount_amt from sales),
t2 as 

(select txn_id,discount_amt,
percent_rank() over(partition by txn_id order by discount_amt)*100 as per from t1)
select * from t2
where per=50
group by txn_id;

with t1 as (select txn_id,(qty*price)-(qty*price*discount*0.01) as discount_amt from sales),
t2 as 

(select txn_id,discount_amt,
percent_rank() over(partition by txn_id order by discount_amt)*100 as per from t1)
select * from t2
where per=75
group by txn_id;

4.What is the average discount value per transaction?
select txn_id,avg((qty*price)-(qty*price*discount*0.01)) as discount_amt from sales
group by txn_id;

5.What is the percentage split of all transactions for members vs non-members?
with t1 as (select *,(qty*price)-(qty*price*discount*0.01) as discount_amt from sales),
t2 as (
select sum(discount_amt) as total_amt,
sum(if(member1='t',discount_amt,null)) as members,
sum(if(member1='f',discount_amt,null)) as non_members from t1)
Select members*100/total_amt as members_percentage,
 non_members*100/total_amt as non_members_percentage from t2;
 
 6.What is the average revenue for member transactions and non-member transactions?
select member1,avg((qty*price)-(qty*price*discount*0.01)) as discount_amt from sales
group by member1

                                   Product Analysis
1.What are the top 3 products by total revenue before discount?
Select sum(s.qty*s.price) as total_amt, d.product_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
where s.discount= 0
 group by d.product_name
 order by total_amt desc
 limit 3;

2.What is the total quantity, revenue and discount for each segment?

Select sum(s.qty),s.discount,sum(s.qty*s.price) as revenue,sum((s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) as discount_amt, 
d.product_name,d.segment_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
group by d.segment_name ;

3.What is the top selling product for each segment?


With t1 as (Select d.product_name,sum(s.qty),s.discount,sum(s.qty*s.price) as revenue,
sum((s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) as discount_amt, 
d.segment_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
group by d.segment_name,d.product_name
order by segment_name),
T2 as 

(Select *, 
dense_rank() over(partition by segment_name order by discount_amt desc) as rank1 from t1)

select* from t2 
Where rank1=1;

4.What is the total quantity, revenue and discount for each category?

Select sum(s.qty) as total_quantity,s.discount,sum(s.qty*s.price) as revenue,sum((s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) as discount_amt, 
d.category_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
group by d.category_name ;

5.What is the top selling product for each category?

With t1 as ( Select d.category_name,d.product_name,sum(s.qty),s.discount,sum(s.qty*s.price) as revenue,
sum((s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) as discount_amt, 
d.segment_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
group by d.category_name,d.product_name
order by segment_name
),
T2 as 

(Select *, 
dense_rank() over(partition by category_name order by discount_amt desc) as rank1 from t1)

select* from t2 
Where rank1=1;

6.What is the percentage split of revenue by product for each segment?
    
With t1 as (Select d.category_name,d.product_name,s.discount,sum(s.qty*s.price) as revenue,
sum(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.segment_name,
 SUM(sum(s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) OVER (PARTITION BY d.segment_name ) total_sales 
 from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id   
group by d.segment_name ,d.product_name
order by d.segment_name)

Select *, discount_amt*100/total_sales as percentage from t1;

  
  
  
  7.What is the percentage split of revenue by segment for each category?
  
  
 
 
 With t1 as (Select d.category_name,d.product_name,s.discount,sum(s.qty*s.price) as revenue,
sum(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.segment_name,
 SUM(sum(s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) OVER (PARTITION BY  d.category_name  ) total_sales 
 from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id   
group by d.segment_name , d.category_name
order by d.segment_name)

Select *, discount_amt*100/total_sales as percentage from t1;
 
 8.What is the percentage split of total revenue by category?
 
 with t1 as (Select sum(s.qty) as total_quantity,s.discount,sum(s.qty*s.price) as revenue,
  sum((s.qty*s.price)-(s.qty*s.price*s.discount*0.01)) as discount_amt, 
d.category_name from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
group by d.category_name),
 t2 as (
select sum(discount_amt) as total_amt,
sum(if(category_name='womens',discount_amt,null)) as women,
sum(if(category_name='mens',discount_amt,null)) as men from t1)
Select women*100/total_amt as women,
 men*100/total_amt as men from t2;
 
 9.What is the total transaction “penetration” for each product? 
 (hint: penetration = number of transactions
 where at least 1 quantity of a product was purchased divided by total number of transactions)
 
 Select (s.qty),s.discount,(s.qty*s.price) as revenue,(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.product_name,d.segment_name,s.txn_id, 
count(s.txn_id) OVER (PARTITION BY  s.txn_id ) as counts,
 s.qty/count(s.txn_id) OVER (PARTITION BY  s.txn_id ) as penetration
from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id

With t1 as (Select (s.qty),s.discount,(s.qty*s.price) as revenue,(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.product_name,d.segment_name,s.txn_id, 
count(s.txn_id) OVER (PARTITION BY  s.txn_id ) as counts,
 s.qty/count(s.txn_id) OVER (PARTITION BY  s.txn_id ) as penetration
from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id)

Select *, sum(penetration) as total_transaction from t1
Group by product_name;

10.What is the most common combination of 
at least 1 quantity of any 3 products in a 1 single transaction?

Select (s.qty),s.discount,(s.qty*s.price) as revenue,(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.product_name,d.segment_name,d.product_id,s.txn_id 
from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
order by s.txn_id,d.product_id


Select distinct(p.id),(s.qty),s.discount,(s.qty*s.price) as revenue,
(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.product_name,d.segment_name,d.product_id,s.txn_id 
from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
Join balanced_tree.product_prices p
On p.product_id=s.prod_id
order by s.txn_id,p.id


With t1 as (Select distinct(p.id),(s.qty),s.discount,(s.qty*s.price) as revenue,
(s.qty*s.price)-(s.qty*s.price*s.discount*0.01) as discount_amt, 
d.product_name,d.segment_name,d.product_id,s.txn_id 
from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
Join balanced_tree.product_prices p
On p.product_id=s.prod_id
order by s.txn_id,p.id)

Select *,
count(id) from t1
group by id
order by count(id) desc
limit 3


  REPORT CHALLENGE
  Select (s.qty*s.price) as total_amt, d.product_name, MONTHNAME(S.START_TXN_TIME) from  balanced_tree.product_details d
Join balanced_tree.sales s
On d.product_id=s.prod_id
where s.discount= 0
 order by total_amt desc
 limit 3;
 
 
 
Select h.id,h.parent_id,h.level_text,h.level_name,p.price from product_hierarchy h
Join balanced_tree.product_prices p
On h.id=p.id