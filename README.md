# SSRS → Power BI Migration Demo
## Copilot-Driven Agentic Migration

> **Powered by:** GitHub Copilot CLI + Power BI MCP Server  
> **Sample data:** AdventureWorks 2019  
> **Difficulty:** Beginner–Intermediate  
> **Time to complete:** ~30 minutes

---

## 👋 New here? Start with [QUICKSTART.md](QUICKSTART.md) — up and running in 5 minutes.

---

## What This Demo Shows

This repository is a **self-guided, hands-on walkthrough** of how GitHub Copilot can drive an end-to-end migration from SQL Server Reporting Services (SSRS) to Microsoft Power BI.

You will see — and can reproduce — exactly how Copilot:

1. **Reads** SSRS `.rdl` report files and `.rsd` shared datasets
2. **Analyses** the report structure, SQL queries, expressions, and layout
3. **Generates** Power Query M scripts, DAX measures, and report layout specifications
4. **Deploys** to Power BI via the **Power BI MCP Server** (Model Context Protocol)

No manual redevelopment. No copy-paste SQL. **Copilot does the heavy lifting.**

### Prerequisites

| Tool | Purpose | Download |
|---|---|---|
| [Power BI Desktop](https://powerbi.microsoft.com/desktop/) | Build and view Power BI reports | Free |
| [SQLite](https://sqlite.org/download.html) | Run the sample database | Free |
| [SQLite ODBC Driver](http://www.ch-werner.de/sqliteodbc/) | Connect Power BI to SQLite | Free |
| [Git](https://git-scm.com/) | Clone this repo | Free |

> **Don't have SQL Server?** No problem — use the SQLite path throughout. Every step has SQLite instructions.

---

## Repository Structure

```
demo/
├── ssrs-samples/                    ← SOURCE: Original SSRS reports
│   ├── Orders_Made_by_Salesperson.rdl
│   ├── Territory_Sales_Report.rdl
│   ├── Salesperson_Summary_Report.rdl
│   ├── OrdersBySalesPerson.rsd      ← Shared dataset
│   ├── SalesPerson.rsd              ← Shared dataset
│   └── AdventureWorks_2.rds        ← Shared data source
│
├── database/                        ← DATA: Sample database setup
│   ├── adventureworks_sqlite.sql    ← SQLite (run locally, no SQL Server needed)
│   └── azure_sql_setup.sql         ← Azure SQL / SQL Server T-SQL
│
├── migration-output/                ← OUTPUT: Copilot-generated migration artifacts
│   ├── 01_orders_power_query.m          ← Power Query M for Report 1
│   ├── 01_orders_dax_measures.dax       ← DAX measures for Report 1
│   ├── 01_orders_report_layout.md       ← Report layout spec for Report 1
│   ├── 02_territory_sales_power_query.m
│   ├── 02_territory_sales_dax_measures.dax
│   ├── 02_territory_sales_report_layout.md
│   ├── 03_salesperson_summary_power_query.m
│   ├── 03_salesperson_summary_dax_measures.dax
│   └── 03_salesperson_summary_report_layout.md
│
└── README.md                        ← This file
```

---

## Setup

### Option A — SQLite (Recommended for demo, no SQL Server needed)

```bash
# Install sqlite3 if needed (Windows)
winget install SQLite.SQLite

# Create the demo database
sqlite3 database/adventureworks_demo.db < database/adventureworks_sqlite.sql

# Verify
sqlite3 database/adventureworks_demo.db "SELECT Name, SalesYTD FROM SalesTerritory;"
```

In Power BI Desktop:
- **Get Data** → **ODBC** → configure SQLite DSN pointing to `adventureworks_demo.db`
- Or use the **SQLite ODBC Driver** and paste the Power Query M scripts directly

### Option B — Azure SQL / SQL Server

```sql
-- Run in Azure Data Studio or SSMS
-- against your Azure SQL Database or SQL Server instance
-- File: database/azure_sql_setup.sql
```

Then in Power Query, update the server/database in the first line of each `.m` file:
```m
Source = Sql.Database("your-server.database.windows.net", "AdventureWorks_Demo"),
```

---

## SSRS Reports Being Migrated

| # | Report | Complexity | Key SSRS Features |
|---|---|---|---|
| 1 | Orders Made by Salesperson | 🟢 Simple | Shared dataset, CASE expression, INNER JOIN, currency format |
| 2 | Territory Sales Report | 🟢 Simple | Inline SQL, `=RowNumber()`, alternating row colour (`IIf`) |
| 3 | Salesperson Summary | 🟡 Medium | Shared dataset, grouped by territory, LEFT OUTER JOIN, ISNULL |

---

## SSRS Feature → Power BI Mapping

| SSRS Feature | Power BI Equivalent | Notes |
|---|---|---|
| Tablix (flat table) | Table visual | Direct replacement |
| Tablix with row grouping | Matrix visual | Row groups become matrix levels |
| Shared dataset (`.rsd`) | Shared semantic model / dataset | Centralised in Power BI Service |
| Shared data source (`.rds`) | Gateway data source | On-premises gateway if needed |
| `CASE` expression in SQL | Conditional column in Power Query | Step 6 in `01_orders_power_query.m` |
| `ISNULL(col, default)` | `Table.ReplaceValue` in Power Query | Step 7 in `03_salesperson_summary_power_query.m` |
| `=RowNumber(Nothing)` | Index column (optional) | Not needed in Power BI table visuals |
| `=IIf(RowNumber Mod 2, ...)` | Table visual → Alternate row color | Format pane, no code needed |
| Group header row (custom colour) | Matrix subtotal row formatting | Format pane → Row subtotals → Background color |
| `=Sum(Fields!X.Value)` | `SUM(Table[Column])` DAX measure | Explicit measures in Power BI |
| `=Avg(Fields!X.Value)` | `AVERAGE(Table[Column])` DAX measure | |
| Parameters | Slicers | Interactive, no re-render needed |
| Report subscriptions (email) | Power BI subscriptions | Cloud-native, more flexible |
| Drillthrough | Power BI drillthrough pages | Built-in, no configuration needed |

---

## Walkthrough — Self-Guided Steps

> Follow these steps in order. Each step builds on the previous one.  
> **~30 minutes total.** Skip to any step if you're already familiar with that concept.

---

### 🎬 Step 1 — Understand the SSRS Estate

Open the `ssrs-samples/` folder. There are three file types:

| Extension | What it is | Example |
|---|---|---|
| `.rds` | Shared data source — the database connection string | `AdventureWorks_2.rds` |
| `.rsd` | Shared dataset — a reusable SQL query | `OrdersBySalesPerson.rsd` |
| `.rdl` | Report definition — layout + data binding | `Orders_Made_by_Salesperson.rdl` |

**Open `ssrs-samples/AdventureWorks_2.rds`** and find the connection string:
```xml
<ConnectString>Data Source=(local);Initial Catalog=AdventureWorks2019</ConnectString>
```
> In a real migration, this is where you note the source database. In Power BI, this becomes the data gateway configuration.

**Open `ssrs-samples/OrdersBySalesPerson.rsd`** and find the SQL query inside `<CommandText>`. This is the query Copilot extracted and translated into Power Query M.

---

### 🔍 Step 2 — See What Copilot Extracted

Open `ssrs-samples/Territory_Sales_Report.rdl` and search for these SSRS-specific expressions:

```xml
<!-- Row number expression -->
<Value>=RowNumber(Nothing)</Value>

<!-- Alternating row colour — VB.NET IIf expression -->
<BackgroundColor>=IIf(RowNumber(Nothing) Mod 2,"OldLace","Ivory")</BackgroundColor>
```

These are SSRS-only VB.NET expressions with no direct Power BI equivalent. Copilot identifies them automatically and maps them to Power BI alternatives.

Open `migration-output/02_territory_sales_report_layout.md` to see the mapping Copilot produced. The key row:

| SSRS Feature | Power BI Equivalent | Notes |
|---|---|---|
| `=IIf(RowNumber Mod 2, ...)` | Table visual → **Alternate row color** | Format pane, no code needed |

> 💡 **Insight:** This is the analysis phase. Traditionally a senior developer spends days cataloguing these. Copilot does it in seconds for every report.

---

### ⚙️ Step 3 — Explore the Power Query M Scripts

Open `migration-output/01_orders_power_query.m` in any text editor.

Read the numbered steps and their comments. Key translations to notice:

| Step in M file | SSRS Original | Power Query Equivalent |
|---|---|---|
| Step 4 | `INNER JOIN Person.Person` | `Table.NestedJoin(..., JoinKind.Inner)` |
| Step 6 | `CASE Status WHEN 1 THEN 'In Process'...` | `if [Status] = 1 then "In Process" else if...` |
| Step 8 | Status integer column (raw) | Removed — replaced by human-readable `orderStatus` |

Open `migration-output/03_salesperson_summary_power_query.m` and find Step 7:
```m
ReplaceNullTerritory = Table.ReplaceValue(
    ExpandTerritory, null, "*No Territory", ...
```
> This is the translation of `ISNULL(ST.Name,'*No Territory')` from the SQL LEFT OUTER JOIN.

---

### 📐 Step 4 — Explore the DAX Measures

Open `migration-output/01_orders_dax_measures.dax`.

In SSRS, aggregations like totals were **implicit** — the report engine calculated them at render time. In Power BI, they must be **explicit DAX measures**.

Notice the measure `Total Due YTD`:
```dax
Total Due YTD =
    TOTALYTD(
        [Total Due],
        'Date'[Date]
    )
```
> This requires a `Date` table in your model (standard practice in Power BI).

Open `migration-output/03_salesperson_summary_dax_measures.dax` and find `Quota Attainment %`:
```dax
Quota Attainment % =
    DIVIDE(
        [SP Total Sales YTD],
        [SP Total Quota],
        0
    )
```
> ⭐ This measure did **not exist** in the original SSRS report. Copilot identified that `SalesQuota` and `SalesYTD` were both present and suggested this as a new insight the business couldn't see before.

---

### 🗄️ Step 5 — Set Up the Database

**Option A: SQLite (Recommended — no SQL Server needed)**

```bash
sqlite3 database/adventureworks_demo.db < database/adventureworks_sqlite.sql

# Verify
sqlite3 database/adventureworks_demo.db \
  "SELECT Name, printf('$%.0f', SalesYTD) AS SalesYTD FROM SalesTerritory ORDER BY SalesYTD DESC;"
```

**Option B: Azure SQL / SQL Server**

Open `database/azure_sql_setup.sql` in Azure Data Studio or SSMS and run it against your instance. The script creates `Person` and `Sales` schemas with proper T-SQL types.

---

### 🖥️ Step 6 — Load Data into Power BI Desktop

1. Open **Power BI Desktop**
2. **Home** → **Get Data** → **Blank Query**
3. **Advanced Editor** → replace all content with `migration-output/01_orders_power_query.m`
4. **For SQLite:** update line 5 to:
   ```m
   Source = Odbc.DataSource("dsn=AdventureWorks_Demo"),
   SalesOrderHeader = Source{[Name="SalesOrderHeader"]}[Data],
   ```
5. Rename the query to `SalesOrders` → **Close & Apply**
6. Repeat for `02_territory_sales_power_query.m` (table name: `SalesTerritory`) and `03_salesperson_summary_power_query.m` (table name: `SalesPerson`)

**Set up relationships:**
- `SalesOrders[SalesPersonID]` → `SalesPerson[BusinessEntityID]` (many-to-one)
- `SalesPerson[TerritoryID]` → `SalesTerritory[TerritoryID]` (many-to-one)

---

### 📊 Step 7 — Add DAX Measures and Build Visuals

For each report, select the table in the Fields pane, click **New Measure**, and paste each measure from the corresponding `.dax` file.

Then follow the layout specification in each `_report_layout.md` file to build the visuals. Each layout file includes:
- A recommended visual arrangement
- Formatting instructions (colours, number formats)
- Notes on which SSRS features map to which Power BI settings

---

### 🚀 Step 8 — Deploy via Power BI MCP Server *(Optional)*

If you have GitHub Copilot CLI configured with the Power BI MCP Server, Copilot can deploy the dataset and report automatically without using the Power BI portal.

**Configure the MCP server** (see [Power BI MCP Server Setup](#power-bi-mcp-server-setup) below), then ask Copilot:

```
"Deploy the AdventureWorks Sales dataset and the three migrated reports
to a new Power BI workspace called 'SSRS Migration Demo'"
```

Copilot will call the MCP tools to:
1. Create the workspace
2. Push the semantic model
3. Create each report

> This is the **agentic** part of the demo — Copilot takes action, not just advice.

---

## Power BI MCP Server Setup

The **Power BI MCP Server** enables Copilot to interact with the Power BI REST API programmatically.

### Prerequisites
- Power BI Pro or Premium Per User licence
- Azure AD app registration with Power BI API permissions:
  - `Dataset.ReadWrite.All`
  - `Report.ReadWrite.All`
  - `Workspace.ReadWrite.All`

### MCP Configuration (`~/.copilot/mcp-config.json`)
```json
{
  "servers": {
    "powerbi": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-powerbi"],
      "env": {
        "POWERBI_CLIENT_ID": "<your-app-client-id>",
        "POWERBI_CLIENT_SECRET": "<your-app-secret>",
        "POWERBI_TENANT_ID": "<your-tenant-id>"
      }
    }
  }
}
```

---

## Key Benefits — Talking Points for Customer

| Traditional Migration | Copilot-Driven Migration |
|---|---|
| Developer reads each RDL manually | Copilot parses all RDLs automatically |
| Spec written by hand | Analysis document generated instantly |
| SQL rewritten manually | Power Query M generated from SQL |
| DAX measures written from scratch | DAX generated from SSRS aggregations |
| Deployed by hand through Power BI portal | Deployed programmatically via MCP |
| Days per report | Minutes per report |
| Inconsistent quality | Consistent, reproducible output |

---

## Files Reference

| File | Purpose |
|---|---|
| `ssrs-samples/*.rdl` | Original SSRS report definitions (XML) |
| `ssrs-samples/*.rsd` | Shared dataset definitions with SQL queries |
| `ssrs-samples/*.rds` | Shared data source connection strings |
| `database/adventureworks_sqlite.sql` | SQLite schema + seed data (no SQL Server needed) |
| `database/azure_sql_setup.sql` | Azure SQL / SQL Server T-SQL schema + seed data |
| `migration-output/01_*` | Report 1: Orders by Salesperson — M, DAX, layout |
| `migration-output/02_*` | Report 2: Territory Sales — M, DAX, layout |
| `migration-output/03_*` | Report 3: Salesperson Summary — M, DAX, layout |
