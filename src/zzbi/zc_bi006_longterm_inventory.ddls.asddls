@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for ZI_BI006_LONGTERM_INVENTORY'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI006_LONGTERM_INVENTORY
  provider contract transactional_query
  as projection on ZI_BI006_LONGTERM_INVENTORY
{
      @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode', name: 'I_CompanyCode' } }]
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
  key CompanyCode,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'Plant', name: 'I_Plant' } }]
      @ObjectModel.text.element: [ 'PlantName' ]
  key Plant,
  key FiscalYearMonth,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'Product', name: 'ZI_PRODUCT_VH' } }]
      @ObjectModel.text.element: [ 'ProductName' ]
  key Product,

      FiscalYear,
      Period,
      Type,
      CompanyCodeName,
      PlantName,
      ProductName,

      @ObjectModel.text.element: [ 'ProductTypeName' ]
      ProductType,
      ProductTypeName,

      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      ProfitCenter,
      ProfitCenterName,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'Customer', name: 'I_Customer' } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      CustomerName,
      
      ValuationArea,
      @Semantics.amount.currencyCode: 'Currency'
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BI006_ACTUAL_PRICE'
      @EndUserText.label: '実際原価'
      ActualPrice,

      @Semantics.amount.currencyCode: 'Currency'
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BI006_ACTUAL_PRICE'
      @EndUserText.label: '長期滞留在庫金額'
      InventoryAmount,
      
      FiscalPeriod,
      Currency,
      Qty
}
