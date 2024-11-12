@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1020
  provider contract transactional_query
  as projection on ZR_TFI_1020
{
  key Yearmonth,
  key Companycode,
  key Plant,
  key Product,
  key Businesspartner,
  key Profitcenter,
  key Costcenter,
  key Activitytype,
  key Orderid,
  Companycodetext,
  Planttext,
  Productdescription,
  Mfgorderconfirmedyieldqty,
  @Semantics.unitOfMeasure: true
  Productionunit,
  Businesspartnername,
  Profitcenterlongname,
  Costcenterdescription,
  Costctractivitytypename,
  Department,
  Productionsupervisor,
  Planqtyincostsourceunit,
  Actualqtyincostsourceunit,
  @Semantics.unitOfMeasure: true
  Unitofmeasure,
  Plancostrate,
  Actualcostrate,
  @Semantics.currencyCode: true
  Currency1,
  @Semantics.currencyCode: true
  Currency2,
  CostRateScaleFactor1,
  CostRateScaleFactor2,
  Totalactualcost,
  Actualcost1pc,
  Calendaryear,
  Calendarmonth,
  
  Producedproduct
  
}
