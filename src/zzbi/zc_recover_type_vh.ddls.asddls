@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Comsuption View for Recover Type Search Help'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_RECOVER_TYPE_VH
  provider contract transactional_query
  as projection on ZI_RECOVER_TYPE_VH
{
      @ObjectModel.text.element: [ 'Description' ]
  key RecoverType,
      Description
}
