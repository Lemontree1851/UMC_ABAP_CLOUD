@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for Recover Status Search Help'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_RECOVER_STATUS_VH
  provider contract transactional_query
  as projection on ZI_RECOVER_STATUS_VH
{
      @ObjectModel.text.element: [ 'Description' ]
  key RecoverStatus,
      Description
}
