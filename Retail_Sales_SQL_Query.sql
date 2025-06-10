Create Database sql_project_p2;

Use sql_project_p2;

Drop Table If EXISTS retail_sales;
Create Table retail_sales 
	(
		transactions_id	int PRIMARY KEY,
		sale_date	date,
		sale_time	time,
		customer_id	 int,
		gender	varchar(15),
		age	int,
		category varchar(15), 	
		quantiy	Int,
		price_per_unit float,	
		cogs float , 	
		total_sale float
	);


	Select * from retail_sales;


	EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;


USE sql_project_p2;
GO

BULK INSERT retail_sales
FROM 'D:\Retail\Retail.csv'
WITH (
    FIRSTROW = 2,            -- Skip header row
    FIELDTERMINATOR = ',',   -- Comma separated
    ROWTERMINATOR = '\n',    -- New line at the end of each row
    TABLOCK
);


select * from retail_sales;


SELECT *
FROM information_schema.tables
WHERE table_name = 'retail_sales';

--2. Data Exploration & Cleaning
--Record Count: Determine the total number of records in the dataset.
--Customer Count: Find out how many unique customers are in the dataset.
--Category Count: Identify all unique product categories in the dataset.
--Null Value Check: Check for any null values in the dataset and delete records with missing data.

Select Count(*)
from retail_sales;


Select * 
from retail_sales
where transactions_id is NULL
OR
sale_date is NULL
OR
sale_time is NULL
OR
gender is NULL
OR 
category is NULL
OR
quantiy is NULL
OR
cogs is NULL
;


Delete From	retail_sales
where transactions_id is NULL
OR
sale_date is NULL
OR
sale_time is NULL
OR
gender is NULL
OR 
category is NULL
OR
quantiy is NULL
OR
cogs is NULL
;

Select count (*)
from retail_sales;


-- 3. Data Analysis & Findings


Select Count (distinct customer_id)
from retail_sales

Select distinct category
from retail_sales;


--Data Analysis & Buusiness key problems
--Write a SQL query to retrieve all columns for sales made on '2022-11-05:

select * 
from retail_sales
where sale_date='2022-11-05';


-- Write a SQL query to retrieve all transactions where the 
--category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:

Select *
--category, 
--SUM(quantiy)
from retail_sales
where category='Clothing' 
AND 
FORMAT(sale_date,'yyyy-MM')='2022-11'
AND
quantiy >=4

Group By category;


--Write a SQL query to calculate the total sales (total_sale) for each category.


Select 
category,
sum(total_sale) as Total_Sales,
Count(*) as Total_Orders
From retail_sales
Group By category


--Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

Select
Avg(age)
from retail_sales
where category = 'Beauty'


-- Write a SQL query to find all transactions where the total_sale is greater than 1000.

Select
*
From retail_sales
where total_sale>1000



--Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:


Select 
category,
gender,
COUNT(*) as Total_Transaction
from retail_sales
Group By category,
gender
Order By category;


-- Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:

Select * From 
(
Select
Year(Sale_date) as Sales_Year,
Month(Sale_date) as Sales_Month,
Avg(total_sale) as Avg_Sales,
RANK() Over (Partition By Year(sale_date) Order By Avg(total_sale) DESC) as Rank

from retail_sales
Group By Year(Sale_date), 
		 Month(Sale_date)
) as t1
where Rank=1


-- Write a SQL query to find the top 5 customers based on the highest total sales 

Select Top 5

customer_id,
SUM(Total_sale) as Total_sales
from retail_sales
Group by customer_id
Order by SUM(Total_sale) desc

--Write a SQL query to find the number of unique customers who purchased items from each category

Select
category,
Count(Distinct customer_id) as Customers
from retail_sales
group by category



--Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17):


With Hourly_Sales
as
(


	Select 
	*,
	CASE	
		WHEN format(sale_time, 'hh')<=12 THEN 'Morning'
		WHEN format(sale_time, 'hh') Between 12 and 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift

	from retail_sales

) 


Select shift,
count(*) as Total_Orders
from Hourly_Sales
group by shift




