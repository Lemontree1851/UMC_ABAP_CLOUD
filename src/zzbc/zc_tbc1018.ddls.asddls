@EndUserText.label: 'Permission Access User <-> Shipping Point Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1018
  as projection on ZR_TBC1018
{
  key Uuid,
  key Mail,
      ShippingPoint,
      ShippingPointName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _User : redirected to parent ZC_TBC1004
}
