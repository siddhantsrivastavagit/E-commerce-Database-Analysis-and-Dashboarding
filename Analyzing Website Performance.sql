/* Analyzed top website pages, top entry pages, calculated bounce rates, built conversion funnels */

select 
pageview_url,
count(distinct website_pageview_id) as views
from website_pageviews
group by 1
order by 2 desc;
/* temporary table
create temporary table first_pageview
select website_session_id,
min(website_pageview_id) as min_pv_id
from website_pageviews
group by 1;
*/
create temporary table first_pageview
select website_session_id,
min(website_pageview_id) as min_pv_id
from website_pageviews
group by 1;
select * from first_pageview;
select
count(distinct first_pageview.website_session_id),
website_pageviews.pageview_url
from first_pageview
left join website_pageviews
on first_pageview.min_pv_id = website_pageviews.website_pageview_id
group by 2;

/* S5 FINDING TOP WEBSITE PAGES */
select 
pageview_url,
count(distinct website_session_id)
from website_pageviews
where created_at < '2012-06-09'
group by 1
order by 2 desc;

/* S5 FINDING TOP ENTRY PAGES */
create temporary table abc
select 
website_session_id,
min(website_pageview_id) as mn_pv
from website_pageviews
where created_at < '2012-06-12'
group by 1;
select * from abc;
select website_pageviews.pageview_url,
count(distinct abc.website_session_id)
from abc
left join website_pageviews
on abc.mn_pv = website_pageviews.website_pageview_id
where website_pageviews.created_at < '2012-06-12'
group by 1
order by 2 desc;

/* USING THIS CODE TO MAKE A TEMPORARY TABLE IN NEXT LINE OF CODE */
select 
website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id
from website_pageviews
left join website_sessions
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 1;
create temporary table first_pageviews_demo
select 
website_pageviews.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id
from website_pageviews
left join website_sessions
on website_pageviews.website_session_id = website_sessions.website_session_id
where website_sessions.created_at between '2014-01-01' and '2014-02-01'
group by 1;
select * from first_pageviews_demo;
create temporary table landing_page_session
select first_pageviews_demo.website_session_id,
website_pageviews.pageview_url
from first_pageviews_demo
left join website_pageviews
on first_pageviews_demo.min_pv_id = website_pageviews.website_pageview_id;
select * from landing_page_session;

/* CREATING A TABLE FOR SAME IN NEXT LINE OF CODE*/
select
landing_page_session.website_session_id,
landing_page_session.pageview_url,
count(website_pageviews.website_pageview_id) as no_of_pageviews
from landing_page_session
left join website_pageviews
on landing_page_session.website_session_id = website_pageviews.website_session_id
group by 1,2
having no_of_pageviews = 1;
create temporary table bounced_sessions
select
landing_page_session.website_session_id,
landing_page_session.pageview_url,
count(website_pageviews.website_pageview_id) as no_of_pageviews
from landing_page_session
left join website_pageviews
on landing_page_session.website_session_id = website_pageviews.website_session_id
group by 1,2
having no_of_pageviews = 1;
select * from bounced_sessions;
select 
landing_page_session.website_session_id,
landing_page_session.pageview_url,
bounced_sessions.website_session_id as bounced_session_id
from landing_page_session
left join bounced_sessions
on landing_page_session.website_session_id = bounced_sessions.website_session_id
order by 1;
select 
count(distinct landing_page_session.website_session_id),
landing_page_session.pageview_url,
count(distinct bounced_sessions.website_session_id) as no_of_bounced_sessions
from landing_page_session
left join bounced_sessions
on landing_page_session.website_session_id = bounced_sessions.website_session_id
group by 2
order by 3 desc;

/* CALCULATING BOUNCE RATES */
create temporary table min_pg
select 
website_session_id,
min(website_pageview_id) as min_pv_id
from website_pageviews
where created_at < '2012-06-14'
group by 1;
select * from min_pg;
create temporary table sess_landing_pg
select 
min_pg.website_session_id,
website_pageviews.pageview_url as landing_page
from min_pg
left join website_pageviews
on min_pg.min_pv_id = website_pageviews.website_pageview_id
where website_pageviews.pageview_url = '/home';
select * from sess_landing_pg;
create temporary table bounced_sessions
select 
sess_landing_pg.website_session_id,
sess_landing_pg.landing_page,
count(website_pageviews.website_pageview_id) as no_pv
from sess_landing_pg
left join website_pageviews
on sess_landing_pg.website_session_id = website_pageviews.website_session_id
group by 1
having count(no_pv) = 1;
select * from bounced_sessions;
select 
sess_landing_pg.website_session_id,
bounced_sessions.website_session_id as bounced
from sess_landing_pg
left join bounced_sessions
on bounced_sessions.website_session_id = sess_landing_pg.website_session_id
order by 1;
select 
count(distinct sess_landing_pg.website_session_id),
count(distinct bounced_sessions.website_session_id) as bounced,
count(distinct bounced_sessions.website_session_id)/count(distinct sess_landing_pg.website_session_id) as rate
from sess_landing_pg
left join bounced_sessions
on bounced_sessions.website_session_id = sess_landing_pg.website_session_id;

/* S5 LANDUNG PAGE TREND ANALYSIS */
create temporary table min_pv
select 
website_sessions.website_session_id,
min(website_pageviews.website_pageview_id) as min_pv_id,
count(website_pageviews.website_pageview_id) ct_pv
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where website_sessions.created_at > '2012-06-01'
and website_sessions.created_at < '2012-08-31'
and website_sessions.utm_campaign = 'nonbrand'
and website_sessions.utm_source = 'gsearch'
group by 1;
select * from min_pv;
create temporary table sess_land
select 
min_pv.website_session_id,
min_pv.min_pv_id,
min_pv.ct_pv,
website_pageviews.pageview_url as landing_page,
website_pageviews.created_at as created_at
from min_pv
left join website_pageviews
on min_pv.min_pv_id = website_pageviews.website_pageview_id;
select * from sess_land
where landing_page = '/lander-1';
select 
yearweek(created_at),
min(date(created_at)) as sess_created,
count(distinct website_session_id) as dist_sess,
count(distinct case when landing_page = '/lander-1' then website_session_id else null end) as lander_1,
count(distinct case when landing_page = '/home' then website_session_id else null end) as home_pg
from sess_land
group by 1;

/* BUILDING CONVERSION FUNNELS */

select
website_sessions.website_session_id,
website_sessions.created_at,
website_pageviews.pageview_url,
case when pageview_url = '/products' then 1 else 0 end as prod_pg,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mr_pg,
case when pageview_url = 'cart' then 1 else 0 end as cart_pg
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where pageview_url in ('/lander-1','/products','/the-original-mr-fuzzy','/cart')
order by 1,2;
create temporary table mxpg
select
website_session_id,
max(prod_pg) as prpg,
max(mr_pg) as mrpg,
max(cart_pg) as ctpg
from(
select
website_sessions.website_session_id,
website_sessions.created_at,
website_pageviews.pageview_url,
case when pageview_url = '/products' then 1 else 0 end as prod_pg,
case when pageview_url = '/the-original-mr-fuzzy' then 1 else 0 end as mr_pg,
case when pageview_url = 'cart' then 1 else 0 end as cart_pg
from website_sessions
left join website_pageviews
on website_sessions.website_session_id = website_pageviews.website_session_id
where pageview_url in ('/lander-1','/products','/the-original-mr-fuzzy','/cart')
order by 1,2
)
as pg_level
group by website_session_id;
select * from mxpg;
select
count(website_session_id),
count(distinct case when prpg = '1' then website_session_id else null end) as ct_prpg,
count(distinct case when mrpg = '1' then website_session_id else null end) as ct_mrpg,
count(distinct case when ctpg = '1' then website_session_id else null end) as ct_ctpg
from mxpg;