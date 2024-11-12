@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 005-Job Saved Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_005_JOB
  as select from ztbi_bi003_j05
{
  key material_document          as MaterialDocument,
  key material_document_year     as MaterialDocumentYear,
  key material_document_item     as MaterialDocumentItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key billing_document           as BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key billing_document_item      as BillingDocumentItem,

      @ObjectModel.text.element: [ 'ProductName' ]
      @EndUserText: { label:  'Material', quickInfo: 'Material' }
      material                   as Material,

      @EndUserText: { label:  'Material Text', quickInfo: 'Material Text' }
      product_name               as ProductName,
      recovery_management_number as RecoveryManagementNumber,

      @Semantics.quantity.unitOfMeasure: 'EntryUnit'
      quantity_in_entry_unit     as QuantityInEntryUnit,
      entry_unit                 as EntryUnit,
      fiscal_year_period         as FiscalYearPeriod,
      fiscal_year                as FiscalYear,
      fiscal_month               as FiscalMonth,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      company_code               as CompanyCode,
      company_code_name          as CompanyCodeName,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      recovery_necessary_amount  as RecoveryNecessaryAmount,
      company_currency           as CompanyCurrency,

      @ObjectModel.text.element: [ 'GLAccountName' ]
      gl_account                 as GlAccount,
      gl_account_name            as GlAccountName,
      sales_order_document       as SalesOrderDocument,
      sales_order_document_item  as SalesOrderDocumentItem,

      @ObjectModel.text.element: [ 'CustomerName' ]
      customer                   as Customer,
      customer_name              as CustomerName,
      transaction_currency       as TransactionCurrency,

      @ObjectModel.text.element: [ 'BillingProductText' ]
      @EndUserText: { label:  'Billing Product', quickInfo: 'Billing Product' }
      billing_product            as BillingProduct,

      @EndUserText: { label:  'Billing Product Text', quickInfo: 'Billing Product Text' }
      billing_product_text       as BillingProductText,
      billing_document_date      as BillingDocumentDate,

      @ObjectModel.text.element: [ 'ProfitCenterName' ]
      profit_center              as ProfitCenter,
      profit_center_name         as ProfitCenterName,
      billing_quantity_unit      as BillingQuantityUnit,

      @Semantics.quantity.unitOfMeasure: 'BillingQuantityUnit'
      billing_quantity           as BillingQuantity,
      billing_currency           as BillingCurrency,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      billing_price              as BillingPrice,
      condition_type             as ConditionType,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Condition Amount', quickInfo: 'Condition Amount' }
      condition_rate_amount      as ConditionRateAmount,

      @Semantics.amount.currencyCode: 'BillingCurrency'
      @EndUserText: { label:  'Recovery Amount', quickInfo: 'Recovery Amount' }
      recovery_amount            as RecoveryAmount,
      job_run_by                 as JobRunBy,
      job_run_date               as JobRunDate,
      job_run_time               as JobRunTime
}
