@EndUserText.label: 'Permission Access User <-> Sales Org. Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1013
  as projection on ZR_TBC1013
{
  key Uuid,
      UserUuid,
      SalesOrganization,
      SalesOrganizationName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
