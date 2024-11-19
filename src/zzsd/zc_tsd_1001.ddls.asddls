@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TSD_1001'
@ObjectModel.semanticKey: [ 'Customer', 'BillingToParty', 'Plant' ]
define root view entity ZC_TSD_1001
  provider contract transactional_query
  as projection on ZR_TSD_1001
{
  key Customer,
  key BillingToParty,
  key Plant,
  PartsStorageLocation,
  FinishedStorageLocation,
  ReturnStorageLocation,
  RepairStorageLocation,
  VmiStorageLocation,
  LocalLastChangedAt
  
}
