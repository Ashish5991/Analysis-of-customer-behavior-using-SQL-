
------------------------------------------------BASIC SQL CASE STUDY--------------------------------------------------------------------------

/*Data preparation and understanding */

select * from Customer
select * from Transactions
select * from prod_cat_info
--1. What is th total no of rows in each of the 3 tables in the database ?
   select 
   COUNT(*) as no_of_rows_cus
   from 
   Customer

   select 
   COUNT(*) as no_of_rows_trans
   from 
   Transactions

   select 
   COUNT(*) as no_of_rows_prod
   from 
   prod_cat_info
   
 --2. What is the total number of transactions that have a return
   select 
   count(*) as no_of_trans
   from 
   Transactions
   where Qty < 0

 --3. The date provided across the datasets are not in correcct format . As first steps pls convert the date variables into valid date formats.
    
	select 
	transaction_id ,	cust_id , convert(date, tran_date , 105) as tran_date	, prod_subcat_code	,prod_cat_code	,Qty,	Rate,	Tax	total_amt	,Store_type
	from 
	Transactions 
	select customer_Id ,	convert (date , DOB	, 105) as new_dob ,Gender	, city_code
	from 
	customer 
	
	
 --4. What is the time rangeg of the transation data available for analysis .  Show the output in the number of days , months and years simultaneously in different columns .
       select 
	 transaction_id ,	cust_id , tran_date 	, prod_subcat_code	,prod_cat_code	,Qty,	Rate,	Tax	total_amt	,Store_type,
	 DATEDIFF(DAY ,  tran_date  , GETDATE()) as days_range, 
	 DATEDIFF( month ,  tran_date ,  getdate()) as month_range ,
	 DATEDIFF( year , tran_date , GETDATE()) as year_range
	 from 
	 Transactions

	

 --5. Which product category does the sub category "DIY" belongs to ?
      select 
	  prod_cat 
	  from 
	  prod_cat_info
	  where prod_subcat = 'DIY'


/*DATA analysis*/

--1. Which channel is most frequently used for transactions ?
select * from Transactions
     select top 1
	 Store_type , COUNT(store_type) as no_of_channels 
	 from 
	 Transactions
	 group by Store_type
	 order by no_of_channels desc 

--2. What is the count of male and female customers in the database ?
select * from Customer
     select Gender , COUNT(gender) as no_of_male_female 
	 from Customer
	 where Gender = 'M' or Gender = 'F'
	 group by 
	 Gender

--3. From which city do we have the maximum no of customers and how many ?
     select  
	 top 1
	 city_code , count(customer_Id) as no_of_customer
	 from Customer
	 group by city_code
	 order by 
	 no_of_customer desc
	
--4. How many sub-categories are there under the Books category ?
select * from prod_cat_info
     select 
     * 
	 from prod_cat_info
     where 
	 prod_cat = 'Books'

--5. What is the maximum quantity of products ever ordered ?

	 select 
	 max(Qty) as max_quant_ordered
	 from 
	 Transactions
--6. What is the net total revenue generated in categories Electronics and Books ?
select * from Transactions
select * from prod_cat_info

   select 
   prod_cat , sum(total_amt) as tot_revenue
   from 
   prod_cat_info as T1
   left join Transactions as T2 on T1.prod_cat_code = T2. prod_cat_code  
   where prod_cat = 'Electronics' or prod_cat = 'Books'
   group by prod_cat 

-- Q7. How many customers have > 10 transations with us excluding returns ?
  select 
  cust_id , count( transaction_id) as no_of_trans
  from 
  transactions
  where 
  Qty>0
  group by 
  cust_id
  having 
  count( transaction_id) >10

--Q8. What is the combined revenue earned from the "Electronics" & "Clothing" categories from "Flagship store" ?

 
   
   select sum (tot_revenue) as combined_revenue  from   
   (
   select 
   sum(total_amt) as tot_revenue 
   from 
   prod_cat_info as T1
   left join Transactions as T2 on T1.prod_cat_code = T2. prod_cat_code  
   where 
   (prod_cat = 'Electronics' or prod_cat = 'Clothing') and (Store_type = 'Flagship store')
   group by 
   prod_cat) as Tot_rev
 

 --Q9. What is the total revenue generated from "Male" customers in "electronics" category ? Output should display total revenue by prod sub-cat.
  select 
  prod_subcat , sum(total_amt) as tot_rev
  from 
  Transactions as T1 
  left join Customer as T2 on T1.cust_Id = T2.customer_Id
  left join prod_cat_info as T3 on T1.prod_cat_code = T3. prod_cat_code and T1.prod_subcat_code = T3.prod_sub_cat_code
  where 
  Gender = 'M' and prod_cat = 'Electronics'
  group by 
  prod_subcat
  

--Q10. What is the percentage of sales and returns by product sub category ;Display only top 5 sub categories in terms of sales .
 select 
 top 5 
 prod_subcat,                     

 sum (case when total_amt > 0 then total_amt end ) / (select sum (case when total_amt > 0 then total_amt end )from Transactions) 
 as sales_percentage,

 sum (case when total_amt < 0 then total_amt end ) / ( select  sum (case when total_amt < 0 then total_amt end )from Transactions )
 as returns_percentage 

 from Transactions as T1
 inner join prod_cat_info as T2 on T1.prod_cat_code = T2.prod_cat_code and T1.prod_subcat_code = T2. prod_sub_cat_code
 group by 
 prod_subcat
 order by sales_percentage desc



--Q 11. For all the customers aged between 25 to 35 years find what is the net total revenue genaerated by these consumers 
        --in last 30 days of transactions from max transaction date available in the data .
	select T1.customer_Id ,  sum(total_amt ) as rev , DATEPART(year , getdate())-DATEPART(year , DOB ) as age
	from 
	Customer as T1
	left join Transactions as T2 on T1.customer_Id = T2.cust_id
	left join (select DATEADD(day , -30 ,max_dte) as date_30 ,cust_id
				from
				(                                                 
				select 
				cust_id , max(tran_date)  as max_dte
				from 
				Transactions
				group by cust_id) as TT) as T3 on T2.cust_id = T3.cust_id
	where tran_date > date_30
	group by T1.customer_Id , DATEPART(year , getdate())-DATEPART(year , DOB )
	having DATEPART(year , getdate())-DATEPART(year , DOB ) >='25' and DATEPART(year , getdate())-DATEPART(year , DOB )<='35'

--Q12. Which product category has seen the maximum value of returns in the last 3 months of transactions ?
	select prod_cat , min(case when Qty <0 then Qty end  ) as max_qty  
	from 
	Transactions as T1
	inner join prod_cat_info as T2 on T1.prod_cat_code = T2.prod_cat_code and T1.prod_subcat_code= T2.prod_sub_cat_code
	where tran_date > DATEADD(month , -3 ,tran_date) 
	group by prod_cat

--Q13. Which store type sells the maximum products ; by value of sales amount and by quantity sold ?
	select top 1
	Store_type , sum(total_amt ) as value_sales, sum( Qty)  as qty_sold 
	from 
	Transactions
	group by 
	Store_type
	order by sum(total_amt ) desc

--Q14. What are the categories for which average revenue is above the overall average .
	 select prod_cat , avg(total_amt) as avg_rev 
	 from 
	 Transactions as T1
	 left join prod_cat_info as T2 on T1.prod_cat_code = T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
	 group by prod_cat
	 having avg(total_amt) > (select avg(total_amt ) as overall_avg from Transactions)

--Q15. Find the average and total revenue by each subcategory for the categories which are among top 5 categories in terms of quantity sold 

    select 
	T3.prod_cat ,prod_subcat , avg(total_amt) as avg_rev , sum(total_amt) as tot_rev
	from 
	Transactions as T1
	left join prod_cat_info     as T2 on T1.prod_cat_code= T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
	right join (select top 5
				prod_cat   , sum(qty) as tot_qt                         
				from 
				Transactions as T1
				left join prod_cat_info as T2 on T1.prod_cat_code= T2.prod_cat_code and T1.prod_subcat_code = T2.prod_sub_cat_code
				group by prod_cat 
				order by sum(qty)  desc)     as T3 on T2.prod_cat = T3.prod_cat
	group by prod_subcat , T3.prod_cat

