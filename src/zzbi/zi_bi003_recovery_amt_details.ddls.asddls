@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Recovery Amount for BI003'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI003_RECOVERY_AMT_DETAILS
  as select from ZI_BI003_REPORT_002
{
  key RecoveryManagementNumber,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      RecoveryNecessaryAmount,
      CompanyCurrency,

      @Semantics.amount.currencyCode: 'CompanyCurrency'
      RecoveryAmount
}
union select from ZI_BI003_REPORT_003
{
  key RecoveryManagementNumber,

      RecoveryNecessaryAmount,
      CompanyCurrency,

      RecoveryAmount
}
union select from ZI_BI003_REPORT_004
{
  key RecoveryManagementNumber,

      RecoveryNecessaryAmount,
      CompanyCurrency,

      RecoveryAmount
}
union select from ZI_BI003_REPORT_005
{
  key RecoveryManagementNumber,

      RecoveryNecessaryAmount,
      CompanyCurrency,

      RecoveryAmount
}
