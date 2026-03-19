-- =============================================================
-- AdventureWorks SSRS Demo — SQLite Setup
-- Flat table names (no schemas). Equivalent AdventureWorks
-- schemas noted in comments: Sales.*, Person.*
-- Run with: sqlite3 adventureworks_demo.db < adventureworks_sqlite.sql
-- =============================================================

PRAGMA foreign_keys = ON;

-- -------------------------------------------------------
-- Person.Person
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS Person (
    BusinessEntityID  INTEGER PRIMARY KEY,
    FirstName         TEXT NOT NULL,
    LastName          TEXT NOT NULL
);

-- -------------------------------------------------------
-- Sales.SalesTerritory
-- Note: "Group" is reserved in SQLite → TerritoryGroup
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS SalesTerritory (
    TerritoryID     INTEGER PRIMARY KEY,
    Name            TEXT NOT NULL,
    TerritoryGroup  TEXT NOT NULL,   -- Maps to [Group] in T-SQL
    SalesYTD        REAL NOT NULL DEFAULT 0,
    SalesLastYear   REAL NOT NULL DEFAULT 0
);

-- -------------------------------------------------------
-- Sales.SalesPerson
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS SalesPerson (
    BusinessEntityID  INTEGER PRIMARY KEY,
    TerritoryID       INTEGER,
    SalesQuota        REAL,
    Bonus             REAL NOT NULL DEFAULT 0,
    CommissionPct     REAL NOT NULL DEFAULT 0,
    SalesYTD          REAL NOT NULL DEFAULT 0,
    SalesLastYear     REAL NOT NULL DEFAULT 0,
    FOREIGN KEY (BusinessEntityID) REFERENCES Person(BusinessEntityID),
    FOREIGN KEY (TerritoryID)      REFERENCES SalesTerritory(TerritoryID)
);

-- -------------------------------------------------------
-- Sales.SalesOrderHeader
-- -------------------------------------------------------
CREATE TABLE IF NOT EXISTS SalesOrderHeader (
    SalesOrderID     INTEGER PRIMARY KEY,
    OrderDate        TEXT NOT NULL,   -- ISO-8601: YYYY-MM-DD
    DueDate          TEXT NOT NULL,
    ShipDate         TEXT,
    Status           INTEGER NOT NULL, -- 1=InProcess 2=Approved 3=BackOrdered 4=Rejected 5=Shipped 6=Cancelled
    SalesOrderNumber TEXT NOT NULL,
    SalesPersonID    INTEGER,
    SubTotal         REAL NOT NULL DEFAULT 0,
    TaxAmt           REAL NOT NULL DEFAULT 0,
    Freight          REAL NOT NULL DEFAULT 0,
    TotalDue         REAL GENERATED ALWAYS AS (SubTotal + TaxAmt + Freight) STORED,
    FOREIGN KEY (SalesPersonID) REFERENCES Person(BusinessEntityID)
);

-- =============================================================
-- SEED DATA
-- =============================================================

-- Territories (Sales.SalesTerritory)
INSERT INTO SalesTerritory (TerritoryID, Name, TerritoryGroup, SalesYTD, SalesLastYear) VALUES
    (1, 'Northwest',  'North America', 7887186.78, 5765568.41),
    (2, 'Northeast',  'North America', 2402176.84, 2237516.59),
    (3, 'Central',    'North America', 3072175.12, 2538667.24),
    (4, 'Southwest',  'North America', 10510853.87, 9557153.27),
    (5, 'Southeast',  'North America', 2538667.24, 1983988.43),
    (6, 'Canada',     'North America', 6771829.31, 5753307.59),
    (7, 'France',     'Europe',        4772398.32, 3852252.88),
    (8, 'Germany',    'Europe',        3053307.89, 2641820.04),
    (9, 'Australia',  'Pacific',       5765568.41, 4258494.32),
    (10,'United Kingdom','Europe',     4116871.23, 3497046.38);

-- People (Person.Person) — 10 salespersons + some extras
INSERT INTO Person (BusinessEntityID, FirstName, LastName) VALUES
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

-- SalesPersons (Sales.SalesPerson)
INSERT INTO SalesPerson (BusinessEntityID, TerritoryID, SalesQuota, Bonus, CommissionPct, SalesYTD, SalesLastYear) VALUES
    (274, NULL, NULL,         0,        0,      559697.56,  0),
    (275, 2,    300000.00,    4100.00,  0.012,  3763178.18, 1750406.47),
    (276, 5,    250000.00,    2000.00,  0.012,  4251368.55, 1439156.02),
    (277, 3,    250000.00,    2500.00,  0.015,  3189418.37, 1997186.19),
    (278, 6,    250000.00,    500.00,   0.015,  1453719.47, 1620276.89),
    (279, 4,    300000.00,    6700.00,  0.015,  2315185.61, 1849640.93),
    (280, 1,    250000.00,    5000.00,  0.015,  1352577.13, 0),
    (281, 9,    300000.00,    5000.00,  0.012,  2458535.62, 2278548.98),
    (282, 7,    250000.00,    5000.00,  0.012,  2604540.72, 2038234.65),
    (283, 8,    275000.00,    5000.00,  0.015,  1573012.94, 1371635.09);

-- Sales Orders (Sales.SalesOrderHeader) — 28 orders
INSERT INTO SalesOrderHeader (SalesOrderID, OrderDate, DueDate, ShipDate, Status, SalesOrderNumber, SalesPersonID, SubTotal, TaxAmt, Freight) VALUES
    (43659, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43659', 275, 20565.62, 1971.52, 616.10),
    (43660, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43660', 276, 1294.25,  124.24,  38.82),
    (43661, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43661', 277, 32726.48, 3153.78, 985.55),
    (43662, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43662', 278, 28832.53, 2774.27, 867.27),
    (43663, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43663', 279, 419.46,   40.27,   12.59),
    (43664, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43664', 280, 24432.61, 2349.57, 734.24),
    (43665, '2023-07-01', '2023-07-13', '2023-07-08', 5, 'SO43665', 281, 14352.78, 1379.89, 431.22),
    (43666, '2023-08-01', '2023-08-13', '2023-08-07', 5, 'SO43666', 282, 5765.34,  554.19,  173.18),
    (43667, '2023-08-01', '2023-08-13', '2023-08-07', 5, 'SO43667', 283, 3754.44,  360.88,  112.77),
    (43668, '2023-08-05', '2023-08-17', '2023-08-12', 5, 'SO43668', 275, 14265.87, 1371.24, 428.51),
    (43669, '2023-08-10', '2023-08-22', '2023-08-18', 5, 'SO43669', 276, 7330.90,  704.49,  220.15),
    (43670, '2023-09-01', '2023-09-13', '2023-09-08', 5, 'SO43670', 277, 22143.56, 2128.80, 665.25),
    (43671, '2023-09-05', '2023-09-17', '2023-09-12', 5, 'SO43671', 278, 11389.28, 1095.01, 342.19),
    (43672, '2023-09-15', '2023-09-27', '2023-09-22', 5, 'SO43672', 279, 9165.43,  880.96,  275.30),
    (43673, '2023-10-01', '2023-10-13', '2023-10-07', 5, 'SO43673', 280, 18457.22, 1774.62, 554.57),
    (43674, '2023-10-05', '2023-10-17', '2023-10-12', 5, 'SO43674', 281, 25312.45, 2433.96, 760.61),
    (43675, '2023-10-15', '2023-10-27', '2023-10-22', 5, 'SO43675', 282, 16234.67, 1560.64, 487.70),
    (43676, '2023-11-01', '2023-11-13', '2023-11-08', 5, 'SO43676', 283, 8956.23,  861.11,  269.10),
    (43677, '2023-11-10', '2023-11-22', '2023-11-18', 5, 'SO43677', 275, 32178.90, 3092.04, 966.90),
    (43678, '2023-12-01', '2023-12-13', '2023-12-08', 5, 'SO43678', 276, 4567.89,  439.08,  137.21),
    (43679, '2024-01-05', '2024-01-17', NULL,          3, 'SO43679', 277, 15234.56, 1464.05, 457.52),
    (43680, '2024-01-10', '2024-01-22', NULL,          2, 'SO43680', 278, 9876.54,  949.44,  296.70),
    (43681, '2024-01-15', '2024-01-27', NULL,          1, 'SO43681', 279, 3456.78,  332.21,  103.82),
    (43682, '2024-02-01', '2024-02-13', '2024-02-09', 5, 'SO43682', 280, 21345.67, 2051.35, 641.06),
    (43683, '2024-02-05', '2024-02-17', '2024-02-12', 5, 'SO43683', 281, 17654.32, 1697.21, 530.38),
    (43684, '2024-02-15', '2024-02-27', NULL,          4, 'SO43684', 282, 654.32,   62.90,   19.66),
    (43685, '2024-03-01', '2024-03-13', '2024-03-07', 5, 'SO43685', 283, 12345.67, 1187.17, 371.00),
    (43686, '2024-03-10', '2024-03-22', NULL,          6, 'SO43686', 275, 789.45,   75.92,   23.72);

-- Verification queries (comment out if running as pure setup)
-- SELECT 'Territories: ' || COUNT(*) FROM SalesTerritory;
-- SELECT 'Salespersons: ' || COUNT(*) FROM SalesPerson;
-- SELECT 'Orders: ' || COUNT(*) FROM SalesOrderHeader;
