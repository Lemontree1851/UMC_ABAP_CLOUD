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
  as select from ztbc_1007 as _AssignRole
    inner join   ztbc_1005 on ztbc_1005.role_id = _AssignRole.role_id

  association        to parent ZR_TBC1004 as _User              on $projection.Mail = _User.Mail
  association [0..*] to ZR_TBC1016_1      as _UserRoleAccessBtn on $projection.RoleId = _UserRoleAccessBtn.RoleId
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

      ztbc_1005.role_name               as RoleName,

      _User,
      _UserRoleAccessBtn
}
