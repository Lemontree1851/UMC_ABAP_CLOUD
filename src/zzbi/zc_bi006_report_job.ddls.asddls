@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for BI006 Job Result'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI006_REPORT_JOB
  provider contract transactional_query
  as projection on ZI_BI006_REPORT_JOB
{
  key CompanyCode,
  key Plant,

      @EndUserText.label : 'Year Month'
  key FiscalYearMonth,
  key Product,
      FiscalYear,

      @EndUserText.label : 'Fiscal Period'
      Period,
      FiscalPeriod,

      @EndUserText.label : 'Type'
      Type,
      CompanyCodeName,

      @EndUserText.label : 'Plant Name'
      PlantName,
      ProductName,
      ProductType,

      @EndUserText.label : 'Product Type Name'
      ProductTypeName,
      ProfitCenter,

      @EndUserText.label : 'Profit Center Name'
      ProfitCenterName,
      Customer,

      @EndUserText.label : 'Customer Name'
      CustomerName,
      ValuationArea,

      @EndUserText.label : 'Quantity'
      Qty,
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label : 'Actual Price'
      ActualPrice,

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label : 'Inventory Amount'
      InventoryAmount,
      Currency
}
