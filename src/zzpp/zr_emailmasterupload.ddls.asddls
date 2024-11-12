@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_EMAILMASTERUPLOAD
  as select from ztpp_1011

  association [0..1] to I_Plant          as _Plant      on $projection.Plant = _Plant.Plant
  association [0..1] to I_Customer       as _Customer   on $projection.Customer = _Customer.Customer
  association [0..1] to ZC_EMAILCOPYVH   as _EmailCopy  on $projection.ReceiverType = _EmailCopy.value_low
  association [0..1] to I_BusinessUserVH as _CreateUser on $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser on $projection.LastChangedBy = _UpdateUser.UserID
{
  key uuid                  as UUID,
      plant                 as Plant,
      customer              as Customer,
      receiver              as Receiver,
      receiver_type         as ReceiverType,
      mail_address          as MailAddress,
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

      _Plant,
      _Customer,
      _EmailCopy,
      _CreateUser,
      _UpdateUser
}
