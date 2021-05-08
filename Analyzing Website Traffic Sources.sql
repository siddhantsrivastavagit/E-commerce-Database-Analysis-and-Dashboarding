use mavenfuzzyfactory;
/* Found top traffic sources and their conversion rates, did bid optimizaiton and trend analysis */

select 
distinct utm_content,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct order_id) as orders,
count(distinct order_id)/count(distinct website_sessions.website_session_id) as orders_per_session
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
group by utm_content
order by orders_per_session desc;
select 
utm_source,
utm_campaign,
http_referer,
count(distinct website_session_id)
from website_sessions
where created_at < '2012-04-12'
group by
utm_source,
utm_campaign,
http_referer
order by 
count(distinct website_session_id) desc;
select
count( distinct website_sessions.website_session_id),
count( distinct orders.order_id),
count( distinct orders.order_id) / count( distinct website_sessions.website_session_id) as ratio 
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-04-14'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand';
select
year(created_at),
week(created_at),
count(distinct (website_session_id))
from website_sessions
group by 1,2
order by 3 desc;
select 
primary_product_id,
order_id,
items_purchased,
case when items_purchased = 1 then order_id else null end as single_item_order,
case when items_purchased = 2 then order_id else null end as two_item_order
from orders
where order_id between 31000 and 32000;
select 
primary_product_id,
order_id,
items_purchased,
count(distinct case when items_purchased = 1 then order_id else null end) as single_item_order,
count(distinct case when items_purchased = 2 then order_id else null end) as two_item_order
from orders
where order_id between 31000 and 32000
group by 1,2,3;

/* S4 TRAFFIC SOURCE TRENDING */
select 
week(created_at),
year(created_at),
count(distinct website_session_id) as sessions,
min(date(created_at)) as week_start
from website_sessions
where created_at < '2012-05-10'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 1,2;
select 
count(distinct website_session_id) as sessions,
min(date(created_at)) as week_start
from website_sessions
where created_at < '2012-05-10'
and utm_source = 'gsearch'
and utm_campaign = 'nonbrand'
group by 
week(created_at),
year(created_at);

/* S4 BID OPTIMIZATION FOR PAID TRAFFIC*/
select
device_type,
count(distinct website_sessions.website_session_id) as sessions,
count(distinct orders.order_id) as order_made,
count(distinct orders.order_id) / count(distinct website_sessions.website_session_id) as orders_per_session
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where website_sessions.created_at < '2012-05-11'
and utm_campaign = 'nonbrand'
and utm_source = 'gsearch'
group by 1;

/*S4 TRENDING W/ GRANULAR SEGMENTS */
select
min(date(created_at)) as week_start,
count(distinct case when device_type = 'mobile' then website_session_id else null end) as mobile_sessions,
count(distinct case when device_type = 'desktop' then website_session_id else null end) as desktop_sessions
from website_sessions
where utm_campaign = 'nonbrand'
and utm_source = 'gsearch'
and created_at > '2012-04-15'
and created_at < '2012-06-09'
group by
week(created_at),
year(created_at);
