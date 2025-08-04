-- cleaning the date columns

select 
	date,
    case
		when date like '%-%-%' then str_to_date(date, '%d-%m-%Y')
        when date like '%/%/%' then str_to_date(date, '%m-%d-%Y')
	else null end as clean_date
from expense_optimization;

update expense_optimization set date = str_to_date(date, '%d-%m-%Y') where date like '%-%-%';

update expense_optimization set date = str_to_date(date, '%m-%d-%Y') where date like '%/%/%';

-- fixing the store column

select 
	distinct store 
from 
	expense_optimization 
order by 
	1;
    
update expense_optimization set store = 'East' where store = 'East Store';

update expense_optimization set store = 'North' where store = 'North Store';

update expense_optimization set store = 'South' where store = 'South Store';

update expense_optimization set store = 'West' where store = 'West Store';


-- cost efficiency by store

select 
	store,
    round(sum(amount),2) as total_amount
from 
	expense_optimization
group by 
	store;



-- cost efficiency by category

select 
	category,
    round(sum(amount),2) as total_amount
from 
	expense_optimization
group by 
	category;
