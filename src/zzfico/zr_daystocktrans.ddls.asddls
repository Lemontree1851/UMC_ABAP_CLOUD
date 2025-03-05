@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '日別在庫推移'
@Metadata.allowExtensions: true
define root view entity ZR_DAYSTOCKTRANS
  as select from ztfi_1015
    inner join   ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = ztfi_1015.companycode
    inner join   ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignCompany.Mail
                                                        and _User.UserID = $session.user
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
      ztfi_1015.displaycurrency                as DisplayCurrency,

      @Semantics.user.createdBy: true
      ztfi_1015.created_by                     as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      ztfi_1015.created_at                     as CreatedAt,
      @Semantics.user.lastChangedBy: true
      ztfi_1015.last_changed_by                as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      ztfi_1015.last_changed_at                as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      ztfi_1015.local_last_changed_at          as LocalLastChangedAt
}
