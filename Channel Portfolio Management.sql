/* Analyzed channel portfolios, channel portfolio trends, compared channel characteristics, did cross channel bid optimizations */ 


select
min(date(created_at)) as wk,
count(distinct website_session_id) as sess,
count(distinct case when utm_source = 'gsearch' then website_session_id else null end) as gs,
count(distinct case when utm_source = 'bsearch' then website_session_id else null end) as bs
from website_sessions
where created_at >= '2012-08-22'
group by yearweek(created_at);
create temporary table abc
select
website_session_id,
utm_source,
utm_campaign,
device_type
from website_sessions
where
utm_source in ('gsearch','bsearch')
and utm_campaign = 'nonbrand'
and device_type = 'mobile';
select * from abc;
create temporary table abd
select
website_session_id,
utm_source,
utm_campaign,
device_type
from website_sessions
where
utm_source in ('gsearch','bsearch')
and utm_campaign = 'nonbrand';
select * from abd;
select 
utm_source,
count(distinct website_session_id) as sess,
count(distinct case when device_type = 'mobile' then website_session_id else null end) as mob
from abd
group by 1;


create temporary table xy
select 
website_sessions.website_session_id,
utm_source,
device_type,
orders.order_id
from website_sessions
left join orders
on website_sessions.website_session_id = orders.website_session_id
where utm_source in ('gsearch','bsearch')
and website_sessions.created_at > '2012-08-22'
and website_sessions.created_at < '2012-09-18';
select * from xy;
select
utm_source,
device_type,
count(distinct website_session_id) as sess,
count(distinct order_id) as orde
from xy
group by 1,2;


create temporary table ax
select
website_session_id,
device_type,
utm_source,
created_at
from website_sessions
where utm_source in ('gsearch','bsearch')
and created_at < '2012-12-22';
select * from ax;
select 
min(date(created_at)) as wk,
-- count(distinct website_session_id) as sess,
count(distinct case when device_type='desktop' and utm_source='gsearch' then website_session_id else null end) as gdesk,
count(distinct case when device_type='mobile' and utm_source='gsearch' then website_session_id else null end) as gmob,
count(distinct case when device_type='desktop' and utm_source='bsearch' then website_session_id else null end) as bdesk,
count(distinct case when device_type='mobile' and utm_source='bsearch' then website_session_id else null end) as bmob
from ax
group by yearweek(created_at);


select 
year(created_at) as yr,
month(created_at) as mo,
count(distinct case when utm_campaign='nonbrand' then website_session_id else null end) as nonb,
count(distinct case when utm_campaign='brand' then website_session_id else null end) as brand,
count(distinct case when utm_campaign is null and http_referer is null then website_session_id else null end) as direct,
count(distinct case when utm_campaign is null and http_referer is not null then website_session_id else null end) as organic
from website_sessions
where created_at < '2012-12-23'
group by 1,2;