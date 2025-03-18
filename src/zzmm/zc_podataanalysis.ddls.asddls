@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'PO Data Analysis'
define view entity ZC_PODATAANALYSIS
  as select distinct from ZC_POMM01

  association [1..1] to I_Supplier              as _Supplier        on  ZC_POMM01.Supplier               = _Supplier.Supplier
  association [0..1] to I_MRPController         as _MRPController   on  ZC_POMM01.MRPResponsible         = _MRPController.MRPController
                                                                    and ZC_POMM01.Plant                  = _MRPController.Plant
  association [0..1] to I_SupplierPurchasingOrg as _SupplierPurOrg  on  ZC_POMM01.Supplier               = _SupplierPurOrg.Supplier
                                                                    and ZC_POMM01.PurchasingOrganization = _SupplierPurOrg.PurchasingOrganization
  association [0..1] to I_PurchasingGroup       as _PurchasingGroup on  ZC_POMM01.PurchasingGroup        = _PurchasingGroup.PurchasingGroup
                                                                    
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key SequentialNmbrOfSuplrConf,
      popoitem,
      DeliveryDate,
      SupplierConfirmationExtNumber,
      OrderQuantityUnit,
      MRPRelevantQuantity,
      ConfirmedQuantity,
      PurchaseOrderType,
      Supplier,
      PurchasingGroup,
      PurchaseOrderDate,
      DocumentCurrency,
      PurchasingOrganization,
      CreatedByUser,
      CorrespncInternalReference,
      CorrespncExternalReference,
      Material,
      PurchaseOrderItemText,
      ManufacturerMaterial,
      ManufacturerPartNmbr,
      Manufacturer,
      AccountAssignmentCategory,
      SupplierName2,
      PlannedDeliveryDurationInDays,
      GoodsReceiptDurationInDays,
      OrderQuantity,
      PurchaseOrderQuantityUnit,
      PurchaseRequisition,
      PurchaseRequisitionItem,
      RequirementTracking,
      RequisitionerName,
      InternationalArticleNumber,
      MaterialGroup,
      NetAmount,
      Plant,
      StorageLocation,
      IsCompletelyDelivered,
      TaxCode,
      PricingDateControl,
      // IncotermsClassification, DEL BY XINLEI XU 2025/03/18 I_PurgInfoRecdOrgPlntDataApi01-IncotermsClassification
      NetPriceQuantity,
      NetPriceAmount,
      PurchaseOrderItemCategory,
      SupplierMaterialNumber,
      MRPArea,
      MRPResponsible,
      SupplierCertOriginCountry,
      PurchasingInfoRecord,
      SupplierSubrange,
      StorageLocationName,
      ProductionMemoPageFormat,
      ProductionOrInspectionMemoTxt,
      YY1_BPCODE_PRD_PRD,
      BaseUnit,
      LotSizeRoundingQuantity,
      ScheduleLineDeliveryDate,
      RoughGoodsReceiptQty,

      _Supplier.SupplierName as SupplierName1,
      _MRPController.MRPControllerName,
      _SupplierPurOrg.SupplierRespSalesPersonName,
      _PurchasingGroup.PurchasingGroupName,

      _Supplier,
      _MRPController,
      _SupplierPurOrg,
      _PurchasingGroup
}
