@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Item'
define root view entity ZC_PurchaseOrderItemAPI
  as select from I_PurchaseOrderItemAPI01

  association [1..*] to ZC_PurOrdScheduleLineAPI as _PurchaseOrderScheduleLineTP on  _PurchaseOrderScheduleLineTP.PurchaseOrder     = $projection.PurchaseOrder
                                                                                 and _PurchaseOrderScheduleLineTP.PurchaseOrderItem = $projection.PurchaseOrderItem
{
  key PurchaseOrder,
  key PurchaseOrderItem,
      PurchaseOrderItemUniqueID,
      PurchaseOrderCategory,
      DocumentCurrency,
      PurchasingDocumentDeletionCode,
      PurchasingDocumentItemOrigin,
      MaterialGroup,
      Material,
      MaterialType,
      SupplierMaterialNumber,
      SupplierSubrange,
      ManufacturerPartNmbr,
      Manufacturer,
      ManufacturerMaterial,
      PurchaseOrderItemText,
      ProductType,
      CompanyCode,
      Plant,
      ManualDeliveryAddressID,
      ReferenceDeliveryAddressID,
      Customer,
      Subcontractor,
      SupplierIsSubcontractor,
      CrossPlantConfigurableProduct,
      ArticleCategory,
      PlndOrderReplnmtElmntType,
      ProductPurchasePointsQtyUnit,
      ProductPurchasePointsQty,
      StorageLocation,
      PurchaseOrderQuantityUnit,
      OrderItemQtyToBaseQtyNmrtr,
      OrderItemQtyToBaseQtyDnmntr,
      NetPriceQuantity,
      IsCompletelyDelivered,
      IsFinallyInvoiced,
      GoodsReceiptIsExpected,
      InvoiceIsExpected,
      InvoiceIsGoodsReceiptBased,
      PurchaseContractItem,
      PurchaseContract,
      PurchaseRequisition,
      RequirementTracking,
      PurchaseRequisitionItem,
      EvaldRcptSettlmtIsAllowed,
      UnlimitedOverdeliveryIsAllowed,
      OverdelivTolrtdLmtRatioInPct,
      UnderdelivTolrtdLmtRatioInPct,
      RequisitionerName,
      PlannedDeliveryDurationInDays,
      GoodsReceiptDurationInDays,
      PartialDeliveryIsAllowed,
      ConsumptionPosting,
      ServicePerformer,
      BaseUnit,
      PurchaseOrderItemCategory,
      ProfitCenter,
      OrderPriceUnit,
      ItemVolumeUnit,
      ItemWeightUnit,
      MultipleAcctAssgmtDistribution,
      PartialInvoiceDistribution,
      PricingDateControl,
      IsStatisticalItem,
      PurchasingParentItem,
      GoodsReceiptLatestCreationDate,
      IsReturnsItem,
      PurchasingOrderReason,
      IncotermsClassification,
      IncotermsTransferLocation,
      IncotermsLocation1,
      IncotermsLocation2,
      PriorSupplier,
      InternationalArticleNumber,
      IntrastatServiceCode,
      CommodityCode,
      MaterialFreightGroup,
      DiscountInKindEligibility,
      PurgItemIsBlockedForDelivery,
      SupplierConfirmationControlKey,
      PriceIsToBePrinted,
      AccountAssignmentCategory,
      PurchasingInfoRecord,
      NetAmount,
      GrossAmount,
      EffectiveAmount,
      Subtotal1Amount,
      Subtotal2Amount,
      Subtotal3Amount,
      Subtotal4Amount,
      Subtotal5Amount,
      Subtotal6Amount,
      OrderQuantity,
      NetPriceAmount,
      ItemVolume,
      ItemGrossWeight,
      ItemNetWeight,
      OrderPriceUnitToOrderUnitNmrtr,
      OrdPriceUnitToOrderUnitDnmntr,
      GoodsReceiptIsNonValuated,
      IsToBeAcceptedAtOrigin,
      TaxCode,
      TaxJurisdiction,
      ShippingInstruction,
      ShippingType,
      NonDeductibleInputTaxAmount,
      StockType,
      ValuationType,
      ValuationCategory,
      ItemIsRejectedBySupplier,
      PurgDocPriceDate,
      PurgDocReleaseOrderQuantity,
      //      EarmarkedFunds,
      EarmarkedFundsDocument     as EarmarkedFunds,
      EarmarkedFundsDocument,
      //      EarmarkedFundsItem,
      EarmarkedFundsDocumentItem as EarmarkedFundsItem,
      EarmarkedFundsDocumentItem,
      PartnerReportedBusinessArea,
      InventorySpecialStockType,
      DeliveryDocumentType,
      IssuingStorageLocation,
      AllocationTable,
      AllocationTableItem,
      RetailPromotion,
      DownPaymentType,
      DownPaymentPercentageOfTotAmt,
      DownPaymentAmount,
      DownPaymentDueDate,
      ExpectedOverallLimitAmount,
      OverallLimitAmount,
      PurContractForOverallLimit,
      PurContractItemForOverallLimit,
      RequirementSegment,
      PurgProdCmplncDngrsGoodsStatus,
      PurgProdCmplncSupplierStatus,
      PurgProductMarketabilityStatus,
      PurgSafetyDataSheetStatus,
      SubcontrgCompIsRealTmeCnsmd,
      BR_MaterialOrigin,
      BR_MaterialUsage,
      BR_CFOPCategory,
      BR_NCM,
      BR_IsProducedInHouse,

      /* Associations */
      _PurchaseOrderScheduleLineTP
}
