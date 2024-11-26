@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI006 Long Term Finished Product Material Inventory Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI006_FIN_PROD_INVENTORY
  as select from ZI_BI006_INVENTORY_DETAIL
{
  key CompanyCode,
  key Plant,
  key FiscalYearMonth,
  key Product,
      FiscalYear,
      Period,
      CompanyCodeName,
      PlantName,
      ProductName,
      ProductType,
      ProductTypeName,
      ProfitCenter,
      ProfitCenterName,
      Customer,
      CustomerName,

      @Semantics.amount.currencyCode: 'Currency'
      ActualPrice,

      @Semantics.amount.currencyCode: 'Currency'
      InventoryAmount,
      Currency,
      sum(Qty) as Qty
}
where
  (
       ProductType = 'ZFRT'
    or ProductType = 'ZHLB'
  )
  and  Age         > '003'
group by
  CompanyCode,
  Plant,
  FiscalYearMonth,
  Product,
  FiscalYear,
  Period,
  CompanyCodeName,
  PlantName,
  ProductName,
  ProductType,
  ProductTypeName,
  ProfitCenter,
  ProfitCenterName,
  Customer,
  CustomerName,
  ActualPrice,
  InventoryAmount,
  Currency
