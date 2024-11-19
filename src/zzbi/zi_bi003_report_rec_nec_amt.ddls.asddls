@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Recovery Neccessary Total Amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BI003_REPORT_REC_NEC_AMT
  as select from ZI_BI003_REPORT_REC_NEC_AMT_I
{
  key RecoveryManagementNumber,
  key FiscalYearPeriod,

      CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      sum( TotalAmount ) as TotalAmount
}
group by
  RecoveryManagementNumber,
  FiscalYearPeriod,
  CompanyCurrency
