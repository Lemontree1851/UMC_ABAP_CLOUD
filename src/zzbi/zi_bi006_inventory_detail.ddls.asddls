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
    left outer join I_CompanyCode               as _CompanyCode       on _CompanyCode.CompanyCode = ztfi_1019.companycode
    left outer join I_Plant                     as _Plant             on _Plant.Plant = ztfi_1019.plant
    left outer join I_Product                   as _Product           on _Product.Product = ztfi_1019.product
    left outer join I_ProductText               as _ProductText       on  _ProductText.Product  = ztfi_1019.product
                                                                      and _ProductText.Language = $session.system_language
    left outer join I_ProductTypeText_2         as _ProductTypeText   on  _ProductTypeText.ProductType = _Product.ProductType
                                                                      and _ProductTypeText.Language    = $session.system_language
    left outer join ZI_BI006_PRODUCTPLANT_BASIC as _ProductPlantBasic on  _ProductPlantBasic.Plant   = ztfi_1019.plant
                                                                      and _ProductPlantBasic.Product = ztfi_1019.product
{
  key ztfi_1019.ledger                                                        ,
  key ztfi_1019.companycode                                                   ,
  key ztfi_1019.plant                                                         ,
  key ztfi_1019.fiscalyear                                                    ,
  key ztfi_1019.fiscalperiod                                                  ,
  key ztfi_1019.product                                                       ,
  key ztfi_1019.age                                                           ,

      concat( ztfi_1019.fiscalyear, substring(ztfi_1019.fiscalperiod, 2, 2) ) as FiscalYearMonth,
      substring(ztfi_1019.fiscalperiod, 2, 2)                                 as Period,

      ztfi_1019.qty                                                           as Qty,


      _CompanyCode.Currency                                                   as Currency,

      _CompanyCode.CompanyCodeName                                            as CompanyCodeName,
      _Plant.PlantName                                                        as PlantName,
      _ProductText.ProductName                                                as ProductName,
      _Product.ProductType                                                    as ProductType,
      _ProductTypeText.ProductTypeName                                        as ProductTypeName,

      _ProductPlantBasic.ProfitCenter                                         as ProfitCenter,
      _ProductPlantBasic.ProfitCenterName                                     as ProfitCenterName,
      _ProductPlantBasic._BusinessPartner.BusinessPartner                     as Customer,
      _ProductPlantBasic._BusinessPartner.BusinessPartnerName                 as CustomerName,

      @Semantics.amount.currencyCode: 'Currency' 
      //@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BI006_ACTUAL_PRICE' 
      cast('0.00' as dmbtr ) as ActualPrice,

      @Semantics.amount.currencyCode: 'Currency' 
      //@ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_BI006_ACTUAL_PRICE' 
      cast('0.00' as dmbtr) as InventoryAmount,

      _Plant.ValuationArea
}
