-- full data with days data cleaned
create view v1 as (
select sk_id_curr as debt_id,
		case when application_data.debtpayment_status = 1 then 'late' else 'on time' end as debt_payment_status,
		name_contract_type,
		code_gender,
		flag_own_car ,
		flag_own_realty,
		cnt_children,
		amt_income_total,
		application_data."AMT_CREDIT",
		amt_annuity,
		amt_goods_price,
		name_type_suite,
		name_income_type,
		name_education_type,
		name_housing_type,
		region_population_relative,
		days_birth::numeric*-1.0 as days_birth,
		days_employed::numeric*-1.0 as days_employed,
		days_registration::numeric*-1.0 as days_registration,
		days_id_publish::numeric*-1.0 as days_id_publish,
		own_car_age ,
		occupation_type,
		cnt_fam_members,
		region_rating_client,
		region_rating_client_w_city,
		organization_type
		from loans.application_data
)
select *
from v1

-- Distribution of loan volume, credit exposure, and repayment burden by payment behavior
-- Percentages calculated using window functions for scalability
select debt_payment_status ,
		count(*) as total_number,
		Round(count(*)::numeric/ sum(count(*)) over() * 100, 2) as percentage_of_total_num,
		sum(v1."AMT_CREDIT") as total_debt,
		Round(sum(v1."AMT_CREDIT")::numeric/sum(sum(v1."AMT_CREDIT")::numeric) over() * 100, 2) as percentage_of_total_debt,
		sum(amt_annuity) as total_annual_payments,
		Round(sum(amt_annuity)::numeric/sum(sum(amt_annuity)::numeric) over() * 100, 2) as percentage_of_total_annual_payment
from v1
group by debt_payment_status



-- cte shows the (payment/income)(payment/debt)ratios for each debt then the total mean and median of both categorized by payment status
with ratios as (
    select
        debt_payment_status,
        (amt_annuity / nullif(v1."AMT_CREDIT", 0) * 100)::numeric as payment_debt_ratio,
        (amt_annuity / nullif(amt_income_total, 0) * 100)::numeric as payment_income_ratio
    from v1
)
select
    debt_payment_status,
    round(avg(payment_debt_ratio), 2) as avg_payment_debt_ratio,
    round(percentile_cont(0.5) within group (order by payment_debt_ratio)::numeric, 2) as median_payment_debt_ratio,
    round(avg(payment_income_ratio), 2) as avg_payment_income_ratio,
    round(percentile_cont(0.5) within group (order by payment_income_ratio)::numeric, 2) as median_payment_income_ratio
from ratios
group by debt_payment_status;


---- cte with the children status then querry to show the data categorized as with kids &no kids

with children_cte as (
select case when cnt_children =0 then 'no kids' else'with kids' end as children_status ,
		debt_payment_status,
		amt_income_total::numeric,
		amt_annuity::numeric,
		v1."AMT_CREDIT"::numeric
from v1
)
select  children_status,
		COUNT(*) total_number,
		count(*)filter (where debt_payment_status = 'on time') as number_of_onTime_payment,
		count(*)filter (where debt_payment_status = 'late') as number_of_late_payment,
		ROUND(COUNT(*)filter (where debt_payment_status = 'late')::numeric/COUNT(*) * 100,2) AS late_payment_ratio,
		round(avg(amt_income_total),2) as avg_income,
		round(avg(amt_annuity),2) as avg_annual_payment,
		round(avg(children_cte."AMT_CREDIT"),2) as avg_debt_amount
from children_cte
group by children_status


-- categorizing data based on age 

with age_cte as (
select  debt_id,
		debt_payment_status,
		amt_income_total,
		amt_annuity,
		v1."AMT_CREDIT",
		(days_birth/365) as age_in_years,
		case when (days_birth/365.25)<30 then 'youth' when (days_birth/365.25)>60 then 'elderly' else 'mature'end as age_category
	
from v1
)
select age_category,
		count(age_category) as total_number,
		count(*) filter (where debt_payment_status = 'on time') as number_of_onTime_payment,
		count(*) filter (where debt_payment_status = 'late') as number_of_late_payment,
		round(count(*) filter (where debt_payment_status = 'late')::numeric /count(*) * 100,2) as late_payment_rate
from age_cte
group by age_category


--employment stability VS late payment rate

select
    case 
        when days_employed/365.25 > 10 then '10+ years'
        when days_employed/365.25 between 5 and 10  then '5–10 years'
        when days_employed/365.25 < 5 and  days_employed/365.25 >=1 then '1–5 years'
        else '<1 year'
    end as employment_length,
    round(count(*) filter (where debt_payment_status = 'late')::numeric / count(*) * 100,2) as late_payment_rate
from v1
group by employment_length;


