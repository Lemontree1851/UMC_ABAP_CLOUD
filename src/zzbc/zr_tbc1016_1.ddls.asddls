@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access Role <-> Access Btn Table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define root view entity ZR_TBC1016_1
  as select from ztbc_1016 as _AccessBtn
    inner join   ztbc_1014              on ztbc_1014.function_id = _AccessBtn.function_id
    inner join   ztbc_1015 as _Function on  _Function.function_id = _AccessBtn.function_id
                                        and _Function.access_id   = _AccessBtn.access_id
{
  key _AccessBtn.role_id               as RoleId,
  key _AccessBtn.access_id             as AccessId,
      _AccessBtn.function_id           as FunctionId,
      @Semantics.user.createdBy: true
      _AccessBtn.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AccessBtn.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AccessBtn.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AccessBtn.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AccessBtn.local_last_changed_at as LocalLastChangedAt,

      _Function.access_name            as AccessName,

      ztbc_1014.design_file_id         as DesignFileId,
      ztbc_1014.function_name          as FunctionName
}
