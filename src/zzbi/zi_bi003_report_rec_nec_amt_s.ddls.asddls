@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Recovery Neccessary Total Amount'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_BI003_REPORT_REC_NEC_AMT_S
  as select from    ZI_BI003_REPORT_REC_NEC_AMT as old
    left outer join ZI_BI003_REPORT_REC_NEC_AMT as new on  old.RecoveryManagementNumber =  new.RecoveryManagementNumber
                                                       and new.FiscalYearPeriod         <= old.FiscalYearPeriod
{
  key old.RecoveryManagementNumber,
      old.FiscalYearPeriod,

      old.CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      sum( new.TotalAmount ) as TotalAmount
}
group by
  old.RecoveryManagementNumber,
  old.FiscalYearPeriod,
  old.CompanyCurrency
