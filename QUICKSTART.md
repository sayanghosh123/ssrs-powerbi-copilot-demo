# ⚡ Quick Start — SSRS to Power BI Migration Demo

Get up and running in **5 minutes**.

---

## Prerequisites

Install these before starting:

| Tool | Purpose | Download |
|---|---|---|
| [Power BI Desktop](https://powerbi.microsoft.com/desktop/) | View and build Power BI reports | Free |
| [SQLite](https://sqlite.org/download.html) or `winget install SQLite.SQLite` | Run the sample database | Free |
| [SQLite ODBC Driver](http://www.ch-werner.de/sqliteodbc/) | Connect Power BI to SQLite | Free |
| [Git](https://git-scm.com/) | Clone this repo | Free |

> **Don't have SQL Server?** No problem — the demo uses SQLite by default.

---

## Step 1 — Clone the repo

```bash
git clone https://github.com/<your-org>/ssrs-powerbi-copilot-demo.git
cd ssrs-powerbi-copilot-demo
```

---

## Step 2 — Set up the sample database

```bash
# Windows
sqlite3 database/adventureworks_demo.db < database/adventureworks_sqlite.sql

# Verify it worked
sqlite3 database/adventureworks_demo.db "SELECT Name, SalesYTD FROM SalesTerritory;"
```

You should see 10 territory rows printed. If so, your database is ready. ✅

---

## Step 3 — Set up the SQLite ODBC DSN

1. Open **ODBC Data Sources (64-bit)** from Windows Start menu
2. Click **Add** → select **SQLite3 ODBC Driver**
3. Set **Data Source Name** to: `AdventureWorks_Demo`
4. Set **Database** to the full path of `adventureworks_demo.db`
5. Click **OK**

---

## Step 4 — Open a migration artifact in Power BI Desktop

1. Open **Power BI Desktop**
2. Click **Get Data** → **Blank Query**
3. In the Power Query Editor, click **Advanced Editor**
4. Delete the existing content and paste the contents of:
   ```
   migration-output/01_orders_power_query.m
   ```
5. On line 5, change:
   ```m
   Source = Sql.Database("(local)", "AdventureWorks2019"),
   ```
   to:
   ```m
   Source = Odbc.DataSource("dsn=AdventureWorks_Demo"),
   SalesOrderHeader = Source{[Name="SalesOrderHeader"]}[Data],
   ```
   *(See the comment in the .m file for the full SQLite version)*
6. Click **Done** → **Close & Apply**

---

## Step 5 — Add DAX measures

1. In Power BI Desktop, select the `SalesOrders` table in the Fields pane
2. Click **New Measure** for each measure in `migration-output/01_orders_dax_measures.dax`
3. Paste each measure definition and press Enter

---

## Step 6 — Build the report

Refer to `migration-output/01_orders_report_layout.md` for the recommended visual layout.

Repeat Steps 4–6 for reports 02 and 03.

---

## What to explore next

- 📖 Read the full [README.md](README.md) for the complete SSRS→Power BI feature mapping
- 🤖 See how Copilot generated these files by reading the [inline comments](migration-output/01_orders_power_query.m) in each `.m` file
- 🚀 Try the [Power BI MCP Server](#power-bi-mcp-server-setup) section in README.md to deploy programmatically
