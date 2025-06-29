select *
 from world_layoffs.layoffs;
 
 -- Step-1--Creating a staging table
 
 create Table world_layoffs.layoffs_staging
 like world_layoffs.layoffs;

Insert world_layoffs.layoffs_staging
Select * from world_layoffs.layoffs;

-- Step-2 -- Finding duplicates in the table

Select *
From world_layoffs.layoffs_staging;

Select company,industry,total_laid_off,`date`,
	row_number() Over(
		Partition by company,location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
        as row_num
From world_layoffs.layoffs_staging;
	-- Now we have selected the duplicates rows
Select*
From(Select company,location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions,
	row_number() Over(
		Partition by company,location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
        as row_num
From world_layoffs.layoffs_staging) duplicates
where 
	row_num>1;
    
    -- In order to delte these rows
 Select*
From(Select company,location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions,
	row_number() Over(
		Partition by company,location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
        as row_num
From world_layoffs.layoffs_staging) duplicates
where 
	row_num>1;
    
    -- what we will do is create a new table with a new column of row_num and then we will delete all the rows with row_num>2
CREATE TABLE  world_layoffs.`layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  row_num Int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select*
from  world_layoffs.layoffs_staging2;

Insert into world_layoffs.layoffs_staging2
Select *, row_number() Over(
		Partition by company,location, industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
        as row_num
From world_layoffs.layoffs_staging ;

Select*
from  world_layoffs.layoffs_staging2
where row_num>1;

-- deleting all the duplicate rows

Delete
from  world_layoffs.layoffs_staging2
where row_num>1;

Select*
from  world_layoffs.layoffs_staging2
where row_num>1;

-- standardising the data

Select*
from  world_layoffs.layoffs_staging2;

-- first company column
Select company,trim(company)
from  world_layoffs.layoffs_staging2;

update  world_layoffs.layoffs_staging2
SET company = trim(company);

-- industry column

Select distinct industry
from  world_layoffs.layoffs_staging2
order by 1;

update world_layoffs.layoffs_staging2
set industry='Crypto'
where industry like "Crypto%";
    
-- just checking all other columns

Select *
from  world_layoffs.layoffs_staging2;

Select distinct country
from  world_layoffs.layoffs_staging2
order by 1;

update world_layoffs.layoffs_staging2
set country ='United States'
where country like "United States%";
    
-- changing the date datatype to date

Select `date`, str_to_date(`date`,'%m/%d/%Y')
from  world_layoffs.layoffs_staging2;

UPDATE world_layoffs.layoffs_staging2
set `date`= str_to_date(`date`,'%m/%d/%Y');

ALTER TABLE world_layoffs.layoffs_staging2
MODIFY `date` DATE;

Select *
from world_layoffs.layoffs_staging2;

-- Removing null values

Select *
from world_layoffs.layoffs_staging2
where country is null
or country = "";

Select *
from world_layoffs.layoffs_staging2
where industry is null
or industry = "";

Select *
from world_layoffs.layoffs_staging2
where company='Airbnb';

update world_layoffs.layoffs_staging2
set industry=null
where industry='';

Select *
from world_layoffs.layoffs_staging2
where industry is null;

Select *
from world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	on t1.company=t2.company
    and t1.location=t2.location
where t1.industry is null
and t2.industry is not null;

Update world_layoffs.layoffs_staging2 t1
JOIN world_layoffs.layoffs_staging2 t2
	on t1.company=t2.company
    and t1.location=t2.location
SET t1.industry=t2.industry
where t1.industry is null
and t2.industry is not null;

Select *
from world_layoffs.layoffs_staging2
where company like 'Ball%';

-- now all the  nulls from industry which can be are eleminated 

SELECT *
from world_layoffs.layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

DELETE 
from world_layoffs.layoffs_staging2
where total_laid_off is null
and percentage_laid_off is null;

alter table world_layoffs.layoffs_staging2
DROP column  row_num;

SELECT *
from world_layoffs.layoffs_staging2;

-- SUMMARY 
-- 1. REMOVED THE DUPLICATES
-- 2. STANDARDISED THE DATA
-- 3. REMOVED NULL VALUES
-- 4. REMOVED COLUMNS NOT REQUIRED 

