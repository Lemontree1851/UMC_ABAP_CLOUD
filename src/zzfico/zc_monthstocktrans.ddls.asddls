@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '月別在庫推移'
define root view entity ZC_MONTHSTOCKTRANS
  provider contract transactional_query
  as projection on ZR_MONTHSTOCKTRANS
{
  key Yearmonth,
  key Companycode,
  key Plant,
  key Material,
  key Businesspartner,
      Type,
      Businesspartnername,
      Materialtype,
      Materialtypename,
      Movingaverageprice,
      Standardprice,
      Priceunitqty,
      Valuationquantity,
      Total,
      @Semantics.currencyCode: true
      Displaycurrency,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt
}
