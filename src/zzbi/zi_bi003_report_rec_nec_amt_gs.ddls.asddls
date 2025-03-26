@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 003 Sum Amount by Material Group'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_REPORT_REC_NEC_AMT_GS
  with parameters
    p_product_group : matkl
  as select from    ZI_BI003_REPORT_REC_NEC_AMT_GP(p_product_group: $parameters.p_product_group) as old
    left outer join ZI_BI003_REPORT_REC_NEC_AMT_GP(p_product_group: $parameters.p_product_group) as new on  old.RecoveryManagementNumber =  new.RecoveryManagementNumber
                                                                                                        and new.FiscalYearPeriod         <= old.FiscalYearPeriod // ADD BY XINLEI XU 2025/02/11
{
  key old.RecoveryManagementNumber,
  key old.FiscalYearPeriod,
      old.CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }
      sum( new.TotalGroupAmount ) as TotalGroupAmount
}
group by
  old.RecoveryManagementNumber,
  old.FiscalYearPeriod,
  old.CompanyCurrency
