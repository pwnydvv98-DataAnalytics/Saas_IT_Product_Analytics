--- 1 Table Creation 

--- 1 User_clean table
create table users_clean(
User_ID INT primary key,
Signup_Date date not null,
Plan varchar(50) not null,
Country varchar(100) not null,
Device varchar(50) not null);

--- 2 Campaigns_Clean table 
create table campaigns_clean(
Campaign_ID varchar(50) primary key,
Campaign_Name varchar(100) not null,
Channel varchar(50) not null,
Budget_USD decimal(12,2) not null); 

--- 3 features_clean table
create table features_clean (
Feature_ID varchar(50) primary key,
Feature_Name Varchar(100) not null,
Category varchar(50) not null,
Minimum_Plan varchar(50) not null);

--- 4 Subscription_clean table 
create table subscriptions_clean(
Subscription_ID int primary key,
User_ID int not null,
Plan varchar(50) not null,
Start_Date date not null,
End_Date date not null,
Monthly_Revenue decimal(10,2) not null default 0.00,
constraint fk_sub_user foreign key (User_ID) references users_clean(User_ID));

--- 5 session_clean table
create table session_clean (
Session_ID int primary key,
User_ID int not null,
Session_Date date not null,
Duration_Seconds decimal(10,2) not null,
Pages_Viewed int not null,
Campaign_ID varchar(50),
constraint fk_sess_user foreign key (User_ID) references users_clean(User_ID));

--- 6 Payment_Clean table
create table payment_clean (
Payment_ID int primary key,
Subscription_ID int not null,
User_ID int not null,
Payment_Date date not null,
Amount_USD decimal(10,2) not null,
Status varchar(50) not null,
constraint fk_pay_sub foreign key (Subscription_ID) references subscriptions_clean(Subscription_ID),
constraint fk_pay_user foreign key (User_ID) references users_clean(User_ID));

--- 7 event_clean table
create table event_clean (
Event_ID int primary key,
User_ID int not null,
Event_Date date not null,
Event_Type varchar(50) not null,
Session_ID int not null,
constraint fk_event_user foreign key (User_ID) references users_clean(User_ID));

--- 8 Support_clean table
create table support_clean (
Ticket_ID int primary key,
User_ID int not null,
Create_Date date not null,
Resolved_Date date,
Priority varchar(20) not null,
Status Varchar(20) not null,
constraint fk_ticket_user foreign key (User_ID) references users_clean(User_ID));

--- 2  Data load

--- 1 load user_clean
set global local_infile = 1;
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/users_clean.csv"
into table users_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

--- 2 load campaigns_clean
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/campaigns_clean.csv"
into table campaigns_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

--- 3 load features_clean
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/features_clean.csv"
into table features_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

--- 4 load subscription_clean
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/subscriptions_clean.csv"
into table subscriptions_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(Subscription_ID,User_ID,Plan,Start_Date,@v_end_date,Monthly_Revenue)
set End_Date = nullif(@v_end_date,'');

--- 5 load session_clean table 
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/sessions_clean.csv"
into table session_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

--- 6 Load payment table
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/payment_clean.csv"
into table payment_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;

--- 7 load event table 
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/event_clean.csv"
into table event_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\r\n'
ignore 1 rows
(Event_ID,User_ID,Event_Date,Event_Type,@v_session_id)
set Session_ID =  nullif(@v_session_id,'');

--- 8 load support table 
load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/saas/support_clean.csv"
into table support_clean
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows
(Ticket_ID,User_ID,Create_Date,@v_resol_date,Priority,Status)
set Resolved_Date = nullif(@v_resol_date,'');

--- 3 count rows
select count(*) from campaigns_clean;
select count(*) from event_clean;
select count(*) from features_clean;
select count(*) from payment_clean;
select count(*) from session_clean;
select count(*) from subscriptions_clean;
select count(*) from support_clean;
select count(*) from users_clean;

--- 4 create index 
create index idx_event_user_date on event_clean(User_ID,Event_Date);
create index idx_session_user_date on session_clean(User_ID,Session_Date);
create index idx_subs_user_dates on subscriptions_clean(User_ID,Start_Date,End_Date);
create index idx_payment_status_dates on payment_clean(Status,Payment_Date);
create index idx_tickets_user_status on support_clean(User_ID,Status,Create_Date);

--- 5 KPI analysis
--- 5.1 Daily Active Users, Monthly Active Users, Stickiness Ratio
with daily_active as (
	select 
		Event_Date,
        count(distinct User_ID) as DAU
	from event_clean group by Event_Date
),
monthly_active as (
	select 
		date_format(Event_Date,'%Y-%m') as Year_Months,
        count(distinct User_ID) as MAU
	from event_clean group by date_format(Event_Date,'%Y-%m')
)
select 
	d.Event_Date,
    d.DAU,
    m.MAU,
    round((d.DAU/m.MAU)*100,2) as Stickiness_pct
from daily_active d
join monthly_active m
on date_format(d.Event_Date,'%Y-%m')=m.year_months 
order by d.Event_Date;

--- 5.2 Feature Adoption by Plan Tier
select 
	u.Plan,
    e.Event_Type,
    count(e.Event_ID) as Total_Interactions,
    count(distinct e.User_ID) as Unique_Users,
    round(Count(e.Event_ID)*1.0/ count(distinct e.User_ID),1) as Avg_Events_Per_Users
from event_clean e 
join users_clean u 
on e.User_ID=u.User_ID
group by u.Plan,e.Event_Type order by u.Plan,Total_Interactions desc;

--- 6 Financial & Revenue 
-- 6.1 Monthly Recurring Revenue & Annual Recurring Revenue
with recursive months as (
select '2023-01-01' as month_start
union all 
select date_add(month_start,interval 1 month) from Months
where month_start < '2025-12-01')
select 
	date_format(m.month_start,'%Y-%m') as Year_Months,
    count(distinct s.User_ID) as Active_Paying_Users,
    sum(s.Monthly_Revenue) as Total_MRR_USD,
    sum(s.Monthly_Revenue) *12 as Project_ARR_USD,
    round(sum(s.Monthly_Revenue)/count(distinct s.User_ID),2) as ARPU_USD
from months m 
join subscriptions_clean s 
on s.Start_Date <= LAST_DAY(m.month_start)
and (s.End_Date is null or s.End_Date >= m.month_start)
where s.Monthly_Revenue > 0
group by m.month_start order by m.month_start;

--- 6.2 Payment Success vs Failure & Refund Analysis
select 
	date_format(Payment_Date,'%Y-%m') as Payment_Month,
    count(Payment_ID) as Total_Transactions,
    sum(case when Status = 'Success' then Amount_USD else 0 end) as Collected_Revenue_USD,
    sum(case when Status = 'Failed' then Amount_USD else 0 end) as Failed_Revenue_USD,
    sum(case when Status = 'Refunded' then Amount_USD else 0 end) as Refunded_Revenue_USD,
    round((sum(case when Status = 'Success' then 1 else 0 end)*100.0)/count(Payment_ID),2)as Payment_Success_Rate_Pct
from payment_clean
group by date_format(Payment_Date,'%Y-%m') order by Payment_Month;

--- checking the Status Column
select Status,count(*) as Total_count from payment_clean group by Status;

--- other option 
SELECT 
    DATE_FORMAT(Payment_Date, '%Y-%m') AS Payment_Month,
    COUNT(Payment_ID) AS Total_Transactions,
    SUM(CASE 
        WHEN TRIM(REPLACE(Status, '\r', '')) = 'Success' 
        THEN Amount_USD ELSE 0 
    END) AS Collected_Revenue_USD,
    SUM(CASE 
        WHEN TRIM(REPLACE(Status, '\r', '')) = 'Failed' 
        THEN Amount_USD ELSE 0 
    END) AS Failed_Revenue_USD,
    SUM(CASE 
        WHEN TRIM(REPLACE(Status, '\r', '')) = 'Refunded' 
        THEN Amount_USD ELSE 0 
    END) AS Refunded_Revenue_USD,
    ROUND(
        (SUM(CASE 
            WHEN TRIM(REPLACE(Status, '\r', '')) = 'Success' 
            THEN 1 ELSE 0 
        END) * 100.0) / COUNT(Payment_ID), 
        2
    ) AS Payment_Success_Rate_Pct
FROM payment_clean
GROUP BY DATE_FORMAT(Payment_Date, '%Y-%m')
ORDER BY Payment_Month;

--- fix the Characters
SET SQL_SAFE_UPDATES = 0;
UPDATE payment_clean
SET Status = TRIM(REPLACE(Status, '\r', ''));
SET SQL_SAFE_UPDATES = 1;

--- 7 Subscriber Churn Rate & Customer Lifetime Value
--- 7.1 Monthly Subscriber Churn Rate
with recursive Months as (
select '2023-02-01' as month_start
union all 
select date_add(month_start,interval 1 month)
from months 
where month_start <'2025-11-01'),
monthly_metrics as (
select 
	m.month_start,
    count(distinct case when s.Start_Date < m.month_start and (s.End_Date is null or s.End_Date >= m.month_start)
    and s.Monthly_Revenue > 0 then s.Subscription_ID end) as Active_Start_Count,
    count(distinct case when s.End_Date >= m.month_start and s.End_Date <= LAST_DAY(m.month_start)
    and s.Monthly_Revenue > 0
    then s.Subscription_ID end) as Churned_Count
from months m 
join subscriptions_clean s 
	on s.Start_Date <= LAST_DAY(m.month_start)
group by m.month_start)
select 
	date_format(month_start,'%Y-%m') as Calendar_Month,
    Active_Start_Count,
    Churned_Count,
    round((Churned_Count * 100.0)/nullif(Active_Start_Count,0),2) as Monthly_Churn_Rate_Pct
from monthly_metrics order by Calendar_Month;

--- 7.2 Customer Lifetime Value & Duration by Plan
select 
	Plan,
    count(Subscription_ID) as Total_Subscriptions,
    round(avg(Datediff(coalesce(End_Date,'2025-12-31'),Start_Date)),0) as Avg_Tenure_Days,
    round(avg(Datediff(coalesce(End_Date,'2025-12-31'),Start_Date))/30.4,1) as Avg_Tenure_Months,
    round(avg(Monthly_Revenue * (Datediff(coalesce(End_Date,'2025-12-31'),Start_Date)/30.4)),2) as Estimated_LTV_USD
from subscriptions_clean
where Monthly_Revenue > 0 group by Plan order by Estimated_LTV_USD desc;

--- 8 Marketing Channel Customer Acquisition Cost & Support Ticket SLA vs Churn
-- 8.1 Customer Acquisition Cost 

select distinct Campaign_ID from session_clean;
select distinct Campaign_ID from campaigns_clean;

set sql_safe_updates =0;
update session_clean
set Campaign_ID = trim(replace(Campaign_ID, '\r',''));
set sql_safe_updates = 1;

with first_touch_attribution as (
select 
	User_ID,
    Campaign_ID,
    row_number()over(partition by User_ID order by Session_Date asc) as rn
from session_clean
where Campaign_ID is not null and upper(trim(Campaign_ID)) != 'DIRECT_ORGANIC'),
user_acquisition as (
select
	User_ID,
    lower(trim(Campaign_ID)) as Campaign_ID
from first_touch_attribution where rn =1 ),
channel_revenue as (
select 
	ua.Campaign_ID,
    count(distinct ua.User_ID) as Total_Users_Acquired,
    count(distinct p.User_ID) as Paying_Customers,
    sum(p.Amount_USD) as Total_Revenue_Generated
from user_acquisition ua 
left join payment_clean p 
	on ua.User_ID = p.User_ID
    and lower(trim(p.Status))='success'
group by ua.Campaign_ID)
select 
	c.Campaign_Name,
    c.Channel,
    c.Budget_USD,
    coalesce(cr.Total_Users_Acquired,0) as Total_Users_Acquired,
    coalesce(cr.Paying_Customers,0) as Paying_Customers,
    round(c.Budget_USD/nullif(cr.Paying_Customers,0),2) as CAC_USD,
    coalesce(cr.Total_Revenue_Generated,0.00) as Toatl_Revenue_USD,
    round(coalesce(cr.Total_Revenue_Generated,0)/nullif(c.Budget_USD,0),2) as ROI_Multiple
from campaigns_clean c 
left join channel_revenue cr 
	on lower(trim(c.Campaign_ID)) = cr.Campaign_ID 
order by ROI_Multiple desc;

--- 8.2 Support SLA Resolution Time vs Churn
with user_support_sla as(
select 
	User_ID,
    count(Ticket_ID) as total_tickets,
    avg(datediff(coalesce(Resolved_Date,'2025-12-31'),Create_Date)) as Avg_Resolution_Days
from support_clean
group by User_ID),
user_churn_status as (
select 
	User_ID,
    case when max(End_Date) is not null then 1 else 0 end as Has_Churned
from subscriptions_clean
group by User_ID)
select 
	case
		when s.Avg_Resolution_Days<=1 then'Fast(<=24Hours)'
        when s.Avg_Resolution_Days<=3 then 'Standard(1-3 Days)'
        else 'Delayed(> 3 Days)'
	end as SLA_Bucket,
    count(s.User_ID) as Total_Users_with_Tickets,
    sum(c.Has_Churned) as Churned_Users,
    round((sum(c.Has_Churned)*100.0)/count(s.User_ID),2) as Churn_Rate_Pct
from user_support_sla s 
join user_churn_status c 
on s.User_ID = c.User_ID
group by
case
	when s.Avg_Resolution_Days<=1 then'Fast(<=24Hours)'
	when s.Avg_Resolution_Days<=3 then 'Standard(1-3 Days)'
	else 'Delayed(> 3 Days)'
end
order by Churn_Rate_Pct asc;