@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TFI_1011000
  provider contract transactional_query
  as projection on ZR_TFI_1011000
{
  key Companycode,
  key Fiscalyear,
  key Period,
  key Customer,
  key Supplier,
  key Profitcenter,
  key Purchasinggroup,
  Customername,
  Suppliername,
  Profitcentername,
  Purgrpamount,
  Chargeableamount,
  Chargeablerate,
  Previousstocktotal,
  Currentstockpaid,
  Currentstocksemi,
  Currentstockfin,
  Currentstocktotal,
  Stockchangeamount,
  Paidmaterialcost,
  Customerrevenue,
  Revenue,
  Revenuerate,
  YearMonth,
  @Semantics.currencyCode: true
  Currency,
  Gjahr1,
  Belnr1,
  Gjahr2,
  Belnr2,
  Gjahr3,
  Belnr3,
  Gjahr4,
  Belnr4,
  Status,
  Message
  
}
