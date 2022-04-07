-- showin first 20 records to get familiar with data
select *
from [covid-cases]
-- where datepart(month, date) = 3 and datepart(year, date) = 2020

select* 
from [covid-cases-detailed]


-- (1) get the total deaths for each country 
select Location, max(cast(total_deaths as int)) as countries_tot_deaths
from [covid-cases] 
-- location contains other values that make the data not accurate  
where continent is not null 
group by location 
order by countries_tot_deaths desc


-- (2)percentage of total death for each country per total cases
select Location, max(cast(total_deaths as int)) as countries_tot_deaths,
	max(total_cases) as country_tot_cases,
	(max(cast(total_deaths as int))/max(total_cases)) *100  as deaths_per_cases
from [covid-cases]   
where continent is not null 
group by location 




-- (3)percentage of total cases for each country per population
select Location,  population, 
	max(total_cases) as country_tot_cases, 
	(max(total_cases)/population) *100 as cases_per_pop
from [covid-cases]   
where continent is not null 
group by location, population 
order by cases_per_pop desc



-- (4) percentage of total death for each country per pop
select Location,population, max(cast(total_deaths as int)) as country_tot_deaths, 
	(max(cast(total_deaths as int))/population) *100 as deaths_per_pop
from [covid-cases]   
where continent is not null 
group by location, population 
order by deaths_per_pop desc





-- (5) total cases and total deaths per year and total cases per year for each ountry
select location, year(date),
	case when year(date) = 2021 or year(date) = 2022 then (max(cast(total_deaths as int)) - min(cast(total_deaths as int)))
		else max(cast(total_deaths as int)) end as tot_deaths_per_year ,
	case when year(date) = 2021 or year(date) = 2022 then (max(total_cases ) - min(total_cases ))
		else max(total_cases ) end as tot_cases_per_year	
from [covid-cases]
where continent is not null 
group by location, year(date)   
order by location , year(date) 
 



-- (6) new cases and new deaths over the world per months
select  year(convert(datetime ,date)) as year ,
		format(convert(datetime ,date), 'MMMM') as months_name,
		sum(new_cases) as new_cases_per_months,
		sum(cast(new_deaths as int)) as new_deaths_per_months
from [covid-main-table]
where continent is not null 
group by year(convert(datetime ,date)) , month(convert(datetime ,date)) ,
		format(convert(datetime ,date) , 'MMMM')
order by year(convert(datetime ,date)) ,month(convert(datetime ,date))

--(6 bi) 
 select  sum(new_cases_per_months), sum(new_deaths_per_months)
 from (
select  format(convert(datetime ,date), 'yyyy-MM') as year , month(convert(datetime ,date)) as months,
		
		sum(new_cases)  as new_cases_per_months ,
		sum(cast(new_deaths as int)) as new_deaths_per_months
from [covid-main-table]
where continent is not null 
group by format(convert(datetime ,date), 'yyyy-MM'),month(convert(datetime ,date)) 
--order by format(convert(datetime ,date), 'yyyy-MM')
 ) as cte
 



-- making sure of our previous query result by getting the sum of total deaths for any country
/*with ctt as(
			select  year(convert(datetime ,date)) as year ,
				format(convert(datetime ,date), 'MMMM') as months_name,
				sum(cast(new_deaths as int)) as new_deaths_per_months
			from [covid-main-table]
			where continent is not null 
			group by year(convert(datetime ,date)) , month(convert(datetime ,date)) ,
				format(convert(datetime ,date) , 'MMMM')
			--order by year(convert(datetime ,date)) ,month(convert(datetime ,date))
			)
select sum(ctt.new_deaths_per_months) --6.103M deaths
from ctt */



-- (7) percentage of new deaths and new cases per months 
select  year(convert(datetime ,date)) as year ,
		format(convert(datetime ,date), 'MMMM') as months_name,
		sum(new_cases ) new_cases,
		sum(cast(new_deaths as int)) as new_deaths_per_months,
		(sum(cast(new_deaths as float)) / sum(new_cases)*100)as new_dth_per_case_overMonths
from [covid-main-table]
where continent is not null and location = 'United states'
group by year(convert(datetime ,date)) , month(convert(datetime ,date)) ,
		format(convert(datetime ,date) , 'MMMM')
order by year(convert(datetime ,date)) ,month(convert(datetime ,date))



-- (8) cases and deaths per continent
select location , max(total_cases) as total_cases,
				max(cast(total_deaths as int)) as total_deaths
from [covid-cases]
where continent is null 
group by location
order by max(total_cases) desc





-- (9) people that fully vaccinated per each country
select location, population ,max(cast(people_fully_vaccinated as int)) as fully_vaccinated,
		(max(cast(people_fully_vaccinated as int))/population *100) fully_vaccinated_percent,
		(100 -(max(cast(people_fully_vaccinated as int))/population *100)) as diff_pop ,-- for power bi
		(population/ population*100 )as pop_perc -- for power bi 
from [covid-cases]
where continent is not null 
group by location,population
order by (max(cast(people_fully_vaccinated as int))/population *100) desc



--(10) bosters 
with mm as (select location, population ,max(cast(total_boosters as int)) as tot_boosters,
		(max(cast(total_boosters as int))/population *100) tot_boosters_percent
from [covid-cases]
where continent is not null 
group by location,population
--order by (max(cast(total_boosters as int))/population *100) desc
)
select sum(tot_boosters)
from mm

