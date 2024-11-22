@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '加工費'
@Metadata.allowExtensions: true
define root view entity ZR_PROCESSINGCOST
  as select from ztbi_1002
{
  key zyear,
  key zmonth,
  key yearmonth,
  key companycode,
  key plant,
  key product,
  customer,
  customername,
  companycodetext,
  planttext,
  productdescription,
  @Semantics.amount.currencyCode : 'currency'
  estimatedprice_smt,
  @Semantics.amount.currencyCode : 'currency'
  estimatedprice_ai,
  @Semantics.amount.currencyCode : 'currency'
  estimatedprice_fat,
  @Semantics.amount.currencyCode : 'currency'
  actualprice_smt,
  @Semantics.amount.currencyCode : 'currency'
  actualprice_ai,
  @Semantics.amount.currencyCode : 'currency'
  actualprice_fat,
  currency,
  billingquantity,
  billingquantityunit,
  profitcenter,
  profitcentername,
  yieldqty
}
