-- =============================================================
-- AdventureWorks SSRS Demo — Azure SQL / SQL Server Setup
-- Preserves AdventureWorks schemas: Sales.*, Person.*
-- Compatible with: Azure SQL Database, SQL Server 2019+
-- Run in: Azure Data Studio, SSMS, or sqlcmd
-- =============================================================

-- Create schemas
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Person')
    EXEC('CREATE SCHEMA Person');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Sales')
    EXEC('CREATE SCHEMA Sales');
GO

-- -------------------------------------------------------
-- Person.Person
-- -------------------------------------------------------
IF OBJECT_ID('Person.Person', 'U') IS NOT NULL DROP TABLE Person.Person;
GO
CREATE TABLE Person.Person (
    BusinessEntityID  INT           NOT NULL,
    FirstName         NVARCHAR(50)  NOT NULL,
    LastName          NVARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Person PRIMARY KEY (BusinessEntityID)
);
GO

-- -------------------------------------------------------
-- Sales.SalesTerritory
-- -------------------------------------------------------
IF OBJECT_ID('Sales.SalesTerritory', 'U') IS NOT NULL DROP TABLE Sales.SalesTerritory;
GO
CREATE TABLE Sales.SalesTerritory (
    TerritoryID    INT             NOT NULL,
    Name           NVARCHAR(50)    NOT NULL,
    [Group]        NVARCHAR(50)    NOT NULL,
    SalesYTD       DECIMAL(19,4)   NOT NULL DEFAULT 0,
    SalesLastYear  DECIMAL(19,4)   NOT NULL DEFAULT 0,
    CONSTRAINT PK_SalesTerritory PRIMARY KEY (TerritoryID)
);
GO

-- -------------------------------------------------------
-- Sales.SalesPerson
-- -------------------------------------------------------
IF OBJECT_ID('Sales.SalesPerson', 'U') IS NOT NULL DROP TABLE Sales.SalesPerson;
GO
CREATE TABLE Sales.SalesPerson (
    BusinessEntityID  INT           NOT NULL,
    TerritoryID       INT           NULL,
    SalesQuota        DECIMAL(19,4) NULL,
    Bonus             DECIMAL(19,4) NOT NULL DEFAULT 0,
    CommissionPct     DECIMAL(10,4) NOT NULL DEFAULT 0,
    SalesYTD          DECIMAL(19,4) NOT NULL DEFAULT 0,
    SalesLastYear     DECIMAL(19,4) NOT NULL DEFAULT 0,
    CONSTRAINT PK_SalesPerson      PRIMARY KEY (BusinessEntityID),
    CONSTRAINT FK_SP_Person        FOREIGN KEY (BusinessEntityID) REFERENCES Person.Person(BusinessEntityID),
    CONSTRAINT FK_SP_Territory     FOREIGN KEY (TerritoryID)      REFERENCES Sales.SalesTerritory(TerritoryID)
);
GO

-- -------------------------------------------------------
-- Sales.SalesOrderHeader
-- -------------------------------------------------------
IF OBJECT_ID('Sales.SalesOrderHeader', 'U') IS NOT NULL DROP TABLE Sales.SalesOrderHeader;
GO
CREATE TABLE Sales.SalesOrderHeader (
    SalesOrderID     INT            NOT NULL,
    OrderDate        DATETIME2      NOT NULL,
    DueDate          DATETIME2      NOT NULL,
    ShipDate         DATETIME2      NULL,
    Status           TINYINT        NOT NULL,  -- 1=InProcess 2=Approved 3=BackOrdered 4=Rejected 5=Shipped 6=Cancelled
    SalesOrderNumber NVARCHAR(25)   NOT NULL,
    SalesPersonID    INT            NULL,
    SubTotal         DECIMAL(19,4)  NOT NULL DEFAULT 0,
    TaxAmt           DECIMAL(19,4)  NOT NULL DEFAULT 0,
    Freight          DECIMAL(19,4)  NOT NULL DEFAULT 0,
    TotalDue         AS (SubTotal + TaxAmt + Freight),
    CONSTRAINT PK_SalesOrderHeader   PRIMARY KEY (SalesOrderID),
    CONSTRAINT FK_SOH_SalesPerson    FOREIGN KEY (SalesPersonID) REFERENCES Person.Person(BusinessEntityID)
);
GO

-- =============================================================
-- SEED DATA
-- =============================================================

-- Sales.SalesTerritory
INSERT INTO Sales.SalesTerritory (TerritoryID, Name, [Group], SalesYTD, SalesLastYear) VALUES
    (1,  'Northwest',      'North America', 7887186.7800, 5765568.4100),
    (2,  'Northeast',      'North America', 2402176.8400, 2237516.5900),
    (3,  'Central',        'North America', 3072175.1200, 2538667.2400),
    (4,  'Southwest',      'North America', 10510853.8700, 9557153.2700),
    (5,  'Southeast',      'North America', 2538667.2400, 1983988.4300),
    (6,  'Canada',         'North America', 6771829.3100, 5753307.5900),
    (7,  'France',         'Europe',        4772398.3200, 3852252.8800),
    (8,  'Germany',        'Europe',        3053307.8900, 2641820.0400),
    (9,  'Australia',      'Pacific',       5765568.4100, 4258494.3200),
    (10, 'United Kingdom', 'Europe',        4116871.2300, 3497046.3800);
GO

-- Person.Person
INSERT INTO Person.Person (BusinessEntityID, FirstName, LastName) VALUES
    (274, 'Stephen',  'Jiang'),
    (275, 'Michael',  'Blythe'),
    (276, 'Linda',    'Mitchell'),
    (277, 'Jillian',  'Carson'),
    (278, 'Garrett',  'Vargas'),
    (279, 'Tsvi',     'Reiter'),
    (280, 'Pamela',   'Ansman-Wolfe'),
    (281, 'Shu',      'Ito'),
    (282, 'Jose',     'Saraiva'),
    (283, 'David',    'Campbell');
GO

-- Sales.SalesPerson
INSERT INTO Sales.SalesPerson (BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear) VALUES
    (274, NULL, NULL,          0.00,    0.0000, 559697.5600,  0.0000),
    (275, 2,    300000.0000,   4100.00, 0.0120, 3763178.1800, 1750406.4700),
    (276, 5,    250000.0000,   2000.00, 0.0120, 4251368.5500, 1439156.0200),
    (277, 3,    250000.0000,   2500.00, 0.0150, 3189418.3700, 1997186.1900),
    (278, 6,    250000.0000,   500.00,  0.0150, 1453719.4700, 1620276.8900),
    (279, 4,    300000.0000,   6700.00, 0.0150, 2315185.6100, 1849640.9300),
    (280, 1,    250000.0000,   5000.00, 0.0150, 1352577.1300, 0.0000),
    (281, 9,    300000.0000,   5000.00, 0.0120, 2458535.6200, 2278548.9800),
    (282, 7,    250000.0000,   5000.00, 0.0120, 2604540.7200, 2038234.6500),
    (283, 8,    275000.0000,   5000.00, 0.0150, 1573012.9400, 1371635.0900);
GO

-- Sales.SalesOrderHeader
INSERT INTO Sales.SalesOrderHeader (SalesOrderID, OrderDate, DueDate, ShipDate, Status, SalesOrderNumber, SalesPersonID, SubTotal, TaxAmt, Freight) VALUES
    (43659, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43659', 275, 20565.6200, 1971.5200, 616.1000),
    (43660, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43660', 276, 1294.2500,  124.2400,  38.8200),
    (43661, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43661', 277, 32726.4800, 3153.7800, 985.5500),
    (43662, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43662', 278, 28832.5300, 2774.2700, 867.2700),
    (43663, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43663', 279, 419.4600,   40.2700,   12.5900),
    (43664, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43664', 280, 24432.6100, 2349.5700, 734.2400),
    (43665, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43665', 281, 14352.7800, 1379.8900, 431.2200),
    (43666, '2023-08-01', '2023-08-13', '2023-08-07', 5, 'SO43666', 282, 5765.3400,  554.1900,  173.1800),
    (43667, '2023-08-01', '2023-08-13', '2023-08-07', 5, 'SO43667', 283, 3754.4400,  360.8800,  112.7700),
    (43668, '2023-08-05', '2023-08-17', '2023-08-12', 5, 'SO43668', 275, 14265.8700, 1371.2400, 428.5100),
    (43669, '2023-08-10', '2023-08-22', '2023-08-18', 5, 'SO43669', 276, 7330.9000,  704.4900,  220.1500),
    (43670, '2023-09-01', '2023-09-13', '2023-09-08', 5, 'SO43670', 277, 22143.5600, 2128.8000, 665.2500),
    (43671, '2023-09-05', '2023-09-17', '2023-09-12', 5, 'SO43671', 278, 11389.2800, 1095.0100, 342.1900),
    (43672, '2023-09-15', '2023-09-27', '2023-09-22', 5, 'SO43672', 279, 9165.4300,  880.9600,  275.3000),
    (43673, '2023-10-01', '2023-10-13', '2023-10-07', 5, 'SO43673', 280, 18457.2200, 1774.6200, 554.5700),
    (43674, '2023-10-05', '2023-10-17', '2023-10-12', 5, 'SO43674', 281, 25312.4500, 2433.9600, 760.6100),
    (43675, '2023-10-15', '2023-10-27', '2023-10-22', 5, 'SO43675', 282, 16234.6700, 1560.6400, 487.7000),
    (43676, '2023-11-01', '2023-11-13', '2023-11-08', 5, 'SO43676', 283, 8956.2300,  861.1100,  269.1000),
    (43677, '2023-11-10', '2023-11-22', '2023-11-18', 5, 'SO43677', 275, 32178.9000, 3092.0400, 966.9000),
    (43678, '2023-12-01', '2023-12-13', '2023-12-08', 5, 'SO43678', 276, 4567.8900,  439.0800,  137.2100),
    (43679, '2024-01-05', '2024-01-17', NULL,          3, 'SO43679', 277, 15234.5600, 1464.0500, 457.5200),
    (43680, '2024-01-10', '2024-01-22', NULL,          2, 'SO43680', 278, 9876.5400,  949.4400,  296.7000),
    (43681, '2024-01-15', '2024-01-27', NULL,          1, 'SO43681', 279, 3456.7800,  332.2100,  103.8200),
    (43682, '2024-02-01', '2024-02-13', '2024-02-09', 5, 'SO43682', 280, 21345.6700, 2051.3500, 641.0600),
    (43683, '2024-02-05', '2024-02-17', '2024-02-12', 5, 'SO43683', 281, 17654.3200, 1697.2100, 530.3800),
    (43684, '2024-02-15', '2024-02-27', NULL,          4, 'SO43684', 282, 654.3200,   62.9000,   19.6600),
    (43685, '2024-03-01', '2024-03-13', '2024-03-07', 5, 'SO43685', 283, 12345.6700, 1187.1700, 371.0000),
    (43686, '2024-03-10', '2024-03-22', NULL,          6, 'SO43686', 275, 789.4500,   75.9200,   23.7200);
GO

-- Verification
SELECT 'Territories' AS TableName, COUNT(*) AS RowCount FROM Sales.SalesTerritory
UNION ALL
SELECT 'SalesPersons',  COUNT(*) FROM Sales.SalesPerson
UNION ALL
SELECT 'Orders',        COUNT(*) FROM Sales.SalesOrderHeader;
GO
