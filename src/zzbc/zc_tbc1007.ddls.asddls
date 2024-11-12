@EndUserText.label: 'Permission Access User <-> Role Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1007
  as projection on ZR_TBC1007
{
  key Uuid,
      UserUuid,
      RoleUuid,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      RoleId,
      RoleName,
      FunctionId,
      AccessId,
      AccessName,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
