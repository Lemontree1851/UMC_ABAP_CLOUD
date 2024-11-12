@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User Data'
define root view entity ZR_TBC1004
  as select from ztbc_1004 as _User

  composition [0..*] of ZR_TBC1006 as _AssignPlant
  composition [0..*] of ZR_TBC1007 as _AssignRole
{
  key user_uuid             as UserUuid,
      user_id               as UserId,
      mail                  as Mail,
      department            as Department,
      user_name             as UserName,
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

      _AssignPlant,
      _AssignRole
}
