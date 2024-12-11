@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '部品費'
@Metadata.allowExtensions: true
define root view entity ZR_COMPONENTCOST
  as select from ztbi_1001
{
  key zyear,
  key zmonth,
  key yearmonth,
  key companycode,
  key plant,
  key product,
  key material,
  companycodetext,
  planttext,
  productdescription,
  materialdescription,
  quantity,
  customer,
  customername,
  @Semantics.amount.currencyCode : 'currency'
  estimatedprice,
  @Semantics.amount.currencyCode : 'currency'
  finalprice,
  finalpostingdate,
  finalsupplier,
  fixedsupplier,
  standardprice,
  movingaverageprice,
  currency,
  billingquantity,
  billingquantityunit,
  profitcenter,
  profitcentername
}
