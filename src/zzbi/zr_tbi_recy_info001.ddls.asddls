@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TBI_RECY_INFO001
  as select from ztbi_recy_info       as recy_info

    inner join   ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = recy_info.company_code
    inner join   ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignCompany.Mail
                                                        and _User.UserID = $session.user

  association [0..1] to ZI_BI003_RECOVERY_AMT_TOTAL as _AmtTotal        on $projection.RecoveryManagementNumber = _AmtTotal.RecoveryManagementNumber
  association [1]    to ZI_RECOVER_TYPE_VH          as _RecoverTypeVH   on $projection.RecoveryType = _RecoverTypeVH.RecoverType
  association [1]    to ZI_RECOVER_STATUS_VH        as _RecoverStatusVH on $projection.RecoveryStatus = _RecoverStatusVH.RecoverStatus
{
  key recy_info.uuid                       as Uuid,
      recy_info.recovery_management_number as RecoveryManagementNumber,
      recy_info.recovery_type              as RecoveryType,
      recy_info.recovery_num               as RecoveryNum,

      @ObjectModel.text.element: [ 'CompanyName' ]
      recy_info.company_code               as CompanyCode,
      recy_info.company_name               as CompanyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      recy_info.customer                   as Customer,
      recy_info.customer_name              as CustomerName,

      @Semantics.calendar.year: true
      recy_info.recovery_year              as RecoveryYear,
      //recovery_month             as RecoveryMonth,
      //recovery_period            as RecoveryPeriod,
      recy_info.machine                    as Machine,
      @Semantics.amount.currencyCode: 'Currency'
      // @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BI003_TEST'
      recy_info.recovery_necessary_amount  as RecoveryNecessaryAmount,



      //@Semantics.amount.currencyCode: 'Currency'
      // AmtTotal.TotalRecoveryNecessaryAmount as RecoveryNeccesaryAmountDisplay,
      @Semantics.amount.currencyCode: 'Currency'
      recy_info.recovery_already           as RecoveryAlready,
      recy_info.currency                   as Currency,
      recy_info.recovery_percentage        as RecoveryPercentage,
      recy_info.recovery_status            as RecoveryStatus,


      @Semantics.user.createdBy: true
      @ObjectModel.text.element: [ 'CreatedName' ]
      recy_info.created_by                 as CreatedBy,

      recy_info.created_name               as CreatedName,
      recy_info.created_date               as CreatedDate,
      @Semantics.systemDateTime.createdAt: true
      recy_info.created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      recy_info.last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      recy_info.last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      recy_info.local_last_changed_at      as LocalLastChangedAt,



      _RecoverStatusVH,
      _RecoverTypeVH,
      _AmtTotal
}
