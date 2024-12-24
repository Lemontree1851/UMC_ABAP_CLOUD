@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access Role Data'
define root view entity ZR_TBC1005
  as select from ztbc_1005

  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID

  composition [0..*] of ZR_TBC1007_1     as _User
  composition [0..*] of ZR_TBC1016       as _AccessBtn
{
  key role_id               as RoleId,
      role_name             as RoleName,
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

      _CreateUser,
      _UpdateUser,
      
      _User,
      _AccessBtn
}
