@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1022
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TFI_1022
{
  key Yearmonth,
  key Companycode,
  key Plant,
  key Product,
  key Soldtoparty,
  key Accountingdocument,
  key Ledgergllineitem,
  Companycodetext,
  Planttext,
  Productdescription,
  Businesspartnername,
  Profitcenter,
  Profitcenterlongname,
  Zamount1,
  Zamount2,
  @Semantics.currencyCode: true
  Displaycurrency,
  Calendaryear,
  Calendarmonth,
  Accountingdocumenttype
  
}
