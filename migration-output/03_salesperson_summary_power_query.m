// ============================================================
// Power Query M — Salesperson Summary Report
// SSRS Source: Salesperson_Summary_Report.rdl / SalesPerson.rsd
//
// SSRS → Power BI translation notes:
//   - INNER JOIN Person.Person              → Table.NestedJoin (Inner)
//   - LEFT OUTER JOIN Sales.SalesTerritory  → Table.NestedJoin (LeftOuter)
//   - ISNULL(ST.Name,'*No Territory')       → Table.ReplaceValue or if null
//   - FirstName + ' ' + LastName            → Table.AddColumn concatenation
//   - Grouped by TerritoryName in SSRS      → Matrix visual in Power BI
//     (grouping moves from report layer to visual layer)
// ============================================================

let
    // ----------------------------------------------------------
    // 1. Connect to data source
    // ----------------------------------------------------------
    Source = Sql.Database("(local)", "AdventureWorks2019"),
    // For SQLite:
    // Source = Odbc.DataSource("dsn=AdventureWorks_SQLite"),

    // ----------------------------------------------------------
    // 2. Load Sales.SalesPerson
    // ----------------------------------------------------------
    SalesPerson = Source{[Schema="Sales", Item="SalesPerson"]}[Data],
    SelectSPColumns = Table.SelectColumns(SalesPerson, {
        "BusinessEntityID", "TerritoryID",
        "SalesQuota", "Bonus", "CommissionPct", "SalesYTD", "SalesLastYear"
    }),

    // ----------------------------------------------------------
    // 3. Load Person.Person
    // ----------------------------------------------------------
    Person = Source{[Schema="Person", Item="Person"]}[Data],
    SelectPersonColumns = Table.SelectColumns(Person, {
        "BusinessEntityID", "FirstName", "LastName"
    }),

    // ----------------------------------------------------------
    // 4. INNER JOIN SalesPerson ↔ Person
    //    SSRS SQL: INNER JOIN Person.Person ON SP.BusinessEntityID = P.BusinessEntityID
    // ----------------------------------------------------------
    JoinPerson = Table.NestedJoin(
        SelectSPColumns, {"BusinessEntityID"},
        SelectPersonColumns, {"BusinessEntityID"},
        "PersonData",
        JoinKind.Inner
    ),
    ExpandPerson = Table.ExpandTableColumn(
        JoinPerson, "PersonData",
        {"FirstName", "LastName"},
        {"FirstName", "LastName"}
    ),

    // ----------------------------------------------------------
    // 5. Load Sales.SalesTerritory
    // ----------------------------------------------------------
    SalesTerritory = Source{[Schema="Sales", Item="SalesTerritory"]}[Data],
    SelectTerritoryColumns = Table.SelectColumns(SalesTerritory, {
        "TerritoryID", "Name"
    }),

    // ----------------------------------------------------------
    // 6. LEFT OUTER JOIN ↔ SalesTerritory
    //    SSRS SQL: LEFT OUTER JOIN Sales.SalesTerritory ON SP.TerritoryID = ST.TerritoryID
    // ----------------------------------------------------------
    JoinTerritory = Table.NestedJoin(
        ExpandPerson, {"TerritoryID"},
        SelectTerritoryColumns, {"TerritoryID"},
        "TerritoryData",
        JoinKind.LeftOuter
    ),
    ExpandTerritory = Table.ExpandTableColumn(
        JoinTerritory, "TerritoryData",
        {"Name"},
        {"TerritoryName_Raw"}
    ),

    // ----------------------------------------------------------
    // 7. ISNULL(ST.Name, '*No Territory')
    //    SSRS SQL: ISNULL(Sales.SalesTerritory.Name,'*No Territory')
    //    Power Query: replace null with default value
    // ----------------------------------------------------------
    ReplaceNullTerritory = Table.ReplaceValue(
        ExpandTerritory,
        null,
        "*No Territory",
        Replacer.ReplaceValue,
        {"TerritoryName_Raw"}
    ),
    RenameTerritory = Table.RenameColumns(ReplaceNullTerritory, {
        {"TerritoryName_Raw", "TerritoryName"}
    }),

    // ----------------------------------------------------------
    // 8. SalesPersonName = FirstName + ' ' + LastName
    //    SSRS SQL: Person.Person.FirstName + ' ' + Person.Person.LastName AS SalesPersonName
    // ----------------------------------------------------------
    AddSalesPersonName = Table.AddColumn(
        RenameTerritory, "SalesPersonName",
        each [FirstName] & " " & [LastName],
        type text
    ),

    // ----------------------------------------------------------
    // 9. Select and reorder final columns
    // ----------------------------------------------------------
    SelectFinal = Table.SelectColumns(AddSalesPersonName, {
        "BusinessEntityID", "TerritoryID", "TerritoryName",
        "FirstName", "LastName", "SalesPersonName",
        "SalesQuota", "Bonus", "CommissionPct", "SalesYTD", "SalesLastYear"
    }),

    // ----------------------------------------------------------
    // 10. Set data types
    // ----------------------------------------------------------
    TypedTable = Table.TransformColumnTypes(SelectFinal, {
        {"BusinessEntityID", Int64.Type},
        {"TerritoryID",      Int64.Type},
        {"TerritoryName",    type text},
        {"FirstName",        type text},
        {"LastName",         type text},
        {"SalesPersonName",  type text},
        {"SalesQuota",       Currency.Type},
        {"Bonus",            Currency.Type},
        {"CommissionPct",    type number},
        {"SalesYTD",         Currency.Type},
        {"SalesLastYear",    Currency.Type}
    })

in
    TypedTable
