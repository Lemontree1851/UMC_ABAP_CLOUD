@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for ZI_BI003_003'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI003_REPORT_003
  provider contract transactional_query
  as projection on ZI_BI003_REPORT_003
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key SourceLedger,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_CompanyCode', element: 'CompanyCode' } }]
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
  key CompanyCode,

      @Consumption.filter:{ selectionType:  #SINGLE, multipleSelections: false}
  key FiscalYear,
  key AccountingDocument,
  key LedgerGLLineItem,
  key Ledger,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key BillingDocumentItem,
      FiscalYearPeriod,

      @Consumption.filter:{ selectionType:  #SINGLE, multipleSelections: true}
      FiscalMonth,

      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZC_RECOVERY_NUMBER_VH', element: 'RecoveryManagementNumber' } }]
      RecoveryManagementNumber,
      CompanyCodeName,

      @ObjectModel.text.element: [ 'MaterialText' ]
      @EndUserText: { label:  'Material', quickInfo: 'Material' }
      Material,
      @EndUserText: { label:  'Material Text', quickInfo: 'Material Text' }
      MaterialText,

      @ObjectModel.text.element: [ 'ProductGroupName' ]
      ProductGroup,
      ProductGroupName,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      OrderQuantity,
      BaseUnit,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      NetPriceAmount,
      CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      RecoveryNecessaryAmount,

      @ObjectModel.text.element: [ 'GLAccountName' ]
      GLAccount,
      GLAccountName,

      @ObjectModel.text.element: [ 'FixedAssetDescription' ]
      FixedAsset,
      FixedAssetDescription,
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

      @EndUserText: { label:  'Percentage Of AP', quickInfo: 'Percentage Of AP' }
      PercentageOfAp,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Accounting Posting Amount', quickInfo: 'Accounting Posting Amount' }
      AccountingPostingAmount
}
