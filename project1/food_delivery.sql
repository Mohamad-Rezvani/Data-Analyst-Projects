-- loading in the data

create table food_delivery (
ID varchar(50),
Delivery_person_ID varchar(255),
Delivery_person_age text,
Delivery_person_ratings text,
Restaurant_latitude decimal(8,6),
Restaurant_longitude decimal(8,6),
Delivery_location_latitude decimal(8,6),
Delivery_location_longitude decimal(8,6),
order_date text,
time_orderd text,
Time_Order_picked text,
Weatherconditions varchar(255),
Road_traffic_density varchar(50),
Vehicle_condition int,
Type_of_order varchar(50),
Type_of_vehicle varchar(50),
multiple_deliveries text,
Festival varchar(50),
City varchar(50),
`Time_taken(min)` int
);

load data infile "E:\project 1 food delivery\data\train.csv"
into table food_delivery
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;



-- cleaning the data

update food_delivery
set delivery_person_age = null
where delivery_person_age = '';

alter table food_delivery
modify column delivery_person_age int;

update food_delivery
set Delivery_person_ratings = null
where Delivery_person_ratings = '';

alter table food_delivery
modify column Delivery_person_ratings float;

update food_delivery
set multiple_deliveries = null
where multiple_deliveries = '';

alter table food_delivery
modify column multiple_deliveries int;

update food_delivery
set order_date =
	case
		when food_delivery = "%/%" then str_to_date(food_delivery, "%d/%m/%Y")
        when food_delivery = "%-%" then str_to_date(food_delivery, "%d-%m-%Y")
        else null
	end;

update food_delivery
set time_orderd = str_to_date(time_orderd, "%h:%i:%s%p");

update food_delivery
set Time_Order_picked = str_to_date(Time_Order_picked, "%h:%i:%s%p");

delete
from food_delivery
where Weatherconditions = 'conditions';

alter table food_delivery
add column age_group varchar(50);

update food_delivery
set age_group =
	case
		when Delivery_person_age < 25 then "<25"
        when Delivery_person_age >=25 and Delivery_person_age < 35 then "25 to 35"
        when Delivery_person_age >= 35 then ">35"
	end;

select distinct Weatherconditions
from food_delivery;

update food_delivery
set Weatherconditions =
	case
		when Weatherconditions = 'conditionsSunny' then 'Sunny'
        when Weatherconditions = 'conditionsStormy' then 'Stormy'
        when Weatherconditions = 'conditionsSandstorms' then 'Sandstorm'
        when Weatherconditions = 'conditionsCloudy' then 'Cloudy'
        when Weatherconditions = 'conditionsFog' then 'Fog'
        when Weatherconditions = 'conditionsWindy' then 'Windy'
	end;


select *
from food_delivery;



















