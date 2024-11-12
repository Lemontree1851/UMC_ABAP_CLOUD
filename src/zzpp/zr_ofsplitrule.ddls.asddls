@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'OF Split Rule'
define root view entity ZR_OFSPLITRULE
  as select from ztpp_1008 as SplitRule

  association [0..1] to I_Customer          as _Customer          on  $projection.Customer = _Customer.Customer
  association [0..1] to I_ProductText       as _ProductText       on  $projection.SplitMaterial = _ProductText.Product
                                                                  and _ProductText.Language     = $session.system_language
  association [0..1] to I_Plant             as _Plant             on  $projection.Plant = _Plant.Plant
  association [0..1] to I_ProductPlantBasic as _ProductPlantBasic on  $projection.SplitMaterial = _ProductPlantBasic.Product
                                                                  and $projection.Plant         = _ProductPlantBasic.Plant
  association [0..1] to ZC_SPLITUNITVH      as _SplitUnit         on  $projection.SplitUnit = _SplitUnit.value_low
  association [0..1] to I_BusinessUserVH    as _CreateUser        on  $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH    as _UpdateUser        on  $projection.LastChangedBy = _UpdateUser.UserID
{
  key customer              as Customer,      // 顧客
  key split_material        as SplitMaterial, // 品目コード
  key plant                 as Plant,         // プラント
  key split_unit            as SplitUnit,     // 分割単位
      ship_unit             as ShipUnit,      // 出荷単位
      valid_end             as ValidEnd,      // 打切り年月
      delete_flag           as DeleteFlag,    // 削除フラグ
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

      _Customer,
      _ProductText,
      _Plant,
      _ProductPlantBasic,
      _SplitUnit,
      _CreateUser,
      _UpdateUser
}
