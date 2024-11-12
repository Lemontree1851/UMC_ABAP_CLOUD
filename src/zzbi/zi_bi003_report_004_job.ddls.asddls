@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 004-Job Saved Data'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_004_JOB
  as select from ztbi_bi003_j04
{
  key purchase_order             as PurchaseOrder,
  key purchase_order_item        as PurchaseOrderItem,

      @EndUserText: { label:  'Billing Document', quickInfo: 'Billing Document' }
  key billing_document           as BillingDocument,

      @EndUserText: { label:  'Billing Document Item', quickInfo: 'Billing Document Item' }
  key billing_document_item      as BillingDocumentItem,
      @ObjectModel.text.element: [ 'CompanyCodeName' ]
      company_code               as CompanyCode,
      company_code_name          as CompanyCodeName,
      fiscal_year_period         as FiscalYearPeriod,
      fiscal_year                as FiscalYear,
      fiscal_month               as FiscalMonth,
      recovery_management_number as RecoveryManagementNumber,

      @ObjectModel.text.element: [ 'MaterialText' ]
      @EndUserText: { label:  'Material', quickInfo: 'Material' }
      material                   as Material,

      @EndUserText: { label:  'Material Text', quickInfo: 'Material Text' }
      material_text              as MaterialText,

      @ObjectModel.text.element: [ 'ProductGroupName' ]
      product_group              as ProductGroup,
      product_group_name         as ProductGroupName,

      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      order_quantity             as OrderQuantity,
      base_unit                  as BaseUnit,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Net Price Amount', quickInfo: 'Net Price Amount' }
      net_price_amount           as NetPriceAmount,
      company_currency           as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      recovery_necessary_amount  as RecoveryNecessaryAmount,

      @ObjectModel.text.element: [ 'GLAccountName' ]
      gl_account                 as GlAccount,
      gl_account_name            as GlAccountName,

      @ObjectModel.text.element: [ 'FixedAssetDescription' ]
      fixed_asset                as FixedAsset,
      fixed_asset_description    as FixedAssetDescription,
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
