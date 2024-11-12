@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> Role Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1007_1
  as select from    ztbc_1007 as _AssignRole
    left outer join ztbc_1004 on ztbc_1004.user_uuid = _AssignRole.user_uuid

  association to parent ZR_TBC1005 as _Role on $projection.RoleUuid = _Role.RoleUuid
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

      ztbc_1004.user_id                 as UserId,
      ztbc_1004.mail                    as Mail,
      ztbc_1004.department              as Department,
      ztbc_1004.user_name               as UserName,

      _Role
}
