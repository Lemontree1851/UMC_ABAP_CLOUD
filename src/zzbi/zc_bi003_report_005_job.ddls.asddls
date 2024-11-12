@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for ZI_BI003_005 Job Saved Data'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI003_REPORT_005_JOB
  provider contract transactional_query
  as projection on ZI_BI003_REPORT_005_JOB
{
  key MaterialDocument,
  key MaterialDocumentYear,
  key MaterialDocumentItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key BillingDocumentItem,

      @ObjectModel.text.element: [ 'ProductName' ]
      @EndUserText: { label:  'Material', quickInfo: 'Material' }
      Material,

      @EndUserText: { label:  'Material Text', quickInfo: 'Material Text' }
      ProductName,
      RecoveryManagementNumber,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,
      FiscalYearPeriod,

      @Consumption.filter:{ selectionType:  #SINGLE, multipleSelections: false}
      FiscalYear,

      @Consumption.filter:{ selectionType:  #SINGLE, multipleSelections: true}
      FiscalMonth,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      CompanyCode,
      CompanyCodeName,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      RecoveryNecessaryAmount,
      CompanyCurrency,

      @ObjectModel.text.element: [ 'GLAccountName' ]
      GlAccount,
      GlAccountName,
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
