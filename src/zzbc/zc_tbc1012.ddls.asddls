@EndUserText.label: 'Permission Access User <-> Company Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1012
  as projection on ZR_TBC1012
{
  key Uuid,
      UserUuid,
      CompanyCode,
      CompanyCodeName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
