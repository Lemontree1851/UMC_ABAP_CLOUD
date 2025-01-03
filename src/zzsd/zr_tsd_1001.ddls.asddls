@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD_1001'
define root view entity ZR_TSD_1001
  as select from ztsd_1001 as main
  //权限控制
    inner join   ZR_TBC1006           as _AssignPlant on _AssignPlant.Plant = main.plant
    inner join   ZC_BusinessUserEmail as _User        on  _User.Email  = _AssignPlant.Mail
                                                      and _User.UserID = $session.user
{
  @EndUserText.label:'得意先'
  key main.customer as Customer,
  @EndUserText.label:'請求先'
  key main.billing_to_party  as BillingToParty,
  key main.plant as Plant,
  @EndUserText.label:'部品倉庫'
  main.parts_storage_location as PartsStorageLocation,
  @EndUserText.label:'製品倉庫'
  main.finished_storage_location as FinishedStorageLocation,
  @EndUserText.label:'返品倉庫'
  main.return_storage_location as ReturnStorageLocation,
  @EndUserText.label:'修理品倉庫'
  main.repair_storage_location as RepairStorageLocation,
  @EndUserText.label:'VMI倉庫'
  main.vmi_storage_location as VmiStorageLocation,
  @Semantics.user.createdBy: true
  main.local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  main.local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  main.local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  main.local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  main.lat_cahanged_at as LatCahangedAt
  
}
