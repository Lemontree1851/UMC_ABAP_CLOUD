@EndUserText.label: 'Permission Access Role <-> Access Btn Table'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_TBC1016_1
  provider contract transactional_query
  as projection on ZR_TBC1016_1
{
  key RoleId,
  key AccessId,
      FunctionId,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      AccessName,
      DesignFileId,
      FunctionName
}
