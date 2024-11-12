@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for ZI_BI003_002 Job Saved Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI003_REPORT_002_JOB
  provider contract transactional_query
  as projection on ZI_BI003_REPORT_002_JOB
{
  key PurchaseOrder,
  key PurchaseOrderItem,
      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key BillingDocument,
      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key BillingDocumentItem,
      RecoveryManagementNumber,
      DocumentCurrency,
      BaseUnit,
      CompanyCurrency,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      NetPriceAmount,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      CompanyCode,
      CompanyCodeName,

      @ObjectModel.text.element: [ 'SpotbuyMaterialText' ]
      @EndUserText: { label:  'Spotbuy Material', quickInfo: 'Spotbuy Material' }
      SpotbuyMaterial,

      @EndUserText: { label:  'Spotbuy Material Text', quickInfo: 'Spotbuy Material Text' }
      SpotbuyMaterialText,

      @ObjectModel.text.element: [ 'ProductOldText' ]
      @EndUserText: { label:  'Old Product ID', quickInfo: 'Old Product ID' }
      ProductOldId,

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
      RecoveryNecessaryAmount,
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
      RecoveryAmount,
      JobRunBy,
      JobRunDate,
      JobRunTime
}
