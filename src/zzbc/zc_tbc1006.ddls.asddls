@EndUserText.label: 'Permission Access User <-> Plant Data'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1006
  as projection on ZR_TBC1006
{
  key Uuid,
      UserUuid,
      Plant,
      PlantName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
