@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Requirement Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_InventoryRequirement_fixed
  as select from I_ProductPlantBasic as _ProductPlantBasic

  association [0..1] to I_Product                    as _Product                    on  $projection.Product = _Product.Product
  association [0..1] to I_ProductDescription_2       as _ProductDescription         on  $projection.Product          = _ProductDescription.Product
                                                                                    and _ProductDescription.Language = $session.system_language
  association [0..1] to I_MRPControllerVH            as _MRPController              on  $projection.Plant         = _MRPController.Plant
                                                                                    and $projection.MRPController = _MRPController.MRPController
  association [0..1] to I_ProductPlantSupplyPlanning as _ProductPlantSupplyPlanning on  $projection.Product = _ProductPlantSupplyPlanning.Product
                                                                                    and $projection.Plant   = _ProductPlantSupplyPlanning.Plant
  association [0..1] to I_ProductValuationBasic      as _ProductValuation           on  $projection.Product             = _ProductValuation.Product
                                                                                    and $projection.Plant               = _ProductValuation.ValuationArea
                                                                                    and _ProductValuation.ValuationType = ''
  association [0..1] to I_MPPurchasingSourceItem     as _MPPurchasingSourceItem     on  $projection.Product                       = _MPPurchasingSourceItem.Material
                                                                                    and $projection.Plant                         = _MPPurchasingSourceItem.Plant
                                                                                    and _MPPurchasingSourceItem.SupplierIsFixed   = 'X'
                                                                                    and _MPPurchasingSourceItem.ValidityStartDate <= $session.system_date
                                                                                    and _MPPurchasingSourceItem.ValidityEndDate   >= $session.system_date
{
  key _ProductPlantBasic.Plant,
  key _ProductPlantBasic.Product,
      _ProductPlantBasic.PurchasingGroup,
      _ProductPlantBasic.MRPResponsible as MRPController,
      _ProductPlantBasic.ABCIndicator,
      _ProductPlantBasic.ProcurementType,
      _ProductPlantBasic.GoodsReceiptDuration,

      _MPPurchasingSourceItem.Supplier,

      cast( '' as abap.char(1000) )     as StandardPrice,
      cast( '' as abap.char(1000) )     as SupplierPrice,
      cast( '' as abap.char(1000) )     as EOLGroup,
      ''                                as IsMainProduct,

      // ADD BEGIN BY XINLEI XU 2025/03/25
      _Product.ExternalProductGroup,
      _Product.ProductGroup,
      _Product.ProductType,
      _Product.IndustryStandardName,
      _Product.ProductManufacturerNumber,
      _Product.ManufacturerNumber,
      _ProductDescription.ProductDescription,
      _MRPController.MRPControllerName,
      _ProductPlantSupplyPlanning.LotSizingProcedure,
      @Semantics.amount.currencyCode: 'Currency'
      _ProductValuation.StandardPrice   as ProductStandardPrice,
      _ProductValuation.Currency,
      _ProductValuation.PriceUnitQty,
      // ADD END BY XINLEI XU 2025/03/25

      _Product,
      _ProductDescription,
      _MRPController,
      _ProductPlantSupplyPlanning,
      _ProductValuation,
      _MPPurchasingSourceItem
}
