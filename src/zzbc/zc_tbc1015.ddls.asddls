@EndUserText.label: 'Permission Access Function <-> AccessBtn Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1015
  as projection on ZR_TBC1015
{
  key Uuid,
  key FunctionId,
      AccessId,
      AccessName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Function : redirected to parent ZC_TBC1014
}
