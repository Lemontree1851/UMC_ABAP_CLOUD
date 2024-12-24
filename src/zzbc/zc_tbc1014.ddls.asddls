@EndUserText.label: 'Permission Access Function Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1014
  provider contract transactional_query
  as projection on ZR_TBC1014
{
  key FunctionId,
      DesignFileId,
      FunctionName,
      @ObjectModel.text.element: ['CreateUserName']
      CreatedBy,
      CreatedAt,
      @ObjectModel.text.element: ['UpdateUserName']
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden: true
      _CreateUser.PersonFullName as CreateUserName,
      @UI.hidden: true
      _UpdateUser.PersonFullName as UpdateUserName,

      /* Associations */
      _AccessBtn : redirected to composition child ZC_TBC1015
}
