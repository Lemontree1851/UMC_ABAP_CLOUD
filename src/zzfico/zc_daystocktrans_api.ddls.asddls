@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '日別在庫推移 API'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_DAYSTOCKTRANS_API
  as select from ztfi_1015
{
  key ztfi_1015.excudate                       as ExcuDate,
  key ztfi_1015.companycode                    as CompanyCode,
  key ztfi_1015.plant                          as Plant,
  key ztfi_1015.businesspartner                as BusinessPartner,
      ztfi_1015.businesspartnername            as BusinessPartnerName,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      ztfi_1015.finishedgoods                  as FinishedGoods,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      ztfi_1015.semifinishedgoods              as SemiFinishedGoods,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      ztfi_1015.material                       as Material,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      ztfi_1015.movingaverageprice             as MovingAveragePrice,
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      ztfi_1015.standardprice                  as StandardPrice,
      ztfi_1015.priceunitqty                   as Priceunitqty,
      ztfi_1015.valuationquantity              as ValuationQuantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      ztfi_1015.total                          as Total,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      ztfi_1015.salesperfactlamtindspcurrency  as SalesPerfActlAmtInDspCurrency,
      ztfi_1015.salesperformanceactualquantity as SalesPerformanceActualQuantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      ztfi_1015.saleactual                     as SaleActual,
      ztfi_1015.necessraryquantity             as NecessraryQuantity,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      ztfi_1015.salesprice                     as SalesPrice,
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      ztfi_1015.saleforcast                    as Saleforcast,
      ztfi_1015.displaycurrency                as DisplayCurrency
}
