// ============================================================
// Power Query M — Orders by Salesperson
// SSRS Source: OrdersBySalesPerson.rsd / Orders_Made_by_Salesperson.rdl
// 
// SSRS → Power BI translation notes:
//   - INNER JOIN Person.Person  → Table.NestedJoin
//   - CASE Status expression    → Table.AddColumn with if/else
//   - YEAR(OrderDate)           → Date.Year([OrderDate])
//   - TotalDue computed column  → Table.AddColumn (SubTotal + TaxAmt + Freight)
//
// For SQLite: change Source to Odbc or SQLite connector
// For SQL Server / Azure SQL: use Sql.Database
// ============================================================

let
    // ----------------------------------------------------------
    // 1. Connect to data source
    //    Replace server/database with your actual values
    // ----------------------------------------------------------
    Source = Sql.Database("(local)", "AdventureWorks2019"),
    // For SQLite:
    // Source = Odbc.DataSource("dsn=AdventureWorks_SQLite"),

    // ----------------------------------------------------------
    // 2. Load SalesOrderHeader
    // ----------------------------------------------------------
    SalesOrderHeader = Source{[Schema="Sales", Item="SalesOrderHeader"]}[Data],
    SelectSOHColumns = Table.SelectColumns(SalesOrderHeader, {
        "SalesOrderID", "OrderDate", "DueDate", "ShipDate",
        "Status", "SalesOrderNumber", "SalesPersonID",
        "SubTotal", "TaxAmt", "Freight"
    }),

    // ----------------------------------------------------------
    // 3. Load Person.Person
    // ----------------------------------------------------------
    Person = Source{[Schema="Person", Item="Person"]}[Data],
    SelectPersonColumns = Table.SelectColumns(Person, {
        "BusinessEntityID", "FirstName", "LastName"
    }),

    // ----------------------------------------------------------
    // 4. INNER JOIN — equivalent to SSRS SQL INNER JOIN
    //    SalesOrderHeader.SalesPersonID = Person.BusinessEntityID
    // ----------------------------------------------------------
    JoinedTable = Table.NestedJoin(
        SelectSOHColumns, {"SalesPersonID"},
        SelectPersonColumns, {"BusinessEntityID"},
        "PersonData",
        JoinKind.Inner
    ),
    ExpandPerson = Table.ExpandTableColumn(
        JoinedTable, "PersonData",
        {"FirstName", "LastName"},
        {"FirstName", "LastName"}
    ),

    // ----------------------------------------------------------
    // 5. Add OrderYear column
    //    SSRS SQL: YEAR(OrderDate) AS OrderYear
    // ----------------------------------------------------------
    AddOrderYear = Table.AddColumn(
        ExpandPerson, "OrderYear",
        each Date.Year([OrderDate]),
        Int64.Type
    ),

    // ----------------------------------------------------------
    // 6. Map Status code → label
    //    SSRS SQL: CASE Status WHEN 1 THEN 'In Process' ...
    //    Power Query: if/else conditional column
    // ----------------------------------------------------------
    AddOrderStatus = Table.AddColumn(
        AddOrderYear, "orderStatus",
        each
            if [Status] = 1 then "In Process"
            else if [Status] = 2 then "Approved"
            else if [Status] = 3 then "Back Ordered"
            else if [Status] = 4 then "Rejected"
            else if [Status] = 5 then "Shipped"
            else if [Status] = 6 then "Cancelled"
            else "Invalid",
        type text
    ),

    // ----------------------------------------------------------
    // 7. Set data types
    // ----------------------------------------------------------
    TypedTable = Table.TransformColumnTypes(AddOrderStatus, {
        {"SalesOrderID",     Int64.Type},
        {"OrderDate",        type datetime},
        {"DueDate",          type datetime},
        {"ShipDate",         type datetime},
        {"SalesOrderNumber", type text},
        {"SalesPersonID",    Int64.Type},
        {"FirstName",        type text},
        {"LastName",         type text},
        {"SubTotal",         Currency.Type},
        {"TaxAmt",           Currency.Type},
        {"Freight",          Currency.Type},
        {"OrderYear",        Int64.Type},
        {"orderStatus",      type text}
    }),

    // ----------------------------------------------------------
    // 8. Remove raw Status integer (replaced by orderStatus label)
    // ----------------------------------------------------------
    FinalTable = Table.RemoveColumns(TypedTable, {"Status"})

in
    FinalTable
