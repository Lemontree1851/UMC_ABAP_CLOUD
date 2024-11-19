@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '加工費'
define root view entity ZC_PROCESSINGCOST
  provider contract transactional_query
  as projection on ZR_PROCESSINGCOST
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
    estimatedprice_smt,
    estimatedprice_ai,
    estimatedprice_fat,
    actualprice_smt,
    actualprice_ai,
    actualprice_fat,
    currency,
    billingquantity,
    billingquantityunit
//    _association_name // Make association public
}
