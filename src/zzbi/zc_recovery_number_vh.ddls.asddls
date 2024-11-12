@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for Recovery Number Search Help'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_RECOVERY_NUMBER_VH
  provider contract transactional_query
  as projection on ZI_RECOVERY_NUMBER_VH
{
  key Uuid,
      RecoveryManagementNumber,

      @ObjectModel.text.element: [ 'RecoverTypeDescription' ]
      RecoveryType,
      RecoverTypeDescription,

      @ObjectModel.text.element: [ 'CompanyName' ]
      CompanyCode,
      CompanyName,

      @ObjectModel.text.element: [ 'CustomerName' ]
      Customer,
      CustomerName,
      RecoveryYear
}
