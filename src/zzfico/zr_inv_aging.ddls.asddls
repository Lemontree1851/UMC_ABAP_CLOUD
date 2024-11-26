@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '長期滞在＆低価法レポート'
define root view entity ZR_INV_AGING
  as select from ztfi_1019
    inner join   I_Product as _Product on _Product.Product = ztfi_1019.product
  association [1..1] to I_CompanyCode        as _CompanyCode       on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_ProductDescription as _ProductName       on  $projection.Product   = _ProductName.Product
                                                                   and _ProductName.Language = 'J'//$session.system_language
  association [0..1] to I_ProductTypeText_2  as _ProductTypeName   on  $projection.ProductType   = _ProductTypeName.ProductType
                                                                   and _ProductTypeName.Language = $session.system_language
  association [0..1] to I_ProductPlantBasic  as _ProductPlantBasic on  $projection.Product = _ProductPlantBasic.Product
                                                                   and $projection.Plant   = _ProductPlantBasic.Plant

{
  key ztfi_1019.ledger                                       as Ledger,
  key ztfi_1019.companycode                                  as CompanyCode,
  key ztfi_1019.plant                                        as Plant,
  key ztfi_1019.fiscalyear                                   as FiscalYear,
  key ztfi_1019.fiscalperiod                                 as FiscalPeriod,
  key ztfi_1019.product                                      as Product,
  key ztfi_1019.age                                          as Age,
      ztfi_1019.qty                                          as Qty,
      concat( ztfi_1019.fiscalyear, ztfi_1019.fiscalperiod ) as FiscalYearPeriod,
      _CompanyCode.Currency                                  as Currency,
      _ProductName.ProductDescription                        as ProductDescription,
      _Product.ProductType                                   as ProductType,
      _ProductTypeName.ProductTypeName                       as ProductTypeName,
      _ProductPlantBasic.ProfitCenter                        as ProfitCenter,
      _ProductPlantBasic.MRPResponsible                      as MRPResponsible
}
