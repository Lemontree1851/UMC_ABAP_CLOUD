@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TFI_1010000
  as select from ZTFI_1010
{
  key companycode as Companycode,
  key fiscalyear as Fiscalyear,
  key period as Period,
  key customer as Customer,
  key supplier as Supplier,
  key product as Product,
  key profitcenter as Profitcenter,
  key purchasinggroup as Purchasinggroup,
  key zeile as Zeile,
  customername as Customername,
  suppliername as Suppliername,
  profitcentername as Profitcentername,
  productdescription as Productdescription,
  upperproduct01 as Upperproduct01,
  valuationclass01 as Valuationclass01,
  @Semantics.amount.currencyCode: 'Currency'
  cost01 as Cost01,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity01 as Valuationquantity01,
  upperproduct02 as Upperproduct02,
  valuationclass02 as Valuationclass02,
  @Semantics.amount.currencyCode: 'Currency'
  cost02 as Cost02,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity02 as Valuationquantity02,
  upperproduct03 as Upperproduct03,
  valuationclass03 as Valuationclass03,
  @Semantics.amount.currencyCode: 'Currency'
  cost03 as Cost03,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity03 as Valuationquantity03,
  upperproduct04 as Upperproduct04,
  valuationclass04 as Valuationclass04,
  @Semantics.amount.currencyCode: 'Currency'
  cost04 as Cost04,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity04 as Valuationquantity04,
  upperproduct05 as Upperproduct05,
  valuationclass05 as Valuationclass05,
  @Semantics.amount.currencyCode: 'Currency'
  cost05 as Cost05,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity05 as Valuationquantity05,
  upperproduct06 as Upperproduct06,
  valuationclass06 as Valuationclass06,
  @Semantics.amount.currencyCode: 'Currency'
  cost06 as Cost06,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity06 as Valuationquantity06,
  upperproduct07 as Upperproduct07,
  valuationclass07 as Valuationclass07,
  @Semantics.amount.currencyCode: 'Currency'
  cost07 as Cost07,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity07 as Valuationquantity07,
  upperproduct08 as Upperproduct08,
  valuationclass08 as Valuationclass08,
  @Semantics.amount.currencyCode: 'Currency'
  cost08 as Cost08,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity08 as Valuationquantity08,
  upperproduct09 as Upperproduct09,
  valuationclass09 as Valuationclass09,
  @Semantics.amount.currencyCode: 'Currency'
  cost09 as Cost09,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity09 as Valuationquantity09,
  upperproduct10 as Upperproduct10,
  valuationclass10 as Valuationclass10,
  @Semantics.amount.currencyCode: 'Currency'
  cost10 as Cost10,
  @Semantics.quantity.unitOfMeasure: 'Unitofmeasure'
  valuationquantity10 as Valuationquantity10,
  @Semantics.amount.currencyCode: 'Currency'
  materialcost2000 as Materialcost2000,
  @Semantics.amount.currencyCode: 'Currency'
  materialcost3000 as Materialcost3000,
  @Semantics.amount.currencyCode: 'Currency'
  purgrpamount as Purgrpamount,
  @Semantics.amount.currencyCode: 'Currency'
  chargeableamount as Chargeableamount,
  @Semantics.amount.currencyCode: 'Currency'
  previousstockamount as Previousstockamount,
  @Semantics.amount.currencyCode: 'Currency'
  currentstockamount as Currentstockamount,
  @Semantics.amount.currencyCode: 'Currency'
  customerrevenue as Customerrevenue,
  @Semantics.amount.currencyCode: 'Currency'
  revenue as Revenue,
  unitofmeasure as Unitofmeasure,
  currency as Currency
  
}
