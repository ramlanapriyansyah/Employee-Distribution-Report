drop table hr;

select * from hr;

alter table hr
change ï»¿id emp_id varchar(20);

start transaction;
update hr
set birthdate = date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d');

select term_date from hr;
select hire_date from hr;

update hr
set hire_date = date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d');
update hr
set term_date = case
	when term_date = '' then null
    else str_to_date(term_date, '%Y-%m-%d %H:%i:%s UTC')
end;

select birthdate, hire_date, term_date
from hr;
describe hr;
commit;

select * from hr;
use project;

alter table hr
modify column hire_date date;

alter table hr
add column age int;

update hr
set age = timestampdiff(year, birthdate, curdate());

alter table hr
change age age int after birthdate;

select min(age) as youngest,
	max(age) as oldest
from hr;

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as total
from hr
where age >= 18 and term_date is null
group by gender;

-- 2. What is the race/ethnicity breakdown of employees in the company?
select race, count(*) as total
from hr
where age >= 18 and term_date is null
group by race
order by total desc;

-- 3. What is the age distribution of employees in the company?
select
	min(age) as youngest,
    max(age) as oldest
from hr;

select
	case
		when age between 18 and 24 then '18-24'
        when age between 25 and 34 then '25-34'
        when age between 35 and 44 then '35-44'
        when age between 45 and 54 then '45-54'
        when age between 55 and 64 then '55-64'
        else '65+'
	end as age_group,
count(*) as total
from hr
where age >= 18 and term_date is null
group by age_group
order by age_group;

select
	case
		when age between 18 and 24 then '18-24'
        when age between 25 and 34 then '25-34'
        when age between 35 and 44 then '35-44'
        when age between 45 and 54 then '45-54'
        when age between 55 and 64 then '55-64'
        else '65+'
	end as age_group, 
count(*) as total
from hr
where age >= 18 and term_date is null
group by age_group
order by age_group;

-- 4. How many employees work at headquarters versus remote locations?
select location, count(location) as total
from hr
where age >= 18 and term_date is null
group by location;

-- 5. What is the average length of employment for employees who have been terminated?
select emp_id,
    concat(
		timestampdiff(year, hire_date, term_date), 'years ',
		timestampdiff(month, hire_date, term_date) % 12, ' months ',
		timestampdiff(day, hire_date, term_date) % 30, ' days'
        ) as length_of_employment
from hr
where term_date is not null
order by length_of_employment desc;

select round(avg(timestampdiff(year, hire_date, term_date)), 2
    ) as avg_length_employment
from hr
where age >= 18 and term_date is not null;

-- 6. How does the gender distribution vary across departments and job titles?
select department, gender, count(gender) as total
from hr
where age >= 18 and term_date is null
group by department, gender;

select jobtitle, gender, count(gender) as total
from hr
where age >= 18 and term_date is null
group by jobtitle, gender;

-- 7. What is the distribution of job titles across the company?
select jobtitle, count(jobtitle) as total
from hr
where age >= 18 and term_date is null
group by jobtitle
order by jobtitle;

-- 8. Which department has the highest turnover rate?
select department, total_count, terminated_count, terminated_count/total_count as termination_rate
from(
	select 
    department,
    count(*) as total_count,
    sum(case
		when term_date is not null and term_date <> curdate() then 1 
        else 0
        end) as terminated_count
	from hr 
    where age >= 18
    group by department
	) as subquery
order by termination_rate desc;

-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as total_employees
from hr
where age >= 18 and term_date is not null
group by location_state
order by total_employees desc;

-- 10. How has the company's employees count changed over time based on hire and term dates?
select
	year,
    hires,
    terminations,
    hires - terminations as net_change,
    round(((hires - terminations)/hires)*100, 2) as net_change_percent
from(
	select
		year(hire_date) as year,
        count(hire_date) as hires,
        sum(case
				when term_date is not null and term_date <= curdate() then 1 else 0
			end) as terminations
	from hr
    where age >= 18
    group by year) as subquery
order by year;

-- 11. What is the tenure distribution for each department?
select department, round(avg(timestampdiff(year, hire_date, term_date)),0) as avg_tenure
from hr
where term_date <= curdate() and term_date is not null and age >= 18
group by department;

select count(*) from hr;
