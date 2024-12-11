@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access Function Table'
define root view entity ZR_TBC1014
  as select from ztbc_1014 as _Function

  composition [0..*] of ZR_TBC1015 as _AccessBtn
{
  key function_id           as FunctionId,
      design_file_id        as DesignFileId,
      function_name         as FunctionName,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _AccessBtn
}
