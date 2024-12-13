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
  as select from ztbc_1007 as _AssignRole
    inner join   ztbc_1004 on ztbc_1004.mail = _AssignRole.mail

  association to parent ZR_TBC1005 as _Role on $projection.RoleId = _Role.RoleId
{
  key _AssignRole.uuid                  as Uuid,
  key _AssignRole.mail                  as Mail,
      _AssignRole.role_id               as RoleId,
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
      ztbc_1004.user_name               as UserName,
      ztbc_1004.department              as Department,

      _Role
}
