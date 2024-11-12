@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1004000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TFI_1004000
{
  key Plant,
  key Material,
  Age,
  Qty,
  Calendaryear,
  Calendarmonth,
  CreatedBy,
  CreatedAt,
  LastChangedBy,
  LastChangedAt,
  LocalLastChangedAt
  
}
