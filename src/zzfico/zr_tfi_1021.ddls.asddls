@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TFI_1021
  as select from ZTFI_1021
{
  key yearmonth as Yearmonth,
  key companycode as Companycode,
  key plant as Plant,
  key product as Product,
  key soldtoparty as Soldtoparty,
  key orderid as Orderid,
  key orderitem as Orderitem,
  companycodetext as Companycodetext,
  planttext as Planttext,
  productdescription as Productdescription,
  businesspartnername as Businesspartnername,
  @Semantics.quantity.unitOfMeasure: 'Salesperfactualquantityunit'
  salesperformanceactualquantity as Salesperformanceactualquantity,
  salesperfactualquantityunit as Salesperfactualquantityunit,
  @Semantics.amount.currencyCode: 'Displaycurrency'
  salesperfactlamtindspcurrency as Salesperfactlamtindspcurrency,
  displaycurrency as Displaycurrency,
  calendaryear as Calendaryear,
  calendarmonth as Calendarmonth
  
}
