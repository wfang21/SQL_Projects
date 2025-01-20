-- Data Cleaning 

select * 
from layoffs; 

-- 1. Remove Duplicates 
-- 2. Standardise the Data 
-- 3. Null Values or Blank values 
-- 4. Remove Any Columns 

-- copy all the data in raw table into the staging table 
create table layoffs_staging 
like layoffs; 

select * 
from layoffs_staging; 

-- insert data to layoffs_staging 
insert layoffs_staging 
select * 
from layoffs; 


select *, 
row_number() over(
partition by company, industry, total_laid_off, percentage_laid_off, `date`) as row_num
from layoffs_staging; 

with duplicate_cte as 
( 
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
select * 
from duplicate_cte 
where row_num > 1; 

select * 
from layoffs_staging
where company = 'Oda';   
-- no duplicates，needs to modify "partition by" above

-- after modifying "partition by" , then check other companies 
select * 
from layoffs_staging
where company = 'Casper'; 

with duplicate_cte as 
( 
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_num
from layoffs_staging
)
delete 
from duplicate_cte 
where row_num > 1; 
-- delete = update，cannot use 

-- right click table "layoffs_staging" --> copy to clipboard --> create statement
CREATE TABLE `layoffs_staging2` (                                    -- change table name
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` bigint DEFAULT NULL,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int                                                        -- insert this row 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci; 


select * 
from layoffs_staging2; 

insert into layoffs_staging2
select *, 
row_number() over(
partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) as row_num
from layoffs_staging;

-- filter
select * 
from layoffs_staging2
where row_num > 1; 

-- delete duplicates
delete 
from layoffs_staging2
where row_num > 1; 

select * 
from layoffs_staging2; 

-- Standardising data 

select company, trim(company)
from layoffs_staging2; 

update layoffs_staging2
set company = trim(company);

select distinct(industry)
from layoffs_staging2
order by 1; 

select * 
from layoffs_staging2 
where industry like 'Crypto%';

update layoffs_staging2
set industry = 'Crypto' 
where industry like 'Crypto%'; 

select distinct(industry) 
from layoffs_staging2; 

select distinct(country) 
from layoffs_staging2
order by 1; 

select distinct(country) 
from layoffs_staging2
order by 1;

select *
from layoffs_staging2
where country like 'United States%'
order by 1; 

select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country) 
where country like 'United States%'; 

select *
from layoffs_staging2; 

-- change date column 
select `date`, 
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging2; 

update layoffs_staging2 
set `date` =  str_to_date(`date`, '%m/%d/%Y');    

select `date`
from layoffs_staging2; 

-- date column 
alter table layoffs_staging2 
modify column `date` date; 

select *
from layoffs_staging2; 

-- null or blank column 

select *
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null; 

update layoffs_staging2 
set industry = null 
where industry = ''; 

select *
from layoffs_staging2
where industry is null or industry = ''; 

select *
from layoffs_staging2 
where company = 'Airbnb'; 

select t1.industry, t2.industry
from layoffs_staging2 t1 
join layoffs_staging2 t2 
	on t1.company = t2.company 
where (t1.industry is null or t1.industry = '') 
and t2.industry is not null; 

update layoffs_staging2 t1  
join layoffs_staging2 t2 
	on t1.company = t2.company 
set t1.industry = t2.industry
where t1.industry is null 
and t2.industry is not null; 

select *
from layoffs_staging2
where industry is null or industry = ''; 

select *
from layoffs_staging2 
where company like 'Bally%'; 

select *
from layoffs_staging2; 

select *
from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null; 

delete 
from layoffs_staging2 
where total_laid_off is null and percentage_laid_off is null; 

select *
from layoffs_staging2; 

alter table layoffs_staging2
drop column row_num;