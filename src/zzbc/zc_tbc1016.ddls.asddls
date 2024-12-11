@EndUserText.label: 'Permission Access Role <-> Access Btn Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_TBC1016
  as projection on ZR_TBC1016
{
  key Uuid,
  key RoleId,
      FunctionId,
      DesignFileId,
      FunctionName,
      AccessId,
      AccessName,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Role : redirected to parent ZC_TBC1005
}
