@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '日別在庫推移'
@Metadata.allowExtensions: true
define root view entity ZR_DAYSTOCKTRANS
  as select from ztfi_1015
{
  key excudate                       as ExcuDate,
  key companycode                    as CompanyCode,
  key plant                          as Plant,
  key businesspartner                as BusinessPartner,
      businesspartnername            as BusinessPartnerName,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      finishedgoods                  as FinishedGoods,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      semifinishedgoods              as SemiFinishedGoods,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      material                       as Material,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      movingaverageprice             as MovingAveragePrice,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      standardprice                  as StandardPrice,
      priceunitqty                   as Priceunitqty,
      valuationquantity              as ValuationQuantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      total                          as Total,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      salesperfactlamtindspcurrency  as SalesPerfActlAmtInDspCurrency,
      salesperformanceactualquantity as SalesPerformanceActualQuantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      saleactual                     as SaleActual,
      necessraryquantity             as NecessraryQuantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      salesprice                     as SalesPrice,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      saleforcast                    as Saleforcast,
      displaycurrency                as DisplayCurrency,

      @Semantics.user.createdBy: true
      created_by                     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                     as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by                as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at                as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at          as LocalLastChangedAt

}
