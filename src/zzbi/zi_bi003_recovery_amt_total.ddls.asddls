@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Total Recovery Amount for BI003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_RECOVERY_AMT_TOTAL
  as select from ZI_BI003_RECOVERY_AMT_DETAILS
{
  key RecoveryManagementNumber,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      sum(RecoveryNecessaryAmount) as TotalRecoveryNecessaryAmount,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      sum(RecoveryAmount)          as TotalRecoveryAmount,

      CompanyCurrency
}
group by
  RecoveryManagementNumber,
  CompanyCurrency
