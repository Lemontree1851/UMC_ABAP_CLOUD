@EndUserText.label: 'Permission Access User <-> PurchOrgTable'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1017
  as projection on ZR_TBC1017
{
  key Uuid,
  key Mail,
      PurchasingOrganization,
      PurchasingOrganizationName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
