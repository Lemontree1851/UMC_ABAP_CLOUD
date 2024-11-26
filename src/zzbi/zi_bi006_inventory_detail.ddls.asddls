@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BI006 Long Term Inventory Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZI_BI006_INVENTORY_DETAIL
  as select from    ztfi_1019
    left outer join I_CompanyCode       as _CompanyCode     on _CompanyCode.CompanyCode = ztfi_1019.companycode
    left outer join I_Plant             as _Plant           on _Plant.Plant = ztfi_1019.plant
    left outer join I_Product           as _Product         on _Product.Product = ztfi_1019.product
    left outer join I_ProductText       as _ProductText     on  _ProductText.Product  = ztfi_1019.product
                                                            and _ProductText.Language = $session.system_language
    left outer join I_ProductTypeText_2 as _ProductTypeText on  _ProductTypeText.ProductType = _Product.ProductType
                                                            and _ProductTypeText.Language    = $session.system_language
{
  key ztfi_1019.ledger                                                        as Ledger,
  key ztfi_1019.companycode                                                   as CompanyCode,
  key ztfi_1019.plant                                                         as Plant,
  key ztfi_1019.fiscalyear                                                    as FiscalYear,
  key ztfi_1019.fiscalperiod                                                  as FiscalPeriod,
  key ztfi_1019.product                                                       as Product,
  key ztfi_1019.age                                                           as Age,

      concat( ztfi_1019.fiscalyear, substring(ztfi_1019.fiscalperiod, 2, 2) ) as FiscalYearMonth,
      substring(ztfi_1019.fiscalperiod, 2, 2)                                 as Period,

      ztfi_1019.qty                                                           as Qty,
      cast('' as prctr)                                                       as ProfitCenter,
      cast('' as abap.char( 20 ))                                             as ProfitCenterName,

      cast('' as kunnr)                                                       as Customer,
      cast('' as abap.char(80))                                               as CustomerName,

      @Semantics.amount.currencyCode: 'Currency'
      cast( '0.00' as dmbtr )                                                 as ActualPrice,

      @Semantics.amount.currencyCode: 'Currency'
      cast('0.00' as dmbtr )                                                  as InventoryAmount,
      _CompanyCode.Currency                                                   as Currency,

      _CompanyCode.CompanyCodeName                                            as CompanyCodeName,
      _Plant.PlantName                                                        as PlantName,
      _ProductText.ProductName                                                as ProductName,
      _Product.ProductType                                                    as ProductType,
      _ProductTypeText.ProductTypeName                                        as ProductTypeName
}
