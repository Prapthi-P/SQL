/*

-----------------------------------------------------------------------------------------------------------------------------------
													    Guidelines
-----------------------------------------------------------------------------------------------------------------------------------

The provided document is a guide for the project. Follow the instructions and take the necessary steps to finish
the project in the SQL file			

-----------------------------------------------------------------------------------------------------------------------------------
                                                         Queries
                                               
-----------------------------------------------------------------------------------------------------------------------------------*/
 
 USE new_wheels;
  

  
/*-- QUESTIONS RELATED TO CUSTOMERS
     [Q1] What is the distribution of customers across states?
     Hint: For each state, count the number of customers.*/
 
 SELECT State, COUNT(*) AS CUSTOMER_COUNT
 FROM  customer_t
 GROUP BY STATE
 ORDER BY CUSTOMER_COUNT DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q2] What is the average rating in each quarter?
-- Very Bad is 1, Bad is 2, Okay is 3, Good is 4, Very Good is 5.

Hint: Use a common table expression and in that CTE, assign numbers to the different customer ratings. 
      Now average the feedback for each quarter. */


WITH CTE AS(
	SELECT QUARTER_NUMBER, CUSTOMER_FEEDBACK,
		CASE 
			WHEN customer_feedback = 'Very Bad' THEN 1
			WHEN customer_feedback = 'Bad' THEN 2
			WHEN customer_feedback = 'Okay' THEN 3
			WHEN customer_feedback = 'Good' THEN 4
			WHEN customer_feedback = 'Very Good' THEN 5
			ELSE customer_feedback  
		END AS CUSTOMER_RATING
	FROM order_t)
SELECT quarter_number, AVG(CUSTOMER_RATING) AS AVG_RATING
FROM CTE
GROUP BY QUARTER_NUMBER
ORDER BY QUARTER_NUMBER;




-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q3] Are customers getting more dissatisfied over time?

Hint: Need the percentage of different types of customer feedback in each quarter. Use a common table expression and
	  determine the number of customer feedback in each category as well as the total number of customer feedback in each quarter.
	  Now use that common table expression to find out the percentage of different types of customer feedback in each quarter.
      Eg: (total number of very good feedback/total customer feedback)* 100 gives you the percentage of very good feedback. */
      

WITH CTE AS 
(SELECT QUARTER_NUMBER, COUNT(*) AS TOTAL_FEEDBACK,
	COUNT(CASE 
			WHEN CUSTOMER_FEEDBACK ='Very Bad' THEN 1
		  END) AS VeryBad_Count,
	COUNT(CASE 
			WHEN CUSTOMER_FEEDBACK ='Bad' THEN 2
          END) AS Bad_Count,  
	COUNT(CASE 
			WHEN CUSTOMER_FEEDBACK ='Okay' THEN 3
          END) AS Okay_Count,
	COUNT(CASE 
			WHEN CUSTOMER_FEEDBACK ='Good' THEN 4
          END) AS Good_Count,       
	COUNT(CASE 
			WHEN CUSTOMER_FEEDBACK ='Very Good' THEN 5
          END) AS VeryGood_Count   		

FROM order_t
GROUP BY QUARTER_NUMBER
ORDER BY QUARTER_NUMBER
)
SELECT QUARTER_NUMBER,
	((VeryBad_Count / TOTAL_FEEDBACK) * 100) AS VeryBad_Percentage,
	((Bad_Count / TOTAL_FEEDBACK) * 100) AS Bad_Percentage,
	((Okay_Count / TOTAL_FEEDBACK) * 100) AS Okay_Percentage,
	((Good_Count / TOTAL_FEEDBACK) * 100) AS Good_Percentage,
	((VeryGood_Count / TOTAL_FEEDBACK) * 100) AS VeryGood_Percentage
FROM CTE;



-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q4] Which are the top 5 vehicle makers preferred by the customer.

Hint: For each vehicle make what is the count of the customers.*/

SELECT VEHICLE_MAKER, COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT
FROM order_t AS ot
INNER JOIN product_t AS pt ON pt.PRODUCT_ID= ot.PRODUCT_ID
GROUP BY VEHICLE_MAKER
ORDER BY CUSTOMER_COUNT DESC LIMIT 5;


-- ---------------------------------------------------------------------------------------------------------------------------------

/*[Q5] What is the most preferred vehicle make in each state?

Hint: Use the window function RANK() to rank based on the count of customers for each state and vehicle maker. 
After ranking, take the vehicle maker whose rank is 1.*/

SELECT STATE, VEHICLE_MAKER, CUSTOMER_COUNT
FROM(
	SELECT CT.STATE, PT.VEHICLE_MAKER, COUNT(OT.CUSTOMER_ID) AS CUSTOMER_COUNT,
		RANK() OVER(PARTITION BY CT.STATE ORDER BY COUNT(OT.CUSTOMER_ID) DESC) AS RANKING
    FROM order_t AS OT
	INNER JOIN customer_t AS CT ON CT.CUSTOMER_ID= OT.CUSTOMER_ID
	INNER JOIN product_t AS PT ON PT.PRODUCT_ID= OT.PRODUCT_ID
	GROUP BY CT.STATE, PT.VEHICLE_MAKER
	) AS RESULT
WHERE RANKING = 1;




-- ---------------------------------------------------------------------------------------------------------------------------------

/*QUESTIONS RELATED TO REVENUE and ORDERS 

-- [Q6] What is the trend of number of orders by quarters?

Hint: Count the number of orders for each quarter.*/

SELECT ot.quarter_number, COUNT(ot.ORDER_ID) AS ORDER_COUNT
FROM order_t AS ot
/*INNER JOIN order_t AS rep ON ot.quarter_number= rep.quarter_number*/
GROUP BY ot.quarter_number 
ORDER BY ot.quarter_number;

-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q7] What is the quarter over quarter % change in revenue? 

Hint: Quarter over Quarter percentage change in revenue means what is the change in revenue from the subsequent quarter to the previous quarter in percentage.
      To calculate you need to use the common table expression to find out the sum of revenue for each quarter.
      Then use that CTE along with the LAG function to calculate the QoQ percentage change in revenue.
*/
      
WITH CTE AS (
	SELECT QUARTER_NUMBER,
		SUM(VEHICLE_PRICE * QUANTITY * (1 - DISCOUNT / 100)) AS REVENUE
	FROM order_t AS ot
	GROUP BY QUARTER_NUMBER
	ORDER BY QUARTER_NUMBER)
SELECT QUARTER_NUMBER, REVENUE,
	LAG(REVENUE) OVER (ORDER BY QUARTER_NUMBER) AS PREV_REVENUE,
	(((REVENUE-LAG(REVENUE) OVER (ORDER BY QUARTER_NUMBER)) / LAG(REVENUE) OVER (ORDER BY QUARTER_NUMBER)) * 100) AS QOQ
FROM CTE;



-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q8] What is the trend of revenue and orders by quarters?

Hint: Find out the sum of revenue and count the number of orders for each quarter.*/


SELECT ot.QUARTER_NUMBER, COUNT(ot.ORDER_ID) AS ORDER_COUNT,
	SUM(VEHICLE_PRICE * QUANTITY *(1-DISCOUNT/100)) AS REVENUE
FROM order_t AS ot
GROUP BY ot.quarter_number
ORDER BY ot.quarter_number;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* QUESTIONS RELATED TO SHIPPING 
    [Q9] What is the average discount offered for different types of credit cards?

Hint: Find out the average of discount for each credit card type.*/

SELECT CREDIT_CARD_TYPE, AVG(DISCOUNT) AS DISCOUNT_AVG
FROM customer_t AS ct
INNER JOIN order_t AS ot ON ct.CUSTOMER_ID= ot.CUSTOMER_ID
GROUP BY CREDIT_CARD_TYPE
ORDER BY DISCOUNT_AVG DESC;


-- ---------------------------------------------------------------------------------------------------------------------------------

/* [Q10] What is the average time taken to ship the placed orders for each quarters?
	Hint: Use the dateiff function to find the difference between the ship date and the order date.
*/

SELECT QUARTER_NUMBER, 
	AVG(DATEDIFF(SHIP_DATE, ORDER_DATE)) AS AVG_SHIPPING_TIME
FROM order_t 
GROUP BY QUARTER_NUMBER
ORDER BY QUARTER_NUMBER;


-- --------------------------------------------------------Done----------------------------------------------------------------------
-- ----------------------------------------------------------------------------------------------------------------------------------
#Overview 

#Total customers
SELECT SUM(CUSTOMER_COUNT) AS TOTAL_CUSTOMERS
FROM (
    SELECT COUNT(*) AS CUSTOMER_COUNT
    FROM customer_t
    GROUP BY STATE) AS STATE_COUNTS;

#Total orders
SELECT SUM(ORDER_COUNT) AS TOTAL_ORDERS
FROM (
    SELECT COUNT(ORDER_ID) AS ORDER_COUNT
    FROM order_t
    GROUP BY quarter_number) AS QUARTERLY_COUNTS;

#Total revenue
SELECT SUM(REVENUE) AS TOTAL_REVENUE
FROM (
    SELECT SUM(VEHICLE_PRICE * QUANTITY * (1 - DISCOUNT / 100)) AS REVENUE
    FROM order_t
    GROUP BY QUARTER_NUMBER) AS QUARTERLY_REVENUE;

#Avg days to ship
SELECT AVG(AVG_SHIPPING_TIME) AS AVERAGE_DAYS_TO_SHIP
FROM (
    SELECT QUARTER_NUMBER, AVG(DATEDIFF(SHIP_DATE, ORDER_DATE)) AS AVG_SHIPPING_TIME
    FROM order_t 
    GROUP BY QUARTER_NUMBER) AS QUARTERLY_AVERAGE;
    

# % of Good Feedback

WITH CTE AS(
		SELECT QUARTER_NUMBER, COUNT(*) AS TOTAL_FEEDBACK,
			COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Very Bad' THEN 1 END) AS VeryBad_Count,
			COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Bad' THEN 1 END) AS Bad_Count,  
			COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Okay' THEN 1 END) AS Okay_Count,
			COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Good' THEN 1 END) AS Good_Count,       
			COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Very Good' THEN 1 END) AS VeryGood_Count   		
		FROM order_t
		GROUP BY QUARTER_NUMBER
		ORDER BY QUARTER_NUMBER)
SELECT AVG((Good_Count + VeryGood_Count) * 100.0 / TOTAL_FEEDBACK) AS Overall_Good_Percentage
FROM CTE;

#Avg Rating
WITH CTE AS (
    SELECT QUARTER_NUMBER, COUNT(*) AS TOTAL_FEEDBACK,
        COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Very Bad' THEN 1 END) * 1 AS VeryBad_Score,
        COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Bad' THEN 1 END) * 2 AS Bad_Score,  
        COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Okay' THEN 1 END) * 3 AS Okay_Score,
        COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Good' THEN 1 END) * 4 AS Good_Score,       
        COUNT(CASE WHEN CUSTOMER_FEEDBACK ='Very Good' THEN 1 END) * 5 AS VeryGood_Score   		
    FROM order_t
    GROUP BY QUARTER_NUMBER
    ORDER BY QUARTER_NUMBER)
SELECT AVG((VeryBad_Score + Bad_Score + Okay_Score + Good_Score + VeryGood_Score) / TOTAL_FEEDBACK) AS Average_Rating
FROM CTE;


#Last quarter revenue, orders
SELECT 
    SUM(REVENUE) AS Last_Quarter_Revenue,
    SUM(ORDER_COUNT) AS Last_Quarter_Orders
FROM (
    SELECT 
        QUARTER_NUMBER,
        SUM(VEHICLE_PRICE * QUANTITY * (1 - DISCOUNT / 100)) AS REVENUE,
        COUNT(ORDER_ID) AS ORDER_COUNT
    FROM order_t
    GROUP BY QUARTER_NUMBER
    HAVING QUARTER_NUMBER = (SELECT MAX(QUARTER_NUMBER) FROM order_t)
) AS Last_Quarter_Data;







