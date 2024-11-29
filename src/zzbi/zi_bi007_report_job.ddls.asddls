@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '長期滞留在庫予測'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI007_REPORT_JOB
  as select from ztbi_bi007_j01
{
  key company_code       as CompanyCode,
  key plant              as Plant,
  key fiscal_year_month  as FiscalYearMonth,
  key base_year_month    as BaseYearMonth,
  key product            as Product,
      fiscal_year        as FiscalYear,
      period             as Period,
      fiscal_period      as FiscalPeriod,
      type               as Type,
      company_code_name  as CompanyCodeName,
      plant_name         as PlantName,
      product_name       as ProductName,
      product_type       as ProductType,
      product_type_name  as ProductTypeName,
      profit_center      as ProfitCenter,
      profit_center_name as ProfitCenterName,
      customer           as Customer,
      customer_name      as CustomerName,
      valuation_area     as ValuationArea,
      qty                as Qty,
      @Semantics.amount.currencyCode: 'Currency'
      actual_price       as ActualPrice,
      @Semantics.amount.currencyCode: 'Currency'
      inventory_amount   as InventoryAmount,
      currency           as Currency
}
