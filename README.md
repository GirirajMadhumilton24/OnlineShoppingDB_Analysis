# OnlineShoppingDB_Analaysis_on_SSMS

## Project Overview
OnlineShoppingDB is a relational database system developed to support the operations of an online retail platform. It manages key data entities such as customers, products, orders, and payments, facilitating consistent and reliable transactional processing. Designed using structured T-SQL and normalized to Third Normal Form (3NF), the system ensures minimal redundancy and maintains data integrity.

This database supports secure and efficient handling of order management, payment tracking, and insightful reporting, enabling smarter business decisions and enhanced customer engagement.

---

## Part 1: Database Setup and Structure

### Creating the Database
- The database `OnlineShoppingDB` provides a clean environment to store tables, queries, and other objects related to the online shopping system.
- Use `USE OnlineShoppingDB;` to select the database context for all subsequent operations.

### Importing Data
- CSV files containing Customers, Products, Orders, Order_items, and Payments data are imported via SQL Server Management Studio’s Import Flat File wizard.
- During import, appropriate primary keys are set and data types are assigned for each column.

### Verifying Data Import
- Imported tables are verified with simple queries like `SELECT * FROM Customers` to ensure accuracy and accessibility.

### Defining Relationships
- Foreign key constraints enforce relationships:
  - Orders linked to Customers (`customer_id`)
  - Order_items linked to Orders (`order_id`) and Products (`product_id`)
  - Payments linked to Orders (`order_id`)
- These constraints maintain referential integrity and prevent orphaned records.

### Data Type Adjustments
- Monetary columns such as prices and payment amounts are altered to use `DECIMAL(12,2)` for precision and consistency.

### Entity-Relationship Diagram (ERD)
- The ERD illustrates the relationships among Customers, Orders, Order_items, Products, and Payments, ensuring seamless integration of customer activity, product selection, and transaction handling.

---

## Part 2: Queries and Stored Procedures

### Key Queries
1. **Customers with Orders Between £500 and £1000**  
   Retrieves customer names and countries for orders within this range, sorted by total amount.

2. **Total Amount Paid by UK Customers Buying More Than Three Products**  
   Lists UK customers with total payments, identifying high-value buyers.

3. **Top Two Highest Payments from UK or Australia After VAT (12.2%)**  
   Returns the highest and second highest payment amounts with VAT applied, rounded to the nearest integer.

4. **Product Sales Summary**  
   Shows distinct product names and total quantities sold, sorted by quantity to identify best-sellers.

5. **Stored Procedure: Apply 5% Discount on High-Value Laptop or Smartphone Orders**  
   Reduces payment amounts by 5% for orders with payments ≥ £17,000 involving laptops or smartphones.

### Additional Queries
- Customers who have never purchased from the 'Accessories' category.
- Customers with more than three orders and their total spend.
- Customers who have made at least one payment using PayPal.
- For each product, the customer who spent the most and the amount spent.
- Number of orders placed each month in 2024, sorted chronologically.

---

## Backup and Restore Procedures

### Backup
- Backup the database through SSMS by selecting Tasks > Backup.
- Choose destination, set compression, overwrite existing backups, and define expiration date.
- Confirm success via notification.

### Restore
- Restore the database using SSMS Object Explorer by selecting Restore Database.
- Specify the backup file location and proceed with the restore process.
- Confirm successful restoration via notification.

---

## Conclusion

This database system supports enhanced business intelligence by providing detailed insights into customer behavior, payment preferences, product popularity, and sales trends. By identifying high-value customers and purchase patterns, businesses can tailor marketing strategies, optimize inventory management, and increase profitability. The normalized structure and well-defined relationships ensure data accuracy and reliability, empowering data-driven decision-making for improved customer engagement and sales growth.

---

## Technologies Used
- Microsoft SQL Server
- T-SQL (Transact-SQL)
- SQL Server Management Studio (SSMS)

---

## Author
[Your Name]

---

## License
[Specify license here, if applicable]
