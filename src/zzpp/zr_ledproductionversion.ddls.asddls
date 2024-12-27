@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LED Material Production Version Info'
define root view entity ZR_LEDPRODUCTIONVERSION
  as select from ztpp_1017
    inner join   ZR_TBC1006           as _AssignPlant on _AssignPlant.Plant = ztpp_1017.plant
    inner join   ZC_BusinessUserEmail as _User        on  _User.Email  = _AssignPlant.Mail
                                                      and _User.UserID = $session.user

  association [0..1] to I_ProductText    as _MaterialText  on  $projection.Material   = _MaterialText.Product
                                                           and _MaterialText.Language = $session.system_language
  association [0..1] to I_ProductText    as _ComponentText on  $projection.Component   = _ComponentText.Product
                                                           and _ComponentText.Language = $session.system_language
  association [0..1] to I_Plant          as _Plant         on  $projection.Plant = _Plant.Plant
  association [0..1] to I_BusinessUserVH as _CreateUser    on  $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser    on  $projection.LastChangedBy = _UpdateUser.UserID
{
  key ztpp_1017.material              as Material,
  key ztpp_1017.plant                 as Plant,
  key ztpp_1017.version_info          as VersionInfo,
  key ztpp_1017.component             as Component,
      ztpp_1017.delete_flag           as DeleteFlag,
      @Semantics.user.createdBy: true
      ztpp_1017.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ztpp_1017.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      ztpp_1017.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      ztpp_1017.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ztpp_1017.local_last_changed_at as LocalLastChangedAt,

      _MaterialText,
      _ComponentText,
      _Plant,
      _CreateUser,
      _UpdateUser
}
