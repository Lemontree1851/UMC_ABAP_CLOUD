@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '部品費'
define root view entity ZC_COMPONENTCOST
  provider contract transactional_query
  as projection on ZR_COMPONENTCOST
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
    estimatedprice,
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
//    _association_name // Make association public
}
