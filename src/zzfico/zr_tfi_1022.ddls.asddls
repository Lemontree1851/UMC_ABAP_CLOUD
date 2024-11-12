@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TFI_1022
  as select from ZTFI_1022
{
  key yearmonth as Yearmonth,
  key companycode as Companycode,
  key plant as Plant,
  key product as Product,
  key soldtoparty as Soldtoparty,
  key accountingdocument as Accountingdocument,
  key ledgergllineitem as Ledgergllineitem,
  companycodetext as Companycodetext,
  planttext as Planttext,
  productdescription as Productdescription,
  businesspartnername as Businesspartnername,
  profitcenter as Profitcenter,
  profitcenterlongname as Profitcenterlongname,
  @Semantics.amount.currencyCode: 'Displaycurrency'
  zamount1 as Zamount1,
  @Semantics.amount.currencyCode: 'Displaycurrency'
  zamount2 as Zamount2,
  displaycurrency as Displaycurrency,
  calendaryear as Calendaryear,
  calendarmonth as Calendarmonth,
  accountingdocumenttype as Accountingdocumenttype
  
}
