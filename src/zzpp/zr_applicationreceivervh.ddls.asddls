@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'MR Application Receiver Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_ApplicationReceiverVH
  as select from ztpp_1011

  association [0..1] to I_Plant          as _Plant      on $projection.Plant = _Plant.Plant
  association [0..1] to I_Customer       as _Customer   on $projection.Customer = _Customer.Customer
  association [0..1] to ZC_EMAILCOPYVH   as _EmailCopy  on $projection.ReceiverType = _EmailCopy.value_low
  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID

{
  key ztpp_1011.uuid                  as UUID,
      ztpp_1011.plant                 as Plant,
      ztpp_1011.customer              as Customer,
      ztpp_1011.receiver              as Receiver,
      ztpp_1011.receiver_type         as ReceiverType,
      ztpp_1011.mail_address          as MailAddress,
      @Semantics.user.createdBy: true
      ztpp_1011.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ztpp_1011.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      ztpp_1011.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      ztpp_1011.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ztpp_1011.local_last_changed_at as LocalLastChangedAt,

      _Plant,
      _Customer,
      _EmailCopy,
      _CreateUser,
      _UpdateUser
}
