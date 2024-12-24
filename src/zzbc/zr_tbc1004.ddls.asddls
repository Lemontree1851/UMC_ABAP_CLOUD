@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User Data'
define root view entity ZR_TBC1004
  as select from ztbc_1004 as _User

  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID

  composition [0..*] of ZR_TBC1006       as _AssignPlant
  composition [0..*] of ZR_TBC1012       as _AssignCompany
  composition [0..*] of ZR_TBC1013       as _AssignSalesOrg
  composition [0..*] of ZR_TBC1017       as _AssignPurchOrg
  composition [0..*] of ZR_TBC1007       as _AssignRole
{
  key mail                  as Mail,
      user_id               as UserId,
      user_name             as UserName,
      department            as Department,
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

      _AssignPlant,
      _AssignCompany,
      _AssignSalesOrg,
      _AssignPurchOrg,
      _AssignRole
}
