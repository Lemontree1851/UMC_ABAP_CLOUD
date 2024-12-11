@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access Role <-> Access Btn Table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1016
  as select from ztbc_1016 as _AccessBtn
    inner join   ztbc_1014              on ztbc_1014.function_id = _AccessBtn.function_id
    inner join   ztbc_1015 as _Function on  _Function.function_id = _AccessBtn.function_id
                                        and _Function.access_id   = _AccessBtn.access_id

  association to parent ZR_TBC1005 as _Role on $projection.RoleId = _Role.RoleId
{
  key _AccessBtn.uuid                  as Uuid,
  key _AccessBtn.role_id               as RoleId,
      _AccessBtn.function_id           as FunctionId,
      _AccessBtn.access_id             as AccessId,
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
      ztbc_1014.function_name          as FunctionName,

      _Role
}
