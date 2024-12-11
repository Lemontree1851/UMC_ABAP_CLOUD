@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Permission Access User <-> Plant Data'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_TBC1006
  as select from ztbc_1006 as _AssignPlant
    inner join   I_Plant   as _Plant on _Plant.Plant = _AssignPlant.plant

  association to parent ZR_TBC1004 as _User on $projection.UserId = _User.UserId
{
  key _AssignPlant.uuid                  as Uuid,
  key _AssignPlant.user_id               as UserId,
      _AssignPlant.plant                 as Plant,
      @Semantics.user.createdBy: true
      _AssignPlant.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      _AssignPlant.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      _AssignPlant.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      _AssignPlant.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      _AssignPlant.local_last_changed_at as LocalLastChangedAt,

      _Plant.PlantName,

      _User
}
