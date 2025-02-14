@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User - Access Btn'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_USER_ACCESSBUTTON
  as select distinct from ZR_TBC1007 as _User
    inner join            ZR_TBC1016 as _AccessBtn on _AccessBtn.RoleId = _User.RoleId
{
  key _User.Mail,
  key _AccessBtn.AccessId,
      _AccessBtn.AccessName
}
