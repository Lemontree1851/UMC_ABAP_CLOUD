@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1021
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_TFI_1021
{
  key Yearmonth,
  key Companycode,
  key Plant,
  key Product,
  key Soldtoparty,
  key Orderid,
  key Orderitem,
  Companycodetext,
  Planttext,
  Productdescription,
  Businesspartnername,
  Salesperformanceactualquantity,
  @Semantics.unitOfMeasure: true
  Salesperfactualquantityunit,
  Salesperfactlamtindspcurrency,
  @Semantics.currencyCode: true
  Displaycurrency,
  Calendaryear,
  Calendarmonth
  
}
