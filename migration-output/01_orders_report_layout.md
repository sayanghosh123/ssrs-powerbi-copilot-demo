# Report Layout — Orders by Salesperson
## Power BI Equivalent of SSRS Report

**SSRS Report:** `Orders_Made_by_Salesperson.rdl`  
**Dataset:** `OrdersBySalesPerson` (shared dataset)  
**Complexity:** 🟢 Simple — flat tabular list, no parameters, no grouping

---

## SSRS → Power BI Feature Mapping

| SSRS Element | Power BI Equivalent |
|---|---|
| Tablix (flat table) | Table visual |
| Column headers (Silver background) | Visual header / column formatting |
| Currency format (`C2`) | Column format: Currency, 2 decimal places |
| `=Fields!FirstName.Value & " " & Fields!LastName.Value` | Calculated column: `SalesPersonName = [FirstName] & " " & [LastName]` |
| Report footer totals | Card visuals or table totals row |
| No parameters | Slicers for filtering |

---

## Recommended Power BI Report Layout

### Page: Orders by Salesperson

```
┌─────────────────────────────────────────────────────────────────┐
│  SLICERS (top bar)                                              │
│  [ Year Slicer ]  [ Order Status Slicer ]  [ Salesperson ]     │
├──────────────┬──────────────────────────────────────────────────┤
│  KPI Cards   │  Total Due   │  Order Count  │  Avg Order Value │
│  (row)       │  $X,XXX,XXX  │  ###          │  $XX,XXX         │
├─────────────────────────────────────────────────────────────────┤
│  TABLE VISUAL                                                   │
│  Columns: Salesperson Name | Order Date | Due Date | Ship Date  │
│           | Sales Order # | Status | Sub Total | Tax | Freight  │
│           | Total Due                                           │
│  Sort: Order Date desc (default)                                │
│  Row subtotals: ON                                              │
├─────────────────────────────────────────────────────────────────┤
│  BAR CHART: Total Due by Salesperson (horizontal)               │
└─────────────────────────────────────────────────────────────────┘
```

---

## Model Notes

- **Table name:** `SalesOrders` (from Power Query step `01_orders_power_query.m`)
- **Relationship:** `SalesOrders[SalesPersonID]` → `SalesPerson[BusinessEntityID]` (many-to-one)
- **Date table:** Recommended for YTD measures — mark `OrderDate` as a date table or add a separate `Date` dimension
- **Row-level security:** Apply on `SalesPersonID` if individual salespersons should only see their own orders

---

## Formatting Guidelines

| Column | Format | Notes |
|---|---|---|
| Order Date / Due Date / Ship Date | Short Date | `dd/MM/yyyy` |
| Sub Total / Tax Amt / Freight / Total Due | Currency | `$#,##0.00` |
| Order Status | Text | Consider colour-coding: Shipped=Green, Cancelled=Red |
| Salesperson Name | Text | Combine FirstName + LastName in Power Query |
