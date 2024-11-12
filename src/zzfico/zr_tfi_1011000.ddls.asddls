@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TFI_1011000
  as select from ZTFI_1011
{
  key companycode as Companycode,
  key fiscalyear as Fiscalyear,
  key period as Period,
  key customer as Customer,
  key supplier as Supplier,
  key profitcenter as Profitcenter,
  key purchasinggroup as Purchasinggroup,
  customername as Customername,
  suppliername as Suppliername,
  profitcentername as Profitcentername,
  @Semantics.amount.currencyCode: 'Currency'
  purgrpamount as Purgrpamount,
  @Semantics.amount.currencyCode: 'Currency'
  chargeableamount as Chargeableamount,
  chargeablerate as Chargeablerate,
  @Semantics.amount.currencyCode: 'Currency'
  previousstocktotal as Previousstocktotal,
  @Semantics.amount.currencyCode: 'Currency'
  currentstockpaid as Currentstockpaid,
  @Semantics.amount.currencyCode: 'Currency'
  currentstocksemi as Currentstocksemi,
  @Semantics.amount.currencyCode: 'Currency'
  currentstockfin as Currentstockfin,
  @Semantics.amount.currencyCode: 'Currency'
  currentstocktotal as Currentstocktotal,
  @Semantics.amount.currencyCode: 'Currency'
  stockchangeamount as Stockchangeamount,
  @Semantics.amount.currencyCode: 'Currency'
  paidmaterialcost as Paidmaterialcost,
  @Semantics.amount.currencyCode: 'Currency'
  customerrevenue as Customerrevenue,
  @Semantics.amount.currencyCode: 'Currency'
  revenue as Revenue,
  revenuerate as Revenuerate,
  currency as Currency,
  gjahr1 as Gjahr1,
  belnr1 as Belnr1,
  gjahr2 as Gjahr2,
  belnr2 as Belnr2,
  gjahr3 as Gjahr3,
  belnr3 as Belnr3,
  gjahr4 as Gjahr4,
  belnr4 as Belnr4,
  status as Status,
  message as Message
  
}
