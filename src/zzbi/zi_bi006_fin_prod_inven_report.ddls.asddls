@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI006 Long Term Finished Product Material Inventory Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI006_FIN_PROD_INVEN_REPORT
  as select from ZI_BI006_FIN_PROD_INVENTORY
{
  key CompanyCode,
  key Plant,
  key FiscalYearMonth,
  key Product,
      FiscalYear,
      Period,
      FiscalPeriod,
      cast('長滞在庫' as abap.char( 20 ) ) as Type,
      CompanyCodeName,
      PlantName,
      ProductName,
      ProductType,
      ProductTypeName,
      ProfitCenter,
      ProfitCenterName,
      Customer,
      CustomerName,
      Currency,
      ValuationArea,
      @Semantics.amount.currencyCode: 'Currency'
      ActualPrice,

      @Semantics.amount.currencyCode: 'Currency'
      InventoryAmount,
      Qty
}
