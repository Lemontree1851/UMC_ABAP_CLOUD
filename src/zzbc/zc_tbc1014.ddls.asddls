@EndUserText.label: 'Permission Access Function Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1014
  provider contract transactional_query
  as projection on ZR_TBC1014
{
  key FunctionId,
      DesignFileId,
      FunctionName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _AccessBtn : redirected to composition child ZC_TBC1015
}
