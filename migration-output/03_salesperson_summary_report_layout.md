# Report Layout — Salesperson Summary Report
## Power BI Equivalent of SSRS Report

**SSRS Report:** `Salesperson_Summary_Report.rdl`  
**Dataset:** `SalesPerson.rsd` (shared dataset)  
**Complexity:** 🟡 Medium — grouped report (by TerritoryName), group header rows, LEFT OUTER JOIN, ISNULL handling

---

## SSRS → Power BI Feature Mapping

| SSRS Element | Power BI Equivalent | Notes |
|---|---|---|
| Tablix grouped by TerritoryName | **Matrix visual** with TerritoryName as row group | Matrix natively produces group subtotals |
| Group header row (PowderBlue background) | Matrix subtotal row formatting | Format pane → Row subtotals → Background color |
| `=Sum(Fields!SalesQuota.Value)` in group row | Matrix subtotal (automatic) | Enable "Subtotals" in matrix settings |
| `=Avg(Fields!CommissionPct.Value)` in group row | `SP Avg Commission Pct` DAX measure | Measure, not a simple sum |
| `ISNULL(ST.Name,'*No Territory')` | Handled in Power Query (step 7) | Null replaced with `"*No Territory"` |
| `LEFT OUTER JOIN SalesTerritory` | Left outer join in Power Query (step 6) | Preserves salespersons without territory |
| `FirstName + ' ' + LastName` | `SalesPersonName` calculated in Power Query | Combined in M, not DAX |
| ColSpan=2 on TerritoryName | Matrix visual natural grouping | No colspan needed in Power BI |

---

## Recommended Power BI Report Layout

### Page: Salesperson Summary

```
┌─────────────────────────────────────────────────────────────────┐
│  SLICERS                                                        │
│  [ Territory Name ]  [ Salesperson Name ]                       │
├──────────────┬──────────────┬──────────────┬────────────────────┤
│  KPI Cards   │ Total YTD    │ Quota Att.%  │ Total Bonus        │
│              │ $XX,XXX,XXX  │ XXX%         │ $XXX,XXX           │
├─────────────────────────────────────────────────────────────────┤
│  MATRIX VISUAL                                                  │
│  Row group: TerritoryName (bold subtotal rows)                  │
│  Detail rows: SalesPersonName                                   │
│  Columns: Sales Quota | Bonus | Commission % | Sales YTD        │
│           | Sales Last Year | YoY Growth %  | Quota Att. %      │
│  Subtotals: ON (territory level)                                │
│  Grand total: ON                                                │
├─────────────────────────────────────────────────────────────────┤
│  BAR CHART: Sales YTD by Territory (sorted desc)                │
│  SCATTER CHART: Quota vs Actual by Salesperson (NEW insight)    │
└─────────────────────────────────────────────────────────────────┘
```

---

## Replicating the SSRS Group Header (PowderBlue Row)

**In SSRS:** Territory header row with `BackgroundColor=PowderBlue`, spans 2 columns, shows territory totals.

**In Power BI Matrix:**
1. Select the Matrix visual
2. Format pane → **Row subtotals** → toggle ON
3. **Subtotals background color** → set to `#B0E0E6` (PowderBlue equivalent)
4. **Subtotals font** → Bold

This replicates the SSRS group header behaviour without any custom code.

---

## Model Relationships

```
SalesPerson[BusinessEntityID] ←→ (none — SalesPerson IS the main table)
SalesPerson[TerritoryID]  →  SalesTerritory[TerritoryID]   (many-to-one)
SalesOrders[SalesPersonID] →  SalesPerson[BusinessEntityID] (many-to-one)
```

---

## New Insights Unlocked by Power BI

These were **not possible in the original SSRS report**:

| New Insight | Visual Type |
|---|---|
| Quota attainment % per salesperson | Bar chart / KPI card |
| YoY growth % per territory | Matrix column |
| Scatter: Quota vs Actual (outlier detection) | Scatter chart |
| Interactive drill-down: Territory → Salesperson | Matrix expand/collapse |
| Cross-filter with Orders report | Cross-report drill-through |
