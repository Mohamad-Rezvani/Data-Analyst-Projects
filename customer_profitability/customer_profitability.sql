-- fixing the date columns

alter table customer_support modify support_date date;

alter table customers modify signup_date date;

alter table transactions modify transaction_date date;

-- customer profit vs customer support cost

select 
	t.customer_id, 
    round(sum(t.quantity*(t.unit_price-t.unit_cost)),2) as profit, 
    round(sum(cs.support_cost),2) as support_cost 
from 
	transactions t 
join 
	customer_support cs on t.customer_id = cs.customer_id 
group by 
	t.customer_id 
order by 
	t.customer_id;

-- profit over time

select 
	date_format(transaction_date, '%Y-%m') as month, 
    round(sum(quantity*(unit_price-unit_cost)),2) as profit 
from 
	transactions 
group by 
	month 
order by 
	month;

-- comparing each category by the revenue

select 
	p.category, 
    round(sum((t.quantity*t.unit_price)),2) as revenue 
from 
	transactions t 
join 
	products p on t.product_id = p.product_id 
group by 
	p.category 
order by 
	revenue desc;

-- total cost

select 
	round(sum(quantity*unit_cost),2) as cost 
from 
	transactions;
    
-- total profit

select 
	round(sum(quantity*(unit_price-unit_cost)),2) as total_profit
from 
	transactions;

-- total revenue

select round(sum(quantity*unit_price),2) as total_revenue
from transactions;

-- average profit of all customers

select 
	round(avg(profit),2) as average_profit 
from 
	(select 
		customer_id, 
        round(sum(quantity*(unit_price-unit_cost)),2) as profit 
	from 
		transactions 
	group by 
		customer_id) as customer_profits;

-- are high-revenue customers always high profit? 

select 	
	c.customer_id,	
    round(sum(t.quantity*(t.unit_price-t.unit_cost)),2) as profit,    
    round(sum(t.quantity*t.unit_price),2) as revenue 
from	
	transactions t 
join 	
	customers c on t.customer_id = c.customer_id 
group by 	
	c.customer_id;

-- which customers gave the most profits?(top 10)

select 	
	c.customer_id,	
    round(sum(t.quantity*(t.unit_price-t.unit_cost)),2) as profit,    
    c.customer_name,    
    c.region	
from 
	transactions t 
join	
	customers c on t.customer_id = c.customer_id 
group by
	c.customer_name, c.region, c.customer_id 
order by 	
	profit desc 
limit 10;

-- which industries generate the most revenue, and which region contribute the most within each?

select
	c.industry,
    c.region,
    round(sum(t.quantity*t.unit_price),2) as revenue
from
	transactions t
join
	customers c on  	t.customer_id = c.customer_id
group by
	c.industry, c.region
order by
	c.industry;
