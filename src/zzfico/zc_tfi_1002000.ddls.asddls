@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1002000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TFI_1002000
{
  key Chartofaccounts,
  key Glaccount,
  Financialstatement,
  Financialstatementitemtext,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
