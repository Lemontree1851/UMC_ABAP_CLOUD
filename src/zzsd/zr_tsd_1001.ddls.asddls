@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '##GENERATED ZTSD_1001'
define root view entity ZR_TSD_1001
  as select from ztsd_1001
{
  @EndUserText.label:'Sold-to Party'
  key customer as Customer,
  key billing_to_party as BillingToParty,
  key plant as Plant,
  @EndUserText.label:'Issue Sloc.'
  issue_storage_location as IssueStorageLocation,
  @EndUserText.label:'Finished Sloc.'
  finished_storage_location as FinishedStorageLocation,
  @EndUserText.label:'Return Sloc.'
  return_storage_location as ReturnStorageLocation,
  @EndUserText.label:'Repair Sloc.'
  repair_storage_location as RepairStorageLocation,
  @EndUserText.label:'Vim Sloc.'
  vim_storage_location as VimStorageLocation,
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
