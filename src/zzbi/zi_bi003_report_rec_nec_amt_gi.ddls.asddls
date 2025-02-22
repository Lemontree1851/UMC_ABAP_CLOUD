// NEW BEGIN BY XINLEI XU 2025/02/11
@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Sum Amount by Material Group'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_REC_NEC_AMT_GI
  with parameters
    p_product_group : matkl
  as select from ZI_BI003_REPORT_003_PO( p_recover_type:'IN' )
{
  key RecoveryManagementNumber,
  key _Matdoc.FiscalYearPeriod as FiscalYearPeriod,

      _CompanyCode.Currency    as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      cast ( cast( currency_conversion( amount => NetPriceAmount,
                         exchange_rate_date => _PurchaseOrder.CreationDate,
                         source_currency => DocumentCurrency,
                         target_currency => _CompanyCode.Currency
                 ) as abap.dec( 16, 2 ) ) * OrderQuantity
             as dmbtr
           )                   as TotalGroupAmount
}
where
  _Product.ProductGroup = $parameters.p_product_group

union all select from ZI_BI003_REPORT_002_BILLING_F3( p_recover_type: 'IN', p_condition_type: 'ZPIN' )
{
  key RecoveryManagementNumber,
  key _FiscalCalendarDate.FiscalYearPeriod,
      _Companycode.Currency   as CompanyCurrency,
      cast( '0.00' as dmbtr ) as TotalGroupAmount
}

union all select from ztbi_bi003_j03 as _table
{
  key recovery_management_number as RecoveryManagementNumber,
  key fiscal_year_period         as FiscalYearPeriod,
      company_currency           as CompanyCurrency,
      recovery_necessary_amount  as TotalGroupAmount
}
where
      job_run_by    = 'UPLOAD'
  and product_group = $parameters.p_product_group
// NEW END BY XINLEI XU 2025/02/11
