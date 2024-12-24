@EndUserText.label: 'Permission Access Role Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1005
  provider contract transactional_query
  as projection on ZR_TBC1005
{
  key RoleId,
      RoleName,
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
      _User      : redirected to composition child ZC_TBC1007_1,
      _AccessBtn : redirected to composition child ZC_TBC1016
}
