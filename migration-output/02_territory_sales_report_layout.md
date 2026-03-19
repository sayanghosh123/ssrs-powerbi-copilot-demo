# Report Layout — Territory Sales Report
## Power BI Equivalent of SSRS Report

**SSRS Report:** `Territory_Sales_Report.rdl`  
**Dataset:** Inline SQL — `SELECT TerritoryID, Name, [Group], SalesYTD, SalesLastYear FROM Sales.SalesTerritory`  
**Complexity:** 🟢 Simple — flat table with SSRS expression-based row formatting

---

## SSRS → Power BI Feature Mapping

| SSRS Element | Power BI Equivalent | Notes |
|---|---|---|
| Tablix flat table | Table visual | Direct replacement |
| `=RowNumber(Nothing)` | Table visual row numbers | Built-in, no DAX needed |
| `=RowNumber(Nothing) Mod 2` | Not needed | Power BI handles this visually |
| `=IIf(RowNumber Mod 2,"OldLace","Ivory")` | Table visual → **Alternate row color** | Format pane → Style presets |
| Column headers (Silver) | Table visual header formatting | Format pane → Column headers |
| Currency format (`C0`) | Column format: `$#,##0` | Format pane → Column values |
| `[Group]` field | `TerritoryGroup` (renamed in Power Query) | Reserved word avoided |

---

## Recommended Power BI Report Layout

### Page: Territory Sales

```
┌─────────────────────────────────────────────────────────────────┐
│  SLICERS                                                        │
│  [ Territory Group Filter: North America / Europe / Pacific ]   │
├────────────┬────────────┬──────────────┬────────────────────────┤
│  KPI Cards │ Total YTD  │ Total LY     │ YoY Growth %           │
│            │ $XX,XXX    │ $XX,XXX      │ +X.X%                  │
├─────────────────────────────────────────────────────────────────┤
│  TABLE VISUAL (with alternating row colours)                    │
│  Columns: Territory Name | Group | Sales YTD | Sales Last Year  │
│           | YoY Growth $ | YoY Growth %                         │
│  Sort: Sales YTD desc (default)                                 │
│  Totals: ON                                                     │
├─────────────────────────────────────────────────────────────────┤
│  BAR CHART: Sales YTD vs Sales Last Year by Territory           │
│  (Clustered bar, colour-coded: Current Year vs Prior Year)      │
└─────────────────────────────────────────────────────────────────┘
```

---

## SSRS Alternating Row Colour → Power BI

**In SSRS:** `=IIf(RowNumber(Nothing) Mod 2, "OldLace", "Ivory")` expression on each cell.

**In Power BI:** 
1. Select the Table visual
2. Format pane → **Visual** tab → **Style presets** → choose "Alternating rows"
3. Or manually: **Row** section → **Alternate background color** → set to `#FDF5E6` (OldLace equivalent)

No DAX, no M code needed — purely a visual formatting setting.

---

## Model Notes

- **Table name:** `SalesTerritory` (from `02_territory_sales_power_query.m`)
- **Relationship:** `SalesTerritory[TerritoryID]` → `SalesPerson[TerritoryID]` (one-to-many)
- The `TerritoryGroup` column enables natural slicing by region (North America / Europe / Pacific)
