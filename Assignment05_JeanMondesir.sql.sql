--*************************************************************************--
-- Title: Assignment05
-- Author: Jean Mondesir
-- Desc: This file demonstrates how to use Joins and Subqueiers
-- Change Log: When,Who,What
-- 2024-07-31,Jean Mondesir,Created File
--**************************************************************************--
Use Master;
go

If Exists(Select Name From SysDatabases Where Name = 'Assignment05DB_JeanMondesir')
 Begin 
  Alter Database [Assignment05DB_JeanMondesir] set Single_user With Rollback Immediate;
  Drop Database Assignment05DB_JeanMondesir;
 End
go

Create Database Assignment05DB_JeanMondesir;
go

Use Assignment05DB_JeanMondesir;
go

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go


Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10 -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, UnitsInStock + 20 -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
-- Question 1 (10 pts): How can you show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
SELECT 
    C.CategoryName, 
    P.ProductName, 
    P.UnitPrice
FROM 
    Categories C
INNER JOIN Products P
    ON C.CategoryID = P.CategoryID
ORDER BY 
    C.CategoryName, 
    P.ProductName,
	P.UnitPrice;


-- Question 2 (10 pts): How can you show a list of Product name 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Date, Product,  and Count!
SELECT 
    P.ProductName, 
    I.InventoryDate, 
    I.Count
FROM 
    Inventories I
JOIN 
    Products P ON I.ProductID = P.ProductID
ORDER BY 
    I.InventoryDate, 
    P.ProductName, 
    I.Count;


-- Question 3 (10 pts): How can you show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
SELECT DISTINCT 
    I.InventoryDate, 
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM 
    Inventories I
JOIN 
    Employees E ON I.EmployeeID = E.EmployeeID
ORDER BY 
    I.InventoryDate;


-- Question 4 (10 pts): How can you show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
SELECT 
    C.CategoryName, 
    P.ProductName, 
    I.InventoryDate, 
    I.Count
FROM 
    Inventories I
JOIN 
    Products P ON I.ProductID = P.ProductID
JOIN 
    Categories C ON P.CategoryID = C.CategoryID
ORDER BY 
    C.CategoryName, 
    P.ProductName, 
    I.InventoryDate, 
    I.Count;


-- Question 5 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
SELECT 
    C.CategoryName, 
    P.ProductName, 
    I.InventoryDate, 
    I.Count, 
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM 
    Inventories I
JOIN 
    Products P ON I.ProductID = P.ProductID
JOIN 
    Categories C ON P.CategoryID = C.CategoryID
JOIN 
    Employees E ON I.EmployeeID = E.EmployeeID
ORDER BY 
    I.InventoryDate, 
    C.CategoryName, 
    P.ProductName, 
    E.EmployeeFirstName, 
    E.EmployeeLastName;


-- Question 6 (20 pts): How can you show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
-- For Practice; Use a Subquery to get the ProductID based on the Product Names 
-- and order the results by the Inventory Date, Category, and Product!
SELECT 
    C.CategoryName, 
    P.ProductName, 
    I.InventoryDate, 
    I.Count, 
    E.EmployeeFirstName + ' ' + E.EmployeeLastName AS EmployeeName
FROM 
    Inventories I
JOIN 
    Products P ON I.ProductID = P.ProductID
JOIN 
    Categories C ON P.CategoryID = C.CategoryID
JOIN 
    Employees E ON I.EmployeeID = E.EmployeeID
WHERE 
    P.ProductID IN (SELECT ProductID FROM Products WHERE ProductName IN ('Chai', 'Chang'))
ORDER BY 
    I.InventoryDate, 
    C.CategoryName, 
    P.ProductName;


-- Question 7 (20 pts): How can you show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
SELECT 
    E1.EmployeeFirstName + ' ' + E1.EmployeeLastName AS EmployeeName,
    E2.EmployeeFirstName + ' ' + E2.EmployeeLastName AS ManagerName
FROM 
    Employees E1
JOIN 
    Employees E2 ON E1.ManagerID = E2.EmployeeID
ORDER BY 
    ManagerName;


/***************************************************************************************/