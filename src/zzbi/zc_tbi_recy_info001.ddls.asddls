@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TBI_RECY_INFO001
  provider contract transactional_query
  as projection on ZR_TBI_RECY_INFO001
  //  association [1] to ZI_RECOVER_TYPE_VH   as _RecoverTypeVH   on $projection.RecoveryType = _RecoverTypeVH.RecoverType
  //association [1] to ZI_RECOVER_STATUS_VH as _RecoverStatusVH on $projection.RecoveryStatus = _RecoverStatusVH.RecoverStatus

{
  key Uuid,
      RecoveryManagementNumber,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'RecoverType', name: 'ZI_RECOVER_TYPE_VH' } }]
      @ObjectModel.text.element: [ 'RecoverTypeDescription' ]
      RecoveryType,
      RecoveryNum,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'CompanyCode' , name: 'I_CompanyCode' } }]
      @ObjectModel.text.element: [ 'CompanyName' ]
      CompanyCode,

      CompanyName,

      //@Consumption.valueHelpDefinition: [{ entity:{ element: 'CalendarYear', name: 'I_CalendarYear' }  }]
      @Consumption.filter:{ selectionType: #SINGLE, multipleSelections: false }
      RecoveryYear,
      //RecoveryMonth,
      //RecoveryPeriod,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'Customer', name: 'I_Customer' } }]
      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      CustomerName,
      Machine,
      //RecoveryNecessaryAmount,
      //RecoveryAlready,

      @Semantics.amount.currencyCode: 'Currency'
      _AmtTotal.TotalRecoveryNecessaryAmount as RecoveryNecessaryAmount,

      @Semantics.amount.currencyCode: 'Currency'
      _AmtTotal.TotalRecoveryAmount          as RecoveryAlready,




      Currency,

      RecoveryPercentage,

      //      case when RecoveryNecessaryAmount <> 0 then
      //         cast ( ( cast( RecoveryAlready as abap.dec(6, 3) ) /
      //                  cast( RecoveryNecessaryAmount as abap.dec(6, 3) )
      //                     ) as ze_recycle_progress )
      //
      //      else cast('0' as ze_recycle_progress ) end as RecoveryPercentage,

      //RecoveryPercentage,

      // _AmtTotal.TotalRecoveryNecessaryAmount,

      @Consumption.valueHelpDefinition: [{ entity:{ element: 'RecoverStatus', name: 'ZI_RECOVER_STATUS_VH' }  }]
      @ObjectModel.text.element: [ 'RecoverStatusDescription' ]
      RecoveryStatus,

      @ObjectModel.text.element: [ 'CreatedName' ] 
      CreatedBy,
      CreatedName,
      CreatedDate,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,


      _RecoverTypeVH.Description             as RecoverTypeDescription,
      _RecoverStatusVH.Description           as RecoverStatusDescription

}
