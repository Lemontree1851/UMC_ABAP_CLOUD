@EndUserText.label: 'Permission Access User <-> Role Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1007
  as projection on ZR_TBC1007
{
  key Uuid,
  key UserId,
      RoleId,
      RoleName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
