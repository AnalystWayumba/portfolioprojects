select*
from `layoffs (2)`;

#1. remove duplicates
#2.Standardize the data
#3.check null or blank values
#4. Remove any columns that are unneccessary

CREATE table layoffs_staging
LIKE `layoffs (2)`;

select *
from layoffs_staging;
insert into layoffs_staging
select*
from `layoffs (2)`;

#Create row numbers as a new column 

select *,
row_number() over( partition by company,location,industry,total_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;

#create a cte to help you check for duplicate rows
WITH duplicate_cte as 
(select *,
row_number() over( partition by company,location,industry,total_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select*
from duplicate_cte
where row_num>1;
# Try checking all the duplicate rows to ascertain whether its true the values are duplicates and there is need to remove them.
select*
from layoffs_staging
where company like 'casper';
 
 # We create a final table by using the create statement. We right click on the statging table and include the row number as a new column within the create statement.
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
select*
from layoffs_staging2;

#Once the table is created, we insert into it using the window statement(row creation statement)
INSERT INTO layoffs_staging2
select *,
row_number() over( partition by company,location,industry,total_laid_off,`date`,stage,country,funds_raised_millions) as row_num
from layoffs_staging;
SELECT*
FROM layoffs_staging2;

SELECT*
FROM layoffs_staging2
WHERE row_num>1;
#We finally delete the duplicate rows i.e with row_numbers greater than 1.
DELETE
FROM layoffs_staging2
WHERE row_num>1;

SELECT*
FROM layoffs_staging2;

#Standardization of data. This is done after the duplicates have been removed. We start by trimming all the columns.
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company=trim(company);

select company, trim(company)
from layoffs_staging2;

select distinct industry
from layoffs_staging2
order by 1;
# We check distinct column values and check for any spelling errors or similar words with different wordings.
select*
from layoffs_staging2
where industry like 'crypto%';

select distinct industry
from layoffs_staging2
order by 1;

update layoffs_staging2
set industry='crypto'
where industry like 'crypto%';

select distinct country
from layoffs_staging2
order by 1;

update layoffs_staging2
set country='United States'
where country like 'United States%';
#we change the date formarts and the date's data type.
select `date`,
STR_TO_DATE(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date` =STR_TO_DATE(`date`,'%m/%d/%Y');

select *
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` date;

# Removing blanks and nulls 
select *
from layoffs_staging2
where industry is null
or industry ='';

update layoffs_staging2
set industry=null
where industry='';

select*
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
where t1.industry is null
and t2.industry is not null;    

select t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
	on t1.company=t2.company
where t1.industry is null
and t2.industry is not null;

update  layoffs_staging2 t1  
join layoffs_staging2 t2
	on t1.company=t2.company
set t1.industry=t2.industry  
where t1.industry is null
and t2.industry is not null;  

select*
from layoffs_staging2
where industry is null
or industry='';
# This should be done to each column that has blank or null values . The null/blank values can be populated once we notice similarities in the missing values with other populated values.
select*
from layoffs_staging2
where company like 'ball%';

#Removing columns and rows that we need to remove.
select*
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;
# we checked the two columns because the EDA of the data is focused on the layoff data.
delete
from layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

select *
from layoffs_staging2;

alter table layoffs_staging2
drop column row_num;

delete
from layoffs_staging2
where company like 'bally%';