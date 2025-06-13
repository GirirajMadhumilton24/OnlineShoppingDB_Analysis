-- CREATING DATABASE
CREATE DATABASE OnlineShoppingDB;

-- USING DATABASE
USE OnlineShoppingDB;

-- VIEWING ALL THE IMPORTED TABLES
SELECT * FROM Customers
SELECT * FROM Order_items
SELECT * FROM Orders
SELECT * FROM Products
SELECT * FROM Payments

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- QUESTION 1
-- BUILDING RELATIONSHIP USING 
-- Orders → Customers
ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customers
FOREIGN KEY (customer_id)
REFERENCES Customers(customer_id);

-- Orders_items → Orders
ALTER TABLE Order_items
ADD CONSTRAINT FK_OrderItems_Orders
FOREIGN KEY (order_id)
REFERENCES Orders(order_id);

-- Orders_items → Products
ALTER TABLE Order_items
ADD CONSTRAINT FK_OrderItems_Products
FOREIGN KEY (product_id)
REFERENCES Products(product_id);

-- Payments → Orders
ALTER TABLE Payments
ADD CONSTRAINT FK_Payments_Orders
FOREIGN KEY (order_id)
REFERENCES Orders(order_id);
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- FORMATTING DECIMAL VALUES ON THE TABLE
-- ORDER_ITEMS TABLE
ALTER TABLE Order_items
ALTER COLUMN price_each DECIMAL(12,2);

ALTER TABLE Order_items
ALTER COLUMN Total_price DECIMAL(12,2);

ALTER TABLE Order_items
ALTER COLUMN [Total amount] DECIMAL(12,2);

-- PAYMENTS TABLE
ALTER TABLE Payments
ALTER COLUMN Amount_paid DECIMAL(12,2);

-- PRODUCTS TABLE
ALTER TABLE Products
ALTER COLUMN price DECIMAL(12,2);
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 2
-- Get names and countries of customers who made orders with a total amount between £500 and £1000.
-- SOLUTION FOR Q2
SELECT 
    C.name, 
    C.country,
	OI.[Total amount]
FROM 
    Customers AS C
JOIN Orders AS O
    ON C.customer_id = O.customer_id
JOIN Order_items AS OI
    ON O.order_id = OI.order_id
WHERE 
    OI.[Total amount] BETWEEN 500 AND 1000
ORDER BY OI.[Total amount] ASC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 3
-- Get the total amount paid by customers belonging to UK who bought at least more than three products in an order.
-- SOLUTION FOR Q3
SELECT 
    C.name,
    SUM(P.Amount_paid) AS Total_amount_paid
FROM 
    Customers AS C
JOIN Orders AS O
    ON C.customer_id = O.customer_id
JOIN Order_items AS OI
    ON O.order_id = OI.order_id
JOIN Payments AS P
    ON O.order_id = P.order_id
WHERE 
    C.country = 'UK'
GROUP BY 
    C.name, 
    C.country
HAVING 
    SUM(OI.quantity) > 3;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 4
-- Return the highest and second highest amount_paid from UK or Australia after applying VAT (12.2%) — round to nearest integer
-- SOLUTION FOR Q4
SELECT DISTINCT TOP 2
   CAST( ROUND(P.Amount_paid * 1.122, 0) AS DECIMAL(10,0)) AS amount_with_vat,
    C.country
FROM 
    Customers AS C
JOIN Orders AS O
    ON C.customer_id = O.customer_id
JOIN Payments AS P
    ON O.order_id = P.order_id
WHERE 
    C.country IN ('UK', 'Australia')
ORDER BY 
    amount_with_vat DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 5
-- Return distinct product_name and total quantity purchased, sorted by total_quantity
-- SOLUTION FOR 5
SELECT 
    DISTINCT(P.product_name),
    SUM(OI.quantity) AS total_quantity
FROM 
    Products AS P
JOIN Order_items AS OI
    ON P.product_id = OI.product_id
GROUP BY 
    P.product_name
ORDER BY 
    total_quantity DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- QUESTION 6
-- Write a stored procedure for the query given as: Update the amount_paid of customers who purchased either laptop or smartphone as products and amount_paid>=£17000 of all orders to the discount of 5%.
-- SOLUTION FOR Q6
-- CREATING STORED PROCEDURE

CREATE PROCEDURE Apply_Discount_To_HighValue_Orders
AS
BEGIN
    UPDATE P
    SET P.Amount_paid = P.Amount_paid * 0.95
    FROM Payments AS P
    JOIN Orders AS O
        ON P.order_id = O.order_id
    JOIN Order_items AS OI
        ON O.order_id = OI.order_id
    JOIN Products AS PR
        ON OI.product_id = PR.product_id
    WHERE 
        PR.product_name IN ('Laptop', 'Smartphone')
        AND P.Amount_paid >= 17000;
END;

-- BEFORE STORED PROCEDURE
SELECT 
    PR.Product_name, 
    P.Amount_paid
FROM Payments AS P
JOIN Orders AS O 
    ON P.order_id = O.order_id
JOIN Order_items AS OI 
    ON O.order_id = OI.order_id
JOIN Products AS PR 
    ON OI.product_id = PR.product_id
WHERE PR.product_name IN ('Laptop', 'Smartphone')
ORDER BY Amount_paid DESC;

-- AFTER STORED PROCEDURE
-- Start the transaction
BEGIN TRANSACTION;

-- Execute the stored procedure to apply the discount to qualifying orders (Laptop or Smartphone)
EXEC Apply_Discount_To_HighValue_Orders;

-- Display the Product Name and Amount Paid
SELECT 
    PR.Product_name, 
    P.Amount_paid
FROM Payments AS P
JOIN Orders AS O 
    ON P.order_id = O.order_id
JOIN Order_items AS OI 
    ON O.order_id = OI.order_id
JOIN Products AS PR 
    ON OI.product_id = PR.product_id
WHERE PR.product_name IN ('Laptop', 'Smartphone')
ORDER BY Amount_paid DESC;

-- Rollback the changes to undo the discount
ROLLBACK;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--QUESTION 7
--You should also write at least five queries of your own.

--Q1
-- Find customers who have never bought products from the category 'Accessories'.
SELECT name, country
FROM Customers C
WHERE NOT EXISTS (
    SELECT 1
    FROM Orders O
    JOIN Order_items OI ON O.order_id = OI.order_id
    JOIN Products P ON OI.product_id = P.product_id
    WHERE O.customer_id = C.customer_id AND P.category = 'Accessories'
)
ORDER BY C.country;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q2
--Which customers have placed more than 3 orders, and what is their total spend?
SELECT 
    C.name,
    COUNT(O.order_id) AS total_orders,
    SUM(P.Amount_paid) AS total_spent
FROM Customers C
JOIN Orders O ON C.customer_id = O.customer_id
JOIN Payments P ON O.order_id = P.order_id
GROUP BY C.name
HAVING COUNT(O.order_id) > 3;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q3
--List all customers who made at least one payment using 'PayPal'.
SELECT name, email
FROM Customers C
WHERE EXISTS (
    SELECT 1
    FROM Orders O
    JOIN Payments P ON O.order_id = P.order_id
    WHERE O.customer_id = C.customer_id
    AND P.payment_method = 'PayPal'
);
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q4
--For each product, show the customer who spent the most on it (by total amount), including how much they spent.
SELECT product_name, name AS top_buyer, MAX(customer_spend) AS amount_spent
FROM (
    SELECT 
        P.product_name,
        C.name,
        SUM(OI.Total_price) AS customer_spend
    FROM Order_items OI
    JOIN Products P ON OI.product_id = P.product_id
    JOIN Orders O ON OI.order_id = O.order_id
    JOIN Customers C ON O.customer_id = C.customer_id
    GROUP BY P.product_name, C.name
) AS spend_data
GROUP BY product_name, name;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--Q5
-- Find the number of orders placed by customers in each month of the year 2024, and sort by month.
SELECT 
    DATENAME(MONTH, O.order_date) AS order_month,
    COUNT(O.order_id) AS total_orders
FROM Orders O
WHERE YEAR(O.order_date) = 2024
GROUP BY DATENAME(MONTH, O.order_date), DATEPART(MONTH, O.order_date)
ORDER BY DATEPART(MONTH, O.order_date);