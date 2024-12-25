@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> Shipping Point Table'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1018
  as select from ztbc_1018           as _AssignShippingPoint
    inner join   I_ShippingPointText as _ShippingPointText on  _ShippingPointText.ShippingPoint = _AssignShippingPoint.shipping_point
                                                           and _ShippingPointText.Language      = $session.system_language

  association to parent ZR_TBC1004 as _User on $projection.Mail = _User.Mail
{
  key _AssignShippingPoint.uuid                  as Uuid,
  key _AssignShippingPoint.mail                  as Mail,
      _AssignShippingPoint.shipping_point        as ShippingPoint,
      @Semantics.user.createdBy: true
      _AssignShippingPoint.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AssignShippingPoint.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AssignShippingPoint.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AssignShippingPoint.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AssignShippingPoint.local_last_changed_at as LocalLastChangedAt,

      _ShippingPointText.ShippingPointName,

      _User
}
