@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TFI_1020
  as select from ztfi_1020
{
  key yearmonth as Yearmonth,
  key companycode as Companycode,
  key plant as Plant,
  key product as Product,
  key businesspartner as Businesspartner,
  key profitcenter as Profitcenter,
  key costcenter as Costcenter,
  key activitytype as Activitytype,
  key orderid as Orderid,
  companycodetext as Companycodetext,
  planttext as Planttext,
  productdescription as Productdescription,
  @Semantics.quantity.unitOfMeasure: 'Productionunit'
  mfgorderconfirmedyieldqty as Mfgorderconfirmedyieldqty,
  productionunit as Productionunit,
  businesspartnername as Businesspartnername,
  profitcenterlongname as Profitcenterlongname,
  costcenterdescription as Costcenterdescription,
  costctractivitytypename as Costctractivitytypename,
  department as Department,
  productionsupervisor as Productionsupervisor,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  planqtyincostsourceunit as Planqtyincostsourceunit,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  actualqtyincostsourceunit as Actualqtyincostsourceunit,
  unitofmeasure as Unitofmeasure,
  @Semantics.amount.currencyCode: 'Currency1'
  plancostrate as Plancostrate,
  @Semantics.amount.currencyCode: 'Currency2'
  actualcostrate as Actualcostrate,
  currency1 as Currency1,
  currency2 as Currency2,
  costratescalefactor1      as CostRateScaleFactor1,
  costratescalefactor2      as CostRateScaleFactor2,
  @Semantics.amount.currencyCode: 'Currency2'
  totalactualcost as Totalactualcost,
  @Semantics.amount.currencyCode: 'Currency2'
  actualcost1pc as Actualcost1pc,
  calendaryear as Calendaryear,
  calendarmonth as Calendarmonth,
  
  producedproduct as Producedproduct
  
}
