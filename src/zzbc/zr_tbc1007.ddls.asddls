@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> Role Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1007
  as select from    ztbc_1007 as _AssignRole
    left outer join ztbc_1005 on ztbc_1005.role_uuid = _AssignRole.role_uuid

  association to parent ZR_TBC1004 as _User on $projection.UserUuid = _User.UserUuid
{
  key _AssignRole.uuid                  as Uuid,
      _AssignRole.user_uuid             as UserUuid,
      _AssignRole.role_uuid             as RoleUuid,
      @Semantics.user.createdBy: true
      _AssignRole.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AssignRole.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AssignRole.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AssignRole.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AssignRole.local_last_changed_at as LocalLastChangedAt,

      ztbc_1005.role_id                 as RoleId,
      ztbc_1005.role_name               as RoleName,
      ztbc_1005.function_id             as FunctionId,
      ztbc_1005.access_id               as AccessId,
      ztbc_1005.access_name             as AccessName,

      _User
}
