@EndUserText.label: 'Permission Access Role Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1005
  provider contract transactional_query
  as projection on ZR_TBC1005
{
  key RoleId,
      RoleName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User      : redirected to composition child ZC_TBC1007_1,
      _AccessBtn : redirected to composition child ZC_TBC1016
}
