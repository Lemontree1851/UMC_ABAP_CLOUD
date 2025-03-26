@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Requirement Report'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZC_InventoryRequirement_fixed
  as select from ZR_InventoryRequirement_fixed

  association [0..1] to I_BusinessPartner           as _BusinessPartner      on  $projection.Supplier = _BusinessPartner.BusinessPartner
  association [0..1] to I_PurchasingInfoRecordApi01 as _PurchasingInfoRecord on  $projection.Supplier            = _PurchasingInfoRecord.Supplier
                                                                             and $projection.Product             = _PurchasingInfoRecord.Material
                                                                             and _PurchasingInfoRecord.IsDeleted = ''
{
  key Plant,
  key Product,
      PurchasingGroup,
      MRPController,
      ABCIndicator,
      ProcurementType,
      GoodsReceiptDuration,
      Supplier,

      StandardPrice,
      SupplierPrice,
      EOLGroup,
      IsMainProduct,

      _PurchasingInfoRecord.PurchasingInfoRecord,

      // ADD BEGIN BY XINLEI XU 2025/03/25
      ExternalProductGroup,
      ProductGroup,
      ProductType,
      IndustryStandardName,
      ProductManufacturerNumber,
      ManufacturerNumber,
      ProductDescription,
      MRPControllerName,
      LotSizingProcedure,
      @Semantics.amount.currencyCode: 'Currency'
      ProductStandardPrice,
      Currency,
      PriceUnitQty,
      _BusinessPartner.OrganizationBPName1,
      _PurchasingInfoRecord.SupplierCertOriginCountry,
      _PurchasingInfoRecord.SupplierMaterialNumber,
      // ADD END BY XINLEI XU 2025/03/25

      /* Associations */
      _Product,
      _ProductDescription,
      _MRPController,
      _ProductPlantSupplyPlanning,
      _ProductValuation,
      _MPPurchasingSourceItem,
      _BusinessPartner,
      _PurchasingInfoRecord
}
