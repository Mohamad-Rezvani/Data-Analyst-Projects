-- loading data

create table dim_date (
				date text,
				fiscal_year int,
				quarter varchar(50)
);

load data infile "E:\\project 3 AtliQ Motors\\RPC12_Input_For_Participants\\RPC12_Input_For_Participants\\datasets\\dim_date.csv"
into table dim_date
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table ev_sales_by_maker (
				date text,
				vehicle_category varchar(50),
				maker varchar(250),
                electric_vehicles_sold int
);

load data infile "E:\\project 3 AtliQ Motors\\RPC12_Input_For_Participants\\RPC12_Input_For_Participants\\datasets\\electric_vehicle_sales_by_makers.csv"
into table ev_sales_by_maker
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

create table ev_sales_by_state (
				date text,
				state varchar(50),
                vehicle_category varchar(50),
                electric_vehicles_sold int,
                total_vehicles_sold int
);

load data infile "E:\\project 3 AtliQ Motors\\RPC12_Input_For_Participants\\RPC12_Input_For_Participants\\datasets\\electric_vehicle_sales_by_state.csv"
into table ev_sales_by_state
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- cleaning the data

update ev_sales_by_state
set `date` = str_to_date(`date`, "%d-%b-%y");

alter table ev_sales_by_state
modify `date` date;

update ev_sales_by_maker
set `date` = str_to_date(`date`, "%d-%b-%y");

alter table ev_sales_by_maker
modify `date` date;

update dim_date
set `date` = str_to_date(`date`, "%d-%b-%y");

alter table dim_date
modify `date` date;

-- the top 3 and bottom 3 makers for the fiscal years 2023 and 2024 in terms of the number of 2-wheelers sold

(
	select 
		maker,
        vehicle_category,
        sum(electric_vehicles_sold) as total_electric_vehicles_sold,
        'top 3' as category
	from 
		ev_sales_by_maker a
	join 
		dim_date b on a.date = b.date
	where 
		fiscal_year in (2023, 2024)
		and vehicle_category = '2-wheelers'
	group by 
		maker, vehicle_category
	order by total_electric_vehicles_sold desc
	limit 3
)
UNION ALL
(
	select 
		maker,
        vehicle_category,
        sum(electric_vehicles_sold) as total_electric_vehicles_sold,
        'bottom 3' as category
	from 
		ev_sales_by_maker a
	join 
		dim_date b on a.date = b.date
	where 
		fiscal_year in (2023, 2024)
		and vehicle_category = '2-wheelers'
	group by 
		maker, vehicle_category
	order by 
		total_electric_vehicles_sold asc
	limit 3
) 
order by 
	total_electric_vehicles_sold desc;

-- top 5 states with the highest penetration rate in EV sales in FY 2024

select 
	t1.state, 
    (total_ev_sold_2-total_ev_sold_1) as penetration_rate
from(
	select 
		date, 
		state, 
		sum(electric_vehicles_sold) as total_ev_sold_1
	from 
		ev_sales_by_state
	where 
		date = '2023-04-01'
	group by 
		state,
		date
	order by 2
) as t1
join
(
	select 
		date, 
        state, 
        sum(electric_vehicles_sold) as total_ev_sold_2
	from 
		ev_sales_by_state
	where 
		date = '2024-03-01'
	group by 
		state, date
	order by 2
) as t2
on 
	t1.state = t2.state
order by penetration_rate desc
limit 5;

-- quarterly trends based on sales volume for the top 5 EV makers (4-wheelers) from 2022 to 2024

select maker, sum(electric_vehicles_sold) as total_ev_sold
from ev_sales_by_maker
where vehicle_category = "4-wheelers"
group by maker
order by total_ev_sold desc
limit 5;

select
	case
		when date like "%01-01" or date like "%02-01" or date like "%03-01" then "Winter"
		when date like "%04-01" or date like "%05-01" or date like "%06-01" then "Spring"
		when date like "%07-01" or date like "%08-01" or date like "%09-01" then "Summer"
		when date like "%10-01" or date like "%11-01" or date like "%12-01" then "Autumn"
	end as season,
			vehicle_category,
            sum(electric_vehicles_sold) as total_ev_sold,
            maker
from 
	ev_sales_by_maker
where 
	vehicle_category = '4-wheelers'
    and maker in ('Tata Motors', 'Mahindra & Mahindra', 'MG Motor', 'BYD India', 'Hyundai Motor')
group by 
	maker,
	vehicle_category,
    season
order by 
	4 asc;

-- How do the EV sales and penetration rates in Delhi compare to Karnataka for 2024

select 
	state, 
    sum(electric_vehicles_sold) as total_ev_sold, 
    sum(total_vehicles_sold) as total_v_sold, 
    "2024" year, 
    round((sum(electric_vehicles_sold)/sum(total_vehicles_sold))*100,2) as penetration_rate
from 
	ev_sales_by_state
where 
	year(date) = 2024
	and state in ('Delhi', 'Karnataka')
group by 
	state;

-- top 10 states that had the highest compounded annual growth rate (CAGR) from 2022 to 2024 in total vehicles sold

select 
	t1.state, 
	total_v_sold_2022, 
	estimated_total_v_sold_2024, 
	round(power((estimated_total_v_sold_2024/total_v_sold_2022),1/2)-1,2) as CAGR
from
(
	select 
		state, 
        sum(total_vehicles_sold) as total_v_sold_2022
	from 
		ev_sales_by_state
	where 
		year(date) = 2022
		and vehicle_category = "4-wheelers"
	group by state
) t1
join
(
	select 
		state, 
        sum(total_vehicles_sold)*4 as estimated_total_v_sold_2024
	from 
		ev_sales_by_state
	where 
		year(date) = 2024
		and vehicle_category = "4-wheelers"
	group by state
) t2
on t1.state = t2.state
order by cagr desc
limit 10;

-- peak and low season months for EV sales based on the data from 2022 to 2024

(
	select 
		monthname(date) as monthname, 
        round(avg(electric_vehicles_sold),1) as average_ev_sold, 
        "Peak" seasonality
	from 
		ev_sales_by_state
	where 
		date >= '2022-01-01'
	group by monthname
	order by 2 desc
	limit 1
)
union all
(
	select 
		monthname(date) as monthname, 
        round(avg(electric_vehicles_sold),1) as average_ev_sold, 
        "Low" seasonality
	from 
		ev_sales_by_state
	where 
		date >= '2022-01-01'
	group by monthname
	order by 2 asc
	limit 1
)
order by 2 desc;

select 
	monthname(date) as monthname, 
	round(avg(electric_vehicles_sold),1) as average_ev_sold
from 
	ev_sales_by_state
where 
	date >= '2022-01-01'
group by monthname
order by 2 desc;





























