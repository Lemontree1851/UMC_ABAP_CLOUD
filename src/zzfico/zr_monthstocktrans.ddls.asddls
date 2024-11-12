@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '月別在庫推移'
@Metadata.allowExtensions: true
define root view entity ZR_MONTHSTOCKTRANS
  as select from ztfi_1016
{
  key yearmonth             as Yearmonth,
  key companycode           as Companycode,
  key plant                 as Plant,
  key material              as Material,
  key businesspartner       as Businesspartner,
      type                  as Type,
      businesspartnername   as Businesspartnername,
      materialtype          as Materialtype,
      materialtypename      as Materialtypename,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      movingaverageprice    as Movingaverageprice,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      standardprice         as Standardprice,
      valuationquantity     as Valuationquantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      total                 as Total,
      displaycurrency       as Displaycurrency,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
