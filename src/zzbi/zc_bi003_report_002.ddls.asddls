@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for ZI_BI003_002'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI003_REPORT_002
  provider contract transactional_query
  as projection on ZI_BI003_REPORT_002
{
  key PurchaseOrder,
  key PurchaseOrderItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key BillingDocumentItem,

      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZC_RECOVERY_NUMBER_VH', element: 'RecoveryManagementNumber' } }]
      RecoveryManagementNumber,
      DocumentCurrency,
      BaseUnit,
      CreationDate,
      CompanyCurrency,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      NetPriceAmount,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_CompanyCode', element: 'CompanyCode' } }]
      CompanyCode,

      @ObjectModel.text.element: [ 'SpotbuyMaterialText' ]
      @EndUserText: { label:  'Spotbuy Material', quickInfo: 'Spotbuy Material' }
      SpotbuyMaterial,

      @EndUserText: { label:  'Spotbuy Material Text', quickInfo: 'Spotbuy Material Text' }
      SpotbuyMaterialText,

      @ObjectModel.text.element: [ 'ProductOldText' ]
      @EndUserText: { label:  'Old Product ID', quickInfo: 'Old Product ID' }
      ProductOldID,

      @EndUserText: { label:  'Old Product Text', quickInfo: 'Old Product Text' }
      ProductOldText,
      FiscalYearPeriod,

      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: false }
      FiscalYear,

      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: true }
      FiscalMonth,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Old Material Price', quickInfo: 'Old Material Price' }
      OldMaterialPrice,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Diff', quickInfo: 'Net Price Diff' }
      NetPriceDiff,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      RecoveryNecessaryAmount, //NetAmountDiff,
      CompanyCodeName,
      SalesOrderDocument,
      SalesOrderDocumentItem,

      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      CustomerName,
      TransactionCurrency,

      @ObjectModel.text.element: [ 'BillingProductText' ]
      @EndUserText: { label:  'Billing Product', quickInfo: 'Billing Product' }
      BillingProduct,

      @EndUserText: { label:  'Billing Product Text', quickInfo: 'Billing Product Text' }
      BillingProductText,
      BillingDocumentDate,

      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      ProfitCenter,
      ProfitCenterName,
      BillingQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      BillingQuantity,
      BillingCurrency,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      BillingPrice,
      ConditionType,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Condition Amount', quickInfo: 'Condition Amount' }
      ConditionRateAmount,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Recovery Amount', quickInfo: 'Recovery Amount' }
      RecoveryAmount //BillingTotalAmount
}
