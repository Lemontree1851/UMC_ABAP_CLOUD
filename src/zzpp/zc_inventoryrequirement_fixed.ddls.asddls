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
