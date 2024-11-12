@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for Recovery Number'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZI_RECOVERY_NUMBER_VH
  as select from ZR_TBI_RECY_INFO001
{
  key Uuid,
      RecoveryManagementNumber,

      @ObjectModel.text.element: [ 'RecoverTypeDescription' ]
      RecoveryType,

      @ObjectModel.text.element: [ 'CompanyName' ]
      CompanyCode,
      CompanyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      CustomerName,
      RecoveryYear,

      _RecoverTypeVH.Description as RecoverTypeDescription
}
