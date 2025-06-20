# < DATA CLEANING > < LAYOFFS > < MySQL > < ALI SHAHHOUD THE ANALYST >

# => Look At Hole Dataset
select *
from layoffs;
# --------------------

# => Create `layoffs_cleaned` Table
create table layoffs_cleaned
select *,
       row_number() over (
           partition by
               company,
               location,
               industry,
               total_laid_off,
               percentage_laid_off,
               `date`,
               stage,
               country,
               funds_raised_millions
           ) as row_num
from layoffs;

select *
from layoffs_cleaned;
# --------------------

# => Check Rows Count Between The Tables
select 'layoffs' as 'tables', count(*) as 'row_count'
from layoffs
union
select 'layoffs_cleaned', count(*)
from layoffs_cleaned;
# --------------------

# => Check Table Columns Standardization And Consistency
select distinct company
from layoffs_cleaned
order by 1;
#  E Inc.
#  Included Health
# . . .

# => Standardizing 'company' Column
update layoffs_cleaned
set company = trim(regexp_replace(company, '[[:space:]]+', ' '));
# --------------------

select distinct location
from layoffs_cleaned
order by 1;

select distinct stage
from layoffs_cleaned
order by 1;

select distinct country
from layoffs_cleaned
order by 1;
# . . .
# United States
# United States.
# . . .

# => Standardizing 'country' Column
update layoffs_cleaned
set country = trim(TRAILING '.' from country)
where country like 'United States%';
# --------------------

select distinct `date`
from layoffs_cleaned
order by 1;

# => Convert 'date' Column From Text Type To Date Type
update layoffs_cleaned
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoffs_cleaned
    modify column `date` date;
# --------------------

select distinct industry
from layoffs_cleaned
order by 1;
# . . .
# Crypto
# Crypto Currency
# CryptoCurrency
# . . .

# => Standardizing 'industry' Column
select industry, COUNT(*)
from layoffs_cleaned
where industry like 'Crypto%'
group by industry
order by industry;
# Crypto             99
# Crypto Currency    2
# CryptoCurrency     1

# 'Crypto' is reduplicate more than the other two values 'Crypto Currency', 'CryptoCurrency'

update layoffs_cleaned
set industry = 'Crypto'
where industry like 'Crypto%';

update layoffs_cleaned
set industry = null
where industry = '';
# --------------------

select distinct total_laid_off
from layoffs_cleaned
order by 1;

select distinct percentage_laid_off
from layoffs_cleaned
order by 1;

# => Standardizing 'percentage_laid_off' Column
alter table layoffs_cleaned
    modify column percentage_laid_off decimal(10, 4);
# --------------------

select distinct funds_raised_millions
from layoffs_cleaned
order by 1;
# --------------------

# => Find Duplicate Rows
select *
from layoffs_cleaned
where row_num > 1;
# --------------------

# => Delete Duplicate Rows
delete
from layoffs_cleaned
where row_num > 1;
# --------------------

# => Populate Null Or Blank Values

# We Note That The Columns Which Contain Null Values At Some Of Their Fields Are :
# [
#   industry,
#   date,
#   stage,
#   total_laid_off,
#   percentage_laid_off,
#   funds_raised_millions
# ]

# We Will Try To Populate (If It Possible) Null Or Blank Values Depend On The Information In The Same Table
# Logically 'industry' Values Must Be The Same Between Multiple Rows If 'company' And 'location' Values are The Same Too
select t1.company, t1.location, t1.industry, t2.company, t2.location, t2.industry
from layoffs_cleaned t1
         inner join layoffs_cleaned t2
                    on t1.company = t2.company and t1.location = t2.location
where t1.industry is null
  and t2.industry is not null;
# -t1.company -t1.location -t1.industry -t2.company -t2.location -t2.industry
#  Airbnb      SF Bay Area  null         Airbnb      SF Bay Area  Travel
#  Carvana     Phoenix      null         Carvana     Phoenix      Transportation
#  Carvana     Phoenix      null         Carvana     Phoenix      Transportation
#  Juul        SF Bay Area  null         Juul        SF Bay Area  Consumer

update layoffs_cleaned t1
    inner join layoffs_cleaned t2
    on t1.company = t2.company and t1.location = t2.location
set t1.industry = t2.industry
where t1.industry is null
  and t2.industry is not null;
# --------------------
# --------------------

# => Remove Any Unnecessary Rows

# Any Rows Have Null Values In Both 'total_laid_off' And 'percentage_laid_off' Columns, I Think They Are Not Important In Analysing Process. So We Can Delete Them
select *
from layoffs_cleaned
where total_laid_off is null
  and percentage_laid_off is null;
# We Got 361 Rows

delete
from layoffs_cleaned
where total_laid_off is null
  and percentage_laid_off is null;
# --------------------
# --------------------

# => Drop Unnecessary Columns

# => Drop 'row_num' Column Because We Do Not Need It Any More
alter table layoffs_cleaned
    drop column row_num;
# --------------------

# Check Only The Columns That Contain Null Values If Most Of Their Values Are Null, Then We Can Delete Them If They Aren't Useful
select count(*) as total_rows_count, count(*) - count(industry) as industry_null_count
from layoffs_cleaned;
# 1/1995

select count(*) as total_rows_count, count(*) - count(date) as date_null_count
from layoffs_cleaned;
# 1/1995

select count(*) as total_rows_count, count(*) - count(stage) as stage_null_count
from layoffs_cleaned;
# 5/1995

select count(*) as total_rows_count, count(*) - count(total_laid_off) as total_laid_off_null_count
from layoffs_cleaned;
# 378/1995

select count(*) as total_rows_count, count(*) - count(percentage_laid_off) as percentage_laid_off_null_count
from layoffs_cleaned;
# 423/1995

select count(*) as total_rows_count, count(*) - count(funds_raised_millions) as funds_raised_millions_null_count
from layoffs_cleaned;
# 165/1995
# --------------------
# --------------------