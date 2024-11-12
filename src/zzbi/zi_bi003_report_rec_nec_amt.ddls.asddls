@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Recovery Neccessary Total Amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BI003_REPORT_REC_NEC_AMT
  as select from ZI_BI003_REPORT_003_PO( p_recover_type:'IN' )
{
  key RecoveryManagementNumber,

      _CompanyCode.Currency as CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      sum( cast ( cast( currency_conversion( amount => NetPriceAmount,
                        exchange_rate_date => _PurchaseOrder.CreationDate,
                        source_currency => DocumentCurrency,
                        target_currency => _CompanyCode.Currency
                 ) as abap.dec( 16, 2 ) ) * OrderQuantity
             as dmbtr
           ) )              as TotalAmount
}
group by
  RecoveryManagementNumber,
  _CompanyCode.Currency
