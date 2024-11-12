@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 002-Job Saved Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_002_JOB
  as select from ztbi_bi003_j02
{
  key purchase_order             as PurchaseOrder,
  key purchase_order_item        as PurchaseOrderItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key billing_document           as BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key billing_document_item      as BillingDocumentItem,
      recovery_management_number as RecoveryManagementNumber,
      document_currency          as DocumentCurrency,
      base_unit                  as BaseUnit,
      company_currency           as CompanyCurrency,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      order_quantity             as OrderQuantity,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      net_price_amount           as NetPriceAmount,

      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      company_code               as CompanyCode,
      company_code_name          as CompanyCodeName,

      @ObjectModel.text.element: [ 'SpotbuyMaterialText' ]
      @EndUserText: { label:  'Spotbuy Material', quickInfo: 'Spotbuy Material' }
      spotbuy_material           as SpotbuyMaterial,

      @EndUserText: { label:  'Spotbuy Material Text', quickInfo: 'Spotbuy Material Text' }
      spotbuy_material_text      as SpotbuyMaterialText,

      @ObjectModel.text.element: [ 'ProductOldText' ]
      @EndUserText: { label:  'Old Product ID', quickInfo: 'Old Product ID' }
      product_old_id             as ProductOldId,

      @EndUserText: { label:  'Old Product Text', quickInfo: 'Old Product Text' }
      product_old_text           as ProductOldText,
      fiscal_year_period         as FiscalYearPeriod,

      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: false }
      fiscal_year                as FiscalYear,

      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: true }
      fiscal_month               as FiscalMonth,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Old Material Price', quickInfo: 'Old Material Price' }
      old_material_price         as OldMaterialPrice,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Diff', quickInfo: 'Net Price Diff' }
      net_price_diff             as NetPriceDiff,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      recovery_necessary_amount  as RecoveryNecessaryAmount,
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
