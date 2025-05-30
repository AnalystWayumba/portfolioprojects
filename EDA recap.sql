select*
from layoffs_staging2;

select max(total_laid_off)
from layoffs_staging2;

select max(total_laid_off),max(percentage_laid_off)
from layoffs_staging2;

select *
from layoffs_staging2
order by total_laid_off desc; 

select *
from layoffs_staging2
where percentage_laid_off=1
order by total_laid_off desc; 
# We have a look at the funds raised in millions from the layoffs. Companies that had huge fundings.
select *
from layoffs_staging2
where percentage_laid_off=1
order by funds_raised_millions desc; 
# we look at the total number of layoffs per company. when we order by the sum of total laid off in a desc order, we get an insight of the companies that laid off a lot of people in that order.

select company, sum(total_laid_off)
from layoffs_staging2
group by company
order by sum(total_laid_off) desc;

#We have a look at the date range. Time between the first and the last layoff
select min(`date`),max(`date`)
from layoffs_staging2;

# we can also have a look at the total layoffs per country,industry

select country, sum(total_laid_off)
from layoffs_staging2
group by country
order by sum(total_laid_off) desc;

select industry, sum(total_laid_off)
from layoffs_staging2
group by industry
order by sum(total_laid_off) desc;

#we can as well check the layoffs per year 
select year(`date`), sum(total_laid_off)
from layoffs_staging2
group by year(`date`)
order by sum(total_laid_off) desc;

# we also have a look at what stage of the companies had the largest layoffs
select stage, sum(total_laid_off)
from layoffs_staging2
group by stage
order by sum(total_laid_off) desc;

#we then have a look at the progression of the layoffs/ the rolling sum
select substring(`date`,1,7) `month`, sum(total_laid_off) total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc;

with Rolling_total as
(select substring(`date`,1,7) `month`, sum(total_laid_off) total_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `month`
order by 1 asc
)
select `month`,total_off,sum(total_off) over(order by `month`) rolling_total
from Rolling_total;

#Rolling totals of company layoffs and ranking which years most employees were laid off

select company,year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
order by sum(total_laid_off) desc ;

with company_year(company,years,total_laid_off) as 
(select company,year(`date`), sum(total_laid_off)
from layoffs_staging2
group by company,year(`date`)
), company_year_rank as 
(select *, dense_rank() over(partition by years order by total_laid_off desc) rank_num
from company_year
where years is not null
)
select *
from company_year_rank
where rank_num <=5;


# check for the industries that had the largest numbers of layoffs per year

select industry, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by industry, year(`date`)
order by sum(total_laid_off) desc;

#create a cte for the dense_rank ignoring null values that might interfere with the ranks.
with industry_year(industry,years,industry_sum) as 
(select industry, year(`date`), sum(total_laid_off)
from layoffs_staging2
group by industry, year(`date`)
), industry_years_rank as 
(select *, dense_rank() over(partition by years order by industry_sum) year_rank
from industry_year
where years is not null
and industry_sum is not null)
select*
from industry_years_rank
where year_rank <=5
and industry_sum is not null;

