@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LED Material Production Version Info'
define root view entity ZR_LEDPRODUCTIONVERSION
  as select from ztpp_1017

  association [0..1] to I_ProductText    as _MaterialText  on  $projection.Material   = _MaterialText.Product
                                                           and _MaterialText.Language = $session.system_language
  association [0..1] to I_ProductText    as _ComponentText on  $projection.Component   = _ComponentText.Product
                                                           and _ComponentText.Language = $session.system_language
  association [0..1] to I_Plant          as _Plant         on  $projection.Plant = _Plant.Plant
  association [0..1] to I_BusinessUserVH as _CreateUser    on  $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser    on  $projection.LastChangedBy = _UpdateUser.UserID
{
  key material              as Material,
  key plant                 as Plant,
  key version_info          as VersionInfo,
  key component             as Component,
      delete_flag           as DeleteFlag,
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

      _MaterialText,
      _ComponentText,
      _Plant,
      _CreateUser,
      _UpdateUser
}
