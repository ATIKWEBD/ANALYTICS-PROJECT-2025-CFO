CREATE DATABASE accordionp;
USE accordionp;

CREATE TABLE products (SKU VARCHAR(255), Product_Category VARCHAR(255), Unit_Cost DECIMAL(10, 2));
CREATE TABLE customers (Customer_ID INT PRIMARY KEY, Customer_Name VARCHAR(255), Salesperson_ID INT);
CREATE TABLE sales_team (Salesperson_ID INT PRIMARY KEY, Salesperson_Name VARCHAR(255));
CREATE TABLE transactions (Transaction_ID INT PRIMARY KEY, Customer_ID INT, SKU VARCHAR(255), Units_Sold INT, Unit_Price DECIMAL(10, 2), Transaction_Date DATE);
CREATE TABLE logistics (Transaction_ID INT, Shipping_Cost DECIMAL(10, 2), Delivery_Region VARCHAR(255));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/erp_products.csv' INTO TABLE products FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm_customers.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/hr_sales_team.csv' INTO TABLE sales_team FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/crm_transactions.csv' INTO TABLE transactions FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS (Transaction_ID, Customer_ID, SKU, Units_Sold, @Unit_Price, Transaction_Date) SET Unit_Price = NULLIF(@Unit_Price, '');
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/warehouse_logistics.csv' INTO TABLE logistics FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
CREATE TABLE single_source_of_truth AS
SELECT
    t.Transaction_ID, t.Transaction_Date, p.Product_Category, c.Customer_Name, s.Salesperson_Name,
    IFNULL(l.Delivery_Region, 'Unknown') AS Delivery_Region,
    t.Units_Sold,
    IFNULL(t.Unit_Price, (SELECT AVG(Unit_Price) FROM transactions)) AS Unit_Price,
    p.Unit_Cost,
    IFNULL(l.Shipping_Cost, 0) AS Shipping_Cost,
    (t.Units_Sold * IFNULL(t.Unit_Price, (SELECT AVG(Unit_Price) FROM transactions))) AS Total_Revenue,
    (t.Units_Sold * p.Unit_Cost) AS Total_Cost,
    ((t.Units_Sold * IFNULL(t.Unit_Price, (SELECT AVG(Unit_Price) FROM transactions))) - (t.Units_Sold * p.Unit_Cost) - IFNULL(l.Shipping_Cost, 0)) AS Gross_Profit
FROM transactions t
LEFT JOIN (SELECT DISTINCT UPPER(SKU) AS SKU, Product_Category, Unit_Cost FROM products) p ON UPPER(t.SKU) = p.SKU
LEFT JOIN customers c ON t.Customer_ID = c.Customer_ID
LEFT JOIN sales_team s ON c.Salesperson_ID = s.Salesperson_ID
LEFT JOIN logistics l ON t.Transaction_ID = l.Transaction_ID;
(SELECT
    'Transaction_ID', 'Transaction_Date', 'Product_Category', 'Customer_Name', 'Salesperson_Name',
    'Delivery_Region', 'Units_Sold', 'Unit_Price', 'Unit_Cost', 'Shipping_Cost',
    'Total_Revenue', 'Total_Cost', 'Gross_Profit'
)
UNION ALL
(SELECT * FROM single_source_of_truth)
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/single_source_of_truth.csv'
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n';