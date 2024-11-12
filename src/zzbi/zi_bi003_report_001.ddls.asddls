@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI003 Report 001'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_BI003_REPORT_001
  as select from ZR_TBI_RECY_INFO001
{
  key Uuid,
      RecoveryManagementNumber,
      RecoveryType,
      RecoveryNum,
      CompanyCode,
      CompanyName,
      Customer,
      CustomerName,
      RecoveryYear,
      Machine,

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText: { label:  'Recovery Necessary Amount', quickInfo: 'Recovery Necessary Amount' }

      _AmtTotal.TotalRecoveryNecessaryAmount           as RecoveryNecessaryAmount,

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText: { label:  'Recovery Already', quickInfo: 'Recovery Already' }

      _AmtTotal.TotalRecoveryAmount                    as RecoveryAlready,
      Currency,

      @EndUserText: { label:  'Recovery Percentage', quickInfo: 'Recovery Percentage' }
      case when _AmtTotal.TotalRecoveryNecessaryAmount <> 0 then
      cast(
        ( cast( _AmtTotal.TotalRecoveryAmount as abap.dec( 16, 2 ) ) /
          cast( _AmtTotal.TotalRecoveryNecessaryAmount as abap.dec(16, 2) )
        ) as ze_recycle_progress )
      else 0 end                                       as RecoveryPercentage,

      case when RecoveryStatus = '2' then '2'
      when _AmtTotal.TotalRecoveryAmount >= _AmtTotal.TotalRecoveryNecessaryAmount then '2'
      else '1' end                                     as RecoveryStatus,

      @Semantics.user.createdBy: true
      @ObjectModel.text.element: [ 'CreatedName' ]
      CreatedBy,
      CreatedName,

      CreatedDate,

      @Semantics.systemDateTime.createdAt: true
      CreatedAt,

      @Semantics.user.lastChangedBy: true
      LastChangedBy,

      @Semantics.systemDateTime.lastChangedAt: true
      LastChangedAt,

      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      LocalLastChangedAt,

      ZR_TBI_RECY_INFO001._RecoverStatusVH.Description as RecoverStatusDescription,
      ZR_TBI_RECY_INFO001._RecoverTypeVH.Description   as RecoverTypeDescription
      //      info._RecoverStatusVH
}
