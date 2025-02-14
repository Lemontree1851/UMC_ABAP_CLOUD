@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Sum Amount by Material Group'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_REC_NEC_AMT_GP
  with parameters
    p_product_group : matkl
  // DEL BEGIN BY XINLEI XU 2025/02/11
  //  as select from ZI_BI003_REPORT_003_PO( p_recover_type:'IN' )
  //{
  //  key RecoveryManagementNumber,
  //  key _Matdoc.FiscalYearPeriod as FiscalYearPeriod,
  //
  //      _CompanyCode.Currency    as CompanyCurrency,
  //
  //      @Semantics.amount.currencyCode: 'CompanyCurrency'
  //      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
  //      sum(  cast ( cast( currency_conversion( amount => NetPriceAmount,
  //                         exchange_rate_date => _PurchaseOrder.CreationDate,
  //                         source_currency => DocumentCurrency,
  //                         target_currency => _CompanyCode.Currency
  //                 ) as abap.dec( 16, 2 ) ) * OrderQuantity
  //             as dmbtr
  //           )   )               as TotalGroupAmount
  //}
  //where
  //  _Product.ProductGroup = $parameters.p_product_group
  //group by
  //  RecoveryManagementNumber,
  //  _Matdoc.FiscalYearPeriod,
  //  _CompanyCode.Currency
  // DEL END BY XINLEI XU 2025/02/11

  // ADD BEGIN BY XINLEI XU 2025/02/11
  as select from ZI_BI003_REPORT_REC_NEC_AMT_GI(p_product_group: $parameters.p_product_group)
{
  key RecoveryManagementNumber,
  key FiscalYearPeriod,
      CompanyCurrency,
      @Semantics.amount.currencyCode: 'CompanyCurrency'
      sum( TotalGroupAmount ) as TotalGroupAmount
}
group by
  RecoveryManagementNumber,
  FiscalYearPeriod,
  CompanyCurrency
// ADD END BY XINLEI XU 2025/02/11
