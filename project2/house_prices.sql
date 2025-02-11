-- loading data

create table house_listing (
				City varchar(50),
				Price int,
				Address varchar(250),
				Number_Beds int,
				Number_Baths int,
				Province varchar(50),
				Population int,
				Latitude float,
				Longitude float,
				Median_Family_Income int
);

load data infile "E:\\project 2 housing prices canada\\HouseListings.csv"
into table house_listing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;




-- removing duplicates

WITH duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY address) AS row_num
    FROM house_listing
)
DELETE FROM house_listing
WHERE (address, Number_Beds) IN (
    SELECT address, Number_Beds
    FROM duplicates
    WHERE row_num > 1
);



-- best city and province for home buyers based on price to income ratio

with top_city as (
	select city, Latitude, Longitude, round(avg(price),1) as `average house price`, 
			Population, Province, round(avg(Median_Family_Income),1) as `average family income`
	from house_listing
	group by city, Latitude, Longitude, Population, Province
)
	select *, round(`average house price`/`average family income` ,2) as `price to income ratio`
	from top_city
	order by `price to income ratio` asc
;

with top_province as (
	select round(avg(price),1) as `average house price`, sum(Population) `total population`, 
			Province, round(avg(Median_Family_Income),1) as `average family income`
	from house_listing
	group by Province
)
	select *, round(`average house price`/`average family income` ,2) as `price to income ratio`
	from top_province
	order by `price to income ratio` asc
;

select *
from house_listing;










