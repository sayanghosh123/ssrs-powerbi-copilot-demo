// ============================================================
// Power Query M — Territory Sales Report
// SSRS Source: Territory_Sales_Report.rdl (inline dataset)
//
// SSRS → Power BI translation notes:
//   - Simple SELECT from Sales.SalesTerritory — direct table load
//   - =RowNumber(Nothing)          → Index column (for reference only;
//                                    Power BI handles row numbers natively
//                                    in table visuals — not needed in model)
//   - =RowNumber(Nothing) Mod 2    → Removed; Power BI table visuals have
//                                    built-in alternating row colour
//   - =IIf(RowNumber Mod 2, ...)   → Replaced by conditional formatting
//                                    rules in the Power BI table visual
//   - [Group] reserved word        → Renamed to TerritoryGroup in model
// ============================================================

let
    // ----------------------------------------------------------
    // 1. Connect to data source
    // ----------------------------------------------------------
    Source = Sql.Database("(local)", "AdventureWorks2019"),
    // For SQLite (flat table named SalesTerritory, no schema):
    // Source = Odbc.DataSource("dsn=AdventureWorks_SQLite"),

    // ----------------------------------------------------------
    // 2. Load Sales.SalesTerritory
    //    SSRS SQL: SELECT TerritoryID, Name, [Group], SalesYTD, SalesLastYear
    //              FROM Sales.SalesTerritory
    // ----------------------------------------------------------
    SalesTerritory = Source{[Schema="Sales", Item="SalesTerritory"]}[Data],
    // For SQLite: SalesTerritory = Source{[Name="SalesTerritory"]}[Data],

    SelectColumns = Table.SelectColumns(SalesTerritory, {
        "TerritoryID", "Name", "Group", "SalesYTD", "SalesLastYear"
    }),

    // ----------------------------------------------------------
    // 3. Rename [Group] → TerritoryGroup to avoid reserved word issues
    //    and improve readability in Power BI field list
    // ----------------------------------------------------------
    RenameColumns = Table.RenameColumns(SelectColumns, {
        {"Group", "TerritoryGroup"},
        {"Name",  "TerritoryName"}
    }),

    // ----------------------------------------------------------
    // 4. Set data types
    // ----------------------------------------------------------
    TypedTable = Table.TransformColumnTypes(RenameColumns, {
        {"TerritoryID",    Int64.Type},
        {"TerritoryName",  type text},
        {"TerritoryGroup", type text},
        {"SalesYTD",       Currency.Type},
        {"SalesLastYear",  Currency.Type}
    })

    // ----------------------------------------------------------
    // NOTE: Row numbers and alternating row colours from SSRS
    // are NOT replicated in Power Query — these are visual
    // formatting concerns handled in the Power BI report canvas:
    //   - Alternating row colour: Table visual → Row > Alternate background color
    //   - Row numbers: Table visual settings (no DAX needed)
    // ----------------------------------------------------------

in
    TypedTable
