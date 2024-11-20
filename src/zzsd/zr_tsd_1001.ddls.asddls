@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD_1001'
define root view entity ZR_TSD_1001
  as select from ztsd_1001
{
  @EndUserText.label:'得意先'
  key customer as Customer,
  @EndUserText.label:'請求先'
  key billing_to_party  as BillingToParty,
  key plant as Plant,
  @EndUserText.label:'部品倉庫'
  parts_storage_location as PartsStorageLocation,
  @EndUserText.label:'製品倉庫'
  finished_storage_location as FinishedStorageLocation,
  @EndUserText.label:'返品倉庫'
  return_storage_location as ReturnStorageLocation,
  @EndUserText.label:'修理品倉庫'
  repair_storage_location as RepairStorageLocation,
  @EndUserText.label:'VMI倉庫'
  vmi_storage_location as VmiStorageLocation,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  lat_cahanged_at as LatCahangedAt
  
}
