What is the unique number of visits by all users per month?
SELECT U.USER_ID,count(E.VISIT_ID),E.COOKIE_ID,month(E.event_time) FROM clique_bait.users U
 JOIN clique_bait.events E 
 ON E.COOKIE_ID=U.COOKIE_ID
 group by month(E.event_time),U.USER_ID
 order by u.user_id;

What is the number of events for each event type?

select count(event_type) from event_identifier
group by event_name;

What is the percentage of visits which have a purchase event?

with t1 as ( select count(event_type) as totalcount,
count(if(event_type=3,event_type,null))as purchase_count from events)

select (purchase_count*100)/totalcount as purcahse_perc from t1;

What is the percentage of visits which view the checkout page but do not have a purchase event?
with t1 as ( select count(event_type) as totalcount,
count(if(event_type!=3 and page_id=12 ,page_id,null))as purchase_count from events)

select (purchase_count*100)/totalcount as purcahse_perc from t1;

What are the top 3 pages by number of views?
select page_id,count(visit_id) from events
group by page_id
order by count(visit_id) desc
limit 3 ;

What is the number of views and cart adds for each product category?
select page_id,count(visit_id) from events
where event_type=2
group by page_id
order by page_id;

What are the top 3 products by purchases?
select page_id,count(page_id) from events
where event_type=3
group by visit_id
order by count(visit_id) desc;

with t1 as (select visit_id,page_id,event_type,
row_number() over (partition by visit_id order by sequence_number) as row_nu,
lead (event_type) over (partition by visit_id order by sequence_number) as lead1,
event_type-lead (event_type) over (partition by visit_id order by sequence_number) as diff 
from events) ,
 t2 as (
select page_id,count(page_id) from t1
where diff = -1 and event_type!=4
group by page_id,visit_id) 
select page_id,count(page_id) as total_purchases from t2 
group by page_id
order by total_purchases desc 
limit 3;
                       3. Product Funnel Analysis
                       
How many times was each product viewed?
select count(page_id),page_id from events
where page_id !=  1 AND 
page_id !=  2 AND
page_id != 12 AND 
page_id !=  13 AND
EVENT_TYPE = 1
GROUP BY PAGE_ID
ORDER BY PAGE_ID;


How many times was each product added to cart?
select count(page_id),page_id from events
where page_id !=  1 AND 
page_id !=  2 AND
page_id != 12 AND 
page_id !=  13 AND
EVENT_TYPE = 2 
GROUP BY PAGE_ID
ORDER BY PAGE_ID;

How many times was each product added to a cart but not purchased (abandoned)?

select page_id,
count(event_type=2)  from events
where page_id !=12 
group by page_id;

How many times was each product purchased?

with t1 as (select visit_id,page_id,event_type,
row_number() over (partition by visit_id order by sequence_number) as row_nu,
lead (event_type) over (partition by visit_id order by sequence_number) as lead1,
event_type-lead (event_type) over (partition by visit_id order by sequence_number) as diff 
from events) ,
 t2 as (
select page_id,count(page_id) from t1
where diff = -1 and event_type!=4
group by page_id,visit_id) 
select page_id,count(page_id) as total_purchases from t2 
group by page_id
order by page_id ;

Which product had the most views, cart adds and purchases?










What is the average conversion rate from view to cart add?

with t1 as   (  select visit_id,page_id,event_type,event_time,
row_number() over (partition by visit_id order by sequence_number) as row_nu,
lead (event_type) over (partition by visit_id order by sequence_number) as lead1,
event_type-lead (event_type) over (partition by visit_id order by sequence_number) as diff,
 lead (event_time) over (partition by visit_id order by sequence_number) as lead_time
from events  )

select page_id,avg( timediff(lead_time,event_time)) from t1
where diff = -1 and event_type!=4
group by page_id
order by page_id;

What is the average conversion rate from cart add to purchase?


with t1 as   (  select visit_id,page_id,event_type,event_time,
row_number() over (partition by visit_id order by sequence_number) as row_nu,
lead (event_type) over (partition by visit_id order by sequence_number) as lead1,
event_type-lead (event_type) over (partition by visit_id order by sequence_number) as diff,
 lag (event_time) over (partition by visit_id order by sequence_number) as lead_time
from events  )

select event_type,avg( timediff(event_time,lead_time)) from t1
where event_type=2 and event_type=3
group by event_type
order by event_type;


drop table if exists campaign_identifier_new;
  CREATE TABLE campaign_identifier_new (
      campaign_id INTEGER,
      product_id VARCHAR(3),
      campaign_name VARCHAR(33),
      start_date TIMESTAMP,
      end_date TIMESTAMP
    );
    
    INSERT INTO campaign_identifier_new
      (campaign_id,product_id, campaign_name, start_date, end_date)
    VALUES
      ('1', '1', 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
      ('1', '2', 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
      ('1', '3', 'BOGOF - Fishing For Compliments', '2020-01-01', '2020-01-14'),
      ('2', '4', '25% Off - Living The Lux Life', '2020-01-15', '2020-01-28'),
        ('2', '5', '25% Off - Living The Lux Life', '2020-01-15', '2020-01-28'),
      ('3', '6', 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31'),
      ('3', '7', 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31'),
      ('3', '8', 'Half Off - Treat Your Shellf(ish)', '2020-02-01', '2020-03-31');
      
      select * from campaign_identifier_new;
      
      with t1 as (select e.visit_id,e.page_id,p.product_id,p.page_name,e.event_type,e.cookie_id,
      first_value(e.event_time) over(partition by e.visit_id order by e.event_time) as visit_start_time from events e
      join page_hierarchy p 
      on e.page_id=p.page_id) , t2 as (
      
      
      select *, c.campaign_name,c.start_date,c.end_date
 from t1
      join  campaign_identifier_new c
      on t1.product_id =c.product_id
      order  by t1.visit_id,t1.page_id   ) , t3 as
      (select *,
	
      (case when t2.visit_start_time  between  t2.start_date and t2.end_date then t2.campaign_name
      else 'no_offer'
      end )  as x  from t2    ) , t4 as(
      
     
     Select *, u.user_id from users u 
Join t3 
On u.cookie_id= t3.cookie_id  )

Select t4.user_id,t4.visit_id,t4.event_start_time,t4.product_id,
count(if(t4.event_type=1,t4.event_type,null)) as page_views,
count(if(t4.event_type=2,t4.event_type,null)) as cart_views,
count(if(t4.event_type=3,t4.event_type,null)) as purchase_views,
count(if(t4.event_type=4,t4.event_type,null)) as impression_views,
count(if(t4.event_type=5,t4.event_type,null)) as ad_views, t4.campaign_name from t4 
Group by t4.visit_id  ;  



 with t1 as (select e.visit_id,e.page_id,p.product_id,p.page_name,e.event_type,e.cookie_id,
      first_value(e.event_time) over(partition by e.visit_id order by e.event_time) as visit_start_time from events e
      join page_hierarchy p 
      on e.page_id=p.page_id ) 
      
      
      
      
      
      
        with t1 as (select e.visit_id,e.page_id,p.product_id,p.page_name,e.event_type,e.cookie_id,
      first_value(e.event_time) over(partition by e.visit_id order by e.event_time) as visit_start_time from events e
      join page_hierarchy p 
      on e.page_id=p.page_id) ,
      t2 as (
      select c.start_date,c.end_date,c.campaign_name,
t1.visit_id,t1.page_id,t1.product_id,t1.page_name,t1.event_type,t1.cookie_id,t1.visit_start_time
 from  campaign_identifier_new c
      join  t1
      on c.product_id =t1.product_id
      order  by t1.visit_id,t1.page_id   ) ,
      t3 as
      (select *,
	
      (case when t2.visit_start_time  between  t2.start_date and t2.end_date then t2.campaign_name
      else 'no_offer'
      end )  as x  from t2    ) 
      
      Select u.user_id,t3.visit_id,t3.product_id,
count(if(t3.event_type=1,t3.event_type,null)) as page_views,
count(if(t3.event_type=2,t3.event_type,null)) as cart_views,
count(if(t3.event_type=3,t3.event_type,null)) as purchase_views,
count(if(t3.event_type=4,t3.event_type,null)) as impression_views,
count(if(t3.event_type=5,t3.event_type,null)) as ad_views, t3.campaign_name 
  from users u 
Join t3 
On u.cookie_id= t3.cookie_id
Group by t3.visit_id;

      
     


Select u.user_id,t3.visit_id,t3.event_start_time,t3.product_id,
count(if(t4.event_type=1,t4.event_type,null)) as page_views,
count(if(t4.event_type=2,t4.event_type,null)) as cart_views,
count(if(t4.event_type=3,t4.event_type,null)) as purchase_views,
count(if(t4.event_type=4,t4.event_type,null)) as impression_views,
count(if(t4.event_type=5,t4.event_type,null)) as ad_views, t4.campaign_name 
 u.user_id from users u 
Join t3 
On u.cookie_id= t3.cookie_id
Group by t4.visit_id;

      


