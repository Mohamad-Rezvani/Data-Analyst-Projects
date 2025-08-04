-- cleaning the date columns

SELECT 
	hire_date,
		CASE    
			WHEN hire_date LIKE '__-__-____' THEN STR_TO_DATE(hire_date, '%d-%m-%Y')    
            WHEN hire_date LIKE '____/__/__' THEN STR_TO_DATE(hire_date, '%Y/%m/%d')    
		ELSE NULL  END AS parsed_date 
FROM employee;

update employee set hire_date = str_to_date(hire_date, '%d-%m-%Y') where hire_date like '__-__-____';

update employee set hire_date = str_to_date(hire_date, '%Y/%m/%d') where hire_date like '____/__/__';

update employee set exit_date = str_to_date(exit_date, '%d-%m-%Y') where exit_date like '__-__-____';

update employee set exit_date = str_to_date(exit_date, '%Y/%m/%d') where exit_date like '____/__/__';


-- attrition rate by age groups

create view age_groups as
select *,
case 
		when age >= 20 and age <30 then '20s'
		when age >= 30 and age <40 then '30s'
		when age >= 40 and age <50 then '40s'
        when age >= 50 and age <60 then '50s'
	end as age_group
from employee;

select 
	status,
    count(*) as num_of_employees,
    age_group
from 
	age_groups
group by 
	status,
    age_group;

-- attrition rate(each department/2022 & 2023)

create view attrition_rate as 
SELECT 
	department,
	round(COUNT(CASE WHEN status = 'Exited' AND exit_date BETWEEN '2022-01-01' AND '2023-12-31' THEN 1 END) * 100.0 / COUNT(CASE WHEN hire_date <= '2023-12-31' THEN 1 END),2) AS attrition_rate
FROM 
	employee 
GROUP BY 
	department;

select *
from attrition_rate;

-- hr cost per employee(each department year by year)

create view num_of_employees as
select 
	department, 
    year(hire_date) as hire_date_year, 
    count(*) as total
from 
	employee
where 
	year(hire_date) >= 2018
group by 
	department, hire_date_year
order by 
	department;

select 
	h.department, 
    year, 
    (h.recruitment_cost+h.training_cost+h.benefit_cost) as total_cost, 
    n.total, 
    round(((h.recruitment_cost+h.training_cost+h.benefit_cost)/n.total),2) as hr_cost_per_employee
from 
	hr_costs h
join 
	num_of_employees n on h.department = n.department and h.year = n.hire_date_year;

