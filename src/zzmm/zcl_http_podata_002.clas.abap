class ZCL_HTTP_PODATA_002 definition
  public
  create public .

public section.

"　T024D、T001L、MARC、MKAL、AFKO、AFPO、PLPO、RESB、AFVC、ZPLAF
" 20241010 MBEW
    TYPES:
      BEGIN OF ty_item,
        tablename         TYPE c    LENGTH 10,
        prametername      TYPE c    LENGTH 10,
        value             type      string,
      END OF ty_item,

        tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,


      BEGIN OF ty_header,
        items TYPE tt_item,
      END OF ty_header,

      tt_header TYPE STANDARD TABLE OF ty_header WITH EMPTY KEY,

      "NO.1 購買発注
      BEGIN OF TY_EKKO,
        PurchaseOrder                             TYPE C LENGTH  10  ,
        PurchaseOrderType                         TYPE C LENGTH  4  ,
        PurchaseOrderSubtype                      TYPE C LENGTH  1  ,
        PurchasingDocumentOrigin                  TYPE C LENGTH  1  ,
        CreatedByUser                             TYPE C LENGTH  12  ,
        CreationDate                              TYPE C LENGTH  8  ,
        PurchaseOrderDate                         TYPE C LENGTH  8  ,
        Language                                  TYPE C LENGTH  1  ,
        CorrespncExternalReference                TYPE C LENGTH  12  ,
        CorrespncInternalReference                TYPE C LENGTH  12  ,
        PurchasingDocumentDeletionCode            TYPE C LENGTH  1  ,
        ReleaseIsNotCompleted                     TYPE C LENGTH  1  ,
        PurchasingCompletenessStatus              TYPE C LENGTH  1  ,
        PurchasingProcessingStatus                TYPE C LENGTH  2  ,
        PurgReleaseSequenceStatus                 TYPE C LENGTH  8  ,
        ReleaseCode                               TYPE C LENGTH  1  ,
        CompanyCode                               TYPE C LENGTH  4  ,
        PurchasingOrganization                    TYPE C LENGTH  4  ,
        PurchasingGroup                           TYPE C LENGTH  3  ,
        Supplier                                  TYPE C LENGTH  10  ,
        ManualSupplierAddressID                   TYPE C LENGTH  10  ,
        SupplierRespSalesPersonName               TYPE C LENGTH  30  ,
        SupplierPhoneNumber                       TYPE C LENGTH  16  ,
        SupplyingSupplier                         TYPE C LENGTH  10  ,
        SupplyingPlant                            TYPE C LENGTH  4  ,
        InvoicingParty                            TYPE C LENGTH  10  ,
        Customer                                  TYPE C LENGTH  10  ,
        SupplierQuotationExternalID               TYPE C LENGTH  10  ,
        PaymentTerms                              TYPE C LENGTH  4  ,
        CashDiscount1Days                         TYPE C LENGTH  3  ,
        CashDiscount2Days                         TYPE C LENGTH  3  ,
        NetPaymentDays                            TYPE C LENGTH  3  ,
        CashDiscount1Percent                      TYPE C LENGTH  5  ,
        CashDiscount2Percent                      TYPE C LENGTH  5  ,
        DownPaymentType                           TYPE C LENGTH  4  ,
        DownPaymentPercentageOfTotAmt             TYPE C LENGTH  5  ,
        DownPaymentAmount                         TYPE C LENGTH  11  ,
        DownPaymentDueDate                        TYPE C LENGTH  8  ,
        IncotermsClassification                   TYPE C LENGTH  3  ,
        IncotermsTransferLocation                 TYPE C LENGTH  28  ,
        IncotermsVersion                          TYPE C LENGTH  4  ,
        IncotermsLocation1                        TYPE C LENGTH  70  ,
        IncotermsLocation2                        TYPE C LENGTH  70  ,
        IsIntrastatReportingRelevant              TYPE C LENGTH  1  ,
        IsIntrastatReportingExcluded              TYPE C LENGTH  1  ,
        PricingDocument                           TYPE C LENGTH  10  ,
        PricingProcedure                          TYPE C LENGTH  6  ,
        DocumentCurrency                          TYPE C LENGTH  5  ,
        ValidityStartDate                         TYPE C LENGTH  8  ,
        ValidityEndDate                           TYPE C LENGTH  8  ,
        ExchangeRate                              TYPE C LENGTH  9  ,
        ExchangeRateIsFixed                       TYPE C LENGTH  1  ,
        LastChangeDateTime                        TYPE C LENGTH  21  ,
        TaxReturnCountry                          TYPE C LENGTH  3  ,
        VATRegistrationCountry                    TYPE C LENGTH  3  ,
        PurgReasonForDocCancellation              TYPE C LENGTH  2  ,
        PurgReleaseTimeTotalAmount                TYPE C LENGTH  15  ,
        PurgAggrgdProdCmplncSuplrSts              TYPE C LENGTH  1  ,
        PurgAggrgdProdMarketabilitySts            TYPE C LENGTH  1  ,
        PurgAggrgdSftyDataSheetStatus             TYPE C LENGTH  1  ,
        PurgProdCmplncTotDngrsGoodsSts            TYPE C LENGTH  1  ,

      END OF TY_EKKO,

      "NO.2 購買発注明細
      BEGIN OF TY_EKPO,
        PurchaseOrder                                type c length                   10    ,
        PurchaseOrderItem                            type c length                   5     ,
        PurchaseOrderItemUniqueID                    type c length                   15    ,
        PurchaseOrderCategory                        type c length                   1     ,
        DocumentCurrency                             type c length                   5     ,
        PurchasingDocumentDeletionCode               type c length                   1     ,
        PurchasingDocumentItemOrigin                 type c length                   1     ,
        MaterialGroup                                type c length                   9     ,
        Material                                     type c length                   40    ,
        MaterialType                                 type c length                   4     ,
        SupplierMaterialNumber                       type c length                   35    ,
        SupplierSubrange                             type c length                   6     ,
        ManufacturerPartNmbr                         type c length                   40    ,
        Manufacturer                                 type c length                   10    ,
        ManufacturerMaterial                         type c length                   40    ,
        PurchaseOrderItemText                        type c length                   40    ,
        ProductType                                  type c length                   2     ,
        CompanyCode                                  type c length                   4     ,
        Plant                                        type c length                   4     ,
        ManualDeliveryAddressID                      type c length                   10    ,
        ReferenceDeliveryAddressID                   type c length                   10    ,
        Customer                                     type c length                   10    ,
        Subcontractor                                type c length                   10    ,
        SupplierIsSubcontractor                      type c length                   1     ,
        CrossPlantConfigurableProduct                type c length                   40    ,
        ArticleCategory                              type c length                   2     ,
        PlndOrderReplnmtElmntType                    type c length                   1     ,
        ProductPurchasePointsQtyUnit                 type c length                   3     ,
        ProductPurchasePointsQty                     type c length                   13    ,
        StorageLocation                              type c length                   4     ,
        PurchaseOrderQuantityUnit                    type c length                   3     ,
        OrderItemQtyToBaseQtyNmrtr                   type c length                   5     ,
        OrderItemQtyToBaseQtyDnmntr                  type c length                   5     ,
        NetPriceQuantity                             type c length                   5     ,
        IsCompletelyDelivered                        type c length                   1     ,
        IsFinallyInvoiced                            type c length                   1     ,
        GoodsReceiptIsExpected                       type c length                   1     ,
        InvoiceIsExpected                            type c length                   1     ,
        InvoiceIsGoodsReceiptBased                   type c length                   1     ,
        PurchaseContractItem                         type c length                   5     ,
        PurchaseContract                             type c length                   10    ,
        PurchaseRequisition                          type c length                   10    ,
        RequirementTracking                          type c length                   10    ,
        PurchaseRequisitionItem                      type c length                   5     ,
        EvaldRcptSettlmtIsAllowed                    type c length                   1     ,
        UnlimitedOverdeliveryIsAllowed               type c length                   1     ,
        OverdelivTolrtdLmtRatioInPct                 type c length                   3     ,
        UnderdelivTolrtdLmtRatioInPct                type c length                   3     ,
        RequisitionerName                            type c length                   12    ,
        PlannedDeliveryDurationInDays                type c length                   3     ,
        GoodsReceiptDurationInDays                   type c length                   3     ,
        PartialDeliveryIsAllowed                     type c length                   1     ,
        ConsumptionPosting                           type c length                   1     ,
        ServicePerformer                             type c length                   10    ,
        BaseUnit                                     type c length                   3     ,
        PurchaseOrderItemCategory                    type c length                   1     ,
        ProfitCenter                                 type c length                   10    ,
        OrderPriceUnit                               type c length                   3     ,
        ItemVolumeUnit                               type c length                   3     ,
        ItemWeightUnit                               type c length                   3     ,
        MultipleAcctAssgmtDistribution               type c length                   1     ,
        PartialInvoiceDistribution                   type c length                   1     ,
        PricingDateControl                           type c length                   1     ,
        IsStatisticalItem                            type c length                   1     ,
        PurchasingParentItem                         type c length                   5     ,
        GoodsReceiptLatestCreationDate               type c length                   8     ,
        IsReturnsItem                                type c length                   1     ,
        PurchasingOrderReason                        type c length                   3     ,
        IncotermsClassification                      type c length                   3     ,
        IncotermsTransferLocation                    type c length                   28    ,
        IncotermsLocation1                           type c length                   70    ,
        IncotermsLocation2                           type c length                   70    ,
        PriorSupplier                                type c length                   10    ,
        InternationalArticleNumber                   type c length                   18    ,
        IntrastatServiceCode                         type c length                   30    ,
        CommodityCode                                type c length                   30    ,
        MaterialFreightGroup                         type c length                   8     ,
        DiscountInKindEligibility                    type c length                   1     ,
        PurgItemIsBlockedForDelivery                 type c length                   1     ,
        SupplierConfirmationControlKey               type c length                   4     ,
        PriceIsToBePrinted                           type c length                   1     ,
        AccountAssignmentCategory                    type c length                   1     ,
        PurchasingInfoRecord                         type c length                   10    ,
        NetAmount                                    type c length                   13    ,
        GrossAmount                                  type c length                   13    ,
        EffectiveAmount                              type c length                   13    ,
        Subtotal1Amount                              type c length                   13    ,
        Subtotal2Amount                              type c length                   13    ,
        Subtotal3Amount                              type c length                   13    ,
        Subtotal4Amount                              type c length                   13    ,
        Subtotal5Amount                              type c length                   13    ,
        Subtotal6Amount                              type c length                   13    ,
        OrderQuantity                                type c length                   13    ,
        NetPriceAmount                               type c length                   11    ,
        ItemVolume                                   type c length                   13    ,
        ItemGrossWeight                              type c length                   13    ,
        ItemNetWeight                                type c length                   13    ,
        OrderPriceUnitToOrderUnitNmrtr               type c length                   5     ,
        OrdPriceUnitToOrderUnitDnmntr                type c length                   5     ,
        GoodsReceiptIsNonValuated                    type c length                   1     ,
        TaxCode                                      type c length                   2     ,
        TaxJurisdiction                              type c length                   15    ,
        ShippingInstruction                          type c length                   2     ,
        ShippingType                                 type c length                   2     ,
        NonDeductibleInputTaxAmount                  type c length                   13    ,
        StockType                                    type c length                   1     ,
        ValuationType                                type c length                   10    ,
        ValuationCategory                            type c length                   1     ,
        ItemIsRejectedBySupplier                     type c length                   1     ,
        PurgDocPriceDate                             type c length                   8     ,
        PurgDocReleaseOrderQuantity                  type c length                   13    ,
        EarmarkedFunds                               type c length                   10    ,
        EarmarkedFundsDocument                       type c length                   10    ,
        EarmarkedFundsItem                           type c length                   3     ,
        EarmarkedFundsDocumentItem                   type c length                   3     ,
        PartnerReportedBusinessArea                  type c length                   4     ,
        InventorySpecialStockType                    type c length                   1     ,
        DeliveryDocumentType                         type c length                   4     ,
        IssuingStorageLocation                       type c length                   4     ,
        AllocationTable                              type c length                   10    ,
        AllocationTableItem                          type c length                   5     ,
        RetailPromotion                              type c length                   10    ,
        DownPaymentType                              type c length                   4     ,
        DownPaymentPercentageOfTotAmt                type c length                   5     ,
        DownPaymentAmount                            type c length                   11    ,
        DownPaymentDueDate                           type c length                   8     ,
        ExpectedOverallLimitAmount                   type c length                   13    ,
        OverallLimitAmount                           type c length                   13    ,
        RequirementSegment                           type c length                   40    ,
        PurgProdCmplncDngrsGoodsStatus               type c length                   1     ,
        PurgProdCmplncSupplierStatus                 type c length                   1     ,
        PurgProductMarketabilityStatus               type c length                   1     ,
        PurgSafetyDataSheetStatus                    type c length                   1     ,
        SubcontrgCompIsRealTmeCnsmd                  type c length                   1     ,
        BR_MaterialOrigin                            type c length                   1     ,
        BR_MaterialUsage                             type c length                   1     ,
        BR_CFOPCategory                              type c length                   2     ,
        BR_NCM                                       type c length                   16    ,
        BR_IsProducedInHouse                         type c length                   1     ,

      END OF TY_EKPO,

      "NO.3 納入日程行
      BEGIN OF TY_EKET,
        PurchaseOrder                        type c length       10,
        PurchaseOrderItem                    type c length       5 ,
        PurchaseOrderScheduleLine            type c length       4 ,
        PerformancePeriodStartDate           type c length       8 ,
        PerformancePeriodEndDate             type c length       8 ,
        DelivDateCategory                    type c length       1 ,
        ScheduleLineDeliveryDate             type c length       8 ,
        ScheduleLineDeliveryTime             type c length       6 ,
        ScheduleLineOrderQuantity            type c length       13,
        RoughGoodsReceiptQty                 type c length       13,
        PurchaseOrderQuantityUnit            type c length       3 ,
        PurchaseRequisition                  type c length       10,
        PurchaseRequisitionItem              type c length       5 ,
        SourceOfCreation                     type c length       1 ,
        PrevDelivQtyOfScheduleLine           type c length       13,
        NoOfRemindersOfScheduleLine          type c length       3 ,
        ScheduleLineIsFixed                  type c length       1 ,
        ScheduleLineCommittedQuantity        type c length       13,
        Reservation                          type c length       10,
        ProductAvailabilityDate              type c length       8 ,
        MaterialStagingTime                  type c length       6 ,
        TransportationPlanningDate           type c length       8 ,
        TransportationPlanningTime           type c length       6 ,
        LoadingDate                          type c length      8 ,
        LoadingTime                          type c length      6 ,
        GoodsIssueDate                       type c length      8 ,
        GoodsIssueTime                       type c length      6 ,
        STOLatestPossibleGRDate              type c length      8 ,
        STOLatestPossibleGRTime              type c length      6 ,
        StockTransferDeliveredQuantity       type c length      13,
        ScheduleLineIssuedQuantity           type c length      13,
        Batch                                type c length      10,

      END OF TY_EKET,

      "NO.4 購買発注履歴
      BEGIN OF ty_ekbe,
        PurchaseOrder                               type c length   10,
        PurchaseOrderItem                           type c length   5 ,
        AccountAssignmentNumber                     type c length   2 ,
        PurchasingHistoryDocumentType               type c length   1 ,
        PurchasingHistoryDocumentYear               type c length   4 ,
        PurchasingHistoryDocument                   type c length   10,
        PurchasingHistoryDocumentItem               type c length   4 ,
        PurchasingHistoryCategory                   type c length   1 ,
        GoodsMovementType                           type c length   3 ,
        PostingDate                                 type c length   8 ,
        Currency                                    type c length   5 ,
        DebitCreditCode                             type c length   1 ,
        IsCompletelyDelivered                       type c length   1 ,
        ReferenceDocumentFiscalYear                 type c length   4 ,
        ReferenceDocument                           type c length   10,
        ReferenceDocumentItem                       type c length   4 ,
        Material                                    type c length   40,
        Plant                                       type c length   4 ,
        RvslOfGoodsReceiptIsAllowed                 type c length   1 ,
        PricingDocument                             type c length   10,
        TaxCode                                     type c length   2 ,
        DocumentDate                                type c length   8 ,
        InventoryValuationType                      type c length   10,
        DocumentReferenceID                         type c length   16,
        DeliveryQuantityUnit                        type c length   3 ,
        ManufacturerMaterial                        type c length   40,
        AccountingDocumentCreationDate              type c length   8 ,
        PurgHistDocumentCreationTime                type c length   6 ,
        Quantity                                    type c length   13,
        PurOrdAmountInCompanyCodeCrcy               type c length   13,
        PurchaseOrderAmount                         type c length   13,
        QtyInPurchaseOrderPriceUnit                 type c length   13,
        GRIRAcctClrgAmtInCoCodeCrcy                 type c length   13,
        GdsRcptBlkdStkQtyInOrdQtyUnit               type c length   13,
        GdsRcptBlkdStkQtyInOrdPrcUnit               type c length   13,
        InvoiceAmtInCoCodeCrcy                      type c length   13,
        ShipgInstrnSupplierCompliance               type c length   2 ,
        InvoiceAmountInFrgnCurrency                 type c length   13,
        QuantityInDeliveryQtyUnit                   type c length   13,
        GRIRAcctClrgAmtInTransacCrcy                type c length   13,
        QuantityInBaseUnit                          type c length   13,
        Batch                                       type c length   10,
        GRIRAcctClrgAmtInOrdTrnsacCrcy              type c length   13,
        InvoiceAmtInPurOrdTransacCrcy               type c length   13,
        VltdGdsRcptBlkdStkQtyInOrdUnit              type c length   13,
        VltdGdsRcptBlkdQtyInOrdPrcUnit              type c length   13,
        IsToBeAcceptedAtOrigin                      type c length   1 ,
        ExchangeRateDifferenceAmount                type c length   13,
        ExchangeRate                                type c length   9 ,
        DeliveryDocument                            type c length   10,
        DeliveryDocumentItem                        type c length   6 ,
        OrderPriceUnit                              type c length   3 ,
        PurchaseOrderQuantityUnit                   type c length   3 ,
        BaseUnit                                    type c length   3 ,
        DocumentCurrency                            type c length   5 ,
        CompanyCodeCurrency                         type c length   5 ,

      END OF TY_EKBE,

      "NO.5 購買発注の勘定設定
      BEGIN OF TY_EKKN,
        PurchaseOrder                      type c length    10   ,
        PurchaseOrderItem                  type c length    5    ,
        AccountAssignmentNumber            type c length    2    ,
        CostCenter                         type c length    10   ,
        MasterFixedAsset                   type c length    12   ,
        ProjectNetwork                     type c length    12   ,
        Quantity                           type c length    13   ,
        PurchaseOrderQuantityUnit          type c length    3    ,
        MultipleAcctAssgmtDistrPercent     type c length    3    ,
        PurgDocNetAmount                   type c length    13   ,
        DocumentCurrency                   type c length    5    ,
        IsDeleted                          type c length    1    ,
        GLAccount                          type c length    10   ,
        BusinessArea                       type c length    4    ,
        SalesOrder                         type c length    10   ,
        SalesOrderItem                     type c length    6    ,
        SalesOrderScheduleLine             type c length    4    ,
        FixedAsset                         type c length    4    ,
        OrderID                            type c length    12   ,
        UnloadingPointName                 type c length    25   ,
        ControllingArea                    type c length    4    ,
        CostObject                         type c length    12   ,
        ProfitabilitySegment               type c length    10   ,
        ProfitabilitySegment_2             type c length    10   ,
        ProfitCenter                       type c length    10   ,
        WBSElementInternalID               type c length    8    ,
        WBSElementInternalID_2             type c length    8    ,
        ProjectNetworkInternalID           type c length    10   ,
        CommitmentItem                     type c length    14   ,
        CommitmentItemShortID              type c length    14   ,
        FundsCenter                         type c length   16   ,
        Fund                                type c length   10   ,
        FunctionalArea                      type c length   16   ,
        GoodsRecipientName                  type c length   12   ,
        IsFinallyInvoiced                   type c length   1    ,
        RealEstateObject                    type c length   8    ,
        REInternalFinNumber                 type c length   8    ,
        NetworkActivityInternalID           type c length   8    ,
        PartnerAccountNumber                type c length   10   ,
        JointVentureRecoveryCode            type c length   2    ,
        SettlementReferenceDate             type c length   8    ,
        OrderInternalID                     type c length   10   ,
        OrderIntBillOfOperationsItem        type c length   8    ,
        TaxCode                             type c length   2    ,
        TaxJurisdiction                     type c length   15   ,
        NonDeductibleInputTaxAmount         type c length   13   ,
        CostCtrActivityType                 type c length   6    ,
        BusinessProcess                     type c length   12   ,
        GrantID                             type c length   20   ,
        BudgetPeriod                        type c length   10   ,
        EarmarkedFundsDocument              type c length   10   ,
        EarmarkedFundsItem                  type c length   3    ,
        EarmarkedFundsDocumentItem          type c length   3    ,
        ServiceDocumentType                 type c length   4    ,
        ServiceDocument                     type c length   10   ,
        ServiceDocumentItem                 type c length   6    ,
      END OF TY_EKKN,

      "NO.6 製品
      BEGIN OF TY_MARA,
*        Product                                     type c length   40  ,
*        ProductExternalID                           type c length   40  ,
*        ProductOID                                  type c length   128  ,
*        ProductType                                 type c length   4  ,
*        CreationDate                                type c length   8  ,
*        CreationTime                                type c length   6  ,
*        CreationDateTime                            type c length   21  ,
*        CreatedByUser                               type c length   12  ,
*        LastChangeDate                              type c length   8  ,
*        LastChangedByUser                           type c length   12  ,
*        IsMarkedForDeletion                         type c length   1  ,
*        CrossPlantStatus                            type c length   2  ,
*        CrossPlantStatusValidityDate                type c length   8  ,
*        ProductOldID                                type c length   40  ,
*        GrossWeight                                 type c length   13  ,
*        PurchaseOrderQuantityUnit                   type c length   3  ,
*        SourceOfSupply                              type c length   1  ,
*        WeightUnit                                  type c length   3  ,
*        CountryOfOrigin                             type c length   3  ,
*        CompetitorID                                type c length   10  ,
*        ProductGroup                                type c length   9  ,
*        BaseUnit                                    type c length   3  ,
*        ItemCategoryGroup                           type c length   4  ,
*        NetWeight                                   type c length   13  ,
*        ProductHierarchy                            type c length   18  ,
*        Division                                    type c length   2  ,
*        VarblPurOrdUnitIsActive                     type c length   1  ,
*        VolumeUnit                                  type c length   3  ,
*        MaterialVolume                              type c length   13  ,
*        SalesStatus                                 type c length   2  ,
*        TransportationGroup                         type c length   4  ,
*        SalesStatusValidityDate                     type c length   8  ,
*        AuthorizationGroup                          type c length   4  ,
*        ANPCode                                     type c length   9  ,
*        ProductCategory                             type c length   2  ,
*        Brand                                       type c length   4  ,
*        ProcurementRule                             type c length   1  ,
*        ValidityStartDate                           type c length   8  ,
*        LowLevelCode                                type c length   3  ,
*        ProdNoInGenProdInPrepackProd                type c length   40  ,
*        SerialIdentifierAssgmtProfile               type c length   4  ,
*        SizeOrDimensionText                         type c length   32  ,
*        IndustryStandardName                        type c length   18  ,
*        ProductStandardID                           type c length   18  ,
*        InternationalArticleNumberCat               type c length   2  ,
*        ProductIsConfigurable                       type c length   1  ,
*        IsBatchManagementRequired                   type c length   1  ,
*        HasEmptiesBOM                               type c length   1  ,
*        ExternalProductGroup                        type c length   18  ,
*        CrossPlantConfigurableProduct               type c length   40  ,
*        SerialNoExplicitnessLevel                   type c length   1  ,
*        ProductManufacturerNumber                   type c length   40  ,
*        ManufacturerNumber                          type c length   10  ,
*        ManufacturerPartProfile                     type c length   4  ,
*        QltyMgmtInProcmtIsActive                    type c length   1  ,
*        IsApprovedBatchRecordReqd                   type c length   1  ,
*        HandlingIndicator                           type c length   4  ,
*        WarehouseProductGroup                       type c length   4  ,
*        WarehouseStorageCondition                   type c length   2  ,
*        StandardHandlingUnitType                    type c length   4  ,
*        SerialNumberProfile                         type c length   4  ,
*        AdjustmentProfile                           type c length   3  ,
*        PreferredUnitOfMeasure                      type c length   3  ,
*        IsPilferable                                type c length   1  ,
*        IsRelevantForHzdsSubstances                 type c length   1  ,
*        QuarantinePeriod                            type c length   3  ,
*        TimeUnitForQuarantinePeriod                 type c length   3  ,
*        QualityInspectionGroup                      type c length   4  ,
*        HandlingUnitType                            type c length   4  ,
*        HasVariableTareWeight                       type c length   1  ,
*        MaximumPackagingLength                      type c length   15  ,
*        MaximumPackagingWidth                       type c length   15  ,
*        MaximumPackagingHeight                      type c length   15  ,
*        MaximumCapacity                             type c length   15  ,
*        OvercapacityTolerance                       type c length   3  ,
*        UnitForMaxPackagingDimensions               type c length   3  ,
*        BaseUnitSpecificProductLength               type c length   13  ,
*        BaseUnitSpecificProductWidth                type c length   13  ,
*        BaseUnitSpecificProductHeight               type c length   13  ,
*        ProductMeasurementUnit                      type c length   3  ,
*        ProductValidStartDate                       type c length   8  ,
*        ArticleCategory                             type c length   2  ,
*        ContentUnit                                 type c length   3  ,
*        NetContent                                  type c length   13  ,
*        ComparisonPriceQuantity                     type c length   5  ,
*        GrossContent                                type c length   13  ,
*        ProductValidEndDate                         type c length   8  ,
*        AssortmentListType                          type c length   1  ,
*        HasTextilePartsWthAnimalOrigin              type c length   1  ,
*        ProductSeasonUsageCategory                  type c length   1  ,
*        IndustrySector                              type c length   1  ,
*        ChangeNumber                                type c length   12  ,
*        MaterialRevisionLevel                       type c length   2  ,
*        IsActiveEntity                              type c length   1  ,
*        LastChangeDateTime                          type c length   21  ,
*        LastChangeTime                              type c length   6  ,
*        DangerousGoodsIndProfile                    type c length   3  ,
*        ProductUUID                                 type c length   16  ,
*        ProdSupChnMgmtUUID22                        type c length   22  ,
*        ProductDocumentChangeNumber                 type c length   6  ,
*        ProductDocumentPageCount                    type c length   3  ,
*        ProductDocumentPageNumber                   type c length   3  ,
*        OwnInventoryManagedProduct                  type c length   40  ,
*        DocumentIsCreatedByCAD                      type c length   1  ,
*        ProductionOrInspectionMemoTxt               type c length   18  ,
*        ProductionMemoPageFormat                    type c length   4  ,
*        GlobalTradeItemNumberVariant                type c length   2  ,
*        ProductIsHighlyViscous                      type c length   1  ,
*        TransportIsInBulk                           type c length   1  ,
*        ProdAllocDetnProcedure                      type c length   18  ,
*        ProdEffctyParamValsAreAssigned              type c length   1  ,
*        ProdIsEnvironmentallyRelevant               type c length   1  ,
*        LaboratoryOrDesignOffice                    type c length   3  ,
*        PackagingMaterialGroup                      type c length   4  ,
*        ProductIsLocked                             type c length   1  ,
*        DiscountInKindEligibility                   type c length   1  ,
*        SmartFormName                               type c length   30  ,
*        PackingReferenceProduct                     type c length   40  ,
*        BasicMaterial                               type c length   48  ,
*        ProductDocumentNumber                       type c length   22  ,
*        ProductDocumentVersion                      type c length   2  ,
*        ProductDocumentType                         type c length   3  ,
*        ProductDocumentPageFormat                   type c length   4  ,
*        ProductConfiguration                        type c length   18  ,
*        SegmentationStrategy                        type c length   8  ,
*        SegmentationIsRelevant                      type c length   1  ,
*        ProductCompositionIsRelevant                type c length   1  ,
*        IsChemicalComplianceRelevant                type c length   1  ,
*        ManufacturerBookPartNumber                  type c length   40  ,
*        LogisticalProductCategory                   type c length   1  ,
*        SalesProduct                                type c length   40  ,
*        ProdCharc1InternalNumber                    type c length   10  ,
*        ProdCharc2InternalNumber                    type c length   10  ,
*        ProdCharc3InternalNumber                    type c length   10  ,
*        ProductCharacteristic1                      type c length   18  ,
*        ProductCharacteristic2                      type c length   18  ,
*        ProductCharacteristic3                      type c length   18  ,
*        MaintenanceStatus                           type c length   15  ,
*        FashionProdInformationField1                type c length   10  ,
*        FashionProdInformationField2                type c length   10  ,
*        FashionProdInformationField3                type c length   6  ,

        "add by wang.z 20250207-------

        Product type I_Product-Product,
        CreationDate type I_Product-CreationDate,
        IsMarkedForDeletion type I_Product-IsMarkedForDeletion,
        ProductType type I_Product-ProductType,
        ProductGroup type I_Product-ProductGroup,
        ProductOldID type I_Product-ProductOldID,
        BaseUnit type I_Product-BaseUnit,
        PurchaseOrderQuantityUnit type I_Product-PurchaseOrderQuantityUnit,
        ProductDocumentVersion type I_Product-ProductDocumentVersion,
        ProductDocumentChangeNumber type I_Product-ProductDocumentChangeNumber,
        ProductionOrInspectionMemoTxt type I_Product-ProductionOrInspectionMemoTxt,
        SizeOrDimensionText type I_Product-SizeOrDimensionText,
        LaboratoryOrDesignOffice type I_Product-LaboratoryOrDesignOffice,
        GrossWeight type I_Product-GrossWeight,
        NetWeight type I_Product-NetWeight,
        WeightUnit type I_Product-WeightUnit,
        TransportationGroup type I_Product-TransportationGroup,
        Division type I_Product-Division,
        IsBatchManagementRequired type I_Product-IsBatchManagementRequired,
        PackagingMaterialGroup type I_Product-PackagingMaterialGroup,
        ExternalProductGroup type I_Product-ExternalProductGroup,
        ProductManufacturerNumber type I_Product-ProductManufacturerNumber,
        ManufacturerNumber type I_Product-ManufacturerNumber,
        YY1_BPCODE_PRD_PRD type I_Product-YY1_BPCODE_PRD_PRD,
        YY1_CUSTOMERMATERIAL_PRD type I_Product-YY1_CUSTOMERMATERIAL_PRD,

        PackagingMaterialType type I_ProductSales-PackagingMaterialType,

        "end add by wang.z 20250207---------

      END OF TY_MARA,

      "NO.7 製品テキスト
      BEGIN OF ty_makt,
        Product         type c length   40,
        Language        type c length   1,
        ProductName     type c length   40,
      END OF TY_MAKT,

      "N0.8 製品保管場所
      BEGIN OF TY_MARD,
        Material                                            type c length   40    ,
        Plant                                              type c length   4     ,
        StorageLocation                                    type c length   4     ,
*        WarehouseStorageBin                                type c length   10    ,
*        MaintenanceStatus                                  type c length   15    ,
*        IsMarkedForDeletion                                type c length   1     ,
*        PhysicalInventoryBlockInd                          type c length   1     ,
*        CreationDate                                       type c length   8     ,
*        DateOfLastPostedCntUnRstrcdStk                     type c length   8     ,
*        InventoryCorrectionFactor                          type c length   16    ,
*        InvtryRestrictedUseStockInd                        type c length   3     ,
*        InvtryCurrentYearStockInd                          type c length   3     ,
*        InvtryQualInspCurrentYrStkInd                      type c length   3     ,
*        InventoryBlockStockInd                             type c length   3     ,
*        InvtryRestStockPrevPeriodInd                       type c length   3     ,
*        InventoryStockPrevPeriod                           type c length   3     ,
*        InvtryStockQltyInspPrevPeriod                      type c length   3     ,
*        HasInvtryBlockStockPrevPeriod                      type c length   3     ,
*        FiscalYearCurrentInvtryPeriod                      type c length   4     ,
*        LeanWrhsManagementPickingArea                      type c length   3     ,
*        IsActiveEntity                                     type c length   1     ,
        KLABS                                              type I_MaterialStock_2-MatlWrhsStkQtyInMatlBaseUnit ,
        KINSM                                              type I_MaterialStock_2-MatlWrhsStkQtyInMatlBaseUnit ,
        INSME                                              type I_MaterialStock_2-MatlWrhsStkQtyInMatlBaseUnit ,
        LABST                                              type I_MaterialStock_2-MatlWrhsStkQtyInMatlBaseUnit ,
      END OF TY_MARD,

      "NO.9 MRP 管理者
      BEGIN OF ty_t024d,
        Plant                          TYPE C LENGTH    4  ,
        MRPController                  TYPE C LENGTH    3  ,
        MRPControllerName              TYPE C LENGTH    18 ,
        MRPControllerPhoneNumber       TYPE C LENGTH    12 ,
        PurchasingGroup                TYPE C LENGTH    3  ,
        BusinessArea                   TYPE C LENGTH    4  ,
        ProfitCenter                   TYPE C LENGTH    10 ,
        UserID                         TYPE C LENGTH    70 ,
      END OF TY_T024D,

      "NO.10 保管場所
      BEGIN OF ty_T001L,
        Plant                          TYPE C LENGTH    4  ,
        StorageLocation                TYPE C LENGTH    4  ,
        StorageLocationName            TYPE C LENGTH    16 ,
        SalesOrganization              TYPE C LENGTH    4  ,
        DistributionChannel            TYPE C LENGTH    2  ,
        Division                       TYPE C LENGTH    2  ,
        IsStorLocAuthznCheckActive     TYPE C LENGTH    1  ,
        HandlingUnitIsRequired         TYPE C LENGTH    1  ,
        ConfigDeprecationCode          TYPE C LENGTH    1  ,
      END OF TY_T001L,

      "NO.11 製品プラント
      BEGIN OF ty_MARC,
*        Product                        TYPE C LENGTH   40   ,
*        Plant                          TYPE C LENGTH   4    ,
*        PurchasingGroup                TYPE C LENGTH   3    ,
*        CountryOfOrigin                TYPE C LENGTH   3    ,
*        RegionOfOrigin                 TYPE C LENGTH   3    ,
*        ProductionInvtryManagedLoc     TYPE C LENGTH   4    ,
*        ProfileCode                    TYPE C LENGTH   2    ,
*        ProfileValidityStartDate       TYPE C LENGTH   8    ,
*        AvailabilityCheckType          TYPE C LENGTH   2    ,
*        FiscalYearVariant              TYPE C LENGTH   2    ,
*        PeriodType                     TYPE C LENGTH   1    ,
*        ProfitCenter                   TYPE C LENGTH   10   ,
*        GoodsReceiptDuration           TYPE C LENGTH   3    ,
*        MaintenanceStatusName          TYPE C LENGTH   15   ,
*        IsMarkedForDeletion            TYPE C LENGTH   1    ,
*        MRPType                        TYPE C LENGTH   2    ,
*        MRPResponsible                 TYPE C LENGTH   3    ,
*        ABCIndicator                   TYPE C LENGTH   1    ,
*        MinimumLotSizeQuantity         TYPE C LENGTH   13   ,
*        MaximumLotSizeQuantity         TYPE C LENGTH   13   ,
*        FixedLotSizeQuantity           TYPE C LENGTH   13   ,
*        ConsumptionTaxCtrlCode         TYPE C LENGTH   16   ,
*        IsCoProduct                    TYPE C LENGTH   1    ,
*        ConfigurableProduct            TYPE C LENGTH   40   ,
*        StockDeterminationGroup        TYPE C LENGTH   4    ,
*        HasPostToInspectionStock       TYPE C LENGTH   1    ,
*        IsBatchManagementRequired      TYPE C LENGTH   1    ,
*        SerialNumberProfile            TYPE C LENGTH   4    ,
*        IsNegativeStockAllowed         TYPE C LENGTH   1    ,
*        HasConsignmentCtrl             TYPE C LENGTH   1    ,
*        IsPurgAcrossPurgGroup          TYPE C LENGTH   1    ,
*        IsInternalBatchManaged         TYPE C LENGTH   1    ,
*        ProductCFOPCategory            TYPE C LENGTH   2    ,
*        ProductIsExciseTaxRelevant     TYPE C LENGTH   1    ,
*        UnderDelivToleranceLimit       TYPE C LENGTH   3    ,
*        OverDelivToleranceLimit        TYPE C LENGTH   3    ,
*        ProcurementType                TYPE C LENGTH   1    ,
*        SpecialProcurementType         TYPE C LENGTH   2    ,
*        ProductionSchedulingProfile    TYPE C LENGTH   6    ,
*        ProductionSupervisor           TYPE C LENGTH   3    ,
*        SafetyStockQuantity            TYPE C LENGTH   13   ,
*        GoodsIssueUnit                 TYPE C LENGTH   3    ,
*        SourceOfSupplyCategory         TYPE C LENGTH   1    ,
*        ConsumptionReferenceProduct    TYPE C LENGTH   40   ,
*        ConsumptionReferencePlant      TYPE C LENGTH   4    ,
*        ConsumptionRefUsageEndDate     TYPE C LENGTH   8    ,
*        ConsumptionQtyMultiplier       TYPE C LENGTH   4    ,
*        ProductUnitGroup               TYPE C LENGTH   4    ,
*        DistrCntrDistributionProfile   TYPE C LENGTH   3    ,
*        ConsignmentControl             TYPE C LENGTH   1    ,
*        GoodIssueProcessingDays        TYPE C LENGTH   3    ,
*        PlannedDeliveryDurationInDays  TYPE C LENGTH   3    ,
*        ProductIsCriticalPrt           TYPE C LENGTH   1    ,
*        ProductLogisticsHandlingGroup  TYPE C LENGTH   4    ,
*        MaterialFreightGroup           TYPE C LENGTH   8    ,
*        OriginalBatchReferenceMaterial TYPE C LENGTH   40   ,
*        OriglBatchManagementIsRequired TYPE C LENGTH   1    ,
*        ProductConfiguration           TYPE C LENGTH   18   ,
*        ProductMinControlTemperature   TYPE C LENGTH   7    ,
*        ProductMaxControlTemperature   TYPE C LENGTH   7    ,
*        ProductControlTemperatureUnit  TYPE C LENGTH   3    ,
*        ValuationCategory              TYPE C LENGTH   1    ,
*        BaseUnit                       TYPE C LENGTH   3    ,
*        ItemUniqueIdentifierIsRelevant TYPE C LENGTH   1    ,
*        ItemUniqueIdentifierType       TYPE C LENGTH   10   ,
*        ExtAllocOfItmUnqIdtIsRelevant  TYPE C LENGTH   1    ,


"add by wang.z 20250207 -----------------

        Product type I_ProductPlantBasic-Product,
        Plant type I_ProductPlantBasic-Plant,
        IsMarkedForDeletion type I_ProductPlantBasic-IsMarkedForDeletion,
        ProfileCode type I_ProductPlantBasic-ProfileCode,
        ProductIsCriticalPrt type I_ProductPlantBasic-ProductIsCriticalPrt,
        PurchasingGroup type I_ProductPlantBasic-PurchasingGroup,
        GoodsIssueUnit type I_ProductPlantBasic-GoodsIssueUnit,
        MRPType type I_ProductPlantBasic-MRPType,
        MRPResponsible type I_ProductPlantBasic-MRPResponsible,
        PlannedDeliveryDurationInDays type I_ProductPlantBasic-PlannedDeliveryDurationInDays,
        GoodsReceiptDuration type I_ProductPlantBasic-GoodsReceiptDuration,
        ProcurementType type I_ProductPlantBasic-ProcurementType,
        SpecialProcurementType type I_ProductPlantBasic-SpecialProcurementType,
        SafetyStockQuantity type I_ProductPlantBasic-SafetyStockQuantity,
        MinimumLotSizeQuantity type I_ProductPlantBasic-MinimumLotSizeQuantity,
        MaximumLotSizeQuantity type I_ProductPlantBasic-MaximumLotSizeQuantity,
        FixedLotSizeQuantity type I_ProductPlantBasic-FixedLotSizeQuantity,
        ProductionSupervisor type I_ProductPlantBasic-ProductionSupervisor,
        HasPostToInspectionStock type I_ProductPlantBasic-HasPostToInspectionStock,
        IsBatchManagementRequired type I_ProductPlantBasic-IsBatchManagementRequired,
        AvailabilityCheckType type I_ProductPlantBasic-AvailabilityCheckType,
        ProfitCenter type I_ProductPlantBasic-ProfitCenter,
        ProductionInvtryManagedLoc type I_ProductPlantBasic-ProductionInvtryManagedLoc,

        ProductProductionQuantityUnit type I_ProductWorkScheduling-ProductProductionQuantityUnit,
        ProductionSchedulingProfile type I_ProductWorkScheduling-ProductionSchedulingProfile,

        AssemblyScrapPercent type I_PRODUCTPLANTSUPPLYPLANNING-AssemblyScrapPercent,
        LotSizingProcedure type I_PRODUCTPLANTSUPPLYPLANNING-LotSizingProcedure,
        LotSizeRoundingQuantity type I_PRODUCTPLANTSUPPLYPLANNING-LotSizeRoundingQuantity,
        DependentRequirementsType type I_PRODUCTPLANTSUPPLYPLANNING-DependentRequirementsType,
        SchedulingFloatProfile type I_PRODUCTPLANTSUPPLYPLANNING-SchedulingFloatProfile,
        ProductComponentBackflushCode type I_PRODUCTPLANTSUPPLYPLANNING-ProductComponentBackflushCode,
        ProdInhProdnDurationInWorkDays type I_PRODUCTPLANTSUPPLYPLANNING-ProdInhProdnDurationInWorkDays,
        MRPPlanningCalendar type I_PRODUCTPLANTSUPPLYPLANNING-MRPPlanningCalendar,
        PlanningTimeFence type I_PRODUCTPLANTSUPPLYPLANNING-PlanningTimeFence,
        ProdRqmtsConsumptionMode type I_PRODUCTPLANTSUPPLYPLANNING-ProdRqmtsConsumptionMode,
        BackwardCnsmpnPeriodInWorkDays type I_PRODUCTPLANTSUPPLYPLANNING-BackwardCnsmpnPeriodInWorkDays,
        FwdConsumptionPeriodInWorkDays type I_PRODUCTPLANTSUPPLYPLANNING-FwdConsumptionPeriodInWorkDays,
        MRPGroup type I_PRODUCTPLANTSUPPLYPLANNING-MRPGroup,
        ComponentScrapInPercent type I_PRODUCTPLANTSUPPLYPLANNING-ComponentScrapInPercent,
        PlanningStrategyGroup type I_PRODUCTPLANTSUPPLYPLANNING-PlanningStrategyGroup,
        DfltStorageLocationExtProcmt type I_PRODUCTPLANTSUPPLYPLANNING-DfltStorageLocationExtProcmt,
        ProductIsBulkComponent type I_PRODUCTPLANTSUPPLYPLANNING-ProductIsBulkComponent,
        ProductSafetyTimeMRPRelevance type I_PRODUCTPLANTSUPPLYPLANNING-ProductSafetyTimeMRPRelevance,
        SafetySupplyDurationInDays type I_PRODUCTPLANTSUPPLYPLANNING-SafetySupplyDurationInDays,

        LoadingGroup type I_Productplantsales-LoadingGroup,

        IsAutoPurOrdCreationAllowed type I_Productplantprocurement-IsAutoPurOrdCreationAllowed,
        IsSourceListRequired type I_Productplantprocurement-IsSourceListRequired,

        CostingLotSize type I_PRODUCTPLANTCOSTING-CostingLotSize,
        ProductIsCostingRelevant type I_PRODUCTPLANTCOSTING-ProductIsCostingRelevant,

"end add by wang.z 20250207--------------

      END OF ty_MARC,

      "NO.12 製造バージョン
      BEGIN OF ty_MKAL,
        Material                          type c length    40 ,
        Plant                             type c length    4  ,
        ProductionVersion                 type c length    4  ,
        ProductionVersionText             type c length    40 ,
        ChangeHistoryCount                type c length    4  ,
        ChangeNumber                      type c length    12 ,
        CreationDate                      type c length    8  ,
        CreatedByUser                     type c length    12 ,
        LastChangeDate                    type c length    8  ,
        LastChangedByUser                 type c length    12 ,
        BillOfOperationsType              type c length    1  ,
        BillOfOperationsGroup             type c length    8  ,
        BillOfOperationsVariant           type c length    2  ,
        BillOfMaterialVariantUsage        type c length    1  ,
        BillOfMaterialVariant             type c length    2  ,
        ProductionLine                    type c length    8  ,
        ProductionSupplyArea              type c length    10 ,
        ProductionVersionGroup            type c length    8  ,
        MainProduct                       type c length    40 ,
        MaterialCostApportionmentStruc    type c length    4  ,
        IssuingStorageLocation            type c length    4  ,
        ReceivingStorageLocation          type c length    4  ,
        OriginalBatchReferenceMaterial    type c length    40 ,
        QuantityDistributionKey           type c length    4  ,
        ProductionVersionStatus           type c length    1  ,
        ProductionVersionLastCheckDate    type c length    8  ,
        RateBasedPlanningStatus           type c length    1  ,
        PreliminaryPlanningStatus         type c length    1  ,
        BOMCheckStatus                    type c length    1  ,
        ValidityStartDate                 type c length    8  ,
        ValidityEndDate                   type c length    8  ,
        ProductionVersionIsLocked         type c length    1  ,
        ProdnVersIsAllowedForRptvMfg      type c length    1  ,
        HasVersionCtrldBOMAndRouting      type c length    1  ,
        PlanningAndExecutionBOMIsDiff     type c length    1  ,
        ExecBillOfMaterialVariantUsage    type c length    1  ,
        ExecBillOfMaterialVariant         type c length    2  ,
        ExecBillOfOperationsType          type c length    1  ,
        ExecBillOfOperationsGroup         type c length    8  ,
        ExecBillOfOperationsVariant       type c length    2  ,
        Warehouse                         type c length    4  ,
        DestinationStorageBin             type c length    18 ,
        ProcurementType                   type c length    1  ,
        MaterialProcurementProfile        type c length    2  ,
        UsgeProbltyWthVersCtrlInPct       type c length    3  ,
        MaterialBaseUnit                  type c length    3  ,
        MaterialMinLotSizeQuantity        type c length    13 ,
        MaterialMaxLotSizeQuantity        type c length    13 ,
        CostingLotSize                    type c length    13 ,
        DistributionKey                   type c length    4  ,
        TargetProductionSupplyArea        type c length    10 ,

      END OF TY_MKAL,

      "NO.13 製造指図
      BEGIN OF ty_afko,
        ManufacturingOrder                  TYPE C LENGTH   12   ,
        ManufacturingOrderItem              TYPE C LENGTH   4    ,
        ManufacturingOrderCategory          TYPE C LENGTH   2    ,
        ManufacturingOrderType              TYPE C LENGTH   4    ,
        ManufacturingOrderText              TYPE C LENGTH   40   ,
        ManufacturingOrderHasLongText       TYPE C LENGTH   1    ,
        LongTextLanguageCode                TYPE C LENGTH   1    ,
        ManufacturingOrderImportance        TYPE C LENGTH   1    ,
        IsMarkedForDeletion                 TYPE C LENGTH   1    ,
        IsCompletelyDelivered               TYPE C LENGTH   1    ,
        MfgOrderHasMultipleItems            TYPE C LENGTH   1    ,
        MfgOrderIsPartOfCollvOrder          TYPE C LENGTH   1    ,
        MfgOrderHierarchyLevel              TYPE C LENGTH   2    ,
        MfgOrderHierarchyLevelValue         TYPE C LENGTH   2    ,
        MfgOrderHierarchyPathValue          TYPE C LENGTH   4    ,
        OrderIsNotCostedAutomatically       TYPE C LENGTH   1    ,
        OrdIsNotSchedldAutomatically        TYPE C LENGTH   1    ,
        ProdnProcgIsFlexible                TYPE C LENGTH   1    ,
        CreationDate                        TYPE C LENGTH   8    ,
        CreationTime                        TYPE C LENGTH   6    ,
        CreatedByUser                       TYPE C LENGTH   12   ,
        LastChangeDate                      TYPE C LENGTH   8    ,
        LastChangeTime                      TYPE C LENGTH   6    ,
        LastChangedByUser                   TYPE C LENGTH   12   ,
        Material                            TYPE C LENGTH   40   ,
        Product                             TYPE C LENGTH   40   ,
        StorageLocation                     TYPE C LENGTH   4    ,
        Batch                               TYPE C LENGTH   10   ,
        GoodsRecipientName                  TYPE C LENGTH   12   ,
        UnloadingPointName                  TYPE C LENGTH   25   ,
        InventoryUsabilityCode              TYPE C LENGTH   1    ,
        MaterialGoodsReceiptDuration        TYPE C LENGTH   3    ,
        QuantityDistributionKey             TYPE C LENGTH   4    ,
        StockSegment                        TYPE C LENGTH   40   ,
        MfgOrderInternalID                  TYPE C LENGTH   10   ,
        ReferenceOrder                      TYPE C LENGTH   12   ,
        LeadingOrder                        TYPE C LENGTH   12   ,
        SuperiorOrder                       TYPE C LENGTH   12   ,
        Currency                            TYPE C LENGTH   5    ,
        ProductionPlant                     TYPE C LENGTH   4    ,
        PlanningPlant                       TYPE C LENGTH   4    ,
        MRPArea                             TYPE C LENGTH   10   ,
        MRPController                       TYPE C LENGTH   3    ,
        ProductionSupervisor                TYPE C LENGTH   3    ,
        ProductionSchedulingProfile         TYPE C LENGTH   6    ,
        ResponsiblePlannerGroup             TYPE C LENGTH   3    ,
        ProductionVersion                   TYPE C LENGTH   4    ,
        SalesOrder                          TYPE C LENGTH   10   ,
        SalesOrderItem                      TYPE C LENGTH   6    ,
        WBSElementInternalID                TYPE C LENGTH   8    ,
        WBSElementInternalID_2              TYPE C LENGTH   8    ,
        Reservation                         TYPE C LENGTH   10   ,
        SettlementReservation               TYPE C LENGTH   10   ,
        MfgOrderConfirmation                TYPE C LENGTH   10   ,
        NumberOfMfgOrderConfirmations       TYPE C LENGTH   8    ,
        PlannedOrder                        TYPE C LENGTH   10   ,
        CapacityRequirement                 TYPE C LENGTH   12   ,
        InspectionLot                       TYPE C LENGTH   12   ,
        ChangeNumber                        TYPE C LENGTH   12   ,
        MaterialRevisionLevel               TYPE C LENGTH   2    ,
        MaterialRevisionLevel_2             TYPE C LENGTH   2    ,
        BasicSchedulingType                 TYPE C LENGTH   1    ,
        ForecastSchedulingType              TYPE C LENGTH   1    ,
        ObjectInternalID                    TYPE C LENGTH   22   ,
        ProductConfiguration                TYPE C LENGTH   18   ,
        EffectivityParameterVariant         TYPE C LENGTH   12   ,
        ConditionApplication                TYPE C LENGTH   2    ,
        CapacityActiveVersion               TYPE C LENGTH   2    ,
        CapacityRqmtHasNotToBeCreated       TYPE C LENGTH   1    ,
        OrderSequenceNumber                 TYPE C LENGTH   14   ,
        MfgOrderSplitStatus                 TYPE C LENGTH   1    ,
        BillOfOperationsMaterial            TYPE C LENGTH   40   ,
        BillOfOperationsType                TYPE C LENGTH   1    ,
        BillOfOperations                    TYPE C LENGTH   8    ,
        BillOfOperationsGroup               TYPE C LENGTH   8    ,
        BillOfOperationsVariant             TYPE C LENGTH   2    ,
        BOOInternalVersionCounter           TYPE C LENGTH   8    ,
        BillOfOperationsApplication         TYPE C LENGTH   1    ,
        BillOfOperationsUsage               TYPE C LENGTH   3    ,
        BillOfOperationsVersion             TYPE C LENGTH   4    ,
        BOOExplosionDate                    TYPE C LENGTH   8    ,
        BOOValidityStartDate                TYPE C LENGTH   8    ,
        BillOfMaterialCategory              TYPE C LENGTH   1    ,
        BillOfMaterial                      TYPE C LENGTH   8    ,
        BillOfMaterialInternalID            TYPE C LENGTH   8    ,
        BillOfMaterialVariant               TYPE C LENGTH   2    ,
        BillOfMaterialVariantUsage          TYPE C LENGTH   1    ,
        BillOfMaterialVersion               TYPE C LENGTH   4    ,
        BOMExplosionDate                    TYPE C LENGTH   8    ,
        BOMValidityStartDate                TYPE C LENGTH   8    ,
        BusinessArea                        TYPE C LENGTH   4    ,
        CompanyCode                         TYPE C LENGTH   4    ,
        ControllingArea                     TYPE C LENGTH   4    ,
        ProfitCenter                        TYPE C LENGTH   10   ,
        CostCenter                          TYPE C LENGTH   10   ,
        ResponsibleCostCenter               TYPE C LENGTH   10   ,
        CostElement                         TYPE C LENGTH   10   ,
        CostingSheet                        TYPE C LENGTH   6    ,
        GLAccount                           TYPE C LENGTH   10   ,
        ProductCostCollector                TYPE C LENGTH   12   ,
        ActualCostsCostingVariant           TYPE C LENGTH   4    ,
        PlannedCostsCostingVariant          TYPE C LENGTH   4    ,
        ControllingObjectClass              TYPE C LENGTH   2    ,
        FunctionalArea                      TYPE C LENGTH   16   ,
        OrderIsEventBasedPosting            TYPE C LENGTH   1    ,
        EventBasedPostingMethod             TYPE C LENGTH   1    ,
        EventBasedProcessingKey             TYPE C LENGTH   6    ,
        SchedulingFloatProfile              TYPE C LENGTH   3    ,
        FloatBeforeProductionInWrkDays      TYPE C LENGTH   3    ,
        FloatAfterProductionInWorkDays      TYPE C LENGTH   3    ,
        ReleasePeriodInWorkDays             TYPE C LENGTH   3    ,
        ChangeToScheduledDatesIsMade        TYPE C LENGTH   1    ,
        MfgOrderPlannedStartDate            TYPE C LENGTH   8    ,
        MfgOrderPlannedStartTime            TYPE C LENGTH   6    ,
        MfgOrderPlannedEndDate              TYPE C LENGTH   8    ,
        MfgOrderPlannedEndTime              TYPE C LENGTH   6    ,
        MfgOrderPlannedReleaseDate          TYPE C LENGTH   8    ,
        MfgOrderScheduledStartDate          TYPE C LENGTH   8    ,
        MfgOrderScheduledStartTime          TYPE C LENGTH   6    ,
        MfgOrderScheduledEndDate            TYPE C LENGTH   8    ,
        MfgOrderScheduledEndTime            TYPE C LENGTH   6    ,
        MfgOrderScheduledReleaseDate        TYPE C LENGTH   8    ,
        MfgOrderActualStartDate             TYPE C LENGTH   8    ,
        MfgOrderActualStartTime             TYPE C LENGTH   6    ,
        MfgOrderConfirmedEndDate            TYPE C LENGTH   8    ,
        MfgOrderConfirmedEndTime            TYPE C LENGTH   6    ,
        MfgOrderActualEndDate               TYPE C LENGTH   8    ,
        MfgOrderActualReleaseDate           TYPE C LENGTH   8    ,
        MfgOrderTotalCommitmentDate         TYPE C LENGTH   8    ,
        MfgOrderActualCompletionDate        TYPE C LENGTH   8    ,
        MfgOrderItemActualDeliveryDate      TYPE C LENGTH   8    ,
        ProductionUnit                      TYPE C LENGTH   3    ,
        MfgOrderPlannedTotalQty             TYPE C LENGTH   13   ,
        MfgOrderPlannedScrapQty             TYPE C LENGTH   13   ,
        MfgOrderConfirmedYieldQty           TYPE C LENGTH   13   ,
        MfgOrderConfirmedScrapQty           TYPE C LENGTH   13   ,
        MfgOrderConfirmedReworkQty          TYPE C LENGTH   13   ,
        ExpectedDeviationQuantity           TYPE C LENGTH   13   ,
        ActualDeliveredQuantity             TYPE C LENGTH   13   ,
        MasterProductionOrder               TYPE C LENGTH   12   ,
        ProductSeasonYear                   TYPE C LENGTH   4    ,
        ProductSeason                       TYPE C LENGTH   10   ,
        ProductCollection                   TYPE C LENGTH   10   ,
        ProductTheme                        TYPE C LENGTH   10   ,

        "add by wang.z 20250207-----------------------------------------------------------

        BillOfMaterialStatus  type I_BillOfMaterialHeaderDEX_2-BillOfMaterialStatus,
        BOMHeaderQuantityInBaseUnit  type I_BillOfMaterialHeaderDEX_2-BOMHeaderQuantityInBaseUnit,
        BOMHeaderBaseUnit  type I_BillOfMaterialHeaderDEX_2-BOMHeaderBaseUnit,

        "end add by wang.z 20250207-------------------------------------------------------
      END OF TY_afko,

      "NO.14製造指図明細
      BEGIN OF TY_afpo,
        ManufacturingOrder                TYPE C LENGTH  12     ,
        ManufacturingOrderItem            TYPE C LENGTH  4      ,
        ManufacturingOrderCategory        TYPE C LENGTH  2      ,
        ManufacturingOrderType            TYPE C LENGTH  4      ,
        OrderIsReleased                   TYPE C LENGTH  1      ,
        IsMarkedForDeletion               TYPE C LENGTH  1      ,
        OrderItemIsNotRelevantForMRP      TYPE C LENGTH  1      ,
        Material                          TYPE C LENGTH  40     ,
        Product                           TYPE C LENGTH  40     ,
        ProductionPlant                   TYPE C LENGTH  4      ,
        PlanningPlant                     TYPE C LENGTH  4      ,
        MRPController                     TYPE C LENGTH  3       ,
        ProductionSupervisor              TYPE C LENGTH  3       ,
        Reservation                       TYPE C LENGTH  10      ,
        ProductionVersion                 TYPE C LENGTH  4       ,
        MRPArea                           TYPE C LENGTH  10      ,
        SalesOrder                        TYPE C LENGTH  10      ,
        SalesOrderItem                    TYPE C LENGTH  6       ,
        SalesOrderScheduleLine            TYPE C LENGTH  4       ,
        WBSElementInternalID              TYPE C LENGTH  8       ,
        WBSElementInternalID_2            TYPE C LENGTH  8       ,
        QuotaArrangement                  TYPE C LENGTH  10      ,
        QuotaArrangementItem              TYPE C LENGTH  3        ,
        SettlementReservation             TYPE C LENGTH  10       ,
        SettlementReservationItem         TYPE C LENGTH  4        ,
        CoProductReservation              TYPE C LENGTH  10       ,
        CoProductReservationItem          TYPE C LENGTH  4        ,
        MaterialProcurementCategory       TYPE C LENGTH  1        ,
        MaterialProcurementType           TYPE C LENGTH  1        ,
        SerialNumberAssgmtProfile         TYPE C LENGTH  4        ,
        NumberOfSerialNumbers             TYPE C LENGTH  10       ,
        MfgOrderItemReplnmtElmntType      TYPE C LENGTH  1        ,
        ProductConfiguration              TYPE C LENGTH  18       ,
        ObjectInternalID                  TYPE C LENGTH  22       ,
        ManufacturingObject               TYPE C LENGTH  22       ,
        QuantityDistributionKey           TYPE C LENGTH  4        ,
        EffectivityParameterVariant       TYPE C LENGTH  12       ,
        GoodsReceiptIsExpected            TYPE C LENGTH  1        ,
        GoodsReceiptIsNonValuated         TYPE C LENGTH  1        ,
        IsCompletelyDelivered             TYPE C LENGTH  1        ,
        MaterialGoodsReceiptDuration      TYPE C LENGTH  3        ,
        UnderdelivTolrtdLmtRatioInPct     TYPE C LENGTH  3        ,
        OverdelivTolrtdLmtRatioInPct      TYPE C LENGTH  3        ,
        UnlimitedOverdeliveryIsAllowed    TYPE C LENGTH  1        ,
        StorageLocation                   TYPE C LENGTH  4         ,
        Batch                             TYPE C LENGTH  10        ,
        InventoryValuationType            TYPE C LENGTH  10        ,
        InventoryValuationCategory        TYPE C LENGTH  1         ,
        InventoryUsabilityCode            TYPE C LENGTH  1         ,
        InventorySpecialStockType         TYPE C LENGTH  1         ,
        InventorySpecialStockValnType     TYPE C LENGTH  1         ,
        ConsumptionPosting                TYPE C LENGTH  1         ,
        GoodsRecipientName                TYPE C LENGTH  12        ,
        UnloadingPointName                TYPE C LENGTH  25        ,
        StockSegment                      TYPE C LENGTH  40        ,
        MfgOrderPlannedStartDate          TYPE C LENGTH  8        ,
        MfgOrderPlannedStartTime          TYPE C LENGTH  6        ,
        MfgOrderScheduledStartDate        TYPE C LENGTH  8        ,
        MfgOrderScheduledStartTime        TYPE C LENGTH  6        ,
        MfgOrderActualStartDate           TYPE C LENGTH  8        ,
        MfgOrderActualStartTime           TYPE C LENGTH  6        ,
        MfgOrderPlannedEndDate            TYPE C LENGTH  8        ,
        MfgOrderPlannedEndTime            TYPE C LENGTH  6        ,
        MfgOrderScheduledEndDate          TYPE C LENGTH  8        ,
        MfgOrderScheduledEndTime          TYPE C LENGTH  6        ,
        MfgOrderConfirmedEndDate          TYPE C LENGTH  8        ,
        MfgOrderConfirmedEndTime          TYPE C LENGTH  6        ,
        MfgOrderActualEndDate             TYPE C LENGTH  8        ,
        MfgOrderScheduledReleaseDate      TYPE C LENGTH  8        ,
        MfgOrderActualReleaseDate         TYPE C LENGTH  8        ,
        MfgOrderItemPlannedEndDate        TYPE C LENGTH  8        ,
        MfgOrderItemScheduledEndDate      TYPE C LENGTH  8        ,
        MfgOrderItemPlndDeliveryDate      TYPE C LENGTH  8        ,
        MfgOrderItemActualDeliveryDate    TYPE C LENGTH  8        ,
        MfgOrderItemTotalCmtmtDate        TYPE C LENGTH  8        ,
        ProductionUnit                    TYPE C LENGTH  3        ,
        MfgOrderItemPlannedTotalQty       TYPE C LENGTH  13       ,
        MfgOrderItemPlannedScrapQty       TYPE C LENGTH  13        ,
        MfgOrderItemPlannedYieldQty       TYPE C LENGTH  13        ,
        MfgOrderItemGoodsReceiptQty       TYPE C LENGTH  13        ,
        MfgOrderItemActualDeviationQty    TYPE C LENGTH  13        ,
        MfgOrderItemOpenYieldQty          TYPE C LENGTH  16        ,
        MfgOrderConfirmedYieldQty         TYPE C LENGTH  13        ,
        MfgOrderConfirmedScrapQty         TYPE C LENGTH  13        ,
        MfgOrderConfirmedReworkQty        TYPE C LENGTH  13        ,
        MfgOrderConfirmedTotalQty         TYPE C LENGTH  13        ,
        MfgOrderPlannedTotalQty           TYPE C LENGTH  13        ,
        MfgOrderPlannedScrapQty           TYPE C LENGTH  13        ,
        PlannedOrder                      TYPE C LENGTH  10       ,
        PlndOrderPlannedStartDate         TYPE C LENGTH  8        ,
        PlannedOrderOpeningDate           TYPE C LENGTH  8        ,
        BaseUnit                          TYPE C LENGTH  3        ,
        PlndOrderPlannedTotalQty          TYPE C LENGTH  13       ,
        PlndOrderPlannedScrapQty          TYPE C LENGTH  13       ,
        CompanyCode                       TYPE C LENGTH  4        ,
        BusinessArea                      TYPE C LENGTH  4        ,
        AccountAssignmentCategory         TYPE C LENGTH  1        ,
        CompanyCodeCurrency               TYPE C LENGTH  5        ,
        GoodsReceiptAmountInCoCodeCrcy    TYPE C LENGTH  13       ,
        MasterProductionOrder             TYPE C LENGTH  12        ,
        ProductSeasonYear                 TYPE C LENGTH  4         ,
        ProductSeason                     TYPE C LENGTH  10        ,
        ProductCollection                 TYPE C LENGTH  10        ,
        ProductTheme                      TYPE C LENGTH  10        ,

      END OF TY_AFPO,

      "NO.15 品質検査計画作業のバージョン
      BEGIN OF ty_PLPO,
*        InspectionPlanGroup             type c length     8     ,
*        BOOOperationInternalID          type c length     8     ,
*        BOOOpInternalVersionCounter     type c length     8     ,
*        BillOfOperationsType            type c length     1     ,
*        InspectionPlan                  type c length     2     ,
*        WorkCenterInternalID            type c length     8     ,
*        WorkCenterTypeCode              type c length     2     ,
*        IsDeleted                       type c length     1     ,
*        IsImplicitlyDeleted             type c length     1     ,
*        OperationExternalID             type c length     8     ,
*        Operation                       type c length     4     ,
*        OperationText                   type c length     40    ,
*        Plant                           type c length     4     ,
*        OperationControlProfile         type c length     4     ,
*        OperationStandardTextCode       type c length     7     ,
*        BillOfOperationsRefType         type c length     1     ,
*        BillOfOperationsRefGroup        type c length     8     ,
*        BillOfOperationsRefVariant      type c length     2     ,
*        BOORefOperationIncrementValue   type c length     3     ,
*        InspSbstCompletionConfirmation  type c length     1     ,
*        InspSbstHasNoTimeOrQuantity     type c length     1     ,
*        OperationReferenceQuantity      type c length     13    ,
*        OperationUnit                   type c length     3     ,
*        OpQtyToBaseQtyDnmntr            type c length     5     ,
*        OpQtyToBaseQtyNmrtr             type c length     5     ,
*        CreationDate                    type c length     8     ,
*        CreatedByUser                   type c length     12    ,
*        LastChangeDate                  type c length     8     ,
*        LastChangedByUser               type c length     12    ,
*        ChangeNumber                    type c length     12    ,
*        ValidityStartDate               type c length     8     ,
*        ValidityEndDate                 type c length     8     ,
"change by wang.z 20250207----------------------------------------------------------------
        BillOfOperationsType type I_MfgBOOOperationChangeState-BillOfOperationsType,
        BillOfOperationsGroup type I_MfgBOOOperationChangeState-BillOfOperationsGroup,
        BillOfOperationsVariant type I_MfgBOOOperationChangeState-BillOfOperationsVariant,
        BillOfOperationsSequence type I_MfgBOOOperationChangeState-BillOfOperationsSequence,
        BOOOperationInternalID type I_MfgBOOOperationChangeState-BOOOperationInternalID,
        BOOSqncOpAssgmtIntVersionCntr type I_MfgBOOOperationChangeState-BOOSqncOpAssgmtIntVersionCntr,
        BOOOpInternalVersionCounter type I_MfgBOOOperationChangeState-BOOOpInternalVersionCounter,
        OperationExternalID type I_MfgBOOOperationChangeState-OperationExternalID,
        Operation type I_MfgBOOOperationChangeState-Operation,
        Operation_2 type I_MfgBOOOperationChangeState-Operation_2,
        CreationDate type I_MfgBOOOperationChangeState-CreationDate,
        CreatedByUser type I_MfgBOOOperationChangeState-CreatedByUser,
        LastChangeDate type I_MfgBOOOperationChangeState-LastChangeDate,
        LastChangedByUser type I_MfgBOOOperationChangeState-LastChangedByUser,
        ChangeNumber type I_MfgBOOOperationChangeState-ChangeNumber,
        ValidityStartDate type I_MfgBOOOperationChangeState-ValidityStartDate,
        ValidityEndDate type I_MfgBOOOperationChangeState-ValidityEndDate,
        IsDeleted type I_MfgBOOOperationChangeState-IsDeleted,
        IsImplicitlyDeleted type I_MfgBOOOperationChangeState-IsImplicitlyDeleted,
        OperationText type I_MfgBOOOperationChangeState-OperationText,
        LongTextLanguageCode type I_MfgBOOOperationChangeState-LongTextLanguageCode,
        Plant type I_MfgBOOOperationChangeState-Plant,
        OperationControlProfile type I_MfgBOOOperationChangeState-OperationControlProfile,
        OperationStandardTextCode type I_MfgBOOOperationChangeState-OperationStandardTextCode,
        WorkCenterInternalID type I_MfgBOOOperationChangeState-WorkCenterInternalID,
        WorkCenterTypeCode type I_MfgBOOOperationChangeState-WorkCenterTypeCode,
        FactoryCalendar type I_MfgBOOOperationChangeState-FactoryCalendar,
        CapacityCategoryCode type I_MfgBOOOperationChangeState-CapacityCategoryCode,
        CostElement type I_MfgBOOOperationChangeState-CostElement,
        CompanyCode type I_MfgBOOOperationChangeState-CompanyCode,
        OperationCostingRelevancyType type I_MfgBOOOperationChangeState-OperationCostingRelevancyType,
        NumberOfTimeTickets type I_MfgBOOOperationChangeState-NumberOfTimeTickets,
        NumberOfConfirmationSlips type I_MfgBOOOperationChangeState-NumberOfConfirmationSlips,
        EmployeeWageGroup type I_MfgBOOOperationChangeState-EmployeeWageGroup,
        EmployeeWageType type I_MfgBOOOperationChangeState-EmployeeWageType,
        EmployeeSuitability type I_MfgBOOOperationChangeState-EmployeeSuitability,
        NumberOfEmployees type I_MfgBOOOperationChangeState-NumberOfEmployees,
        BillOfOperationsRefType type I_MfgBOOOperationChangeState-BillOfOperationsRefType,
        BillOfOperationsRefGroup type I_MfgBOOOperationChangeState-BillOfOperationsRefGroup,
        BillOfOperationsRefVariant type I_MfgBOOOperationChangeState-BillOfOperationsRefVariant,
        LineSegmentTakt type I_MfgBOOOperationChangeState-LineSegmentTakt,
        OperationStdWorkQtyGrpgCat type I_MfgBOOOperationChangeState-OperationStdWorkQtyGrpgCat,
        OrderHasNoSubOperations type I_MfgBOOOperationChangeState-OrderHasNoSubOperations,
        OperationSetupType type I_MfgBOOOperationChangeState-OperationSetupType,
        OperationSetupGroupCategory type I_MfgBOOOperationChangeState-OperationSetupGroupCategory,
        OperationSetupGroup type I_MfgBOOOperationChangeState-OperationSetupGroup,
        BOOOperationIsPhase type I_MfgBOOOperationChangeState-BOOOperationIsPhase,
        BOOPhaseSuperiorOpInternalID type I_MfgBOOOperationChangeState-BOOPhaseSuperiorOpInternalID,
        ControlRecipeDestination type I_MfgBOOOperationChangeState-ControlRecipeDestination,
        OpIsExtlyProcdWithSubcontrg type I_MfgBOOOperationChangeState-OpIsExtlyProcdWithSubcontrg,
        PurchasingInfoRecord type I_MfgBOOOperationChangeState-PurchasingInfoRecord,
        PurchasingOrganization type I_MfgBOOOperationChangeState-PurchasingOrganization,
        PurchaseContract type I_MfgBOOOperationChangeState-PurchaseContract,
        PurchaseContractItem type I_MfgBOOOperationChangeState-PurchaseContractItem,
        PurchasingInfoRecdAddlGrpgName type I_MfgBOOOperationChangeState-PurchasingInfoRecdAddlGrpgName,
        MaterialGroup type I_MfgBOOOperationChangeState-MaterialGroup,
        PurchasingGroup type I_MfgBOOOperationChangeState-PurchasingGroup,
        Supplier type I_MfgBOOOperationChangeState-Supplier,
        PlannedDeliveryDuration type I_MfgBOOOperationChangeState-PlannedDeliveryDuration,
        NumberOfOperationPriceUnits type I_MfgBOOOperationChangeState-NumberOfOperationPriceUnits,
        OpExternalProcessingCurrency type I_MfgBOOOperationChangeState-OpExternalProcessingCurrency,
        OpExternalProcessingPrice type I_MfgBOOOperationChangeState-OpExternalProcessingPrice,
        InspectionLotType type I_MfgBOOOperationChangeState-InspectionLotType,
        InspResultRecordingView type I_MfgBOOOperationChangeState-InspResultRecordingView,
        InspSbstCompletionConfirmation type I_MfgBOOOperationChangeState-InspSbstCompletionConfirmation,
        InspSbstHasNoTimeOrQuantity type I_MfgBOOOperationChangeState-InspSbstHasNoTimeOrQuantity,
        OperationReferenceQuantity type I_MfgBOOOperationChangeState-OperationReferenceQuantity,
        OperationUnit type I_MfgBOOOperationChangeState-OperationUnit,
        OperationScrapPercent type I_MfgBOOOperationChangeState-OperationScrapPercent,
        OpQtyToBaseQtyNmrtr type I_MfgBOOOperationChangeState-OpQtyToBaseQtyNmrtr,
        OpQtyToBaseQtyDnmntr type I_MfgBOOOperationChangeState-OpQtyToBaseQtyDnmntr,
        StandardWorkFormulaParam1 type I_MfgBOOOperationChangeState-StandardWorkFormulaParam1,
        StandardWorkQuantity1 type I_MfgBOOOperationChangeState-StandardWorkQuantity1,
        StandardWorkQuantityUnit1 type I_MfgBOOOperationChangeState-StandardWorkQuantityUnit1,
        CostCtrActivityType1 type I_MfgBOOOperationChangeState-CostCtrActivityType1,
        PerfEfficiencyRatioCode1 type I_MfgBOOOperationChangeState-PerfEfficiencyRatioCode1,
        StandardWorkFormulaParam2 type I_MfgBOOOperationChangeState-StandardWorkFormulaParam2,
        StandardWorkQuantity2 type I_MfgBOOOperationChangeState-StandardWorkQuantity2,
        StandardWorkQuantityUnit2 type I_MfgBOOOperationChangeState-StandardWorkQuantityUnit2,
        CostCtrActivityType2 type I_MfgBOOOperationChangeState-CostCtrActivityType2,
        PerfEfficiencyRatioCode2 type I_MfgBOOOperationChangeState-PerfEfficiencyRatioCode2,
        StandardWorkFormulaParam3 type I_MfgBOOOperationChangeState-StandardWorkFormulaParam3,
        StandardWorkQuantity3 type I_MfgBOOOperationChangeState-StandardWorkQuantity3,
        StandardWorkQuantityUnit3 type I_MfgBOOOperationChangeState-StandardWorkQuantityUnit3,
        CostCtrActivityType3 type I_MfgBOOOperationChangeState-CostCtrActivityType3,
        PerfEfficiencyRatioCode3 type I_MfgBOOOperationChangeState-PerfEfficiencyRatioCode3,
        StandardWorkFormulaParam4 type I_MfgBOOOperationChangeState-StandardWorkFormulaParam4,
        StandardWorkQuantity4 type I_MfgBOOOperationChangeState-StandardWorkQuantity4,
        StandardWorkQuantityUnit4 type I_MfgBOOOperationChangeState-StandardWorkQuantityUnit4,
        CostCtrActivityType4 type I_MfgBOOOperationChangeState-CostCtrActivityType4,
        PerfEfficiencyRatioCode4 type I_MfgBOOOperationChangeState-PerfEfficiencyRatioCode4,
        StandardWorkFormulaParam5 type I_MfgBOOOperationChangeState-StandardWorkFormulaParam5,
        StandardWorkQuantity5 type I_MfgBOOOperationChangeState-StandardWorkQuantity5,
        StandardWorkQuantityUnit5 type I_MfgBOOOperationChangeState-StandardWorkQuantityUnit5,
        CostCtrActivityType5 type I_MfgBOOOperationChangeState-CostCtrActivityType5,
        PerfEfficiencyRatioCode5 type I_MfgBOOOperationChangeState-PerfEfficiencyRatioCode5,
        StandardWorkFormulaParam6 type I_MfgBOOOperationChangeState-StandardWorkFormulaParam6,
        StandardWorkQuantity6 type I_MfgBOOOperationChangeState-StandardWorkQuantity6,
        StandardWorkQuantityUnit6 type I_MfgBOOOperationChangeState-StandardWorkQuantityUnit6,
        CostCtrActivityType6 type I_MfgBOOOperationChangeState-CostCtrActivityType6,
        PerfEfficiencyRatioCode6 type I_MfgBOOOperationChangeState-PerfEfficiencyRatioCode6,
        BusinessProcess type I_MfgBOOOperationChangeState-BusinessProcess,
        LeadTimeReductionStrategy type I_MfgBOOOperationChangeState-LeadTimeReductionStrategy,
        TeardownAndWaitIsParallel type I_MfgBOOOperationChangeState-TeardownAndWaitIsParallel,
        BillOfOperationsBreakDuration type I_MfgBOOOperationChangeState-BillOfOperationsBreakDuration,
        BreakDurationUnit type I_MfgBOOOperationChangeState-BreakDurationUnit,
        MaximumWaitDuration type I_MfgBOOOperationChangeState-MaximumWaitDuration,
        MaximumWaitDurationUnit type I_MfgBOOOperationChangeState-MaximumWaitDurationUnit,
        MinimumWaitDuration type I_MfgBOOOperationChangeState-MinimumWaitDuration,
        MinimumWaitDurationUnit type I_MfgBOOOperationChangeState-MinimumWaitDurationUnit,
        StandardQueueDuration type I_MfgBOOOperationChangeState-StandardQueueDuration,
        StandardQueueDurationUnit type I_MfgBOOOperationChangeState-StandardQueueDurationUnit,
        MinimumQueueDuration type I_MfgBOOOperationChangeState-MinimumQueueDuration,
        MinimumQueueDurationUnit type I_MfgBOOOperationChangeState-MinimumQueueDurationUnit,
        StandardMoveDuration type I_MfgBOOOperationChangeState-StandardMoveDuration,
        StandardMoveDurationUnit type I_MfgBOOOperationChangeState-StandardMoveDurationUnit,
        MinimumMoveDuration type I_MfgBOOOperationChangeState-MinimumMoveDuration,
        MinimumMoveDurationUnit type I_MfgBOOOperationChangeState-MinimumMoveDurationUnit,
        OperationSplitIsRequired type I_MfgBOOOperationChangeState-OperationSplitIsRequired,
        MaximumNumberOfSplits type I_MfgBOOOperationChangeState-MaximumNumberOfSplits,
        MinProcessingDurationPerSplit type I_MfgBOOOperationChangeState-MinProcessingDurationPerSplit,
        MinProcessingDurnPerSplitUnit type I_MfgBOOOperationChangeState-MinProcessingDurnPerSplitUnit,
        OperationOverlappingIsRequired type I_MfgBOOOperationChangeState-OperationOverlappingIsRequired,
        OperationOverlappingIsPossible type I_MfgBOOOperationChangeState-OperationOverlappingIsPossible,
        OperationsIsAlwaysOverlapping type I_MfgBOOOperationChangeState-OperationsIsAlwaysOverlapping,
        OperationHasNoOverlapping type I_MfgBOOOperationChangeState-OperationHasNoOverlapping,
        OverlapMinimumDuration type I_MfgBOOOperationChangeState-OverlapMinimumDuration,
        OverlapMinimumDurationUnit type I_MfgBOOOperationChangeState-OverlapMinimumDurationUnit,
        OverlapMinimumTransferQty type I_MfgBOOOperationChangeState-OverlapMinimumTransferQty,
        OverlapMinimumTransferQtyUnit type I_MfgBOOOperationChangeState-OverlapMinimumTransferQtyUnit,
"end change by wang.z 20250207----------------------------------------------------
      END OF TY_PLPO,

      "NO.16 入出庫予定伝票明細
      BEGIN OF ty_RESB,
        Reservation                        type c length   10 ,
        ReservationItem                    type c length   4 ,
        RecordType                         type c length   1 ,
        MaterialGroup                      type c length   9 ,
        Material                           type c length   40 ,
        Plant                              type c length   4 ,
        ManufacturingOrderCategory         type c length   2 ,
        ManufacturingOrderType             type c length   4 ,
        ManufacturingOrder                 type c length   12 ,
        ManufacturingOrderSequence         type c length   6 ,
        MfgOrderSequenceCategory           type c length   1 ,
        ManufacturingOrderOperation        type c length   4 ,
        ManufacturingOrderOperation_2      type c length   4 ,
        ProductionPlant                    type c length   4 ,
        OrderInternalBillOfOperations      type c length   10 ,
        OrderIntBillOfOperationsItem       type c length   8 ,
        AssemblyMRPController              type c length   3 ,
        ProductionSupervisor               type c length   3 ,
        OrderObjectInternalID              type c length   22 ,
        MatlCompRequirementDate            type c length   8 ,
        MatlCompRequirementTime            type c length   6 ,
        LatestRequirementDate              type c length   8 ,
        MfgOrderActualReleaseDate          type c length   8 ,
        ReservationItemCreationCode        type c length   1 ,
        ReservationIsFinallyIssued         type c length   1 ,
        MatlCompIsMarkedForDeletion        type c length   1 ,
        MaterialComponentIsMissing         type c length   1 ,
        IsBulkMaterialComponent            type c length   1 ,
        MatlCompIsMarkedForBackflush       type c length   1 ,
        MatlCompIsTextItem                 type c length   1 ,
        MaterialPlanningRelevance          type c length   1 ,
        MatlCompIsConfigurable             type c length   1 ,
        MaterialComponentIsClassified      type c length   1 ,
        MaterialCompIsIntraMaterial        type c length   1 ,
        MaterialIsDirectlyProduced         type c length   1 ,
        MaterialIsDirectlyProcured         type c length   1 ,
        LongTextLanguageCode               type c length   1 ,
        LongTextExists                     type c length   1 ,
        RequirementType                    type c length   2 ,
        SalesOrder                         type c length   10 ,
        SalesOrderItem                     type c length   6 ,
        WBSElementInternalID               type c length   8 ,
        WBSElementInternalID_2             type c length   8 ,
        ProductConfiguration               type c length   18 ,
        ChangeNumber                       type c length   12 ,
        MaterialRevisionLevel              type c length   2 ,
        EffectivityParameterVariant        type c length   12 ,
        SortField                          type c length   10 ,
        MaterialComponentSortText          type c length   10 ,
        ObjectInternalID                   type c length   22 ,
        BillOfMaterialCategory             type c length   1 ,
        BillOfMaterialInternalID           type c length   8 ,
        BillOfMaterialInternalID_2         type c length   8 ,
        BillOfMaterialVariantUsage         type c length   1 ,
        BillOfMaterialVariant              type c length   2 ,
        BillOfMaterial                     type c length   8 ,
        BOMItem                            type c length   8 ,
        BillOfMaterialVersion              type c length   4 ,
        BOMItemInternalChangeCount         type c length   8 ,
        InheritedBOMItemNode               type c length   8 ,
        BOMItemCategory                    type c length   1 ,
        BillOfMaterialItemNumber           type c length   4 ,
        BillOfMaterialItemNumber_2         type c length   4 ,
        BOMItemDescription                 type c length   40 ,
        BOMItemText2                       type c length   40 ,
        BOMExplosionDateID                 type c length   8 ,
        PurchasingInfoRecord               type c length   10 ,
        PurchasingGroup                    type c length   3 ,
        PurchaseRequisition                type c length   10 ,
        PurchaseRequisitionItem            type c length   5 ,
        PurchaseOrder                      type c length   10 ,
        PurchaseOrderItem                  type c length   5 ,
        PurchaseOrderScheduleLine          type c length   4 ,
        Supplier                           type c length   10 ,
        DeliveryDurationInDays             type c length   3 ,
        MaterialGoodsReceiptDuration       type c length   3 ,
        ExternalProcessingPrice            type c length   15 ,
        NumberOfOperationPriceUnits        type c length   5 ,
        GoodsMovementIsAllowed             type c length   1 ,
        StorageLocation                    type c length   4 ,
        DebitCreditCode                    type c length   1 ,
        GoodsMovementType                  type c length   3 ,
        InventorySpecialStockType          type c length   1 ,
        InventorySpecialStockValnType      type c length   1 ,
        ConsumptionPosting                 type c length   1 ,
        SupplyArea                         type c length   10 ,
        GoodsRecipientName                 type c length   12 ,
        UnloadingPointName                 type c length   25 ,
        StockSegment                       type c length   40 ,
        RequirementSegment                 type c length   40 ,
        Batch                              type c length   10 ,
        BatchEntryDeterminationCode        type c length   1 ,
        BatchSplitType                     type c length   1 ,
        BatchMasterReservationItem         type c length   4 ,
        BatchClassification                type c length   18 ,
        MaterialStaging                    type c length   1 ,
        Warehouse                          type c length   3 ,
        StorageType                        type c length   3 ,
        StorageBin                         type c length   10 ,
        MaterialCompIsCostRelevant         type c length   1 ,
        BusinessArea                       type c length   4 ,
        CompanyCode                        type c length   4 ,
        GLAccount                          type c length   10 ,
        FunctionalArea                     type c length   16 ,
        ControllingArea                    type c length   4 ,
        AccountAssignmentCategory          type c length   1 ,
        CommitmentItem                     type c length   14 ,
        CommitmentItemShortID              type c length   14 ,
        FundsCenter                        type c length   16 ,
        MaterialCompIsVariableSized        type c length   1 ,
        NumberOfVariableSizeComponents     type c length   13 ,
        VariableSizeItemUnit               type c length   3 ,
        VariableSizeItemQuantity           type c length   13 ,
        VariableSizeComponentUnit          type c length   3 ,
        VariableSizeComponentQuantity      type c length   13 ,
        VariableSizeDimensionUnit          type c length   3 ,
        VariableSizeDimension1             type c length   13 ,
        VariableSizeDimension2             type c length   13 ,
        VariableSizeDimension3             type c length   13 ,
        FormulaKey                         type c length   2 ,
        MaterialCompIsAlternativeItem      type c length   1 ,
        AlternativeItemGroup               type c length   2 ,
        AlternativeItemStrategy            type c length   1 ,
        AlternativeItemPriority            type c length   2 ,
        UsageProbabilityPercent            type c length   3 ,
        AlternativeMstrReservationItem     type c length   4 ,
        MaterialComponentIsPhantomItem     type c length   1 ,
        OrderPathValue                     type c length   2 ,
        OrderLevelValue                    type c length   2 ,
        Assembly                           type c length   40 ,
        AssemblyOrderPathValue             type c length   2 ,
        AssemblyOrderLevelValue            type c length   2 ,
        DiscontinuationGroup               type c length   2 ,
        MatlCompDiscontinuationType        type c length   1 ,
        MatlCompIsFollowUpMaterial         type c length   1 ,
        FollowUpGroup                      type c length   2 ,
        FollowUpMaterial                   type c length   40 ,
        FollowUpMaterialIsNotActive        type c length   1 ,
        FollowUpMaterialIsActive           type c length   1 ,
        DiscontinuationMasterResvnItem     type c length   4 ,
        MaterialProvisionType              type c length   1 ,
        MatlComponentSparePartType         type c length   1 ,
        LeadTimeOffset                     type c length   3 ,
        OperationLeadTimeOffsetUnit        type c length   3 ,
        OperationLeadTimeOffset            type c length   3 ,
        QuantityIsFixed                    type c length   1 ,
        IsNetScrap                         type c length   1 ,
        ComponentScrapInPercent            type c length   5 ,
        OperationScrapInPercent            type c length   5 ,
        MaterialQtyToBaseQtyNmrtr          type c length   5 ,
        MaterialQtyToBaseQtyDnmntr         type c length   5 ,
        BaseUnit                           type c length   3 ,
        RequiredQuantity                   type c length   13 ,
        WithdrawnQuantity                  type c length   13 ,
        ConfirmedAvailableQuantity         type c length   15 ,
        MaterialCompOriginalQuantity       type c length   13 ,
        EntryUnit                          type c length   3 ,
        GoodsMovementEntryQty              type c length   13 ,
        Currency                           type c length   5 ,
        WithdrawnQuantityAmount            type c length   13 ,
        CriticalComponentType              type c length   1 ,
        CriticalComponentLevel             type c length   2 ,

        "add by wang.z 20250207

        PlannedOrder type I_ManufacturingOrderItem-PlannedOrder,

        "end add by wang.z 20250207

      END OF TY_RESB,

      "N0.17 指図内作業.
      begin of ty_afvc,
        MfgOrderInternalID                 type c length 10  ,
        OrderOperationInternalID           type c length 8   ,
        ManufacturingOrder                 type c length 12  ,
        ManufacturingOrderSequence         type c length 6   ,
        ManufacturingOrderOperation        type c length 4   ,
        ManufacturingOrderOperation_2      type c length 4   ,
        ManufacturingOrderSubOperation     type c length 4   ,
        ManufacturingOrdSubOperation_2     type c length 4   ,
        MfgOrderOperationOrSubOp           type c length 4   ,
        MfgOrderOperationOrSubOp_2         type c length 4   ,
        MfgOrderOperationIsPhase           type c length 1   ,
        OrderIntBillOfOpItemOfPhase        type c length 8   ,
        MfgOrderPhaseSuperiorOperation     type c length 4   ,
        SuperiorOperation_2                type c length 4   ,
        ManufacturingOrderCategory         type c length 2   ,
        ManufacturingOrderType             type c length 4   ,
        ProductionSupervisor               type c length 3   ,
        MRPController                      type c length 3   ,
        ResponsiblePlannerGroup            type c length 3   ,
        ProductConfiguration               type c length 18  ,
        InspectionLot                      type c length 12  ,
        ManufacturingOrderImportance       type c length 1   ,
        MfgOrderOperationText              type c length 40  ,
        OperationStandardTextCode          type c length 7   ,
        OperationHasLongText               type c length 1   ,
        Language                           type c length 1   ,
        OperationIsToBeDeleted             type c length 1   ,
        NumberOfCapacities                 type c length 3   ,
        NumberOfConfirmationSlips          type c length 3   ,
        OperationImportance                type c length 1   ,
        SuperiorOperationInternalID        type c length 8   ,
        Plant                              type c length 4   ,
        WorkCenterInternalID               type c length 8   ,
        WorkCenterTypeCode                 type c length 1   ,

        WorkCenterTypeCode_2               type c length 2   ,
        OperationControlProfile            type c length 4   ,
        ControlRecipeDestination           type c length 2   ,
        OperationConfirmation              type c length 10  ,
        NumberOfOperationConfirmations     type c length 8   ,
        FactoryCalendar                    type c length 2   ,
        CapacityRequirement                type c length 12  ,
        CapacityRequirementItem            type c length 8   ,
        ChangeNumber                       type c length 12  ,
        ObjectInternalID                   type c length 22  ,
        OperationTrackingNumber            type c length 10  ,
        BillOfOperationsType               type c length 1   ,
        BillOfOperationsGroup              type c length 8   ,
        BillOfOperationsVariant            type c length 2   ,
        BillOfOperationsSequence           type c length 6   ,
        BOOOperationInternalID             type c length 8   ,
        BillOfOperationsVersion            type c length 4   ,
        BillOfMaterialCategory             type c length 1   ,
        BillOfMaterialInternalID           type c length 8   ,
        BillOfMaterialInternalID_2         type c length 8   ,
        BillOfMaterialItemNodeNumber       type c length 8   ,
        BOMItemNodeCount                   type c length 8   ,
        ExtProcgOperationHasSubcontrg      type c length 1   ,
        PurchasingOrganization             type c length 4   ,
        PurchasingGroup                    type c length 3   ,
        PurchaseRequisition                type c length 10  ,
        PurchaseRequisitionItem            type c length 5   ,
        PurchaseOrder                      type c length 10  ,
        PurchaseOrderItem                  type c length 5   ,
        PurchasingInfoRecord               type c length 10  ,
        PurgInfoRecdDataIsFixed            type c length 1  ,
        PurchasingInfoRecordCategory       type c length 1  ,
        Supplier                           type c length 10 ,
        GoodsRecipientName                 type c length 12 ,
        UnloadingPointName                 type c length 25 ,
        MaterialGroup                      type c length 9  ,
        OpExternalProcessingCurrency       type c length 5  ,
        OpExternalProcessingPrice          type c length 11 ,
        NumberOfOperationPriceUnits        type c length 5  ,
        CompanyCode                        type c length 4  ,
        BusinessArea                       type c length 4  ,
        ControllingArea                    type c length 4  ,

        ProfitCenter                       type c length 10 ,
        RequestingCostCenter               type c length 10 ,
        CostElement                        type c length 10 ,
        CostingVariant                     type c length 4  ,
        CostingSheet                       type c length 6 ,
        CostEstimate                       type c length 12,
        ControllingObjectCurrency          type c length 5 ,
        ControllingObjectClass             type c length 2 ,
        FunctionalArea                     type c length 16,
        TaxJurisdiction                    type c length 15,
        EmployeeWageType                   type c length 4 ,
        EmployeeWageGroup                  type c length 3 ,
        EmployeeSuitability                type c length 2 ,
        NumberOfTimeTickets                type c length 3 ,
        Personnel                          type c length 8 ,
        NumberOfEmployees                  type c length 5 ,
        OperationSetupGroupCategory        type c length 10,
        OperationSetupGroup                type c length 10,
        OperationSetupType                 type c length 2 ,
        OperationOverlappingIsRequired     type c length 1 ,
        OperationOverlappingIsPossible     type c length 1 ,
        OperationsIsAlwaysOverlapping      type c length 1 ,
        OperationSplitIsRequired           type c length 1 ,
        MaximumNumberOfSplits              type c length 3 ,
        LeadTimeReductionStrategy          type c length 2 ,
        OpSchedldReductionLevel            type c length 1 ,
        OpErlstSchedldExecStrtDte          type c length 8 ,
        OpErlstSchedldExecStrtTme          type c length 6 ,
        OpErlstSchedldProcgStrtDte         type c length 8 ,
        OpErlstSchedldProcgStrtTme         type c length 6 ,
        OpErlstSchedldTrdwnStrtDte         type c length 8 ,
        OpErlstSchedldTrdwnStrtTme         type c length 6 ,
        OpErlstSchedldExecEndDte           type c length 8 ,
        OpErlstSchedldExecEndTme           type c length 6 ,
        OpLtstSchedldExecStrtDte           type c length 8 ,
        OpLtstSchedldExecStrtTme           type c length 6 ,
        OpLtstSchedldProcgStrtDte          type c length 8 ,
        OpLtstSchedldProcgStrtTme          type c length 6 ,
        OpLtstSchedldTrdwnStrtDte          type c length 8 ,

        OpLtstSchedldTrdwnStrtTme         type c length 6 ,
        OpLtstSchedldExecEndDte           type c length 8 ,
        OpLtstSchedldExecEndTme           type c length 6 ,
        SchedldFcstdEarliestStartDate     type c length 8 ,
        SchedldFcstdEarliestStartTime     type c length 6 ,
        SchedldFcstdEarliestEndDate       type c length 8 ,
        SchedldFcstdEarliestEndTime       type c length 6 ,
        LatestSchedldFcstdStartDate       type c length 8 ,
        SchedldFcstdLatestStartTime       type c length 6 ,
        LatestSchedldFcstdEndDate         type c length 8 ,
        SchedldFcstdLatestEndTime         type c length 6 ,
        OperationConfirmedStartDate       type c length 8 ,
        OperationConfirmedEndDate         type c length 8 ,
        OpActualExecutionStartDate        type c length 8 ,
        OpActualExecutionStartTime        type c length 6 ,
        OpActualSetupEndDate              type c length 8 ,
        OpActualSetupEndTime              type c length 6 ,
        OpActualProcessingStartDate       type c length 8 ,
        OpActualProcessingStartTime       type c length 6 ,
        OpActualProcessingEndDate         type c length 8 ,
        OpActualProcessingEndTime         type c length 6 ,
        OpActualTeardownStartDate         type c length 8 ,
        OpActualTeardownStartTme          type c length 6 ,
        OpActualExecutionEndDate          type c length 8 ,
        OpActualExecutionEndTime          type c length 6 ,
        ActualForecastEndDate             type c length 8 ,
        ActualForecastEndTime             type c length 6 ,
        EarliestScheduledWaitStartDate    type c length 8 ,
        EarliestScheduledWaitStartTime    type c length 6 ,
        EarliestScheduledWaitEndDate      type c length 8 ,
        EarliestScheduledWaitEndTime      type c length 6 ,
        LatestScheduledWaitStartDate      type c length 8 ,
        LatestScheduledWaitStartTime      type c length 6 ,
        LatestScheduledWaitEndDate        type c length 8 ,
        LatestScheduledWaitEndTime        type c length 6 ,
        BreakDurationUnit                 type c length 3 ,
        PlannedBreakDuration              type c length 9 ,
        ConfirmedBreakDuration            type c length 9 ,
        OverlapMinimumDurationUnit        type c length 3 ,
        OverlapMinimumDuration            type c length 9 ,
        MaximumWaitDurationUnit           type c length 3 ,
        MaximumWaitDuration               type c length 9 ,
        MinimumWaitDurationUnit           type c length 3 ,
        MinimumWaitDuration               type c length 9 ,
        StandardMoveDurationUnit          type c length 3 ,
        StandardMoveDuration              type c length 9 ,
        StandardQueueDurationUnit         type c length 3 ,

        StandardQueueDuration              type c length 9 ,
        MinimumQueueDurationUnit           type c length 3 ,
        MinimumQueueDuration               type c length 9 ,
        MinimumMoveDurationUnit            type c length 3 ,
        MinimumMoveDuration                type c length 9 ,
        OperationStandardDuration          type c length 5 ,
        OperationStandardDurationUnit      type c length 3 ,
        MinimumDuration                    type c length 5 ,
        MinimumDurationUnit                type c length 3 ,
        MinimumProcessingDuration          type c length 9 ,
        MinimumProcessingDurationUnit      type c length 3 ,
        ScheduledMoveDuration              type c length 16 ,
        ScheduledMoveDurationUnit          type c length 3 ,
        ScheduledQueueDuration             type c length 16 ,
        ScheduledQueueDurationUnit         type c length 3 ,
        ScheduledWaitDuration              type c length 16 ,
        ScheduledWaitDurationUnit          type c length 3 ,
        PlannedDeliveryDuration            type c length 3 ,
        OpPlannedSetupDurn                 type c length 16 ,
        OpPlannedSetupDurnUnit             type c length 3 ,
        OpPlannedProcessingDurn            type c length 16 ,
        OpPlannedProcessingDurnUnit        type c length 3 ,
        OpPlannedTeardownDurn              type c length 16 ,
        OpPlannedTeardownDurnUnit          type c length 3 ,
        ActualForecastDuration             type c length 5 ,
        ActualForecastDurationUnit         type c length 3 ,
        ForecastProcessingDuration         type c length 16 ,
        ForecastProcessingDurationUnit     type c length 3 ,
        StartDateOffsetReferenceCode       type c length 2 ,
        StartDateOffsetDurationUnit        type c length 3  ,
        StartDateOffsetDuration            type c length 5  ,
        EndDateOffsetReferenceCode         type c length 2  ,
        EndDateOffsetDurationUnit          type c length 3  ,
        EndDateOffsetDuration              type c length 5  ,
        StandardWorkFormulaParamGroup      type c length 4  ,
        OperationUnit                      type c length 3  ,
        OpQtyToBaseQtyDnmntr               type c length 5  ,
        OpQtyToBaseQtyNmrtr                type c length 5  ,
        OperationScrapPercent              type c length 5  ,
        OperationReferenceQuantity         type c length 13 ,
        OpPlannedTotalQuantity             type c length 13 ,
        OpPlannedScrapQuantity             type c length 13 ,
        OpPlannedYieldQuantity             type c length 14 ,
        OpTotalConfirmedYieldQty           type c length 13 ,

        OpTotalConfirmedScrapQty           type c length 13 ,
        OperationConfirmedReworkQty        type c length 13 ,
        ProductionUnit                     type c length 3  ,
        OpTotConfdYieldQtyInOrdQtyUnit     type c length 13 ,
        OpWorkQuantityUnit1                type c length 3  ,
        OpConfirmedWorkQuantity1           type c length 13 ,
        NoFurtherOpWorkQuantity1IsExpd     type c length 1  ,
        OpWorkQuantityUnit2                type c length 3  ,
        OpConfirmedWorkQuantity2           type c length 13 ,
        NoFurtherOpWorkQuantity2IsExpd     type c length 1  ,
        OpWorkQuantityUnit3                type c length 3  ,
        OpConfirmedWorkQuantity3           type c length 13 ,
        NoFurtherOpWorkQuantity3IsExpd     type c length 1  ,
        OpWorkQuantityUnit4                type c length 3  ,
        OpConfirmedWorkQuantity4           type c length 13 ,
        NoFurtherOpWorkQuantity4IsExpd     type c length 1  ,
        OpWorkQuantityUnit5                type c length 3  ,
        OpConfirmedWorkQuantity5           type c length 13 ,
        NoFurtherOpWorkQuantity5IsExpd     type c length 1  ,
        OpWorkQuantityUnit6                type c length 3  ,
        OpConfirmedWorkQuantity6           type c length 13 ,
        NoFurtherOpWorkQuantity6IsExpd     type c length 1  ,
        WorkCenterStandardWorkQtyUnit1     type c length 3  ,
        WorkCenterStandardWorkQty1         type c length 9  ,
        CostCtrActivityType1               type c length 6  ,
        WorkCenterStandardWorkQtyUnit2     type c length 3  ,
        WorkCenterStandardWorkQty2         type c length 9  ,
        CostCtrActivityType2               type c length 6  ,
        WorkCenterStandardWorkQtyUnit3     type c length 3  ,
        WorkCenterStandardWorkQty3         type c length 9  ,
        CostCtrActivityType3               type c length 6  ,
        WorkCenterStandardWorkQtyUnit4     type c length 3  ,
        WorkCenterStandardWorkQty4         type c length 9  ,
        CostCtrActivityType4               type c length 6  ,
        WorkCenterStandardWorkQtyUnit5     type c length 3  ,
        WorkCenterStandardWorkQty5         type c length 9  ,
        CostCtrActivityType5               type c length 6  ,
        WorkCenterStandardWorkQtyUnit6     type c length 3  ,
        WorkCenterStandardWorkQty6         type c length 9  ,
        CostCtrActivityType6               type c length 6  ,
        ForecastWorkQuantity1              type c length 9  ,
        ForecastWorkQuantity2              type c length 9  ,
        ForecastWorkQuantity3              type c length 9  ,
        ForecastWorkQuantity4              type c length 9  ,
        ForecastWorkQuantity5              type c length 9  ,
        ForecastWorkQuantity6              type c length 9  ,

        BusinessProcess                    type c length 12 ,
        BusinessProcessEntryUnit           type c length 3  ,
        BusinessProcessConfirmedQty        type c length 13 ,
        NoFurtherBusinessProcQtyIsExpd     type c length 1  ,
        BusinessProcRemainingQtyUnit       type c length 3  ,
        BusinessProcessRemainingQty        type c length 13 ,
        SetupOpActyNtwkInstance            type c length 10 ,
        ProduceOpActyNtwkInstance          type c length 10 ,
        TeardownOpActyNtwkInstance         type c length 10 ,
        FreeDefinedTableFieldSemantic      type c length 7  ,
        FreeDefinedAttribute01             type c length 20 ,
        FreeDefinedAttribute02             type c length 20 ,
        FreeDefinedAttribute03             type c length 10 ,
        FreeDefinedAttribute04             type c length 10 ,
        FreeDefinedQuantity1Unit           type c length 3  ,
        FreeDefinedQuantity1               type c length 13 ,
        FreeDefinedQuantity2Unit           type c length 3  ,
        FreeDefinedQuantity2               type c length 13 ,
        FreeDefinedAmount1Currency         type c length 5  ,
        FreeDefinedAmount1                 type c length 13 ,
        FreeDefinedAmount2Currency         type c length 5  ,
        FreeDefinedAmount2                 type c length 13 ,
        FreeDefinedDate1                   type c length 8  ,
        FreeDefinedDate2                   type c length 8  ,
        FreeDefinedIndicator1              type c length 1  ,
        FreeDefinedIndicator2              type c length 1  ,

      end of ty_afvc,

      BEGIN OF TY_MBEW,
        Product                           type c length      40       ,
        ValuationArea                     type c length      4        ,
        ValuationType                     type c length      10       ,
        ValuationClass                    type c length      4        ,
        PriceDeterminationControl         type c length      1        ,
        FiscalMonthCurrentPeriod          type c length      2        ,
        FiscalYearCurrentPeriod           type c length      4        ,
        StandardPrice                     type c length      11       ,
        PriceUnitQty                      type c length      5        ,
        InventoryValuationProcedure       type c length      1        ,
        FuturePriceValidityStartDate      type c length      8        ,
        PrevInvtryPriceInCoCodeCrcy       type c length      11       ,
        MovingAveragePrice                type c length      11       ,
        ValuationCategory                 type c length      1        ,
        ProductUsageType                  type c length      1        ,
        ProductOriginType                 type c length      1        ,
        IsProducedInhouse                 type c length      1        ,
        ProdCostEstNumber                 type c length      12       ,
        IsMarkedForDeletion               type c length      1        ,
        ValuationMargin                   type c length      6        ,
        IsActiveEntity                    type c length      1        ,
        CompanyCode                       type c length      4        ,
        ValuationClassSalesOrderStock     type c length      4        ,
        ProjectStockValuationClass        type c length      4        ,
        TaxBasedPricesPriceUnitQty        type c length      5        ,
        PriceLastChangeDate               type c length      8        ,
        FuturePrice                       type c length      11       ,
        MaintenanceStatus                 type c length      15       ,
        Currency                          type c length      5        ,
        BaseUnit                          type c length      3        ,
        MLIsActiveAtProductLevel          type c length      1        ,

      END OF TY_MBEW.

    "传入参数（表名）
    TYPES:
      BEGIN OF ty_inputs,
        tablename type c LENGTH 10,
        sql type string,
      END OF ty_inputs,

      "EKKO   購買発注
      BEGIN OF ty_output_EKKO,
        message type string,
        items TYPE STANDARD TABLE OF ty_EKKO WITH EMPTY KEY,

      END OF ty_output_EKKO,

      "EKPO   購買発注明細
      BEGIN OF ty_output_EKPO,
      message type string,
        items TYPE STANDARD TABLE OF ty_EKPO WITH EMPTY KEY,

      END OF ty_output_EKPO,

      "EKET   納入日程行
      BEGIN OF ty_output_EKET,
      message type string,
        items TYPE STANDARD TABLE OF ty_EKET WITH EMPTY KEY,

      END OF ty_output_EKET,

      "EKBE 購買発注履歴
      BEGIN OF ty_output_EKBE,
      message type string,
        items TYPE STANDARD TABLE OF ty_EKBE WITH EMPTY KEY,

      END OF ty_output_EKBE,

      "EKKN 購買発注の勘定設定
      BEGIN OF ty_output_EKKN,
      message type string,
        items TYPE STANDARD TABLE OF ty_EKKN WITH EMPTY KEY,

      END OF ty_output_EKKN,

      "MARA 製品
      BEGIN OF ty_output_MARA,
              message type string,
        items TYPE STANDARD TABLE OF ty_MARA WITH EMPTY KEY,

      END OF ty_output_MARA,

      "MAKT 製品テキスト
      BEGIN OF ty_output_MAKT,
              message type string,
        items TYPE STANDARD TABLE OF ty_MAKT WITH EMPTY KEY,

      END OF ty_output_MAKT,

      "MARD 製品保管場所
      BEGIN OF ty_output_MARD,
              message type string,
        items TYPE STANDARD TABLE OF ty_MARD WITH EMPTY KEY,

      END OF ty_output_MARD,

      "T024D MRP 管理者
      BEGIN OF ty_output_T024D,
              message type string,
        items TYPE STANDARD TABLE OF ty_T024D WITH EMPTY KEY,

      END OF ty_output_T024D,

      "T001L 保管場所
      BEGIN OF ty_output_T001L,
              message type string,
        items TYPE STANDARD TABLE OF ty_T001L WITH EMPTY KEY,

      END OF ty_output_T001L,

      "MARC 製品プラント
      BEGIN OF ty_output_MARC,
              message type string,
        items TYPE STANDARD TABLE OF ty_MARC WITH EMPTY KEY,

      END OF ty_output_MARC,

      "MKAL 製造バージョン
      BEGIN OF ty_output_MKAL,
              message type string,
        items TYPE STANDARD TABLE OF ty_MKAL WITH EMPTY KEY,

      END OF ty_output_MKAL,

      "AFKO 製造指図
      BEGIN OF ty_output_AFKO,
              message type string,
        items TYPE STANDARD TABLE OF ty_AFKO WITH EMPTY KEY,

      END OF ty_output_AFKO,

      "AFPO 製造指図明細
      BEGIN OF ty_output_AFPO,
              message type string,
        items TYPE STANDARD TABLE OF ty_AFPO WITH EMPTY KEY,

      END OF ty_output_AFPO,

      "PLPO 品質検査計画作業のバージョン
      BEGIN OF ty_output_PLPO,
              message type string,
        items TYPE STANDARD TABLE OF ty_PLPO WITH EMPTY KEY,

      END OF ty_output_PLPO,

      "RESB 入出庫予定伝票明細
      BEGIN OF ty_output_RESB,
              message type string,
        items TYPE STANDARD TABLE OF ty_RESB WITH EMPTY KEY,

      END OF ty_output_RESB,

      "AFVC 指図内作業
      BEGIN OF ty_output_AFVC,
              message type string,
        items TYPE STANDARD TABLE OF ty_AFVC WITH EMPTY KEY,

      END OF ty_output_AFVC,

      "MBEW製品評価
      BEGIN OF ty_output_MBEW,
              message type string,
        items TYPE STANDARD TABLE OF ty_MBEW WITH EMPTY KEY,

      END OF ty_output_MBEW.

  interfaces IF_HTTP_SERVICE_EXTENSION .
protected section.
private section.

  DATA:
    "lt_req            TYPE tt_header,
    lt_req            TYPE tt_ITEM,
    ls_req            type ty_inputs,
    LR_EBELN  TYPE RANGE OF EBELN,
    LRS_EBELN LIKE LINE OF LR_EBELN,
    lv_tablename(10)  type c,
    lv_error(1)       TYPE c,
    lv_error1(1)      type c,
    lv_text           TYPE string,
    lc_header_content TYPE string VALUE 'content-type',
    lc_content_type   TYPE string VALUE 'text/json',
    lv_where type string.
  DATA:
    lv_start_time TYPE sy-uzeit,
    lv_start_date TYPE sy-datum,
    lv_end_time   TYPE sy-uzeit,
    lv_end_date   TYPE sy-datum,
    lv_temp(14)   TYPE c,
    lv_starttime  TYPE p LENGTH 16 DECIMALS 0,
    lv_endtime    TYPE p LENGTH 16 DECIMALS 0,
    lv_count      type i.

ENDCLASS.



CLASS ZCL_HTTP_PODATA_002 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    "读取表名
    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    IF lv_header = 'XML'.

    ELSE.
*    将读取到的表名作为参数后面用
      xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
          ( xco_cp_json=>transformation->underscore_to_pascal_case )
      ) )->write_to( REF #( ls_req ) ).

    ENDIF.

    lv_where = ls_req-sql.
    lv_tablename = ls_req-tablename.

*change by shin1115 20240925 客户改为sql 文形式
*    LOOP AT LT_REQ INTO DATA(LS_REQ).
*        LV_TABLENAME = LS_REQ-tablename.
*
*        CASE LS_REQ-prametername.
*
*        WHEN 'ebeln'.
*
*          lrS_ebeln-sign = 'I'.
*          lrS_ebeln-option = 'CS'.
*          lrS_ebeln-low = LS_REQ-VALUE.
*          APPEND lrS_ebeln TO lr_ebeln.
*          CLEAR: lrs_ebeln.
*
*          DATA(LV_EBELN) =  LS_REQ-VALUE.
*
*         WHEN OTHERS.
*
*         ENDCASE.
*
*    ENDLOOP.

    DATA:
      es_response_ekko  TYPE ty_output_ekko,
      es_response_ekpo  TYPE ty_output_ekpo,
      es_response_eket  TYPE ty_output_eket,
      es_response_ekbe  TYPE ty_output_ekbe,
      es_response_ekkn  TYPE ty_output_ekkn,
      es_response_mara  TYPE ty_output_mara,
      es_response_makt  TYPE ty_output_makt,
      es_response_mard  TYPE ty_output_mard,
      es_response_t024d TYPE ty_output_t024d,
      es_response_t001l TYPE ty_output_t001l,
      es_response_marc  TYPE ty_output_marc,
      es_response_mkal  TYPE ty_output_mkal,
      es_response_afko  TYPE ty_output_afko,
      es_response_afpo  TYPE ty_output_afpo,
      es_response_plpo  TYPE ty_output_plpo,
      es_response_resb  TYPE ty_output_resb,
      es_response_afvc  TYPE ty_output_afvc,
      es_response_mbew  TYPE ty_output_mbew,
      es_ekko           TYPE ty_ekko,
      es_ekpo           TYPE ty_ekpo,
      es_eket           TYPE ty_eket,
      es_ekbe           TYPE ty_ekbe,
      es_ekkn           TYPE ty_ekkn,
      es_mara           TYPE ty_mara,
      es_makt           TYPE ty_makt,
      es_mard           TYPE ty_mard,
      es_t024d          TYPE ty_t024d,
      es_t001l          TYPE ty_t001l,
      es_marc           TYPE ty_marc,
      es_mkal           TYPE ty_mkal,
      es_afko           TYPE ty_afko,
      es_afpo           TYPE ty_afpo,
      es_plpo           TYPE ty_plpo,
      es_resb           TYPE ty_resb,
      es_afvc           TYPE ty_afvc,
      es_mbew           TYPE ty_mbew.

    CASE lv_tablename.
******************************************************************************************************
*      SELECT * FROM I_PurchaseOrderAPI01                                                            *
*        INTO TABLE @DATA(LT_XXX).                                                                   *
*                                                                                                    *
*        IF LT_XXX IS NOT INITIAL.                                                                   *
*          LOOP  AT LT_XXX INTO DATA(LS_XXX).                                                        *
*                                                                                                    *
*            ES_XXX-PurchaseOrder                          = LS_EKKO-PurchaseOrder                   *   .
*                                                                                                    *
*            CONDENSE ES_XXX-PurchaseOrder                            .                              *
*                                                                                                    *
*            APPEND ES_XXX TO es_response_XXX-items.                                                 *
*                                                                                                    *
*          ENDLOOP.                                                                                  *
*                                                                                                    *
*          "respond with success payload                                                             *
*          response->set_status( '200' ).                                                            *
*                                                                                                    *
*          DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response_XXX )->to_string( ).     *
*          response->set_text( lv_json_string ).                                                     *
*          response->set_header_field( i_name  = lc_header_content                                   *
*                                      i_value = lc_content_type ).                                  *
*                                                                                                    *
*        ELSE.                                                                                       *
*          lv_error = 'X'.                                                                           *
*          lv_text = 'There is no data in table'.                                                    *
*        ENDIF.***                                                                                   *
******************************************************************************************************
      WHEN `EKKO` OR 'ekko'.

      data:lv_error_message_ekko type string.


        try.

         SELECT * FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS
         WHERE (lv_where)
         INTO TABLE @DATA(lt_ekko).

        catch cx_sy_dynamic_osql_error into data(lo_sql_error_ekko).

            lv_error = 'X'.
            lv_error_message_ekko = lo_sql_error_ekko->get_text( ).    " 获取错误描述

         ENDTRY.

        IF lt_ekko IS NOT INITIAL.
          LOOP  AT lt_ekko INTO DATA(ls_ekko).

            lv_count = lv_count + 1.

            es_ekko-purchaseorder                          = ls_ekko-purchaseorder                       .
            es_ekko-purchaseordertype                      = ls_ekko-purchaseordertype                   .
            es_ekko-purchaseordersubtype                   = ls_ekko-purchaseordersubtype                .
            es_ekko-purchasingdocumentorigin               = ls_ekko-purchasingdocumentorigin            .
            es_ekko-createdbyuser                          = ls_ekko-createdbyuser                       .
            es_ekko-creationdate                           = ls_ekko-creationdate                        .
            es_ekko-purchaseorderdate                      = ls_ekko-purchaseorderdate                   .
            es_ekko-language                               = ls_ekko-language                            .
            es_ekko-correspncexternalreference             = ls_ekko-correspncexternalreference          .
            es_ekko-correspncinternalreference             = ls_ekko-correspncinternalreference          .
            es_ekko-purchasingdocumentdeletioncode         = ls_ekko-purchasingdocumentdeletioncode      .
            es_ekko-releaseisnotcompleted                  = ls_ekko-releaseisnotcompleted               .
            es_ekko-purchasingcompletenessstatus           = ls_ekko-purchasingcompletenessstatus        .
            es_ekko-purchasingprocessingstatus             = ls_ekko-purchasingprocessingstatus          .
            es_ekko-purgreleasesequencestatus              = ls_ekko-purgreleasesequencestatus           .
            es_ekko-releasecode                            = ls_ekko-releasecode                         .
            es_ekko-companycode                            = ls_ekko-companycode                         .
            es_ekko-purchasingorganization                 = ls_ekko-purchasingorganization              .
            es_ekko-purchasinggroup                        = ls_ekko-purchasinggroup                     .
            es_ekko-supplier                               = ls_ekko-supplier                            .
            es_ekko-manualsupplieraddressid                = ls_ekko-manualsupplieraddressid             .
            es_ekko-supplierrespsalespersonname            = ls_ekko-supplierrespsalespersonname         .
            es_ekko-supplierphonenumber                    = ls_ekko-supplierphonenumber                 .
            es_ekko-supplyingsupplier                      = ls_ekko-supplyingsupplier                   .
            es_ekko-supplyingplant                         = ls_ekko-supplyingplant                      .
            es_ekko-invoicingparty                         = ls_ekko-invoicingparty                      .
            es_ekko-customer                               = ls_ekko-customer                            .
            es_ekko-supplierquotationexternalid            = ls_ekko-supplierquotationexternalid         .
            es_ekko-paymentterms                           = ls_ekko-paymentterms                        .
            es_ekko-cashdiscount1days                      = ls_ekko-cashdiscount1days                   .
            es_ekko-cashdiscount2days                      = ls_ekko-cashdiscount2days                   .
            es_ekko-netpaymentdays                         = ls_ekko-netpaymentdays                      .
            es_ekko-cashdiscount1percent                   = ls_ekko-cashdiscount1percent                .
            es_ekko-cashdiscount2percent                   = ls_ekko-cashdiscount2percent                .
            es_ekko-downpaymenttype                        = ls_ekko-downpaymenttype                     .
            es_ekko-downpaymentpercentageoftotamt          = ls_ekko-downpaymentpercentageoftotamt       .
            es_ekko-downpaymentamount                      = ls_ekko-downpaymentamount                   .
            es_ekko-downpaymentduedate                     = ls_ekko-downpaymentduedate                  .
            es_ekko-incotermsclassification                = ls_ekko-incotermsclassification             .
            es_ekko-incotermstransferlocation              = ls_ekko-incotermstransferlocation           .
            es_ekko-incotermsversion                       = ls_ekko-incotermsversion                    .
            es_ekko-incotermslocation1                     = ls_ekko-incotermslocation1                  .
            es_ekko-incotermslocation2                     = ls_ekko-incotermslocation2                  .
            es_ekko-isintrastatreportingrelevant           = ls_ekko-isintrastatreportingrelevant        .
            es_ekko-isintrastatreportingexcluded           = ls_ekko-isintrastatreportingexcluded        .
            es_ekko-pricingdocument                        = ls_ekko-pricingdocument                     .
            es_ekko-pricingprocedure                       = ls_ekko-pricingprocedure                    .
            es_ekko-documentcurrency                       = ls_ekko-documentcurrency                    .
            es_ekko-validitystartdate                      = ls_ekko-validitystartdate                   .
            es_ekko-validityenddate                        = ls_ekko-validityenddate                     .
            es_ekko-exchangerate                           = ls_ekko-exchangerate                        .
            es_ekko-exchangerateisfixed                    = ls_ekko-exchangerateisfixed                 .
            es_ekko-lastchangedatetime                     = ls_ekko-lastchangedatetime                  .
            es_ekko-taxreturncountry                       = ls_ekko-taxreturncountry                    .
            es_ekko-vatregistrationcountry                 = ls_ekko-vatregistrationcountry              .
            es_ekko-purgreasonfordoccancellation           = ls_ekko-purgreasonfordoccancellation        .
            es_ekko-purgreleasetimetotalamount             = ls_ekko-purgreleasetimetotalamount          .
            es_ekko-purgaggrgdprodcmplncsuplrsts           = ls_ekko-purgaggrgdprodcmplncsuplrsts        .
            es_ekko-purgaggrgdprodmarketabilitysts         = ls_ekko-purgaggrgdprodmarketabilitysts      .
            es_ekko-purgaggrgdsftydatasheetstatus          = ls_ekko-purgaggrgdsftydatasheetstatus       .
            es_ekko-purgprodcmplnctotdngrsgoodssts         = ls_ekko-purgprodcmplnctotdngrsgoodssts      .

            CONDENSE es_ekko-purchaseorder                            .
            CONDENSE es_ekko-purchaseordertype                        .
            CONDENSE es_ekko-purchaseordersubtype                     .
            CONDENSE es_ekko-purchasingdocumentorigin                 .
            CONDENSE es_ekko-createdbyuser                            .
            CONDENSE es_ekko-creationdate                             .
            CONDENSE es_ekko-purchaseorderdate                        .
            CONDENSE es_ekko-language                                 .
            CONDENSE es_ekko-correspncexternalreference               .
            CONDENSE es_ekko-correspncinternalreference               .
            CONDENSE es_ekko-purchasingdocumentdeletioncode           .
            CONDENSE es_ekko-releaseisnotcompleted                    .
            CONDENSE es_ekko-purchasingcompletenessstatus             .
            CONDENSE es_ekko-purchasingprocessingstatus               .
            CONDENSE es_ekko-purgreleasesequencestatus                .
            CONDENSE es_ekko-releasecode                              .
            CONDENSE es_ekko-companycode                              .
            CONDENSE es_ekko-purchasingorganization                   .
            CONDENSE es_ekko-purchasinggroup                          .
            CONDENSE es_ekko-supplier                                 .
            CONDENSE es_ekko-manualsupplieraddressid                  .
            CONDENSE es_ekko-supplierrespsalespersonname              .
            CONDENSE es_ekko-supplierphonenumber                      .
            CONDENSE es_ekko-supplyingsupplier                        .
            CONDENSE es_ekko-supplyingplant                           .
            CONDENSE es_ekko-invoicingparty                           .
            CONDENSE es_ekko-customer                                 .
            CONDENSE es_ekko-supplierquotationexternalid              .
            CONDENSE es_ekko-paymentterms                             .
            CONDENSE es_ekko-cashdiscount1days                        .
            CONDENSE es_ekko-cashdiscount2days                        .
            CONDENSE es_ekko-netpaymentdays                           .
            CONDENSE es_ekko-cashdiscount1percent                     .
            CONDENSE es_ekko-cashdiscount2percent                     .
            CONDENSE es_ekko-downpaymenttype                          .
            CONDENSE es_ekko-downpaymentpercentageoftotamt            .
            CONDENSE es_ekko-downpaymentamount                        .
            CONDENSE es_ekko-downpaymentduedate                       .
            CONDENSE es_ekko-incotermsclassification                  .
            CONDENSE es_ekko-incotermstransferlocation                .
            CONDENSE es_ekko-incotermsversion                         .
            CONDENSE es_ekko-incotermslocation1                       .
            CONDENSE es_ekko-incotermslocation2                       .
            CONDENSE es_ekko-isintrastatreportingrelevant             .
            CONDENSE es_ekko-isintrastatreportingexcluded             .
            CONDENSE es_ekko-pricingdocument                          .
            CONDENSE es_ekko-pricingprocedure                         .
            CONDENSE es_ekko-documentcurrency                         .
            CONDENSE es_ekko-validitystartdate                        .
            CONDENSE es_ekko-validityenddate                          .
            CONDENSE es_ekko-exchangerate                             .
            CONDENSE es_ekko-exchangerateisfixed                      .
            CONDENSE es_ekko-lastchangedatetime                       .
            CONDENSE es_ekko-taxreturncountry                         .
            CONDENSE es_ekko-vatregistrationcountry                   .
            CONDENSE es_ekko-purgreasonfordoccancellation             .
            CONDENSE es_ekko-purgreleasetimetotalamount               .
            CONDENSE es_ekko-purgaggrgdprodcmplncsuplrsts             .
            CONDENSE es_ekko-purgaggrgdprodmarketabilitysts           .
            CONDENSE es_ekko-purgaggrgdsftydatasheetstatus            .
            CONDENSE es_ekko-purgprodcmplnctotdngrsgoodssts           .

            APPEND es_ekko TO es_response_ekko-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_ekko-message = |{ lv_count }件は送信されました。|.

          DATA(lv_json_string) = xco_cp_json=>data->from_abap( es_response_ekko )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.

          if lv_error_message_ekko is NOT INITIAL.

            lv_text = lv_error_message_ekko .

          else.
            lv_text = 'There is no data in table'.

          ENDIF.

        ENDIF.

      WHEN `EKPO` OR 'ekpo'.

      data: lv_error_message_ekpo type String.

       try.

        SELECT * FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_ekpo).

       catch cx_sy_dynamic_osql_error into data(lo_sql_error_ekpo).

            lv_error = 'X'.
            lv_error_message_ekpo = lo_sql_error_ekpo->get_text( ).    " 获取错误描述

       ENDTRY.

        IF lt_ekpo IS NOT INITIAL.
          LOOP  AT lt_ekpo INTO DATA(ls_ekpo).
            lv_count = lv_count + 1.

            es_ekpo-purchaseorder                          =      ls_ekpo-purchaseorder                    .
            es_ekpo-purchaseorderitem                      =      ls_ekpo-purchaseorderitem                .
            es_ekpo-purchaseorderitemuniqueid              =      ls_ekpo-purchaseorderitemuniqueid        .
            es_ekpo-purchaseordercategory                  =      ls_ekpo-purchaseordercategory            .
            es_ekpo-documentcurrency                       =      ls_ekpo-documentcurrency                 .
            es_ekpo-purchasingdocumentdeletioncode         =      ls_ekpo-purchasingdocumentdeletioncode   .
            es_ekpo-purchasingdocumentitemorigin           =      ls_ekpo-purchasingdocumentitemorigin     .
            es_ekpo-materialgroup                          =      ls_ekpo-materialgroup                    .
            es_ekpo-material                               =      ls_ekpo-material                         .
            es_ekpo-materialtype                           =      ls_ekpo-materialtype                     .
            es_ekpo-suppliermaterialnumber                 =      ls_ekpo-suppliermaterialnumber           .
            es_ekpo-suppliersubrange                       =      ls_ekpo-suppliersubrange                 .
            es_ekpo-manufacturerpartnmbr                   =      ls_ekpo-manufacturerpartnmbr             .
            es_ekpo-manufacturer                           =      ls_ekpo-manufacturer                     .
            es_ekpo-manufacturermaterial                   =      ls_ekpo-manufacturermaterial             .
            es_ekpo-purchaseorderitemtext                  =      ls_ekpo-purchaseorderitemtext            .
            es_ekpo-producttype                            =      ls_ekpo-producttype                      .
            es_ekpo-companycode                            =      ls_ekpo-companycode                      .
            es_ekpo-plant                                  =      ls_ekpo-plant                            .
            es_ekpo-manualdeliveryaddressid                =      ls_ekpo-manualdeliveryaddressid          .
            es_ekpo-referencedeliveryaddressid             =      ls_ekpo-referencedeliveryaddressid       .
            es_ekpo-customer                               =      ls_ekpo-customer                         .
            es_ekpo-subcontractor                          =      ls_ekpo-subcontractor                    .
            es_ekpo-supplierissubcontractor                =      ls_ekpo-supplierissubcontractor          .
            es_ekpo-crossplantconfigurableproduct          =      ls_ekpo-crossplantconfigurableproduct    .
            es_ekpo-articlecategory                        =      ls_ekpo-articlecategory                  .
            es_ekpo-plndorderreplnmtelmnttype              =      ls_ekpo-plndorderreplnmtelmnttype        .
            es_ekpo-productpurchasepointsqtyunit           =      ls_ekpo-productpurchasepointsqtyunit     .
            es_ekpo-productpurchasepointsqty               =      ls_ekpo-productpurchasepointsqty         .
            es_ekpo-storagelocation                        =      ls_ekpo-storagelocation                  .
            es_ekpo-purchaseorderquantityunit              =      ls_ekpo-purchaseorderquantityunit        .
            es_ekpo-orderitemqtytobaseqtynmrtr             =      ls_ekpo-orderitemqtytobaseqtynmrtr       .
            es_ekpo-orderitemqtytobaseqtydnmntr            =      ls_ekpo-orderitemqtytobaseqtydnmntr      .
            es_ekpo-netpricequantity                       =      ls_ekpo-netpricequantity                 .
            es_ekpo-iscompletelydelivered                  =      ls_ekpo-iscompletelydelivered            .
            es_ekpo-isfinallyinvoiced                      =      ls_ekpo-isfinallyinvoiced                .
            es_ekpo-goodsreceiptisexpected                 =      ls_ekpo-goodsreceiptisexpected           .
            es_ekpo-invoiceisexpected                      =      ls_ekpo-invoiceisexpected                .
            es_ekpo-invoiceisgoodsreceiptbased             =      ls_ekpo-invoiceisgoodsreceiptbased       .
            es_ekpo-purchasecontractitem                   =      ls_ekpo-purchasecontractitem             .
            es_ekpo-purchasecontract                       =      ls_ekpo-purchasecontract                 .
            es_ekpo-purchaserequisition                    =      ls_ekpo-purchaserequisition              .
            es_ekpo-requirementtracking                    =      ls_ekpo-requirementtracking              .
            es_ekpo-purchaserequisitionitem                =      ls_ekpo-purchaserequisitionitem          .
            es_ekpo-evaldrcptsettlmtisallowed              =      ls_ekpo-evaldrcptsettlmtisallowed        .
            es_ekpo-unlimitedoverdeliveryisallowed         =      ls_ekpo-unlimitedoverdeliveryisallowed   .
            es_ekpo-overdelivtolrtdlmtratioinpct           =      ls_ekpo-overdelivtolrtdlmtratioinpct     .
            es_ekpo-underdelivtolrtdlmtratioinpct          =      ls_ekpo-underdelivtolrtdlmtratioinpct    .
            es_ekpo-requisitionername                      =      ls_ekpo-requisitionername                .
            es_ekpo-planneddeliverydurationindays          =      ls_ekpo-planneddeliverydurationindays    .
            es_ekpo-goodsreceiptdurationindays             =      ls_ekpo-goodsreceiptdurationindays       .
            es_ekpo-partialdeliveryisallowed               =      ls_ekpo-partialdeliveryisallowed         .
            es_ekpo-consumptionposting                     =      ls_ekpo-consumptionposting               .
            es_ekpo-serviceperformer                       =      ls_ekpo-serviceperformer                 .
            es_ekpo-baseunit                               =      ls_ekpo-baseunit                         .
            es_ekpo-purchaseorderitemcategory              =      ls_ekpo-purchaseorderitemcategory        .
            es_ekpo-profitcenter                           =      ls_ekpo-profitcenter                     .
            es_ekpo-orderpriceunit                         =      ls_ekpo-orderpriceunit                   .
            es_ekpo-itemvolumeunit                         =      ls_ekpo-itemvolumeunit                   .
            es_ekpo-itemweightunit                         =      ls_ekpo-itemweightunit                   .
            es_ekpo-multipleacctassgmtdistribution         =      ls_ekpo-multipleacctassgmtdistribution   .
            es_ekpo-partialinvoicedistribution             =      ls_ekpo-partialinvoicedistribution       .
            es_ekpo-pricingdatecontrol                     =      ls_ekpo-pricingdatecontrol               .
            es_ekpo-isstatisticalitem                      =      ls_ekpo-isstatisticalitem                .
            es_ekpo-purchasingparentitem                   =      ls_ekpo-purchasingparentitem             .
            es_ekpo-goodsreceiptlatestcreationdate         =      ls_ekpo-goodsreceiptlatestcreationdate   .
            es_ekpo-isreturnsitem                          =      ls_ekpo-isreturnsitem                    .
            es_ekpo-purchasingorderreason                  =      ls_ekpo-purchasingorderreason            .
            es_ekpo-incotermsclassification                =      ls_ekpo-incotermsclassification          .
            es_ekpo-incotermstransferlocation              =      ls_ekpo-incotermstransferlocation        .
            es_ekpo-incotermslocation1                     =      ls_ekpo-incotermslocation1               .
            es_ekpo-incotermslocation2                     =      ls_ekpo-incotermslocation2               .
            es_ekpo-priorsupplier                          =      ls_ekpo-priorsupplier                    .
            es_ekpo-internationalarticlenumber             =      ls_ekpo-internationalarticlenumber       .
            es_ekpo-intrastatservicecode                   =      ls_ekpo-intrastatservicecode             .
            es_ekpo-commoditycode                          =      ls_ekpo-commoditycode                    .
            es_ekpo-materialfreightgroup                   =      ls_ekpo-materialfreightgroup             .
            es_ekpo-discountinkindeligibility              =      ls_ekpo-discountinkindeligibility        .
            es_ekpo-purgitemisblockedfordelivery           =      ls_ekpo-purgitemisblockedfordelivery     .
            es_ekpo-supplierconfirmationcontrolkey         =      ls_ekpo-supplierconfirmationcontrolkey   .
            es_ekpo-priceistobeprinted                     =      ls_ekpo-priceistobeprinted               .
            es_ekpo-accountassignmentcategory              =      ls_ekpo-accountassignmentcategory        .
            es_ekpo-purchasinginforecord                   =      ls_ekpo-purchasinginforecord             .
            es_ekpo-netamount                              =      ls_ekpo-netamount                        .
            es_ekpo-grossamount                            =      ls_ekpo-grossamount                      .
            es_ekpo-effectiveamount                        =      ls_ekpo-effectiveamount                  .
            es_ekpo-subtotal1amount                        =      ls_ekpo-subtotal1amount                  .
            es_ekpo-subtotal2amount                        =      ls_ekpo-subtotal2amount                  .
            es_ekpo-subtotal3amount                        =      ls_ekpo-subtotal3amount                  .
            es_ekpo-subtotal4amount                        =      ls_ekpo-subtotal4amount                  .
            es_ekpo-subtotal5amount                        =      ls_ekpo-subtotal5amount                  .
            es_ekpo-subtotal6amount                        =      ls_ekpo-subtotal6amount                  .
            es_ekpo-orderquantity                          =      ls_ekpo-orderquantity                    .
            es_ekpo-netpriceamount                         =      ls_ekpo-netpriceamount                   .
            es_ekpo-itemvolume                             =      ls_ekpo-itemvolume                       .
            es_ekpo-itemgrossweight                        =      ls_ekpo-itemgrossweight                  .
            es_ekpo-itemnetweight                          =      ls_ekpo-itemnetweight                    .
            es_ekpo-orderpriceunittoorderunitnmrtr         =      ls_ekpo-orderpriceunittoorderunitnmrtr   .
            es_ekpo-ordpriceunittoorderunitdnmntr          =      ls_ekpo-ordpriceunittoorderunitdnmntr    .
            es_ekpo-goodsreceiptisnonvaluated              =      ls_ekpo-goodsreceiptisnonvaluated        .
            es_ekpo-taxcode                                =      ls_ekpo-taxcode                          .
            es_ekpo-taxjurisdiction                        =      ls_ekpo-taxjurisdiction                  .
            es_ekpo-shippinginstruction                    =      ls_ekpo-shippinginstruction              .
            es_ekpo-shippingtype                           =      ls_ekpo-shippingtype                     .
            es_ekpo-nondeductibleinputtaxamount            =      ls_ekpo-nondeductibleinputtaxamount      .
            es_ekpo-stocktype                              =      ls_ekpo-stocktype                        .
            es_ekpo-valuationtype                          =      ls_ekpo-valuationtype                    .
            es_ekpo-valuationcategory                      =      ls_ekpo-valuationcategory                .
            es_ekpo-itemisrejectedbysupplier               =      ls_ekpo-itemisrejectedbysupplier         .
            es_ekpo-purgdocpricedate                       =      ls_ekpo-purgdocpricedate                 .
            es_ekpo-purgdocreleaseorderquantity            =      ls_ekpo-purgdocreleaseorderquantity      .
*            es_ekpo-earmarkedfunds                         =      ls_ekpo-earmarkedfunds                   .
            es_ekpo-earmarkedfundsdocument                 =      ls_ekpo-earmarkedfundsdocument           .
*            es_ekpo-earmarkedfundsitem                     =      ls_ekpo-earmarkedfundsitem               .
            es_ekpo-earmarkedfundsdocumentitem             =      ls_ekpo-earmarkedfundsdocumentitem       .
            es_ekpo-partnerreportedbusinessarea            =      ls_ekpo-partnerreportedbusinessarea      .
            es_ekpo-inventoryspecialstocktype              =      ls_ekpo-inventoryspecialstocktype        .
            es_ekpo-deliverydocumenttype                   =      ls_ekpo-deliverydocumenttype             .
            es_ekpo-issuingstoragelocation                 =      ls_ekpo-issuingstoragelocation           .
            es_ekpo-allocationtable                        =      ls_ekpo-allocationtable                  .
            es_ekpo-allocationtableitem                    =      ls_ekpo-allocationtableitem              .
            es_ekpo-retailpromotion                        =      ls_ekpo-retailpromotion                  .
            es_ekpo-downpaymenttype                        =      ls_ekpo-downpaymenttype                  .
            es_ekpo-downpaymentpercentageoftotamt          =      ls_ekpo-downpaymentpercentageoftotamt    .
            es_ekpo-downpaymentamount                      =      ls_ekpo-downpaymentamount                .
            es_ekpo-downpaymentduedate                     =      ls_ekpo-downpaymentduedate               .
            es_ekpo-expectedoveralllimitamount             =      ls_ekpo-expectedoveralllimitamount       .
            es_ekpo-overalllimitamount                     =      ls_ekpo-overalllimitamount               .
            es_ekpo-requirementsegment                     =      ls_ekpo-requirementsegment               .
            es_ekpo-purgprodcmplncdngrsgoodsstatus         =      ls_ekpo-purgprodcmplncdngrsgoodsstatus   .
            es_ekpo-purgprodcmplncsupplierstatus           =      ls_ekpo-purgprodcmplncsupplierstatus     .
            es_ekpo-purgproductmarketabilitystatus         =      ls_ekpo-purgproductmarketabilitystatus   .
            es_ekpo-purgsafetydatasheetstatus              =      ls_ekpo-purgsafetydatasheetstatus        .
            es_ekpo-subcontrgcompisrealtmecnsmd            =      ls_ekpo-subcontrgcompisrealtmecnsmd      .
            es_ekpo-br_materialorigin                      =      ls_ekpo-br_materialorigin                .
            es_ekpo-br_materialusage                       =      ls_ekpo-br_materialusage                 .
            es_ekpo-br_cfopcategory                        =      ls_ekpo-br_cfopcategory                  .
            es_ekpo-br_ncm                                 =      ls_ekpo-br_ncm                           .
            es_ekpo-br_isproducedinhouse                   =      ls_ekpo-br_isproducedinhouse             .

            CONDENSE es_ekpo-purchaseorder                     .
            CONDENSE es_ekpo-purchaseorderitem                 .
            CONDENSE es_ekpo-purchaseorderitemuniqueid         .
            CONDENSE es_ekpo-purchaseordercategory             .
            CONDENSE es_ekpo-documentcurrency                  .
            CONDENSE es_ekpo-purchasingdocumentdeletioncode    .
            CONDENSE es_ekpo-purchasingdocumentitemorigin      .
            CONDENSE es_ekpo-materialgroup                     .
            CONDENSE es_ekpo-material                          .
            CONDENSE es_ekpo-materialtype                      .
            CONDENSE es_ekpo-suppliermaterialnumber            .
            CONDENSE es_ekpo-suppliersubrange                  .
            CONDENSE es_ekpo-manufacturerpartnmbr              .
            CONDENSE es_ekpo-manufacturer                      .
            CONDENSE es_ekpo-manufacturermaterial              .
            CONDENSE es_ekpo-purchaseorderitemtext             .
            CONDENSE es_ekpo-producttype                       .
            CONDENSE es_ekpo-companycode                       .
            CONDENSE es_ekpo-plant                             .
            CONDENSE es_ekpo-manualdeliveryaddressid           .
            CONDENSE es_ekpo-referencedeliveryaddressid        .
            CONDENSE es_ekpo-customer                          .
            CONDENSE es_ekpo-subcontractor                     .
            CONDENSE es_ekpo-supplierissubcontractor           .
            CONDENSE es_ekpo-crossplantconfigurableproduct     .
            CONDENSE es_ekpo-articlecategory                   .
            CONDENSE es_ekpo-plndorderreplnmtelmnttype         .
            CONDENSE es_ekpo-productpurchasepointsqtyunit      .
            CONDENSE es_ekpo-productpurchasepointsqty          .
            CONDENSE es_ekpo-storagelocation                   .
            CONDENSE es_ekpo-purchaseorderquantityunit         .
            CONDENSE es_ekpo-orderitemqtytobaseqtynmrtr        .
            CONDENSE es_ekpo-orderitemqtytobaseqtydnmntr       .
            CONDENSE es_ekpo-netpricequantity                  .
            CONDENSE es_ekpo-iscompletelydelivered             .
            CONDENSE es_ekpo-isfinallyinvoiced                 .
            CONDENSE es_ekpo-goodsreceiptisexpected            .
            CONDENSE es_ekpo-invoiceisexpected                 .
            CONDENSE es_ekpo-invoiceisgoodsreceiptbased        .
            CONDENSE es_ekpo-purchasecontractitem              .
            CONDENSE es_ekpo-purchasecontract                  .
            CONDENSE es_ekpo-purchaserequisition               .
            CONDENSE es_ekpo-requirementtracking               .
            CONDENSE es_ekpo-purchaserequisitionitem           .
            CONDENSE es_ekpo-evaldrcptsettlmtisallowed         .
            CONDENSE es_ekpo-unlimitedoverdeliveryisallowed    .
            CONDENSE es_ekpo-overdelivtolrtdlmtratioinpct      .
            CONDENSE es_ekpo-underdelivtolrtdlmtratioinpct     .
            CONDENSE es_ekpo-requisitionername                 .
            CONDENSE es_ekpo-planneddeliverydurationindays     .
            CONDENSE es_ekpo-goodsreceiptdurationindays        .
            CONDENSE es_ekpo-partialdeliveryisallowed          .
            CONDENSE es_ekpo-consumptionposting                .
            CONDENSE es_ekpo-serviceperformer                  .
            CONDENSE es_ekpo-baseunit                          .
            CONDENSE es_ekpo-purchaseorderitemcategory         .
            CONDENSE es_ekpo-profitcenter                      .
            CONDENSE es_ekpo-orderpriceunit                    .
            CONDENSE es_ekpo-itemvolumeunit                    .
            CONDENSE es_ekpo-itemweightunit                    .
            CONDENSE es_ekpo-multipleacctassgmtdistribution    .
            CONDENSE es_ekpo-partialinvoicedistribution        .
            CONDENSE es_ekpo-pricingdatecontrol                .
            CONDENSE es_ekpo-isstatisticalitem                 .
            CONDENSE es_ekpo-purchasingparentitem              .
            CONDENSE es_ekpo-goodsreceiptlatestcreationdate    .
            CONDENSE es_ekpo-isreturnsitem                     .
            CONDENSE es_ekpo-purchasingorderreason             .
            CONDENSE es_ekpo-incotermsclassification           .
            CONDENSE es_ekpo-incotermstransferlocation         .
            CONDENSE es_ekpo-incotermslocation1                .
            CONDENSE es_ekpo-incotermslocation2                .
            CONDENSE es_ekpo-priorsupplier                     .
            CONDENSE es_ekpo-internationalarticlenumber        .
            CONDENSE es_ekpo-intrastatservicecode              .
            CONDENSE es_ekpo-commoditycode                     .
            CONDENSE es_ekpo-materialfreightgroup              .
            CONDENSE es_ekpo-discountinkindeligibility         .
            CONDENSE es_ekpo-purgitemisblockedfordelivery      .
            CONDENSE es_ekpo-supplierconfirmationcontrolkey    .
            CONDENSE es_ekpo-priceistobeprinted                .
            CONDENSE es_ekpo-accountassignmentcategory         .
            CONDENSE es_ekpo-purchasinginforecord              .
            CONDENSE es_ekpo-netamount                         .
            CONDENSE es_ekpo-grossamount                       .
            CONDENSE es_ekpo-effectiveamount                   .
            CONDENSE es_ekpo-subtotal1amount                   .
            CONDENSE es_ekpo-subtotal2amount                   .
            CONDENSE es_ekpo-subtotal3amount                   .
            CONDENSE es_ekpo-subtotal4amount                   .
            CONDENSE es_ekpo-subtotal5amount                   .
            CONDENSE es_ekpo-subtotal6amount                   .
            CONDENSE es_ekpo-orderquantity                     .
            CONDENSE es_ekpo-netpriceamount                    .
            CONDENSE es_ekpo-itemvolume                        .
            CONDENSE es_ekpo-itemgrossweight                   .
            CONDENSE es_ekpo-itemnetweight                     .
            CONDENSE es_ekpo-orderpriceunittoorderunitnmrtr    .
            CONDENSE es_ekpo-ordpriceunittoorderunitdnmntr     .
            CONDENSE es_ekpo-goodsreceiptisnonvaluated         .
            CONDENSE es_ekpo-taxcode                           .
            CONDENSE es_ekpo-taxjurisdiction                   .
            CONDENSE es_ekpo-shippinginstruction               .
            CONDENSE es_ekpo-shippingtype                      .
            CONDENSE es_ekpo-nondeductibleinputtaxamount       .
            CONDENSE es_ekpo-stocktype                         .
            CONDENSE es_ekpo-valuationtype                     .
            CONDENSE es_ekpo-valuationcategory                 .
            CONDENSE es_ekpo-itemisrejectedbysupplier          .
            CONDENSE es_ekpo-purgdocpricedate                  .
            CONDENSE es_ekpo-purgdocreleaseorderquantity       .
            CONDENSE es_ekpo-earmarkedfunds                    .
            CONDENSE es_ekpo-earmarkedfundsdocument            .
            CONDENSE es_ekpo-earmarkedfundsitem                .
            CONDENSE es_ekpo-earmarkedfundsdocumentitem        .
            CONDENSE es_ekpo-partnerreportedbusinessarea       .
            CONDENSE es_ekpo-inventoryspecialstocktype         .
            CONDENSE es_ekpo-deliverydocumenttype              .
            CONDENSE es_ekpo-issuingstoragelocation            .
            CONDENSE es_ekpo-allocationtable                   .
            CONDENSE es_ekpo-allocationtableitem               .
            CONDENSE es_ekpo-retailpromotion                   .
            CONDENSE es_ekpo-downpaymenttype                   .
            CONDENSE es_ekpo-downpaymentpercentageoftotamt     .
            CONDENSE es_ekpo-downpaymentamount                 .
            CONDENSE es_ekpo-downpaymentduedate                .
            CONDENSE es_ekpo-expectedoveralllimitamount        .
            CONDENSE es_ekpo-overalllimitamount                .
            CONDENSE es_ekpo-requirementsegment                .
            CONDENSE es_ekpo-purgprodcmplncdngrsgoodsstatus    .
            CONDENSE es_ekpo-purgprodcmplncsupplierstatus      .
            CONDENSE es_ekpo-purgproductmarketabilitystatus    .
            CONDENSE es_ekpo-purgsafetydatasheetstatus         .
            CONDENSE es_ekpo-subcontrgcompisrealtmecnsmd       .
            CONDENSE es_ekpo-br_materialorigin                 .
            CONDENSE es_ekpo-br_materialusage                  .
            CONDENSE es_ekpo-br_cfopcategory                   .
            CONDENSE es_ekpo-br_ncm                            .
            CONDENSE es_ekpo-br_isproducedinhouse              .
            APPEND es_ekpo TO es_response_ekpo-items.


          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_ekpo-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_ekpo )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.

          lv_error = 'X'.

          if lv_error_message_ekpo is NOT INITIAL.
            lv_text = lv_error_message_ekpo.
          else.
            lv_text = 'There is no data in table'.
          ENDIF.
        ENDIF.

      WHEN `EKET` OR 'eket'.
        SELECT * FROM i_purordschedulelineapi01 WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_eket).

        IF lt_eket IS NOT INITIAL.
          LOOP  AT lt_eket INTO DATA(ls_eket).
            lv_count = lv_count + 1.
            es_eket-purchaseorder                        = ls_eket-purchaseorder                    .
            es_eket-purchaseorderitem                    = ls_eket-purchaseorderitem                .
            es_eket-purchaseorderscheduleline            = ls_eket-purchaseorderscheduleline        .
            es_eket-performanceperiodstartdate           = ls_eket-performanceperiodstartdate       .
            es_eket-performanceperiodenddate             = ls_eket-performanceperiodenddate         .
            es_eket-delivdatecategory                    = ls_eket-delivdatecategory                .
            es_eket-schedulelinedeliverydate             = ls_eket-schedulelinedeliverydate         .
            es_eket-schedulelinedeliverytime             = ls_eket-schedulelinedeliverytime         .
            es_eket-schedulelineorderquantity            = ls_eket-schedulelineorderquantity        .
            es_eket-roughgoodsreceiptqty                 = ls_eket-roughgoodsreceiptqty             .
            es_eket-purchaseorderquantityunit            = ls_eket-purchaseorderquantityunit        .
            es_eket-purchaserequisition                  = ls_eket-purchaserequisition              .
            es_eket-purchaserequisitionitem              = ls_eket-purchaserequisitionitem          .
            es_eket-sourceofcreation                     = ls_eket-sourceofcreation                 .
            es_eket-prevdelivqtyofscheduleline           = ls_eket-prevdelivqtyofscheduleline       .
            es_eket-noofremindersofscheduleline          = ls_eket-noofremindersofscheduleline      .
            es_eket-schedulelineisfixed                  = ls_eket-schedulelineisfixed              .
            es_eket-schedulelinecommittedquantity        = ls_eket-schedulelinecommittedquantity    .
            es_eket-reservation                          = ls_eket-reservation                      .
            es_eket-productavailabilitydate              = ls_eket-productavailabilitydate          .
            es_eket-materialstagingtime                  = ls_eket-materialstagingtime              .
            es_eket-transportationplanningdate           = ls_eket-transportationplanningdate       .
            es_eket-transportationplanningtime           = ls_eket-transportationplanningtime       .
            es_eket-loadingdate                          = ls_eket-loadingdate                      .
            es_eket-loadingtime                          = ls_eket-loadingtime                      .
            es_eket-goodsissuedate                       = ls_eket-goodsissuedate                   .
            es_eket-goodsissuetime                       = ls_eket-goodsissuetime                   .
            es_eket-stolatestpossiblegrdate              = ls_eket-stolatestpossiblegrdate          .
            es_eket-stolatestpossiblegrtime              = ls_eket-stolatestpossiblegrtime          .
            es_eket-stocktransferdeliveredquantity       = ls_eket-stocktransferdeliveredquantity   .
            es_eket-schedulelineissuedquantity           = ls_eket-schedulelineissuedquantity       .
            es_eket-batch                                = ls_eket-batch                            .

            CONDENSE es_eket-purchaseorder                                             .
            CONDENSE es_eket-purchaseorderitem                                         .
            CONDENSE es_eket-purchaseorderscheduleline                                 .
            CONDENSE es_eket-performanceperiodstartdate                                .
            CONDENSE es_eket-performanceperiodenddate                                  .
            CONDENSE es_eket-delivdatecategory                                         .
            CONDENSE es_eket-schedulelinedeliverydate                                  .
            CONDENSE es_eket-schedulelinedeliverytime                                  .
            CONDENSE es_eket-schedulelineorderquantity                                 .
            CONDENSE es_eket-roughgoodsreceiptqty                                      .
            CONDENSE es_eket-purchaseorderquantityunit                                 .
            CONDENSE es_eket-purchaserequisition                                       .
            CONDENSE es_eket-purchaserequisitionitem                                   .
            CONDENSE es_eket-sourceofcreation                                          .
            CONDENSE es_eket-prevdelivqtyofscheduleline                                .
            CONDENSE es_eket-noofremindersofscheduleline                               .
            CONDENSE es_eket-schedulelineisfixed                                       .
            CONDENSE es_eket-schedulelinecommittedquantity                             .
            CONDENSE es_eket-reservation                                               .
            CONDENSE es_eket-productavailabilitydate                                   .
            CONDENSE es_eket-materialstagingtime                                       .
            CONDENSE es_eket-transportationplanningdate                                .
            CONDENSE es_eket-transportationplanningtime                                .
            CONDENSE es_eket-loadingdate                                               .
            CONDENSE es_eket-loadingtime                                               .
            CONDENSE es_eket-goodsissuedate                                            .
            CONDENSE es_eket-goodsissuetime                                            .
            CONDENSE es_eket-stolatestpossiblegrdate                                   .
            CONDENSE es_eket-stolatestpossiblegrtime                                   .
            CONDENSE es_eket-stocktransferdeliveredquantity                            .
            CONDENSE es_eket-schedulelineissuedquantity                                .
            CONDENSE es_eket-batch                                                     .

            APPEND es_eket TO es_response_eket-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_eket-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_eket )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'EKBE'  OR 'ekbe' .
        SELECT * FROM i_purchaseorderhistoryapi01 WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_ekbe).

        IF lt_ekbe IS NOT INITIAL.
          LOOP  AT lt_ekbe INTO DATA(ls_ekbe).

            lv_count = lv_count + 1.
            es_ekbe-purchaseorder                                 = ls_ekbe-purchaseorder                     .
            es_ekbe-purchaseorderitem                             = ls_ekbe-purchaseorderitem                 .
            es_ekbe-accountassignmentnumber                       = ls_ekbe-accountassignmentnumber           .
            es_ekbe-purchasinghistorydocumenttype                 = ls_ekbe-purchasinghistorydocumenttype     .
            es_ekbe-purchasinghistorydocumentyear                 = ls_ekbe-purchasinghistorydocumentyear     .
            es_ekbe-purchasinghistorydocument                     = ls_ekbe-purchasinghistorydocument         .
            es_ekbe-purchasinghistorydocumentitem                 = ls_ekbe-purchasinghistorydocumentitem     .
            es_ekbe-purchasinghistorycategory                     = ls_ekbe-purchasinghistorycategory         .
            es_ekbe-goodsmovementtype                             = ls_ekbe-goodsmovementtype                 .
            es_ekbe-postingdate                                   = ls_ekbe-postingdate                       .
            es_ekbe-currency                                      = ls_ekbe-currency                          .
            es_ekbe-debitcreditcode                               = ls_ekbe-debitcreditcode                   .
            es_ekbe-iscompletelydelivered                         = ls_ekbe-iscompletelydelivered             .
            es_ekbe-referencedocumentfiscalyear                   = ls_ekbe-referencedocumentfiscalyear       .
            es_ekbe-referencedocument                             = ls_ekbe-referencedocument                 .
            es_ekbe-referencedocumentitem                         = ls_ekbe-referencedocumentitem             .
            es_ekbe-material                                      = ls_ekbe-material                          .
            es_ekbe-plant                                         = ls_ekbe-plant                             .
            es_ekbe-rvslofgoodsreceiptisallowed                   = ls_ekbe-rvslofgoodsreceiptisallowed       .
            es_ekbe-pricingdocument                               = ls_ekbe-pricingdocument                   .
            es_ekbe-taxcode                                       = ls_ekbe-taxcode                           .
            es_ekbe-documentdate                                  = ls_ekbe-documentdate                      .
            es_ekbe-inventoryvaluationtype                        = ls_ekbe-inventoryvaluationtype            .
            es_ekbe-documentreferenceid                           = ls_ekbe-documentreferenceid               .
            es_ekbe-deliveryquantityunit                          = ls_ekbe-deliveryquantityunit              .
            es_ekbe-manufacturermaterial                          = ls_ekbe-manufacturermaterial              .
            es_ekbe-accountingdocumentcreationdate                = ls_ekbe-accountingdocumentcreationdate    .
            es_ekbe-purghistdocumentcreationtime                  = ls_ekbe-purghistdocumentcreationtime      .
            es_ekbe-quantity                                      = ls_ekbe-quantity                          .
            es_ekbe-purordamountincompanycodecrcy                 = ls_ekbe-purordamountincompanycodecrcy     .
            es_ekbe-purchaseorderamount                           = ls_ekbe-purchaseorderamount               .
            es_ekbe-qtyinpurchaseorderpriceunit                   = ls_ekbe-qtyinpurchaseorderpriceunit       .
            es_ekbe-griracctclrgamtincocodecrcy                   = ls_ekbe-griracctclrgamtincocodecrcy       .
            es_ekbe-gdsrcptblkdstkqtyinordqtyunit                 = ls_ekbe-gdsrcptblkdstkqtyinordqtyunit     .
            es_ekbe-gdsrcptblkdstkqtyinordprcunit                 = ls_ekbe-gdsrcptblkdstkqtyinordprcunit     .
            es_ekbe-invoiceamtincocodecrcy                        = ls_ekbe-invoiceamtincocodecrcy            .
            es_ekbe-shipginstrnsuppliercompliance                 = ls_ekbe-shipginstrnsuppliercompliance     .
            es_ekbe-invoiceamountinfrgncurrency                   = ls_ekbe-invoiceamountinfrgncurrency       .
            es_ekbe-quantityindeliveryqtyunit                     = ls_ekbe-quantityindeliveryqtyunit         .
            es_ekbe-griracctclrgamtintransaccrcy                  = ls_ekbe-griracctclrgamtintransaccrcy      .
            es_ekbe-quantityinbaseunit                            = ls_ekbe-quantityinbaseunit                .
            es_ekbe-batch                                         = ls_ekbe-batch                             .
            es_ekbe-griracctclrgamtinordtrnsaccrcy                = ls_ekbe-griracctclrgamtinordtrnsaccrcy    .
            es_ekbe-invoiceamtinpurordtransaccrcy                 = ls_ekbe-invoiceamtinpurordtransaccrcy     .
            es_ekbe-vltdgdsrcptblkdstkqtyinordunit                = ls_ekbe-vltdgdsrcptblkdstkqtyinordunit    .
            es_ekbe-vltdgdsrcptblkdqtyinordprcunit                = ls_ekbe-vltdgdsrcptblkdqtyinordprcunit    .
            es_ekbe-istobeacceptedatorigin                        = ls_ekbe-istobeacceptedatorigin            .
            es_ekbe-exchangeratedifferenceamount                  = ls_ekbe-exchangeratedifferenceamount      .
            es_ekbe-exchangerate                                  = ls_ekbe-exchangerate                      .
            es_ekbe-deliverydocument                              = ls_ekbe-deliverydocument                  .
            es_ekbe-deliverydocumentitem                          = ls_ekbe-deliverydocumentitem              .
            es_ekbe-orderpriceunit                                = ls_ekbe-orderpriceunit                    .
            es_ekbe-purchaseorderquantityunit                     = ls_ekbe-purchaseorderquantityunit         .
            es_ekbe-baseunit                                      = ls_ekbe-baseunit                          .
            es_ekbe-documentcurrency                              = ls_ekbe-documentcurrency                  .
            es_ekbe-companycodecurrency                           = ls_ekbe-companycodecurrency               .


            CONDENSE es_ekbe-purchaseorder                                  .
            CONDENSE es_ekbe-purchaseorderitem                              .
            CONDENSE es_ekbe-accountassignmentnumber                        .
            CONDENSE es_ekbe-purchasinghistorydocumenttype                  .
            CONDENSE es_ekbe-purchasinghistorydocumentyear                  .
            CONDENSE es_ekbe-purchasinghistorydocument                      .
            CONDENSE es_ekbe-purchasinghistorydocumentitem                  .
            CONDENSE es_ekbe-purchasinghistorycategory                      .
            CONDENSE es_ekbe-goodsmovementtype                              .
            CONDENSE es_ekbe-postingdate                                    .
            CONDENSE es_ekbe-currency                                       .
            CONDENSE es_ekbe-debitcreditcode                                .
            CONDENSE es_ekbe-iscompletelydelivered                          .
            CONDENSE es_ekbe-referencedocumentfiscalyear                    .
            CONDENSE es_ekbe-referencedocument                              .
            CONDENSE es_ekbe-referencedocumentitem                          .
            CONDENSE es_ekbe-material                                       .
            CONDENSE es_ekbe-plant                                          .
            CONDENSE es_ekbe-rvslofgoodsreceiptisallowed                    .
            CONDENSE es_ekbe-pricingdocument                                .
            CONDENSE es_ekbe-taxcode                                        .
            CONDENSE es_ekbe-documentdate                                   .
            CONDENSE es_ekbe-inventoryvaluationtype                         .
            CONDENSE es_ekbe-documentreferenceid                            .
            CONDENSE es_ekbe-deliveryquantityunit                           .
            CONDENSE es_ekbe-manufacturermaterial                           .
            CONDENSE es_ekbe-accountingdocumentcreationdate                 .
            CONDENSE es_ekbe-purghistdocumentcreationtime                   .
            CONDENSE es_ekbe-quantity                                       .
            CONDENSE es_ekbe-purordamountincompanycodecrcy                  .
            CONDENSE es_ekbe-purchaseorderamount                            .
            CONDENSE es_ekbe-qtyinpurchaseorderpriceunit                    .
            CONDENSE es_ekbe-griracctclrgamtincocodecrcy                    .
            CONDENSE es_ekbe-gdsrcptblkdstkqtyinordqtyunit                  .
            CONDENSE es_ekbe-gdsrcptblkdstkqtyinordprcunit                  .
            CONDENSE es_ekbe-invoiceamtincocodecrcy                         .
            CONDENSE es_ekbe-shipginstrnsuppliercompliance                  .
            CONDENSE es_ekbe-invoiceamountinfrgncurrency                    .
            CONDENSE es_ekbe-quantityindeliveryqtyunit                      .
            CONDENSE es_ekbe-griracctclrgamtintransaccrcy                   .
            CONDENSE es_ekbe-quantityinbaseunit                             .
            CONDENSE es_ekbe-batch                                          .
            CONDENSE es_ekbe-griracctclrgamtinordtrnsaccrcy                 .
            CONDENSE es_ekbe-invoiceamtinpurordtransaccrcy                  .
            CONDENSE es_ekbe-vltdgdsrcptblkdstkqtyinordunit                 .
            CONDENSE es_ekbe-vltdgdsrcptblkdqtyinordprcunit                 .
            CONDENSE es_ekbe-istobeacceptedatorigin                         .
            CONDENSE es_ekbe-exchangeratedifferenceamount                   .
            CONDENSE es_ekbe-exchangerate                                   .
            CONDENSE es_ekbe-deliverydocument                               .
            CONDENSE es_ekbe-deliverydocumentitem                           .
            CONDENSE es_ekbe-orderpriceunit                                 .
            CONDENSE es_ekbe-purchaseorderquantityunit                      .
            CONDENSE es_ekbe-baseunit                                       .
            CONDENSE es_ekbe-documentcurrency                               .
            CONDENSE es_ekbe-companycodecurrency                            .

            APPEND es_ekbe TO es_response_ekbe-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_ekbe-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_ekbe )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'EKKN'  OR 'ekkn' .
        SELECT * FROM i_purordaccountassignmentapi01 WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_ekkn).

        IF lt_ekkn IS NOT INITIAL.
          LOOP AT lt_ekkn INTO DATA(ls_ekkn).
            lv_count = lv_count + 1.
            es_ekkn-purchaseorder                    = ls_ekkn-purchaseorder.
            es_ekkn-purchaseorderitem                = ls_ekkn-purchaseorderitem.
            es_ekkn-accountassignmentnumber          = ls_ekkn-accountassignmentnumber.
            es_ekkn-costcenter                       = ls_ekkn-costcenter.
            es_ekkn-masterfixedasset                 = ls_ekkn-masterfixedasset.
            es_ekkn-projectnetwork                   = ls_ekkn-projectnetwork.
            es_ekkn-quantity                         = ls_ekkn-quantity.
            es_ekkn-purchaseorderquantityunit        = ls_ekkn-purchaseorderquantityunit.
            es_ekkn-multipleacctassgmtdistrpercent   = ls_ekkn-multipleacctassgmtdistrpercent.
            es_ekkn-purgdocnetamount                 = ls_ekkn-purgdocnetamount.
            es_ekkn-documentcurrency                 = ls_ekkn-documentcurrency.
            es_ekkn-isdeleted                        = ls_ekkn-isdeleted.
            es_ekkn-glaccount                        = ls_ekkn-glaccount.
            es_ekkn-businessarea                     = ls_ekkn-businessarea.
            es_ekkn-salesorder                       = ls_ekkn-salesorder.
            es_ekkn-salesorderitem                   = ls_ekkn-salesorderitem.
            es_ekkn-salesorderscheduleline           = ls_ekkn-salesorderscheduleline.
            es_ekkn-fixedasset                       = ls_ekkn-fixedasset.
            es_ekkn-orderid                          = ls_ekkn-orderid.
            es_ekkn-unloadingpointname               = ls_ekkn-unloadingpointname.
            es_ekkn-controllingarea                  = ls_ekkn-controllingarea.
            es_ekkn-costobject                       = ls_ekkn-costobject.
            es_ekkn-profitabilitysegment_2           = ls_ekkn-profitabilitysegment_2.
            es_ekkn-profitcenter                     = ls_ekkn-profitcenter.
            es_ekkn-wbselementinternalid_2           = ls_ekkn-wbselementinternalid_2.
            es_ekkn-projectnetworkinternalid         = ls_ekkn-projectnetworkinternalid.
            es_ekkn-commitmentitemshortid            = ls_ekkn-commitmentitemshortid.
            es_ekkn-fundscenter                      = ls_ekkn-fundscenter.
            es_ekkn-fund                             = ls_ekkn-fund.
            es_ekkn-functionalarea                   = ls_ekkn-functionalarea.
            es_ekkn-goodsrecipientname               = ls_ekkn-goodsrecipientname.
            es_ekkn-isfinallyinvoiced                = ls_ekkn-isfinallyinvoiced.
*            es_ekkn-realestateobject                 = ls_ekkn-realestateobject.
            es_ekkn-reinternalfinnumber              = ls_ekkn-reinternalfinnumber.
            es_ekkn-networkactivityinternalid        = ls_ekkn-networkactivityinternalid.
            es_ekkn-partneraccountnumber             = ls_ekkn-partneraccountnumber.
            es_ekkn-jointventurerecoverycode         = ls_ekkn-jointventurerecoverycode.
            es_ekkn-settlementreferencedate          = ls_ekkn-settlementreferencedate.
            es_ekkn-orderinternalid                  = ls_ekkn-orderinternalid.
            es_ekkn-orderintbillofoperationsitem     = ls_ekkn-orderintbillofoperationsitem.
            es_ekkn-taxcode                          = ls_ekkn-taxcode.
            es_ekkn-taxjurisdiction                  = ls_ekkn-taxjurisdiction.
            es_ekkn-nondeductibleinputtaxamount      = ls_ekkn-nondeductibleinputtaxamount.
            es_ekkn-costctractivitytype              = ls_ekkn-costctractivitytype.
            es_ekkn-businessprocess                  = ls_ekkn-businessprocess.
            es_ekkn-grantid                          = ls_ekkn-grantid.
            es_ekkn-budgetperiod                     = ls_ekkn-budgetperiod.
            es_ekkn-earmarkedfundsdocument           = ls_ekkn-earmarkedfundsdocument.
*            es_ekkn-earmarkedfundsitem               = ls_ekkn-earmarkedfundsitem.
            es_ekkn-earmarkedfundsdocumentitem       = ls_ekkn-earmarkedfundsdocumentitem.
            es_ekkn-servicedocumenttype              = ls_ekkn-servicedocumenttype.
            es_ekkn-servicedocument                  = ls_ekkn-servicedocument.
            es_ekkn-servicedocumentitem              = ls_ekkn-servicedocumentitem.

            CONDENSE es_ekkn-purchaseorder                      .
            CONDENSE es_ekkn-purchaseorderitem                  .
            CONDENSE es_ekkn-accountassignmentnumber            .
            CONDENSE es_ekkn-costcenter                         .
            CONDENSE es_ekkn-masterfixedasset                   .
            CONDENSE es_ekkn-projectnetwork                     .
            CONDENSE es_ekkn-quantity                           .
            CONDENSE es_ekkn-purchaseorderquantityunit          .
            CONDENSE es_ekkn-multipleacctassgmtdistrpercent     .
            CONDENSE es_ekkn-purgdocnetamount                   .
            CONDENSE es_ekkn-documentcurrency                   .
            CONDENSE es_ekkn-isdeleted                          .
            CONDENSE es_ekkn-glaccount                          .
            CONDENSE es_ekkn-businessarea                       .
            CONDENSE es_ekkn-salesorder                         .
            CONDENSE es_ekkn-salesorderitem                     .
            CONDENSE es_ekkn-salesorderscheduleline             .
            CONDENSE es_ekkn-fixedasset                         .
            CONDENSE es_ekkn-orderid                            .
            CONDENSE es_ekkn-unloadingpointname                 .
            CONDENSE es_ekkn-controllingarea                    .
            CONDENSE es_ekkn-costobject                         .
            CONDENSE es_ekkn-profitabilitysegment               .
            CONDENSE es_ekkn-profitabilitysegment_2             .
            CONDENSE es_ekkn-profitcenter                       .
            CONDENSE es_ekkn-wbselementinternalid               .
            CONDENSE es_ekkn-wbselementinternalid_2             .
            CONDENSE es_ekkn-projectnetworkinternalid           .
            CONDENSE es_ekkn-commitmentitem                     .
            CONDENSE es_ekkn-commitmentitemshortid              .
            CONDENSE es_ekkn-fundscenter                        .
            CONDENSE es_ekkn-fund                               .
            CONDENSE es_ekkn-functionalarea                     .
            CONDENSE es_ekkn-goodsrecipientname                 .
            CONDENSE es_ekkn-isfinallyinvoiced                  .
            CONDENSE es_ekkn-realestateobject                   .
            CONDENSE es_ekkn-reinternalfinnumber                .
            CONDENSE es_ekkn-networkactivityinternalid          .
            CONDENSE es_ekkn-partneraccountnumber               .
            CONDENSE es_ekkn-jointventurerecoverycode           .
            CONDENSE es_ekkn-settlementreferencedate            .
            CONDENSE es_ekkn-orderinternalid                    .
            CONDENSE es_ekkn-orderintbillofoperationsitem       .
            CONDENSE es_ekkn-taxcode                            .
            CONDENSE es_ekkn-taxjurisdiction                    .
            CONDENSE es_ekkn-nondeductibleinputtaxamount        .
            CONDENSE es_ekkn-costctractivitytype                .
            CONDENSE es_ekkn-businessprocess                    .
            CONDENSE es_ekkn-grantid                            .
            CONDENSE es_ekkn-budgetperiod                       .
            CONDENSE es_ekkn-earmarkedfundsdocument             .
            CONDENSE es_ekkn-earmarkedfundsitem                 .
            CONDENSE es_ekkn-earmarkedfundsdocumentitem         .
            CONDENSE es_ekkn-servicedocumenttype                .
            CONDENSE es_ekkn-servicedocument                    .
            CONDENSE es_ekkn-servicedocumentitem                .

            APPEND es_ekkn TO es_response_ekkn-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_ekkn-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_ekkn )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'MARA'  OR 'mara' .
        SELECT a~*,
               b~PackagingMaterialType
        FROM i_product WITH PRIVILEGED ACCESS as a
        left join I_ProductSales WITH PRIVILEGED ACCESS as b
        on a~product = b~product
        WHERE (lv_where)
        INTO TABLE @DATA(lt_mara).

        IF lt_mara IS NOT INITIAL.
          LOOP AT lt_mara INTO DATA(ls_mara).
          lv_count = lv_count + 1.
          MOVE-CORRESPONDING ls_mara-a to es_mara.
          es_mara-PackagingMaterialType = ls_mara-PackagingMaterialType .
*            es_mara-product                           = ls_mara-product.
*            es_mara-productexternalid                 = ls_mara-productexternalid.
*            es_mara-productoid                        = ls_mara-productoid.
*            es_mara-producttype                       = ls_mara-producttype.
*            es_mara-creationdate                      = ls_mara-creationdate.
*            es_mara-creationtime                      = ls_mara-creationtime.
*            es_mara-creationdatetime                  = ls_mara-creationdatetime.
*            es_mara-createdbyuser                     = ls_mara-createdbyuser.
*            es_mara-lastchangedate                    = ls_mara-lastchangedate.
*            es_mara-lastchangedbyuser                 = ls_mara-lastchangedbyuser.
*            es_mara-ismarkedfordeletion               = ls_mara-ismarkedfordeletion.
*            es_mara-crossplantstatus                  = ls_mara-crossplantstatus.
*            es_mara-crossplantstatusvaliditydate      = ls_mara-crossplantstatusvaliditydate.
*            es_mara-productoldid                      = ls_mara-productoldid.
*            es_mara-grossweight                       = ls_mara-grossweight.
*            es_mara-purchaseorderquantityunit         = ls_mara-purchaseorderquantityunit.
*            es_mara-sourceofsupply                    = ls_mara-sourceofsupply.
*            es_mara-weightunit                        = ls_mara-weightunit.
*            es_mara-countryoforigin                   = ls_mara-countryoforigin.
*            es_mara-competitorid                      = ls_mara-competitorid.
*            es_mara-productgroup                      = ls_mara-productgroup.
*            es_mara-baseunit                          = ls_mara-baseunit.
*            es_mara-itemcategorygroup                 = ls_mara-itemcategorygroup.
*            es_mara-netweight                         = ls_mara-netweight.
*            es_mara-producthierarchy                  = ls_mara-producthierarchy.
*            es_mara-division                          = ls_mara-division.
*            es_mara-varblpurordunitisactive           = ls_mara-varblpurordunitisactive.
*            es_mara-volumeunit                        = ls_mara-volumeunit.
*            es_mara-materialvolume                    = ls_mara-materialvolume.
*            es_mara-salesstatus                       = ls_mara-salesstatus.
*            es_mara-transportationgroup               = ls_mara-transportationgroup.
*            es_mara-salesstatusvaliditydate           = ls_mara-salesstatusvaliditydate.
*            es_mara-authorizationgroup                = ls_mara-authorizationgroup.
*            es_mara-anpcode                           = ls_mara-anpcode.
*            es_mara-productcategory                   = ls_mara-productcategory.
*            es_mara-brand                             = ls_mara-brand.
*            es_mara-procurementrule                   = ls_mara-procurementrule.
*            es_mara-validitystartdate                 = ls_mara-validitystartdate.
*            es_mara-lowlevelcode                      = ls_mara-lowlevelcode.
*            es_mara-prodnoingenprodinprepackprod      = ls_mara-prodnoingenprodinprepackprod.
*            es_mara-serialidentifierassgmtprofile     = ls_mara-serialidentifierassgmtprofile.
*            es_mara-sizeordimensiontext               = ls_mara-sizeordimensiontext.
*            es_mara-industrystandardname              = ls_mara-industrystandardname.
*            es_mara-productstandardid                 = ls_mara-productstandardid.
*            es_mara-internationalarticlenumbercat     = ls_mara-internationalarticlenumbercat.
*            es_mara-productisconfigurable             = ls_mara-productisconfigurable.
*            es_mara-isbatchmanagementrequired         = ls_mara-isbatchmanagementrequired.
*            es_mara-hasemptiesbom                     = ls_mara-hasemptiesbom.
*            es_mara-externalproductgroup              = ls_mara-externalproductgroup.
*            es_mara-crossplantconfigurableproduct     = ls_mara-crossplantconfigurableproduct.
*            es_mara-serialnoexplicitnesslevel         = ls_mara-serialnoexplicitnesslevel.
*            es_mara-productmanufacturernumber         = ls_mara-productmanufacturernumber.
*            es_mara-manufacturernumber                = ls_mara-manufacturernumber.
*            es_mara-manufacturerpartprofile           = ls_mara-manufacturerpartprofile.
*            es_mara-qltymgmtinprocmtisactive          = ls_mara-qltymgmtinprocmtisactive.
*            es_mara-isapprovedbatchrecordreqd         = ls_mara-isapprovedbatchrecordreqd.
*            es_mara-handlingindicator                 = ls_mara-handlingindicator.
*            es_mara-warehouseproductgroup             = ls_mara-warehouseproductgroup.
*            es_mara-warehousestoragecondition         = ls_mara-warehousestoragecondition.
*            es_mara-standardhandlingunittype          = ls_mara-standardhandlingunittype.
*            es_mara-serialnumberprofile               = ls_mara-serialnumberprofile.
*            es_mara-adjustmentprofile                 = ls_mara-adjustmentprofile.
*            es_mara-preferredunitofmeasure            = ls_mara-preferredunitofmeasure.
*            es_mara-ispilferable                      = ls_mara-ispilferable.
*            es_mara-isrelevantforhzdssubstances       = ls_mara-isrelevantforhzdssubstances.
*            es_mara-quarantineperiod                  = ls_mara-quarantineperiod.
*            es_mara-timeunitforquarantineperiod       = ls_mara-timeunitforquarantineperiod.
*            es_mara-qualityinspectiongroup            = ls_mara-qualityinspectiongroup.
*            es_mara-handlingunittype                  = ls_mara-handlingunittype.
*            es_mara-hasvariabletareweight             = ls_mara-hasvariabletareweight.
*            es_mara-maximumpackaginglength            = ls_mara-maximumpackaginglength.
*            es_mara-maximumpackagingwidth             = ls_mara-maximumpackagingwidth.
*            es_mara-maximumpackagingheight            = ls_mara-maximumpackagingheight.
*            es_mara-maximumcapacity                   = ls_mara-maximumcapacity.
*            es_mara-overcapacitytolerance             = ls_mara-overcapacitytolerance.
*            es_mara-unitformaxpackagingdimensions     = ls_mara-unitformaxpackagingdimensions.
*            es_mara-baseunitspecificproductlength     = ls_mara-baseunitspecificproductlength.
*            es_mara-baseunitspecificproductwidth      = ls_mara-baseunitspecificproductwidth.
*            es_mara-baseunitspecificproductheight     = ls_mara-baseunitspecificproductheight.
*            es_mara-productmeasurementunit            = ls_mara-productmeasurementunit.
*            es_mara-productvalidstartdate             = ls_mara-productvalidstartdate.
*            es_mara-articlecategory                   = ls_mara-articlecategory.
*            es_mara-contentunit                       = ls_mara-contentunit.
*            es_mara-netcontent                        = ls_mara-netcontent.
*            es_mara-comparisonpricequantity           = ls_mara-comparisonpricequantity.
*            es_mara-grosscontent                      = ls_mara-grosscontent.
*            es_mara-productvalidenddate               = ls_mara-productvalidenddate.
*            es_mara-assortmentlisttype                = ls_mara-assortmentlisttype.
*            es_mara-hastextilepartswthanimalorigin    = ls_mara-hastextilepartswthanimalorigin.
*            es_mara-productseasonusagecategory        = ls_mara-productseasonusagecategory.
*            es_mara-industrysector                    = ls_mara-industrysector.
*            es_mara-changenumber                      = ls_mara-changenumber.
*            es_mara-materialrevisionlevel             = ls_mara-materialrevisionlevel.
*            es_mara-isactiveentity                    = ls_mara-isactiveentity.
*            es_mara-lastchangedatetime                = ls_mara-lastchangedatetime.
*            es_mara-lastchangetime                    = ls_mara-lastchangetime.
*            es_mara-dangerousgoodsindprofile          = ls_mara-dangerousgoodsindprofile.
*            es_mara-productuuid                       = ls_mara-productuuid.
*            es_mara-prodsupchnmgmtuuid22              = ls_mara-prodsupchnmgmtuuid22.
*            es_mara-productdocumentchangenumber       = ls_mara-productdocumentchangenumber.
*            es_mara-productdocumentpagecount          = ls_mara-productdocumentpagecount.
*            es_mara-productdocumentpagenumber         = ls_mara-productdocumentpagenumber.
*            es_mara-owninventorymanagedproduct        = ls_mara-owninventorymanagedproduct.
*            es_mara-documentiscreatedbycad            = ls_mara-documentiscreatedbycad.
*            es_mara-productionorinspectionmemotxt     = ls_mara-productionorinspectionmemotxt.
*            es_mara-productionmemopageformat          = ls_mara-productionmemopageformat.
*            es_mara-globaltradeitemnumbervariant      = ls_mara-globaltradeitemnumbervariant.
*            es_mara-productishighlyviscous            = ls_mara-productishighlyviscous.
*            es_mara-transportisinbulk                 = ls_mara-transportisinbulk.
*            es_mara-prodallocdetnprocedure            = ls_mara-prodallocdetnprocedure.
*            es_mara-prodeffctyparamvalsareassigned    = ls_mara-prodeffctyparamvalsareassigned.
*            es_mara-prodisenvironmentallyrelevant     = ls_mara-prodisenvironmentallyrelevant.
*            es_mara-laboratoryordesignoffice          = ls_mara-laboratoryordesignoffice.
*            es_mara-packagingmaterialgroup            = ls_mara-packagingmaterialgroup.
*            es_mara-productislocked                   = ls_mara-productislocked.
*            es_mara-discountinkindeligibility         = ls_mara-discountinkindeligibility.
*            es_mara-smartformname                     = ls_mara-smartformname.
*            es_mara-packingreferenceproduct           = ls_mara-packingreferenceproduct.
*            es_mara-basicmaterial                     = ls_mara-basicmaterial.
*            es_mara-productdocumentnumber             = ls_mara-productdocumentnumber.
*            es_mara-productdocumentversion            = ls_mara-productdocumentversion.
*            es_mara-productdocumenttype               = ls_mara-productdocumenttype.
*            es_mara-productdocumentpageformat         = ls_mara-productdocumentpageformat.
*            es_mara-productconfiguration              = ls_mara-productconfiguration.
*            es_mara-segmentationstrategy              = ls_mara-segmentationstrategy.
*            es_mara-segmentationisrelevant            = ls_mara-segmentationisrelevant.
*            es_mara-productcompositionisrelevant      = ls_mara-productcompositionisrelevant.
*            es_mara-ischemicalcompliancerelevant      = ls_mara-ischemicalcompliancerelevant.
*            es_mara-manufacturerbookpartnumber        = ls_mara-manufacturerbookpartnumber.
*            es_mara-logisticalproductcategory         = ls_mara-logisticalproductcategory.
*            es_mara-salesproduct                      = ls_mara-salesproduct.
*            es_mara-prodcharc1internalnumber          = ls_mara-prodcharc1internalnumber.
*            es_mara-prodcharc2internalnumber          = ls_mara-prodcharc2internalnumber.
*            es_mara-prodcharc3internalnumber          = ls_mara-prodcharc3internalnumber.
*            es_mara-productcharacteristic1            = ls_mara-productcharacteristic1.
*            es_mara-productcharacteristic2            = ls_mara-productcharacteristic2.
*            es_mara-productcharacteristic3            = ls_mara-productcharacteristic3.
*            es_mara-maintenancestatus                 = ls_mara-maintenancestatus.
*            es_mara-fashionprodinformationfield1      = ls_mara-fashionprodinformationfield1.
*            es_mara-fashionprodinformationfield2      = ls_mara-fashionprodinformationfield2.
*            es_mara-fashionprodinformationfield3      = ls_mara-fashionprodinformationfield3.

*            CONDENSE es_mara-product                         .
*            CONDENSE es_mara-productexternalid               .
*            CONDENSE es_mara-productoid                      .
*            CONDENSE es_mara-producttype                     .
*            CONDENSE es_mara-creationdate                    .
*            CONDENSE es_mara-creationtime                    .
*            CONDENSE es_mara-creationdatetime                .
*            CONDENSE es_mara-createdbyuser                   .
*            CONDENSE es_mara-lastchangedate                  .
*            CONDENSE es_mara-lastchangedbyuser               .
*            CONDENSE es_mara-ismarkedfordeletion             .
*            CONDENSE es_mara-crossplantstatus                .
*            CONDENSE es_mara-crossplantstatusvaliditydate    .
*            CONDENSE es_mara-productoldid                    .
*            CONDENSE es_mara-grossweight                     .
*            CONDENSE es_mara-purchaseorderquantityunit       .
*            CONDENSE es_mara-sourceofsupply                  .
*            CONDENSE es_mara-weightunit                      .
*            CONDENSE es_mara-countryoforigin                 .
*            CONDENSE es_mara-competitorid                    .
*            CONDENSE es_mara-productgroup                    .
*            CONDENSE es_mara-baseunit                        .
*            CONDENSE es_mara-itemcategorygroup               .
*            CONDENSE es_mara-netweight                       .
*            CONDENSE es_mara-producthierarchy                .
*            CONDENSE es_mara-division                        .
*            CONDENSE es_mara-varblpurordunitisactive         .
*            CONDENSE es_mara-volumeunit                      .
*            CONDENSE es_mara-materialvolume                  .
*            CONDENSE es_mara-salesstatus                     .
*            CONDENSE es_mara-transportationgroup             .
*            CONDENSE es_mara-salesstatusvaliditydate         .
*            CONDENSE es_mara-authorizationgroup              .
*            CONDENSE es_mara-anpcode                         .
*            CONDENSE es_mara-productcategory                 .
*            CONDENSE es_mara-brand                           .
*            CONDENSE es_mara-procurementrule                 .
*            CONDENSE es_mara-validitystartdate               .
*            CONDENSE es_mara-lowlevelcode                    .
*            CONDENSE es_mara-prodnoingenprodinprepackprod    .
*            CONDENSE es_mara-serialidentifierassgmtprofile   .
*            CONDENSE es_mara-sizeordimensiontext             .
*            CONDENSE es_mara-industrystandardname            .
*            CONDENSE es_mara-productstandardid               .
*            CONDENSE es_mara-internationalarticlenumbercat   .
*            CONDENSE es_mara-productisconfigurable           .
*            CONDENSE es_mara-isbatchmanagementrequired       .
*            CONDENSE es_mara-hasemptiesbom                   .
*            CONDENSE es_mara-externalproductgroup            .
*            CONDENSE es_mara-crossplantconfigurableproduct   .
*            CONDENSE es_mara-serialnoexplicitnesslevel       .
*            CONDENSE es_mara-productmanufacturernumber       .
*            CONDENSE es_mara-manufacturernumber              .
*            CONDENSE es_mara-manufacturerpartprofile          .
*            CONDENSE es_mara-qltymgmtinprocmtisactive         .
*            CONDENSE es_mara-isapprovedbatchrecordreqd        .
*            CONDENSE es_mara-handlingindicator                .
*            CONDENSE es_mara-warehouseproductgroup            .
*            CONDENSE es_mara-warehousestoragecondition        .
*            CONDENSE es_mara-standardhandlingunittype         .
*            CONDENSE es_mara-serialnumberprofile              .
*            CONDENSE es_mara-adjustmentprofile                .
*            CONDENSE es_mara-preferredunitofmeasure           .
*            CONDENSE es_mara-ispilferable                     .
*            CONDENSE es_mara-isrelevantforhzdssubstances      .
*            CONDENSE es_mara-quarantineperiod                 .
*            CONDENSE es_mara-timeunitforquarantineperiod      .
*            CONDENSE es_mara-qualityinspectiongroup           .
*            CONDENSE es_mara-handlingunittype                 .
*            CONDENSE es_mara-hasvariabletareweight            .
*            CONDENSE es_mara-maximumpackaginglength           .
*            CONDENSE es_mara-maximumpackagingwidth            .
*            CONDENSE es_mara-maximumpackagingheight           .
*            CONDENSE es_mara-maximumcapacity                  .
*            CONDENSE es_mara-overcapacitytolerance            .
*            CONDENSE es_mara-unitformaxpackagingdimensions    .
*            CONDENSE es_mara-baseunitspecificproductlength    .
*            CONDENSE es_mara-baseunitspecificproductwidth     .
*            CONDENSE es_mara-baseunitspecificproductheight    .
*            CONDENSE es_mara-productmeasurementunit           .
*            CONDENSE es_mara-productvalidstartdate            .
*            CONDENSE es_mara-articlecategory                  .
*            CONDENSE es_mara-contentunit                      .
*            CONDENSE es_mara-netcontent                       .
*            CONDENSE es_mara-comparisonpricequantity          .
*            CONDENSE es_mara-grosscontent                     .
*            CONDENSE es_mara-productvalidenddate              .
*            CONDENSE es_mara-assortmentlisttype               .
*            CONDENSE es_mara-hastextilepartswthanimalorigin   .
*            CONDENSE es_mara-productseasonusagecategory       .
*            CONDENSE es_mara-industrysector                   .
*            CONDENSE es_mara-changenumber                     .
*            CONDENSE es_mara-materialrevisionlevel            .
*            CONDENSE es_mara-isactiveentity                   .
*            CONDENSE es_mara-lastchangedatetime               .
*            CONDENSE es_mara-lastchangetime                   .
*            CONDENSE es_mara-dangerousgoodsindprofile         .
*            CONDENSE es_mara-productuuid                      .
*            CONDENSE es_mara-prodsupchnmgmtuuid22             .
*            CONDENSE es_mara-productdocumentchangenumber      .
*            CONDENSE es_mara-productdocumentpagecount         .
*            CONDENSE es_mara-productdocumentpagenumber        .
*            CONDENSE es_mara-owninventorymanagedproduct       .
*            CONDENSE es_mara-documentiscreatedbycad           .
*            CONDENSE es_mara-productionorinspectionmemotxt    .
*            CONDENSE es_mara-productionmemopageformat         .
*            CONDENSE es_mara-globaltradeitemnumbervariant     .
*            CONDENSE es_mara-productishighlyviscous           .
*            CONDENSE es_mara-transportisinbulk                .
*            CONDENSE es_mara-prodallocdetnprocedure           .
*            CONDENSE es_mara-prodeffctyparamvalsareassigned   .
*            CONDENSE es_mara-prodisenvironmentallyrelevant    .
*            CONDENSE es_mara-laboratoryordesignoffice         .
*            CONDENSE es_mara-packagingmaterialgroup           .
*            CONDENSE es_mara-productislocked                  .
*            CONDENSE es_mara-discountinkindeligibility        .
*            CONDENSE es_mara-smartformname                    .
*            CONDENSE es_mara-packingreferenceproduct          .
*            CONDENSE es_mara-basicmaterial                    .
*            CONDENSE es_mara-productdocumentnumber            .
*            CONDENSE es_mara-productdocumentversion           .
*            CONDENSE es_mara-productdocumenttype              .
*            CONDENSE es_mara-productdocumentpageformat        .
*            CONDENSE es_mara-productconfiguration             .
*            CONDENSE es_mara-segmentationstrategy             .
*            CONDENSE es_mara-segmentationisrelevant           .
*            CONDENSE es_mara-productcompositionisrelevant     .
*            CONDENSE es_mara-ischemicalcompliancerelevant     .
*            CONDENSE es_mara-manufacturerbookpartnumber       .
*            CONDENSE es_mara-logisticalproductcategory        .
*            CONDENSE es_mara-salesproduct                     .
*            CONDENSE es_mara-prodcharc1internalnumber         .
*            CONDENSE es_mara-prodcharc2internalnumber         .
*            CONDENSE es_mara-prodcharc3internalnumber         .
*            CONDENSE es_mara-productcharacteristic1           .
*            CONDENSE es_mara-productcharacteristic2           .
*            CONDENSE es_mara-productcharacteristic3           .
*            CONDENSE es_mara-maintenancestatus                .
*            CONDENSE es_mara-fashionprodinformationfield1     .
*            CONDENSE es_mara-fashionprodinformationfield2     .
*            CONDENSE es_mara-fashionprodinformationfield3     .

            APPEND es_mara TO es_response_mara-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_mara-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_mara )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'MAKT'  OR 'makt' .
        SELECT * FROM i_producttext WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_makt).

        IF lt_makt IS NOT INITIAL.
          LOOP  AT lt_makt INTO DATA(ls_makt).
          lv_count = lv_count + 1.

            es_makt-product                                     = ls_makt-product                         .
            es_makt-language                                    = ls_makt-language                        .
            es_makt-productname                                 = ls_makt-productname                     .

            CONDENSE es_makt-product                                      .
            CONDENSE es_makt-language                                     .
            CONDENSE es_makt-productname                                  .

            APPEND es_makt TO es_response_makt-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_makt-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_makt )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'MARD'  OR 'mard' .


DATA:
      lv_error_message TYPE string,                   " 错误信息
      lv_sql_statement TYPE string,                   " SQL 语句
      lt_mardbase type STANDARD TABLE OF ty_mard.

        try.
             SELECT     Material,
                        Plant,
                        StorageLocation,
                        InventoryStockType,
                        InventorySpecialStockType,
                        sum( MatlWrhsStkQtyInMatlBaseUnit ) as unit

             FROM I_MaterialStock_2 WITH PRIVILEGED ACCESS
             WHERE (lv_where)
             GROUP BY Material, Plant, StorageLocation, InventoryStockType, InventorySpecialStockType
             into table @data(lt_mard).

         catch cx_sy_dynamic_osql_error into data(lo_sql_error).


            lv_error = 'X'.


            lv_error_message = lo_sql_error->get_text( ).    " 获取错误描述

         ENDTRY.



         if lt_mard is not INITIAL.

             data(lt_mard1) = lt_mard .

             SORT lt_mard1 by Material Plant StorageLocation.
             DELETE ADJACENT DUPLICATES FROM lt_mard1 COMPARING Material Plant StorageLocation.

             move-CORRESPONDING lt_mard1 to lt_mardbase.

             loop at lt_mardbase ASSIGNING FIELD-SYMBOL(<fs_mardbase>).

                  loop at lt_mard into data(lw_mard) where material = <fs_mardbase>-material
                                                     and   plant = <fs_mardbase>-plant
                                                     and   storagelocation = <fs_mardbase>-storagelocation.

                    case lw_mard-InventoryStockType.
*
                    when '01'.

                        if lw_mard-InventorySpecialStockType = 'K'.

                        <fs_mardbase>-klabs = lw_mard-unit.

                        ELSEIF lw_mard-InventorySpecialStockType = ''.

                         <fs_mardbase>-LABST = lw_mard-unit..
                        ENDIF.

                    when '02'.

                        if lw_mard-InventorySpecialStockType = 'K'.

                             <fs_mardbase>-KINSM = lw_mard-Unit.

                        elseif lw_mard-InventorySpecialStockType = ''.

                             <fs_mardbase>-INSME = lw_mard-Unit.

                        endif.

                    when OTHERS.

                    ENDCASE.
                  ENDLOOP.

             ENDLOOP.

         ENDIF.


        IF lt_mardbase IS NOT INITIAL.
          LOOP  AT lt_mardbase INTO DATA(ls_mard1).

          lv_count = lv_count + 1.
            es_mard-material                           = ls_mard1-material                              .
            es_mard-plant                              = ls_mard1-plant                                .
            es_mard-storagelocation                    = ls_mard1-storagelocation                      .
            es_mard-klabs                              = ls_mard1-klabs.
            es_mard-LABST                              = ls_mard1-LABST.
            es_mard-KINSM                              = ls_mard1-KINSM.
            es_mard-INSME                              = ls_mard1-INSME.


            APPEND es_mard TO es_response_mard-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_mard-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_mard )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.

          if lv_error_message is NOT INITIAL.
          lv_text = lv_error_message.
          else.
          lv_text = 'There is no data in table'.
          ENDIF.

        ENDIF.

      WHEN 'T024D' OR 'T024D'.

        SELECT * FROM i_mrpcontroller WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_t024d).


        IF lt_t024d IS NOT INITIAL.
          LOOP  AT lt_t024d INTO DATA(ls_t024d).
          lv_count = lv_count + 1.
            es_t024d-plant                        = ls_t024d-plant                              .
            es_t024d-mrpcontroller                = ls_t024d-mrpcontroller                      .
            es_t024d-mrpcontrollername            = ls_t024d-mrpcontrollername                  .
            es_t024d-mrpcontrollerphonenumber     = ls_t024d-mrpcontrollerphonenumber           .
            es_t024d-purchasinggroup              = ls_t024d-purchasinggroup                    .
            es_t024d-businessarea                 = ls_t024d-businessarea                       .
            es_t024d-profitcenter                 = ls_t024d-profitcenter                       .
            es_t024d-userid                       = ls_t024d-userid                             .

            CONDENSE es_t024d-plant                                                    .
            CONDENSE es_t024d-mrpcontroller                                            .
            CONDENSE es_t024d-mrpcontrollername                                        .
            CONDENSE es_t024d-mrpcontrollerphonenumber                                 .
            CONDENSE es_t024d-purchasinggroup                                          .
            CONDENSE es_t024d-businessarea                                             .
            CONDENSE es_t024d-profitcenter                                             .
            CONDENSE es_t024d-userid                                                   .

            APPEND es_t024d TO es_response_t024d-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_t024d-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_t024d )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'T001L' OR 't001l'.
        SELECT * FROM i_storagelocation WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_t001l).

        IF lt_t001l IS NOT INITIAL.
          LOOP  AT lt_t001l INTO DATA(ls_t001l).
          lv_count = lv_count + 1.
            es_t001l-plant                        = ls_t001l-plant                      .
            es_t001l-storagelocation               = ls_t001l-storagelocation             .
            es_t001l-storagelocationname           = ls_t001l-storagelocationname         .
            es_t001l-salesorganization             = ls_t001l-salesorganization           .
            es_t001l-distributionchannel           = ls_t001l-distributionchannel         .
            es_t001l-division                      = ls_t001l-division                    .
            es_t001l-isstorlocauthzncheckactive    = ls_t001l-isstorlocauthzncheckactive  .
            es_t001l-handlingunitisrequired        = ls_t001l-handlingunitisrequired      .
            es_t001l-configdeprecationcode         = ls_t001l-configdeprecationcode       .

            CONDENSE es_t001l-plant                             .
            CONDENSE es_t001l-storagelocation                    .
            CONDENSE es_t001l-storagelocationname                .
            CONDENSE es_t001l-salesorganization                  .
            CONDENSE es_t001l-distributionchannel                .
            CONDENSE es_t001l-division                           .
            CONDENSE es_t001l-isstorlocauthzncheckactive         .
            CONDENSE es_t001l-handlingunitisrequired             .
            CONDENSE es_t001l-configdeprecationcode              .

            APPEND es_t001l TO es_response_t001l-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_t001l-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_t001l )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'MARC'  OR 'marc' .
        SELECT a~*,
               b~ProductProductionQuantityUnit,
               b~ProductionSchedulingProfile,
               c~*,
               d~LoadingGroup,
               e~IsAutoPurOrdCreationAllowed,
               e~IsSourceListRequired,
               f~CostingLotSize,
               f~ProductIsCostingRelevant

        FROM i_productplantbasic WITH PRIVILEGED ACCESS as a
        LEFT JOIN I_ProductWorkScheduling WITH PRIVILEGED ACCESS as b
          on a~Product = b~product
         and a~plant = b~plant
        LEFT JOIN I_PRODUCTPLANTSUPPLYPLANNING WITH PRIVILEGED ACCESS as c
          on a~product = c~product
         and a~plant = c~Plant
        LEFT JOIN I_Productplantsales WITH PRIVILEGED ACCESS as d
          on a~product = d~product
         and a~plant = d~Plant
        LEFT JOIN I_Productplantprocurement WITH PRIVILEGED ACCESS as e
          on a~product = e~product
         and a~plant = e~Plant
        LEFT JOIN I_PRODUCTPLANTCOSTING WITH PRIVILEGED ACCESS as f
          on a~product = f~product
         and a~plant = f~Plant

        WHERE (lv_where)
        INTO TABLE @DATA(lt_marc).

        IF lt_marc IS NOT INITIAL.
          LOOP  AT lt_marc INTO DATA(ls_marc).
          lv_count = lv_count + 1.
          MOVE-CORRESPONDING ls_marc-c to es_marc.
          MOVE-CORRESPONDING ls_marc-a to es_marc.

*          es_marc-ProductProductionQuantityUnit = ls_marc-ProductProductionQuantityUnit.
*          es_marc-ProductionSchedulingProfile = ls_marc-ProductionSchedulingProfile.
*          es_marc-LoadingGroup = ls_marc-LoadingGroup.
*          es_marc-IsAutoPurOrdCreationAllowed = ls_marc-IsAutoPurOrdCreationAllowed.
*          es_marc-IsSourceListRequired = ls_marc-IsSourceListRequired.
*          es_marc-CostingLotSize = ls_marc-CostingLotSize.
*          es_marc-ProductIsCostingRelevant = ls_marc-ProductIsCostingRelevant.

*            es_marc-product                          = ls_marc-product                          .
*            es_marc-plant                            = ls_marc-plant                            .
*            es_marc-purchasinggroup                  = ls_marc-purchasinggroup                  .
*            es_marc-countryoforigin                  = ls_marc-countryoforigin                  .
*            es_marc-regionoforigin                   = ls_marc-regionoforigin                   .
*            es_marc-productioninvtrymanagedloc       = ls_marc-productioninvtrymanagedloc       .
*            es_marc-profilecode                      = ls_marc-profilecode                      .
*            es_marc-profilevaliditystartdate         = ls_marc-profilevaliditystartdate         .
*            es_marc-availabilitychecktype            = ls_marc-availabilitychecktype            .
*            es_marc-fiscalyearvariant                = ls_marc-fiscalyearvariant                .
*            es_marc-periodtype                       = ls_marc-periodtype                       .
*            es_marc-profitcenter                     = ls_marc-profitcenter                     .
*            es_marc-goodsreceiptduration             = ls_marc-goodsreceiptduration             .
*            es_marc-maintenancestatusname            = ls_marc-maintenancestatusname            .
*            es_marc-ismarkedfordeletion              = ls_marc-ismarkedfordeletion              .
*            es_marc-mrptype                          = ls_marc-mrptype                          .
*            es_marc-mrpresponsible                   = ls_marc-mrpresponsible                   .
*            es_marc-abcindicator                     = ls_marc-abcindicator                     .
*            es_marc-minimumlotsizequantity           = ls_marc-minimumlotsizequantity           .
*            es_marc-maximumlotsizequantity           = ls_marc-maximumlotsizequantity           .
*            es_marc-fixedlotsizequantity             = ls_marc-fixedlotsizequantity             .
*            es_marc-consumptiontaxctrlcode           = ls_marc-consumptiontaxctrlcode           .
*            es_marc-iscoproduct                      = ls_marc-iscoproduct                      .
*            es_marc-configurableproduct              = ls_marc-configurableproduct              .
*            es_marc-stockdeterminationgroup          = ls_marc-stockdeterminationgroup          .
*            es_marc-hasposttoinspectionstock         = ls_marc-hasposttoinspectionstock         .
*            es_marc-isbatchmanagementrequired        = ls_marc-isbatchmanagementrequired        .
*            es_marc-serialnumberprofile              = ls_marc-serialnumberprofile              .
*            es_marc-isnegativestockallowed           = ls_marc-isnegativestockallowed           .
*            es_marc-hasconsignmentctrl               = ls_marc-hasconsignmentctrl               .
*            es_marc-ispurgacrosspurggroup            = ls_marc-ispurgacrosspurggroup            .
*            es_marc-isinternalbatchmanaged           = ls_marc-isinternalbatchmanaged           .
*            es_marc-productcfopcategory              = ls_marc-productcfopcategory              .
*            es_marc-productisexcisetaxrelevant       = ls_marc-productisexcisetaxrelevant       .
*            es_marc-underdelivtolerancelimit         = ls_marc-underdelivtolerancelimit         .
*            es_marc-overdelivtolerancelimit          = ls_marc-overdelivtolerancelimit          .
*            es_marc-procurementtype                  = ls_marc-procurementtype                  .
*            es_marc-specialprocurementtype           = ls_marc-specialprocurementtype           .
*            es_marc-productionschedulingprofile      = ls_marc-productionschedulingprofile      .
*            es_marc-productionsupervisor             = ls_marc-productionsupervisor             .
*            es_marc-safetystockquantity              = ls_marc-safetystockquantity              .
*            es_marc-goodsissueunit                   = ls_marc-goodsissueunit                   .
*            es_marc-sourceofsupplycategory           = ls_marc-sourceofsupplycategory           .
*            es_marc-consumptionreferenceproduct      = ls_marc-consumptionreferenceproduct      .
*            es_marc-consumptionreferenceplant        = ls_marc-consumptionreferenceplant        .
*            es_marc-consumptionrefusageenddate       = ls_marc-consumptionrefusageenddate       .
*            es_marc-consumptionqtymultiplier         = ls_marc-consumptionqtymultiplier         .
*            es_marc-productunitgroup                 = ls_marc-productunitgroup                 .
*            es_marc-distrcntrdistributionprofile     = ls_marc-distrcntrdistributionprofile     .
*            es_marc-consignmentcontrol               = ls_marc-consignmentcontrol               .
*            es_marc-goodissueprocessingdays          = ls_marc-goodissueprocessingdays          .
*            es_marc-planneddeliverydurationindays    = ls_marc-planneddeliverydurationindays    .
*            es_marc-productiscriticalprt             = ls_marc-productiscriticalprt             .
*            es_marc-productlogisticshandlinggroup    = ls_marc-productlogisticshandlinggroup    .
*            es_marc-materialfreightgroup             = ls_marc-materialfreightgroup             .
*            es_marc-originalbatchreferencematerial   = ls_marc-originalbatchreferencematerial   .
*            es_marc-origlbatchmanagementisrequired   = ls_marc-origlbatchmanagementisrequired   .
*            es_marc-productconfiguration             = ls_marc-productconfiguration             .
*            es_marc-productmincontroltemperature     = ls_marc-productmincontroltemperature     .
*            es_marc-productmaxcontroltemperature     = ls_marc-productmaxcontroltemperature     .
*            es_marc-productcontroltemperatureunit    = ls_marc-productcontroltemperatureunit    .
*            es_marc-valuationcategory                = ls_marc-valuationcategory                .
*            es_marc-baseunit                         = ls_marc-baseunit                         .
*            es_marc-itemuniqueidentifierisrelevant   = ls_marc-itemuniqueidentifierisrelevant   .
*            es_marc-itemuniqueidentifiertype         = ls_marc-itemuniqueidentifiertype         .
*            es_marc-extallocofitmunqidtisrelevant    = ls_marc-extallocofitmunqidtisrelevant    .
*
*            CONDENSE es_marc-product                          .
*            CONDENSE es_marc-plant                            .
*            CONDENSE es_marc-purchasinggroup                  .
*            CONDENSE es_marc-countryoforigin                  .
*            CONDENSE es_marc-regionoforigin                   .
*            CONDENSE es_marc-productioninvtrymanagedloc       .
*            CONDENSE es_marc-profilecode                      .
*            CONDENSE es_marc-profilevaliditystartdate         .
*            CONDENSE es_marc-availabilitychecktype            .
*            CONDENSE es_marc-fiscalyearvariant                .
*            CONDENSE es_marc-periodtype                       .
*            CONDENSE es_marc-profitcenter                     .
*            CONDENSE es_marc-goodsreceiptduration             .
*            CONDENSE es_marc-maintenancestatusname            .
*            CONDENSE es_marc-ismarkedfordeletion              .
*            CONDENSE es_marc-mrptype                          .
*            CONDENSE es_marc-mrpresponsible                   .
*            CONDENSE es_marc-abcindicator                     .
*            CONDENSE es_marc-minimumlotsizequantity           .
*            CONDENSE es_marc-maximumlotsizequantity           .
*            CONDENSE es_marc-fixedlotsizequantity             .
*            CONDENSE es_marc-consumptiontaxctrlcode           .
*            CONDENSE es_marc-iscoproduct                      .
*            CONDENSE es_marc-configurableproduct              .
*            CONDENSE es_marc-stockdeterminationgroup          .
*            CONDENSE es_marc-hasposttoinspectionstock         .
*            CONDENSE es_marc-isbatchmanagementrequired        .
*            CONDENSE es_marc-serialnumberprofile              .
*            CONDENSE es_marc-isnegativestockallowed           .
*            CONDENSE es_marc-hasconsignmentctrl               .
*            CONDENSE es_marc-ispurgacrosspurggroup            .
*            CONDENSE es_marc-isinternalbatchmanaged           .
*            CONDENSE es_marc-productcfopcategory              .
*            CONDENSE es_marc-productisexcisetaxrelevant       .
*            CONDENSE es_marc-underdelivtolerancelimit         .
*            CONDENSE es_marc-overdelivtolerancelimit          .
*            CONDENSE es_marc-procurementtype                  .
*            CONDENSE es_marc-specialprocurementtype           .
*            CONDENSE es_marc-productionschedulingprofile      .
*            CONDENSE es_marc-productionsupervisor             .
*            CONDENSE es_marc-safetystockquantity              .
*            CONDENSE es_marc-goodsissueunit                   .
*            CONDENSE es_marc-sourceofsupplycategory           .
*            CONDENSE es_marc-consumptionreferenceproduct      .
*            CONDENSE es_marc-consumptionreferenceplant        .
*            CONDENSE es_marc-consumptionrefusageenddate       .
*            CONDENSE es_marc-consumptionqtymultiplier         .
*            CONDENSE es_marc-productunitgroup                 .
*            CONDENSE es_marc-distrcntrdistributionprofile     .
*            CONDENSE es_marc-consignmentcontrol               .
*            CONDENSE es_marc-goodissueprocessingdays          .
*            CONDENSE es_marc-planneddeliverydurationindays    .
*            CONDENSE es_marc-productiscriticalprt             .
*            CONDENSE es_marc-productlogisticshandlinggroup    .
*            CONDENSE es_marc-materialfreightgroup             .
*            CONDENSE es_marc-originalbatchreferencematerial   .
*            CONDENSE es_marc-origlbatchmanagementisrequired   .
*            CONDENSE es_marc-productconfiguration             .
*            CONDENSE es_marc-productmincontroltemperature     .
*            CONDENSE es_marc-productmaxcontroltemperature     .
*            CONDENSE es_marc-productcontroltemperatureunit    .
*            CONDENSE es_marc-valuationcategory                .
*            CONDENSE es_marc-baseunit                         .
*            CONDENSE es_marc-itemuniqueidentifierisrelevant   .
*            CONDENSE es_marc-itemuniqueidentifiertype         .
*            CONDENSE es_marc-extallocofitmunqidtisrelevant    .

            APPEND es_marc TO es_response_marc-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_marc-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_marc )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.
      WHEN 'MKAL'  OR 'mkal' .
        SELECT * FROM i_productionversion WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_mkal).

        IF lt_mkal IS NOT INITIAL.
          LOOP  AT lt_mkal INTO DATA(ls_mkal).
          lv_count = lv_count + 1.
            es_mkal-material                                        = ls_mkal-material                           .
            es_mkal-plant                                           = ls_mkal-plant                              .
            es_mkal-productionversion                               = ls_mkal-productionversion                  .
            es_mkal-productionversiontext                           = ls_mkal-productionversiontext              .
            es_mkal-changehistorycount                              = ls_mkal-changehistorycount                 .
            es_mkal-changenumber                                    = ls_mkal-changenumber                       .
            es_mkal-creationdate                                    = ls_mkal-creationdate                       .
            es_mkal-createdbyuser                                   = ls_mkal-createdbyuser                      .
            es_mkal-lastchangedate                                  = ls_mkal-lastchangedate                     .
            es_mkal-lastchangedbyuser                               = ls_mkal-lastchangedbyuser                  .
            es_mkal-billofoperationstype                            = ls_mkal-billofoperationstype               .
            es_mkal-billofoperationsgroup                           = ls_mkal-billofoperationsgroup              .
            es_mkal-billofoperationsvariant                         = ls_mkal-billofoperationsvariant            .
            es_mkal-billofmaterialvariantusage                      = ls_mkal-billofmaterialvariantusage         .
            es_mkal-billofmaterialvariant                           = ls_mkal-billofmaterialvariant              .
            es_mkal-productionline                                  = ls_mkal-productionline                     .
            es_mkal-productionsupplyarea                            = ls_mkal-productionsupplyarea               .
            es_mkal-productionversiongroup                          = ls_mkal-productionversiongroup             .
            es_mkal-mainproduct                                     = ls_mkal-mainproduct                        .
            es_mkal-materialcostapportionmentstruc                  = ls_mkal-materialcostapportionmentstruc     .
            es_mkal-issuingstoragelocation                          = ls_mkal-issuingstoragelocation             .
            es_mkal-receivingstoragelocation                        = ls_mkal-receivingstoragelocation           .
            es_mkal-originalbatchreferencematerial                  = ls_mkal-originalbatchreferencematerial     .
            es_mkal-quantitydistributionkey                         = ls_mkal-quantitydistributionkey            .
            es_mkal-productionversionstatus                         = ls_mkal-productionversionstatus            .
            es_mkal-productionversionlastcheckdate                  = ls_mkal-productionversionlastcheckdate     .
            es_mkal-ratebasedplanningstatus                         = ls_mkal-ratebasedplanningstatus            .
            es_mkal-preliminaryplanningstatus                       = ls_mkal-preliminaryplanningstatus          .
            es_mkal-bomcheckstatus                                  = ls_mkal-bomcheckstatus                     .
            es_mkal-validitystartdate                               = ls_mkal-validitystartdate                  .
            es_mkal-validityenddate                                 = ls_mkal-validityenddate                    .
            es_mkal-productionversionislocked                       = ls_mkal-productionversionislocked          .
            es_mkal-prodnversisallowedforrptvmfg                    = ls_mkal-prodnversisallowedforrptvmfg       .
            es_mkal-hasversionctrldbomandrouting                    = ls_mkal-hasversionctrldbomandrouting       .
            es_mkal-planningandexecutionbomisdiff                   = ls_mkal-planningandexecutionbomisdiff      .
            es_mkal-execbillofmaterialvariantusage                  = ls_mkal-execbillofmaterialvariantusage     .
            es_mkal-execbillofmaterialvariant                       = ls_mkal-execbillofmaterialvariant          .
            es_mkal-execbillofoperationstype                        = ls_mkal-execbillofoperationstype           .
            es_mkal-execbillofoperationsgroup                       = ls_mkal-execbillofoperationsgroup          .
            es_mkal-execbillofoperationsvariant                     = ls_mkal-execbillofoperationsvariant        .
            es_mkal-warehouse                                       = ls_mkal-warehouse                          .
            es_mkal-destinationstoragebin                           = ls_mkal-destinationstoragebin              .
            es_mkal-procurementtype                                 = ls_mkal-procurementtype                    .
            es_mkal-materialprocurementprofile                      = ls_mkal-materialprocurementprofile         .
            es_mkal-usgeprobltywthversctrlinpct                     = ls_mkal-usgeprobltywthversctrlinpct        .
            es_mkal-materialbaseunit                                = ls_mkal-materialbaseunit                   .
            es_mkal-materialminlotsizequantity                      = ls_mkal-materialminlotsizequantity         .
            es_mkal-materialmaxlotsizequantity                      = ls_mkal-materialmaxlotsizequantity         .
            es_mkal-costinglotsize                                  = ls_mkal-costinglotsize                     .
            es_mkal-distributionkey                                 = ls_mkal-distributionkey                    .
            es_mkal-targetproductionsupplyarea                      = ls_mkal-targetproductionsupplyarea         .

            CONDENSE es_mkal-material                              .
            CONDENSE es_mkal-plant                                 .
            CONDENSE es_mkal-productionversion                     .
            CONDENSE es_mkal-productionversiontext                 .
            CONDENSE es_mkal-changehistorycount                    .
            CONDENSE es_mkal-changenumber                          .
            CONDENSE es_mkal-creationdate                          .
            CONDENSE es_mkal-createdbyuser                         .
            CONDENSE es_mkal-lastchangedate                        .
            CONDENSE es_mkal-lastchangedbyuser                     .
            CONDENSE es_mkal-billofoperationstype                  .
            CONDENSE es_mkal-billofoperationsgroup                 .
            CONDENSE es_mkal-billofoperationsvariant               .
            CONDENSE es_mkal-billofmaterialvariantusage            .
            CONDENSE es_mkal-billofmaterialvariant                 .
            CONDENSE es_mkal-productionline                        .
            CONDENSE es_mkal-productionsupplyarea                  .
            CONDENSE es_mkal-productionversiongroup                .
            CONDENSE es_mkal-mainproduct                           .
            CONDENSE es_mkal-materialcostapportionmentstruc        .
            CONDENSE es_mkal-issuingstoragelocation                .
            CONDENSE es_mkal-receivingstoragelocation              .
            CONDENSE es_mkal-originalbatchreferencematerial        .
            CONDENSE es_mkal-quantitydistributionkey               .
            CONDENSE es_mkal-productionversionstatus               .
            CONDENSE es_mkal-productionversionlastcheckdate        .
            CONDENSE es_mkal-ratebasedplanningstatus               .
            CONDENSE es_mkal-preliminaryplanningstatus             .
            CONDENSE es_mkal-bomcheckstatus                        .
            CONDENSE es_mkal-validitystartdate                     .
            CONDENSE es_mkal-validityenddate                       .
            CONDENSE es_mkal-productionversionislocked             .
            CONDENSE es_mkal-prodnversisallowedforrptvmfg          .
            CONDENSE es_mkal-hasversionctrldbomandrouting          .
            CONDENSE es_mkal-planningandexecutionbomisdiff         .
            CONDENSE es_mkal-execbillofmaterialvariantusage        .
            CONDENSE es_mkal-execbillofmaterialvariant             .
            CONDENSE es_mkal-execbillofoperationstype              .
            CONDENSE es_mkal-execbillofoperationsgroup             .
            CONDENSE es_mkal-execbillofoperationsvariant           .
            CONDENSE es_mkal-warehouse                             .
            CONDENSE es_mkal-destinationstoragebin                 .
            CONDENSE es_mkal-procurementtype                       .
            CONDENSE es_mkal-materialprocurementprofile            .
            CONDENSE es_mkal-usgeprobltywthversctrlinpct           .
            CONDENSE es_mkal-materialbaseunit                      .
            CONDENSE es_mkal-materialminlotsizequantity            .
            CONDENSE es_mkal-materialmaxlotsizequantity            .
            CONDENSE es_mkal-costinglotsize                        .
            CONDENSE es_mkal-distributionkey                       .
            CONDENSE es_mkal-targetproductionsupplyarea            .

            APPEND es_mkal TO es_response_mkal-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_mkal-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_mkal )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'AFKO'  OR 'afko' .
        SELECT a~*,
               b~*
          FROM i_manufacturingorder WITH PRIVILEGED ACCESS as a
          LEFT JOIN I_BillOfMaterialHeaderDEX_2 WITH PRIVILEGED ACCESS as b
            on a~BillOfMaterialCategory = b~BillOfMaterialCategory
           and a~BillOfMaterial = b~BillOfMaterial
           and a~BillOfMaterialVariant = b~BillOfMaterialVariant
           and a~BillOfMaterialVariantUsage = b~BillOfMaterialVariantUsage
        WHERE (lv_where)
        INTO TABLE @DATA(lt_afko).

        IF lt_afko IS NOT INITIAL.
          LOOP  AT lt_afko INTO DATA(ls_afko).

          lv_count = lv_count + 1.
          MOVE-CORRESPONDING ls_afko-a to es_afko.
          MOVE-CORRESPONDING ls_afko-b to es_afko.
*            es_afko-manufacturingorder                   = ls_afko-manufacturingorder                 .
*            es_afko-manufacturingorderitem               = ls_afko-manufacturingorderitem             .
*            es_afko-manufacturingordercategory           = ls_afko-manufacturingordercategory         .
*            es_afko-manufacturingordertype               = ls_afko-manufacturingordertype             .
*            es_afko-manufacturingordertext               = ls_afko-manufacturingordertext             .
*            es_afko-manufacturingorderhaslongtext        = ls_afko-manufacturingorderhaslongtext      .
*            es_afko-longtextlanguagecode                 = ls_afko-longtextlanguagecode               .
*            es_afko-manufacturingorderimportance         = ls_afko-manufacturingorderimportance       .
*            es_afko-ismarkedfordeletion                  = ls_afko-ismarkedfordeletion                .
*            es_afko-iscompletelydelivered                = ls_afko-iscompletelydelivered              .
*            es_afko-mfgorderhasmultipleitems             = ls_afko-mfgorderhasmultipleitems           .
*            es_afko-mfgorderispartofcollvorder           = ls_afko-mfgorderispartofcollvorder         .
**            es_afko-mfgorderhierarchylevel               = ls_afko-mfgorderhierarchylevel             .
*            es_afko-mfgorderhierarchylevelvalue          = ls_afko-mfgorderhierarchylevelvalue        .
*            es_afko-mfgorderhierarchypathvalue           = ls_afko-mfgorderhierarchypathvalue         .
*            es_afko-orderisnotcostedautomatically        = ls_afko-orderisnotcostedautomatically      .
*            es_afko-ordisnotschedldautomatically         = ls_afko-ordisnotschedldautomatically       .
*            es_afko-prodnprocgisflexible                 = ls_afko-prodnprocgisflexible               .
*            es_afko-creationdate                         = ls_afko-creationdate                       .
*            es_afko-creationtime                         = ls_afko-creationtime                       .
*            es_afko-createdbyuser                        = ls_afko-createdbyuser                      .
*            es_afko-lastchangedate                       = ls_afko-lastchangedate                     .
*            es_afko-lastchangetime                       = ls_afko-lastchangetime                     .
*            es_afko-lastchangedbyuser                    = ls_afko-lastchangedbyuser                  .
*            es_afko-material                             = ls_afko-material                           .
*            es_afko-product                              = ls_afko-product                            .
*            es_afko-storagelocation                      = ls_afko-storagelocation                    .
*            es_afko-batch                                = ls_afko-batch                              .
*            es_afko-goodsrecipientname                   = ls_afko-goodsrecipientname                 .
*            es_afko-unloadingpointname                   = ls_afko-unloadingpointname                 .
*            es_afko-inventoryusabilitycode               = ls_afko-inventoryusabilitycode             .
*            es_afko-materialgoodsreceiptduration         = ls_afko-materialgoodsreceiptduration       .
*            es_afko-quantitydistributionkey              = ls_afko-quantitydistributionkey            .
*            es_afko-stocksegment                         = ls_afko-stocksegment                       .
*            es_afko-mfgorderinternalid                   = ls_afko-mfgorderinternalid                 .
*            es_afko-referenceorder                       = ls_afko-referenceorder                     .
*            es_afko-leadingorder                         = ls_afko-leadingorder                       .
*            es_afko-superiororder                        = ls_afko-superiororder                      .
*            es_afko-currency                             = ls_afko-currency                           .
*            es_afko-productionplant                      = ls_afko-productionplant                    .
*            es_afko-planningplant                        = ls_afko-planningplant                      .
*            es_afko-mrparea                              = ls_afko-mrparea                            .
*            es_afko-mrpcontroller                        = ls_afko-mrpcontroller                      .
*            es_afko-productionsupervisor                 = ls_afko-productionsupervisor               .
*            es_afko-productionschedulingprofile          = ls_afko-productionschedulingprofile        .
*            es_afko-responsibleplannergroup              = ls_afko-responsibleplannergroup            .
*            es_afko-productionversion                    = ls_afko-productionversion                  .
*            es_afko-salesorder                           = ls_afko-salesorder                         .
*            es_afko-salesorderitem                       = ls_afko-salesorderitem                     .
**            es_afko-wbselementinternalid                 = ls_afko-wbselementinternalid               .
*            es_afko-wbselementinternalid_2               = ls_afko-wbselementinternalid_2             .
*            es_afko-reservation                          = ls_afko-reservation                        .
*            es_afko-settlementreservation                = ls_afko-settlementreservation              .
*            es_afko-mfgorderconfirmation                 = ls_afko-mfgorderconfirmation               .
*            es_afko-numberofmfgorderconfirmations        = ls_afko-numberofmfgorderconfirmations      .
*            es_afko-plannedorder                         = ls_afko-plannedorder                       .
*            es_afko-capacityrequirement                  = ls_afko-capacityrequirement                .
*            es_afko-inspectionlot                        = ls_afko-inspectionlot                      .
*            es_afko-changenumber                         = ls_afko-changenumber                       .
**            es_afko-materialrevisionlevel                = ls_afko-materialrevisionlevel              .
*            es_afko-materialrevisionlevel_2              = ls_afko-materialrevisionlevel_2            .
*            es_afko-basicschedulingtype                  = ls_afko-basicschedulingtype                .
*            es_afko-forecastschedulingtype               = ls_afko-forecastschedulingtype             .
*            es_afko-objectinternalid                     = ls_afko-objectinternalid                   .
*            es_afko-productconfiguration                 = ls_afko-productconfiguration               .
*            es_afko-effectivityparametervariant          = ls_afko-effectivityparametervariant        .
*            es_afko-conditionapplication                 = ls_afko-conditionapplication               .
*            es_afko-capacityactiveversion                = ls_afko-capacityactiveversion              .
*            es_afko-capacityrqmthasnottobecreated        = ls_afko-capacityrqmthasnottobecreated      .
*            es_afko-ordersequencenumber                  = ls_afko-ordersequencenumber                .
*            es_afko-mfgordersplitstatus                  = ls_afko-mfgordersplitstatus                .
*            es_afko-billofoperationsmaterial             = ls_afko-billofoperationsmaterial           .
*            es_afko-billofoperationstype                 = ls_afko-billofoperationstype               .
**            es_afko-billofoperations                     = ls_afko-billofoperations                   .
*            es_afko-billofoperationsgroup                = ls_afko-billofoperationsgroup              .
*            es_afko-billofoperationsvariant              = ls_afko-billofoperationsvariant            .
*            es_afko-boointernalversioncounter            = ls_afko-boointernalversioncounter          .
*            es_afko-billofoperationsapplication          = ls_afko-billofoperationsapplication        .
*            es_afko-billofoperationsusage                = ls_afko-billofoperationsusage              .
*            es_afko-billofoperationsversion              = ls_afko-billofoperationsversion            .
*            es_afko-booexplosiondate                     = ls_afko-booexplosiondate                   .
*            es_afko-boovaliditystartdate                 = ls_afko-boovaliditystartdate               .
*            es_afko-billofmaterialcategory               = ls_afko-billofmaterialcategory             .
**            es_afko-billofmaterial                       = ls_afko-billofmaterial                     .
*            es_afko-billofmaterialinternalid             = ls_afko-billofmaterialinternalid           .
*            es_afko-billofmaterialvariant                = ls_afko-billofmaterialvariant              .
*            es_afko-billofmaterialvariantusage           = ls_afko-billofmaterialvariantusage         .
*            es_afko-billofmaterialversion                = ls_afko-billofmaterialversion              .
*            es_afko-bomexplosiondate                     = ls_afko-bomexplosiondate                   .
*            es_afko-bomvaliditystartdate                 = ls_afko-bomvaliditystartdate               .
*            es_afko-businessarea                         = ls_afko-businessarea                       .
*            es_afko-companycode                          = ls_afko-companycode                        .
*            es_afko-controllingarea                      = ls_afko-controllingarea                    .
*            es_afko-profitcenter                         = ls_afko-profitcenter                       .
*            es_afko-costcenter                           = ls_afko-costcenter                         .
*            es_afko-responsiblecostcenter                = ls_afko-responsiblecostcenter              .
*            es_afko-costelement                          = ls_afko-costelement                        .
*            es_afko-costingsheet                         = ls_afko-costingsheet                       .
*            es_afko-glaccount                            = ls_afko-glaccount                          .
*            es_afko-productcostcollector                 = ls_afko-productcostcollector               .
*            es_afko-actualcostscostingvariant            = ls_afko-actualcostscostingvariant          .
*            es_afko-plannedcostscostingvariant           = ls_afko-plannedcostscostingvariant         .
*            es_afko-controllingobjectclass               = ls_afko-controllingobjectclass             .
*            es_afko-functionalarea                       = ls_afko-functionalarea                     .
**            es_afko-orderiseventbasedposting             = ls_afko-orderiseventbasedposting           .
*            es_afko-eventbasedpostingmethod              = ls_afko-eventbasedpostingmethod            .
*            es_afko-eventbasedprocessingkey              = ls_afko-eventbasedprocessingkey            .
*            es_afko-schedulingfloatprofile               = ls_afko-schedulingfloatprofile             .
*            es_afko-floatbeforeproductioninwrkdays       = ls_afko-floatbeforeproductioninwrkdays     .
*            es_afko-floatafterproductioninworkdays       = ls_afko-floatafterproductioninworkdays     .
*            es_afko-releaseperiodinworkdays              = ls_afko-releaseperiodinworkdays            .
*            es_afko-changetoscheduleddatesismade         = ls_afko-changetoscheduleddatesismade       .
*            es_afko-mfgorderplannedstartdate             = ls_afko-mfgorderplannedstartdate           .
*            es_afko-mfgorderplannedstarttime             = ls_afko-mfgorderplannedstarttime           .
*            es_afko-mfgorderplannedenddate               = ls_afko-mfgorderplannedenddate             .
*            es_afko-mfgorderplannedendtime               = ls_afko-mfgorderplannedendtime             .
*            es_afko-mfgorderplannedreleasedate           = ls_afko-mfgorderplannedreleasedate         .
*            es_afko-mfgorderscheduledstartdate           = ls_afko-mfgorderscheduledstartdate         .
*            es_afko-mfgorderscheduledstarttime           = ls_afko-mfgorderscheduledstarttime         .
*            es_afko-mfgorderscheduledenddate             = ls_afko-mfgorderscheduledenddate           .
*            es_afko-mfgorderscheduledendtime             = ls_afko-mfgorderscheduledendtime           .
*            es_afko-mfgorderscheduledreleasedate         = ls_afko-mfgorderscheduledreleasedate       .
*            es_afko-mfgorderactualstartdate              = ls_afko-mfgorderactualstartdate            .
*            es_afko-mfgorderactualstarttime              = ls_afko-mfgorderactualstarttime            .
*            es_afko-mfgorderconfirmedenddate             = ls_afko-mfgorderconfirmedenddate           .
*            es_afko-mfgorderconfirmedendtime             = ls_afko-mfgorderconfirmedendtime           .
**            es_afko-mfgorderactualenddate                = ls_afko-mfgorderactualenddate              .
*            es_afko-mfgorderactualreleasedate            = ls_afko-mfgorderactualreleasedate          .
*            es_afko-mfgordertotalcommitmentdate          = ls_afko-mfgordertotalcommitmentdate        .
*            es_afko-mfgorderactualcompletiondate         = ls_afko-mfgorderactualcompletiondate       .
*            es_afko-mfgorderitemactualdeliverydate       = ls_afko-mfgorderitemactualdeliverydate     .
*            es_afko-productionunit                       = ls_afko-productionunit                     .
*            es_afko-mfgorderplannedtotalqty              = ls_afko-mfgorderplannedtotalqty            .
*            es_afko-mfgorderplannedscrapqty              = ls_afko-mfgorderplannedscrapqty            .
*            es_afko-mfgorderconfirmedyieldqty            = ls_afko-mfgorderconfirmedyieldqty          .
*            es_afko-mfgorderconfirmedscrapqty            = ls_afko-mfgorderconfirmedscrapqty          .
*            es_afko-mfgorderconfirmedreworkqty           = ls_afko-mfgorderconfirmedreworkqty         .
*            es_afko-expecteddeviationquantity            = ls_afko-expecteddeviationquantity          .
*            es_afko-actualdeliveredquantity              = ls_afko-actualdeliveredquantity            .
*            es_afko-masterproductionorder                = ls_afko-masterproductionorder              .
*            es_afko-productseasonyear                    = ls_afko-productseasonyear                  .
*            es_afko-productseason                        = ls_afko-productseason                      .
*            es_afko-productcollection                    = ls_afko-productcollection                  .
*            es_afko-producttheme                         = ls_afko-producttheme                       .



            CONDENSE es_afko-manufacturingorder                  .
            CONDENSE es_afko-manufacturingorderitem              .
            CONDENSE es_afko-manufacturingordercategory          .
            CONDENSE es_afko-manufacturingordertype              .
            CONDENSE es_afko-manufacturingordertext              .
            CONDENSE es_afko-manufacturingorderhaslongtext       .
            CONDENSE es_afko-longtextlanguagecode                .
            CONDENSE es_afko-manufacturingorderimportance        .
            CONDENSE es_afko-ismarkedfordeletion                 .
            CONDENSE es_afko-iscompletelydelivered               .
            CONDENSE es_afko-mfgorderhasmultipleitems            .
            CONDENSE es_afko-mfgorderispartofcollvorder          .
            CONDENSE es_afko-mfgorderhierarchylevel              .
            CONDENSE es_afko-mfgorderhierarchylevelvalue         .
            CONDENSE es_afko-mfgorderhierarchypathvalue          .
            CONDENSE es_afko-orderisnotcostedautomatically       .
            CONDENSE es_afko-ordisnotschedldautomatically        .
            CONDENSE es_afko-prodnprocgisflexible                .
            CONDENSE es_afko-creationdate                        .
            CONDENSE es_afko-creationtime                        .
            CONDENSE es_afko-createdbyuser                       .
            CONDENSE es_afko-lastchangedate                      .
            CONDENSE es_afko-lastchangetime                      .
            CONDENSE es_afko-lastchangedbyuser                   .
            CONDENSE es_afko-material                            .
            CONDENSE es_afko-product                             .
            CONDENSE es_afko-storagelocation                     .
            CONDENSE es_afko-batch                               .
            CONDENSE es_afko-goodsrecipientname                  .
            CONDENSE es_afko-unloadingpointname                  .
            CONDENSE es_afko-inventoryusabilitycode              .
            CONDENSE es_afko-materialgoodsreceiptduration        .
            CONDENSE es_afko-quantitydistributionkey             .
            CONDENSE es_afko-stocksegment                        .
            CONDENSE es_afko-mfgorderinternalid                  .
            CONDENSE es_afko-referenceorder                      .
            CONDENSE es_afko-leadingorder                        .
            CONDENSE es_afko-superiororder                       .
            CONDENSE es_afko-currency                            .
            CONDENSE es_afko-productionplant                     .
            CONDENSE es_afko-planningplant                       .
            CONDENSE es_afko-mrparea                             .
            CONDENSE es_afko-mrpcontroller                       .
            CONDENSE es_afko-productionsupervisor                .
            CONDENSE es_afko-productionschedulingprofile         .
            CONDENSE es_afko-responsibleplannergroup             .
            CONDENSE es_afko-productionversion                   .
            CONDENSE es_afko-salesorder                          .
            CONDENSE es_afko-salesorderitem                      .
            CONDENSE es_afko-wbselementinternalid                .
            CONDENSE es_afko-wbselementinternalid_2              .
            CONDENSE es_afko-reservation                         .
            CONDENSE es_afko-settlementreservation               .
            CONDENSE es_afko-mfgorderconfirmation                .
            CONDENSE es_afko-numberofmfgorderconfirmations       .
            CONDENSE es_afko-plannedorder                        .
            CONDENSE es_afko-capacityrequirement                 .
            CONDENSE es_afko-inspectionlot                       .
            CONDENSE es_afko-changenumber                        .
            CONDENSE es_afko-materialrevisionlevel               .
            CONDENSE es_afko-materialrevisionlevel_2             .
            CONDENSE es_afko-basicschedulingtype                 .
            CONDENSE es_afko-forecastschedulingtype              .
            CONDENSE es_afko-objectinternalid                    .
            CONDENSE es_afko-productconfiguration                .
            CONDENSE es_afko-effectivityparametervariant         .
            CONDENSE es_afko-conditionapplication                .
            CONDENSE es_afko-capacityactiveversion               .
            CONDENSE es_afko-capacityrqmthasnottobecreated       .
            CONDENSE es_afko-ordersequencenumber                 .
            CONDENSE es_afko-mfgordersplitstatus                 .
            CONDENSE es_afko-billofoperationsmaterial            .
            CONDENSE es_afko-billofoperationstype                .
            CONDENSE es_afko-billofoperations                    .
            CONDENSE es_afko-billofoperationsgroup               .
            CONDENSE es_afko-billofoperationsvariant             .
            CONDENSE es_afko-boointernalversioncounter           .
            CONDENSE es_afko-billofoperationsapplication         .
            CONDENSE es_afko-billofoperationsusage               .
            CONDENSE es_afko-billofoperationsversion             .
            CONDENSE es_afko-booexplosiondate                    .
            CONDENSE es_afko-boovaliditystartdate                .
            CONDENSE es_afko-billofmaterialcategory              .
            CONDENSE es_afko-billofmaterial                      .
            CONDENSE es_afko-billofmaterialinternalid            .
            CONDENSE es_afko-billofmaterialvariant               .
            CONDENSE es_afko-billofmaterialvariantusage          .
            CONDENSE es_afko-billofmaterialversion               .
            CONDENSE es_afko-bomexplosiondate                    .
            CONDENSE es_afko-bomvaliditystartdate                .
            CONDENSE es_afko-businessarea                        .
            CONDENSE es_afko-companycode                         .
            CONDENSE es_afko-controllingarea                     .
            CONDENSE es_afko-profitcenter                        .
            CONDENSE es_afko-costcenter                          .
            CONDENSE es_afko-responsiblecostcenter               .
            CONDENSE es_afko-costelement                         .
            CONDENSE es_afko-costingsheet                        .
            CONDENSE es_afko-glaccount                           .
            CONDENSE es_afko-productcostcollector                .
            CONDENSE es_afko-actualcostscostingvariant           .
            CONDENSE es_afko-plannedcostscostingvariant          .
            CONDENSE es_afko-controllingobjectclass              .
            CONDENSE es_afko-functionalarea                      .
            CONDENSE es_afko-orderiseventbasedposting            .
            CONDENSE es_afko-eventbasedpostingmethod             .
            CONDENSE es_afko-eventbasedprocessingkey             .
            CONDENSE es_afko-schedulingfloatprofile              .
            CONDENSE es_afko-floatbeforeproductioninwrkdays      .
            CONDENSE es_afko-floatafterproductioninworkdays      .
            CONDENSE es_afko-releaseperiodinworkdays             .
            CONDENSE es_afko-changetoscheduleddatesismade        .
            CONDENSE es_afko-mfgorderplannedstartdate            .
            CONDENSE es_afko-mfgorderplannedstarttime            .
            CONDENSE es_afko-mfgorderplannedenddate              .
            CONDENSE es_afko-mfgorderplannedendtime              .
            CONDENSE es_afko-mfgorderplannedreleasedate          .
            CONDENSE es_afko-mfgorderscheduledstartdate          .
            CONDENSE es_afko-mfgorderscheduledstarttime          .
            CONDENSE es_afko-mfgorderscheduledenddate            .
            CONDENSE es_afko-mfgorderscheduledendtime            .
            CONDENSE es_afko-mfgorderscheduledreleasedate        .
            CONDENSE es_afko-mfgorderactualstartdate             .
            CONDENSE es_afko-mfgorderactualstarttime             .
            CONDENSE es_afko-mfgorderconfirmedenddate            .
            CONDENSE es_afko-mfgorderconfirmedendtime            .
            CONDENSE es_afko-mfgorderactualenddate               .
            CONDENSE es_afko-mfgorderactualreleasedate           .
            CONDENSE es_afko-mfgordertotalcommitmentdate         .
            CONDENSE es_afko-mfgorderactualcompletiondate        .
            CONDENSE es_afko-mfgorderitemactualdeliverydate      .
            CONDENSE es_afko-productionunit                     .
            CONDENSE es_afko-mfgorderplannedtotalqty             .
            CONDENSE es_afko-mfgorderplannedscrapqty             .
            CONDENSE es_afko-mfgorderconfirmedyieldqty           .
            CONDENSE es_afko-mfgorderconfirmedscrapqty           .
            CONDENSE es_afko-mfgorderconfirmedreworkqty          .
            CONDENSE es_afko-expecteddeviationquantity           .
            CONDENSE es_afko-actualdeliveredquantity             .
            CONDENSE es_afko-masterproductionorder               .
            CONDENSE es_afko-productseasonyear                   .
            CONDENSE es_afko-productseason                       .
            CONDENSE es_afko-productcollection                   .
            CONDENSE es_afko-producttheme                        .

            APPEND es_afko TO es_response_afko-items.
            clear es_afko.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_afko-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_afko )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'AFPO'  OR 'afpo' .
        SELECT * FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_afpo).

        IF lt_afpo IS NOT INITIAL.
          LOOP  AT lt_afpo INTO DATA(ls_afpo).
          lv_count = lv_count + 1.
            es_afpo-manufacturingorder                = ls_afpo-manufacturingorder               .
            es_afpo-manufacturingorderitem            = ls_afpo-manufacturingorderitem           .
            es_afpo-manufacturingordercategory        = ls_afpo-manufacturingordercategory       .
            es_afpo-manufacturingordertype            = ls_afpo-manufacturingordertype           .
            es_afpo-orderisreleased                   = ls_afpo-orderisreleased                  .
            es_afpo-ismarkedfordeletion               = ls_afpo-ismarkedfordeletion              .
            es_afpo-orderitemisnotrelevantformrp      = ls_afpo-orderitemisnotrelevantformrp     .
            es_afpo-material                          = ls_afpo-material                         .
            es_afpo-product                           = ls_afpo-product                          .
            es_afpo-productionplant                   = ls_afpo-productionplant                  .
            es_afpo-planningplant                     = ls_afpo-planningplant                    .
            es_afpo-mrpcontroller                     = ls_afpo-mrpcontroller                    .
            es_afpo-productionsupervisor              = ls_afpo-productionsupervisor             .
            es_afpo-reservation                       = ls_afpo-reservation                      .
            es_afpo-productionversion                 = ls_afpo-productionversion                .
            es_afpo-mrparea                           = ls_afpo-mrparea                          .
            es_afpo-salesorder                        = ls_afpo-salesorder                       .
            es_afpo-salesorderitem                    = ls_afpo-salesorderitem                   .
            es_afpo-salesorderscheduleline            = ls_afpo-salesorderscheduleline           .
*            es_afpo-wbselementinternalid              = ls_afpo-wbselementinternalid             .
            es_afpo-wbselementinternalid_2            = ls_afpo-wbselementinternalid_2           .
            es_afpo-quotaarrangement                  = ls_afpo-quotaarrangement                 .
            es_afpo-quotaarrangementitem              = ls_afpo-quotaarrangementitem             .
            es_afpo-settlementreservation             = ls_afpo-settlementreservation            .
            es_afpo-settlementreservationitem         = ls_afpo-settlementreservationitem        .
            es_afpo-coproductreservation              = ls_afpo-coproductreservation             .
            es_afpo-coproductreservationitem          = ls_afpo-coproductreservationitem         .
            es_afpo-materialprocurementcategory       = ls_afpo-materialprocurementcategory      .
            es_afpo-materialprocurementtype           = ls_afpo-materialprocurementtype          .
            es_afpo-serialnumberassgmtprofile         = ls_afpo-serialnumberassgmtprofile        .
            es_afpo-numberofserialnumbers             = ls_afpo-numberofserialnumbers            .
            es_afpo-mfgorderitemreplnmtelmnttype      = ls_afpo-mfgorderitemreplnmtelmnttype     .
            es_afpo-productconfiguration              = ls_afpo-productconfiguration             .
            es_afpo-objectinternalid                  = ls_afpo-objectinternalid                 .
            es_afpo-manufacturingobject               = ls_afpo-manufacturingobject              .
            es_afpo-quantitydistributionkey           = ls_afpo-quantitydistributionkey          .
            es_afpo-effectivityparametervariant       = ls_afpo-effectivityparametervariant      .
            es_afpo-goodsreceiptisexpected            = ls_afpo-goodsreceiptisexpected           .
            es_afpo-goodsreceiptisnonvaluated         = ls_afpo-goodsreceiptisnonvaluated        .
            es_afpo-iscompletelydelivered             = ls_afpo-iscompletelydelivered            .
            es_afpo-materialgoodsreceiptduration      = ls_afpo-materialgoodsreceiptduration     .
            es_afpo-underdelivtolrtdlmtratioinpct     = ls_afpo-underdelivtolrtdlmtratioinpct    .
            es_afpo-overdelivtolrtdlmtratioinpct      = ls_afpo-overdelivtolrtdlmtratioinpct     .
            es_afpo-unlimitedoverdeliveryisallowed    = ls_afpo-unlimitedoverdeliveryisallowed   .
            es_afpo-storagelocation                   = ls_afpo-storagelocation                  .
            es_afpo-batch                             = ls_afpo-batch                            .
            es_afpo-inventoryvaluationtype            = ls_afpo-inventoryvaluationtype           .
            es_afpo-inventoryvaluationcategory        = ls_afpo-inventoryvaluationcategory       .
            es_afpo-inventoryusabilitycode            = ls_afpo-inventoryusabilitycode           .
            es_afpo-inventoryspecialstocktype         = ls_afpo-inventoryspecialstocktype        .
            es_afpo-inventoryspecialstockvalntype     = ls_afpo-inventoryspecialstockvalntype    .
            es_afpo-consumptionposting                = ls_afpo-consumptionposting               .
            es_afpo-goodsrecipientname                = ls_afpo-goodsrecipientname               .
            es_afpo-unloadingpointname                = ls_afpo-unloadingpointname               .
            es_afpo-stocksegment                      = ls_afpo-stocksegment                     .
            es_afpo-mfgorderplannedstartdate          = ls_afpo-mfgorderplannedstartdate         .
            es_afpo-mfgorderplannedstarttime          = ls_afpo-mfgorderplannedstarttime         .
            es_afpo-mfgorderscheduledstartdate        = ls_afpo-mfgorderscheduledstartdate       .
            es_afpo-mfgorderscheduledstarttime        = ls_afpo-mfgorderscheduledstarttime       .
            es_afpo-mfgorderactualstartdate           = ls_afpo-mfgorderactualstartdate          .
            es_afpo-mfgorderactualstarttime           = ls_afpo-mfgorderactualstarttime          .
            es_afpo-mfgorderplannedenddate            = ls_afpo-mfgorderplannedenddate           .
            es_afpo-mfgorderplannedendtime            = ls_afpo-mfgorderplannedendtime           .
            es_afpo-mfgorderscheduledenddate          = ls_afpo-mfgorderscheduledenddate         .
            es_afpo-mfgorderscheduledendtime          = ls_afpo-mfgorderscheduledendtime         .
            es_afpo-mfgorderconfirmedenddate          = ls_afpo-mfgorderconfirmedenddate         .
            es_afpo-mfgorderconfirmedendtime          = ls_afpo-mfgorderconfirmedendtime         .
            es_afpo-mfgorderactualenddate             = ls_afpo-mfgorderactualenddate            .
            es_afpo-mfgorderscheduledreleasedate      = ls_afpo-mfgorderscheduledreleasedate     .
            es_afpo-mfgorderactualreleasedate         = ls_afpo-mfgorderactualreleasedate        .
            es_afpo-mfgorderitemplannedenddate        = ls_afpo-mfgorderitemplannedenddate       .
            es_afpo-mfgorderitemscheduledenddate      = ls_afpo-mfgorderitemscheduledenddate     .
            es_afpo-mfgorderitemplnddeliverydate      = ls_afpo-mfgorderitemplnddeliverydate     .
            es_afpo-mfgorderitemactualdeliverydate    = ls_afpo-mfgorderitemactualdeliverydate   .
            es_afpo-mfgorderitemtotalcmtmtdate        = ls_afpo-mfgorderitemtotalcmtmtdate       .
            es_afpo-productionunit                    = ls_afpo-productionunit                   .
            es_afpo-mfgorderitemplannedtotalqty       = ls_afpo-mfgorderitemplannedtotalqty      .
            es_afpo-mfgorderitemplannedscrapqty       = ls_afpo-mfgorderitemplannedscrapqty      .
            es_afpo-mfgorderitemplannedyieldqty       = ls_afpo-mfgorderitemplannedyieldqty      .
            es_afpo-mfgorderitemgoodsreceiptqty       = ls_afpo-mfgorderitemgoodsreceiptqty      .
            es_afpo-mfgorderitemactualdeviationqty    = ls_afpo-mfgorderitemactualdeviationqty   .
            es_afpo-mfgorderitemopenyieldqty          = ls_afpo-mfgorderitemopenyieldqty         .
            es_afpo-mfgorderconfirmedyieldqty         = ls_afpo-mfgorderconfirmedyieldqty        .
            es_afpo-mfgorderconfirmedscrapqty         = ls_afpo-mfgorderconfirmedscrapqty        .
            es_afpo-mfgorderconfirmedreworkqty        = ls_afpo-mfgorderconfirmedreworkqty       .
            es_afpo-mfgorderconfirmedtotalqty         = ls_afpo-mfgorderconfirmedtotalqty        .
            es_afpo-mfgorderplannedtotalqty           = ls_afpo-mfgorderplannedtotalqty          .
            es_afpo-mfgorderplannedscrapqty           = ls_afpo-mfgorderplannedscrapqty          .
            es_afpo-plannedorder                      = ls_afpo-plannedorder                     .
            es_afpo-plndorderplannedstartdate         = ls_afpo-plndorderplannedstartdate        .
            es_afpo-plannedorderopeningdate           = ls_afpo-plannedorderopeningdate          .
            es_afpo-baseunit                          = ls_afpo-baseunit                         .
            es_afpo-plndorderplannedtotalqty          = ls_afpo-plndorderplannedtotalqty         .
            es_afpo-plndorderplannedscrapqty          = ls_afpo-plndorderplannedscrapqty         .
            es_afpo-companycode                       = ls_afpo-companycode                      .
            es_afpo-businessarea                      = ls_afpo-businessarea                     .
            es_afpo-accountassignmentcategory         = ls_afpo-accountassignmentcategory        .
            es_afpo-companycodecurrency               = ls_afpo-companycodecurrency              .
            es_afpo-goodsreceiptamountincocodecrcy    = ls_afpo-goodsreceiptamountincocodecrcy   .
            es_afpo-masterproductionorder             = ls_afpo-masterproductionorder            .
            es_afpo-productseasonyear                 = ls_afpo-productseasonyear                .
            es_afpo-productseason                     = ls_afpo-productseason                    .
            es_afpo-productcollection                 = ls_afpo-productcollection                .
            es_afpo-producttheme                      = ls_afpo-producttheme                     .

            CONDENSE es_afpo-manufacturingorder              .
            CONDENSE es_afpo-manufacturingorderitem          .
            CONDENSE es_afpo-manufacturingordercategory      .
            CONDENSE es_afpo-manufacturingordertype          .
            CONDENSE es_afpo-orderisreleased                 .
            CONDENSE es_afpo-ismarkedfordeletion             .
            CONDENSE es_afpo-orderitemisnotrelevantformrp    .
            CONDENSE es_afpo-material                        .
            CONDENSE es_afpo-product                         .
            CONDENSE es_afpo-productionplant                 .
            CONDENSE es_afpo-planningplant                   .
            CONDENSE es_afpo-mrpcontroller                   .
            CONDENSE es_afpo-productionsupervisor            .
            CONDENSE es_afpo-reservation                     .
            CONDENSE es_afpo-productionversion               .
            CONDENSE es_afpo-mrparea                         .
            CONDENSE es_afpo-salesorder                      .
            CONDENSE es_afpo-salesorderitem                  .
            CONDENSE es_afpo-salesorderscheduleline          .
            CONDENSE es_afpo-wbselementinternalid            .
            CONDENSE es_afpo-wbselementinternalid_2          .
            CONDENSE es_afpo-quotaarrangement                .
            CONDENSE es_afpo-quotaarrangementitem            .
            CONDENSE es_afpo-settlementreservation           .
            CONDENSE es_afpo-settlementreservationitem       .
            CONDENSE es_afpo-coproductreservation            .
            CONDENSE es_afpo-coproductreservationitem        .
            CONDENSE es_afpo-materialprocurementcategory     .
            CONDENSE es_afpo-materialprocurementtype         .
            CONDENSE es_afpo-serialnumberassgmtprofile       .
            CONDENSE es_afpo-numberofserialnumbers           .
            CONDENSE es_afpo-mfgorderitemreplnmtelmnttype    .
            CONDENSE es_afpo-productconfiguration            .
            CONDENSE es_afpo-objectinternalid                .
            CONDENSE es_afpo-manufacturingobject             .
            CONDENSE es_afpo-quantitydistributionkey         .
            CONDENSE es_afpo-effectivityparametervariant     .
            CONDENSE es_afpo-goodsreceiptisexpected          .
            CONDENSE es_afpo-goodsreceiptisnonvaluated       .
            CONDENSE es_afpo-iscompletelydelivered           .
            CONDENSE es_afpo-materialgoodsreceiptduration    .
            CONDENSE es_afpo-underdelivtolrtdlmtratioinpct   .
            CONDENSE es_afpo-overdelivtolrtdlmtratioinpct    .
            CONDENSE es_afpo-unlimitedoverdeliveryisallowed  .
            CONDENSE es_afpo-storagelocation                 .
            CONDENSE es_afpo-batch                           .
            CONDENSE es_afpo-inventoryvaluationtype          .
            CONDENSE es_afpo-inventoryvaluationcategory      .
            CONDENSE es_afpo-inventoryusabilitycode          .
            CONDENSE es_afpo-inventoryspecialstocktype       .
            CONDENSE es_afpo-inventoryspecialstockvalntype   .
            CONDENSE es_afpo-consumptionposting              .
            CONDENSE es_afpo-goodsrecipientname              .
            CONDENSE es_afpo-unloadingpointname              .
            CONDENSE es_afpo-stocksegment                    .
            CONDENSE es_afpo-mfgorderplannedstartdate        .
            CONDENSE es_afpo-mfgorderplannedstarttime        .
            CONDENSE es_afpo-mfgorderscheduledstartdate      .
            CONDENSE es_afpo-mfgorderscheduledstarttime      .
            CONDENSE es_afpo-mfgorderactualstartdate         .
            CONDENSE es_afpo-mfgorderactualstarttime         .
            CONDENSE es_afpo-mfgorderplannedenddate          .
            CONDENSE es_afpo-mfgorderplannedendtime          .
            CONDENSE es_afpo-mfgorderscheduledenddate        .
            CONDENSE es_afpo-mfgorderscheduledendtime        .
            CONDENSE es_afpo-mfgorderconfirmedenddate        .
            CONDENSE es_afpo-mfgorderconfirmedendtime        .
            CONDENSE es_afpo-mfgorderactualenddate           .
            CONDENSE es_afpo-mfgorderscheduledreleasedate    .
            CONDENSE es_afpo-mfgorderactualreleasedate       .
            CONDENSE es_afpo-mfgorderitemplannedenddate      .
            CONDENSE es_afpo-mfgorderitemscheduledenddate    .
            CONDENSE es_afpo-mfgorderitemplnddeliverydate    .
            CONDENSE es_afpo-mfgorderitemactualdeliverydate  .
            CONDENSE es_afpo-mfgorderitemtotalcmtmtdate      .
            CONDENSE es_afpo-productionunit                  .
            CONDENSE es_afpo-mfgorderitemplannedtotalqty     .
            CONDENSE es_afpo-mfgorderitemplannedscrapqty     .
            CONDENSE es_afpo-mfgorderitemplannedyieldqty     .
            CONDENSE es_afpo-mfgorderitemgoodsreceiptqty     .
            CONDENSE es_afpo-mfgorderitemactualdeviationqty  .
            CONDENSE es_afpo-mfgorderitemopenyieldqty        .
            CONDENSE es_afpo-mfgorderconfirmedyieldqty       .
            CONDENSE es_afpo-mfgorderconfirmedscrapqty       .
            CONDENSE es_afpo-mfgorderconfirmedreworkqty      .
            CONDENSE es_afpo-mfgorderconfirmedtotalqty       .
            CONDENSE es_afpo-mfgorderplannedtotalqty         .
            CONDENSE es_afpo-mfgorderplannedscrapqty         .
            CONDENSE es_afpo-plannedorder                    .
            CONDENSE es_afpo-plndorderplannedstartdate       .
            CONDENSE es_afpo-plannedorderopeningdate         .
            CONDENSE es_afpo-baseunit                        .
            CONDENSE es_afpo-plndorderplannedtotalqty        .
            CONDENSE es_afpo-plndorderplannedscrapqty        .
            CONDENSE es_afpo-companycode                     .
            CONDENSE es_afpo-businessarea                    .
            CONDENSE es_afpo-accountassignmentcategory       .
            CONDENSE es_afpo-companycodecurrency             .
            CONDENSE es_afpo-goodsreceiptamountincocodecrcy  .
            CONDENSE es_afpo-masterproductionorder           .
            CONDENSE es_afpo-productseasonyear               .
            CONDENSE es_afpo-productseason                   .
            CONDENSE es_afpo-productcollection               .
            CONDENSE es_afpo-producttheme                    .

            APPEND es_afpo TO es_response_afpo-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_afpo-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_afpo )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'PLPO'  OR 'plpo' .
        SELECT *
*           i_inspplanoperationversion_2~inspectionplangroup,
*           i_inspplanoperationversion_2~boooperationinternalid,
*           i_inspplanoperationversion_2~booopinternalversioncounter,
*           i_inspplanoperationversion_2~billofoperationstype,
*           i_inspplanoperationversion_2~inspectionplan,
*           i_inspplanoperationversion_2~workcenterinternalid,
*           i_inspplanoperationversion_2~workcentertypecode,
*           i_inspplanoperationversion_2~isdeleted,
*           i_inspplanoperationversion_2~isimplicitlydeleted,
*           i_inspplanoperationversion_2~operationexternalid,
*           i_inspplanoperationversion_2~operation,
*           i_inspplanoperationversion_2~operationtext,
*           i_inspplanoperationversion_2~plant,
*           i_inspplanoperationversion_2~operationcontrolprofile,
*           i_inspplanoperationversion_2~operationstandardtextcode,
*           i_inspplanoperationversion_2~billofoperationsreftype,
*           i_inspplanoperationversion_2~billofoperationsrefgroup,
*           i_inspplanoperationversion_2~billofoperationsrefvariant,
*           i_inspplanoperationversion_2~boorefoperationincrementvalue,
*           i_inspplanoperationversion_2~inspsbstcompletionconfirmation,
*           i_inspplanoperationversion_2~inspsbsthasnotimeorquantity,
*           i_inspplanoperationversion_2~operationreferencequantity,
*           i_inspplanoperationversion_2~operationunit,
*           i_inspplanoperationversion_2~opqtytobaseqtydnmntr,
*           i_inspplanoperationversion_2~opqtytobaseqtynmrtr,
*           i_inspplanoperationversion_2~creationdate,
*           i_inspplanoperationversion_2~createdbyuser,
*           i_inspplanoperationversion_2~lastchangedate,
*           i_inspplanoperationversion_2~lastchangedbyuser,
*           i_inspplanoperationversion_2~changenumber,
*           i_inspplanoperationversion_2~validitystartdate,
*           i_inspplanoperationversion_2~validityenddate

        FROM I_MfgBOOOperationChangeState WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_plpo).

        IF lt_plpo IS NOT INITIAL.
          LOOP  AT lt_plpo INTO DATA(ls_plpo).
          lv_count = lv_count + 1.
             MOVE-CORRESPONDING ls_plpo to es_plpo.
*            es_plpo-inspectionplangroup             = ls_plpo-inspectionplangroup             .
*            es_plpo-boooperationinternalid          = ls_plpo-boooperationinternalid          .
*            es_plpo-booopinternalversioncounter     = ls_plpo-booopinternalversioncounter     .
*            es_plpo-billofoperationstype            = ls_plpo-billofoperationstype            .
*            es_plpo-inspectionplan                  = ls_plpo-inspectionplan                  .
*            es_plpo-workcenterinternalid            = ls_plpo-workcenterinternalid            .
*            es_plpo-workcentertypecode              = ls_plpo-workcentertypecode              .
*            es_plpo-isdeleted                       = ls_plpo-isdeleted                       .
*            es_plpo-isimplicitlydeleted             = ls_plpo-isimplicitlydeleted             .
*            es_plpo-operationexternalid             = ls_plpo-operationexternalid             .
*            es_plpo-operation                       = ls_plpo-operation                       .
*            es_plpo-operationtext                   = ls_plpo-operationtext                   .
*            es_plpo-plant                           = ls_plpo-plant                           .
*            es_plpo-operationcontrolprofile         = ls_plpo-operationcontrolprofile         .
*            es_plpo-operationstandardtextcode       = ls_plpo-operationstandardtextcode       .
*            es_plpo-billofoperationsreftype         = ls_plpo-billofoperationsreftype         .
*            es_plpo-billofoperationsrefgroup        = ls_plpo-billofoperationsrefgroup        .
*            es_plpo-billofoperationsrefvariant      = ls_plpo-billofoperationsrefvariant      .
*            es_plpo-boorefoperationincrementvalue   = ls_plpo-boorefoperationincrementvalue   .
*            es_plpo-inspsbstcompletionconfirmation  = ls_plpo-inspsbstcompletionconfirmation  .
*            es_plpo-inspsbsthasnotimeorquantity     = ls_plpo-inspsbsthasnotimeorquantity     .
*            es_plpo-operationreferencequantity      = ls_plpo-operationreferencequantity      .
*            es_plpo-operationunit                   = ls_plpo-operationunit                   .
*            es_plpo-opqtytobaseqtydnmntr            = ls_plpo-opqtytobaseqtydnmntr            .
*            es_plpo-opqtytobaseqtynmrtr             = ls_plpo-opqtytobaseqtynmrtr             .
*            es_plpo-creationdate                    = ls_plpo-creationdate                    .
*            es_plpo-createdbyuser                   = ls_plpo-createdbyuser                   .
*            es_plpo-lastchangedate                  = ls_plpo-lastchangedate                  .
*            es_plpo-lastchangedbyuser               = ls_plpo-lastchangedbyuser               .
*            es_plpo-changenumber                    = ls_plpo-changenumber                    .
*            es_plpo-validitystartdate               = ls_plpo-validitystartdate               .
*            es_plpo-validityenddate                 = ls_plpo-validityenddate                 .

*            CONDENSE es_plpo-inspectionplangroup            .
*            CONDENSE es_plpo-boooperationinternalid         .
*            CONDENSE es_plpo-booopinternalversioncounter    .
*            CONDENSE es_plpo-billofoperationstype           .
*            CONDENSE es_plpo-inspectionplan                 .
*            CONDENSE es_plpo-workcenterinternalid           .
*            CONDENSE es_plpo-workcentertypecode             .
*            CONDENSE es_plpo-isdeleted                      .
*            CONDENSE es_plpo-isimplicitlydeleted            .
*            CONDENSE es_plpo-operationexternalid            .
*            CONDENSE es_plpo-operation                      .
*            CONDENSE es_plpo-operationtext                  .
*            CONDENSE es_plpo-plant                          .
*            CONDENSE es_plpo-operationcontrolprofile        .
*            CONDENSE es_plpo-operationstandardtextcode      .
*            CONDENSE es_plpo-billofoperationsreftype        .
*            CONDENSE es_plpo-billofoperationsrefgroup       .
*            CONDENSE es_plpo-billofoperationsrefvariant     .
*            CONDENSE es_plpo-boorefoperationincrementvalue  .
*            CONDENSE es_plpo-inspsbstcompletionconfirmation .
*            CONDENSE es_plpo-inspsbsthasnotimeorquantity    .
*            CONDENSE es_plpo-operationreferencequantity     .
*            CONDENSE es_plpo-operationunit                  .
*            CONDENSE es_plpo-opqtytobaseqtydnmntr           .
*            CONDENSE es_plpo-opqtytobaseqtynmrtr            .
*            CONDENSE es_plpo-creationdate                   .
*            CONDENSE es_plpo-createdbyuser                  .
*            CONDENSE es_plpo-lastchangedate                 .
*            CONDENSE es_plpo-lastchangedbyuser              .
*            CONDENSE es_plpo-changenumber                   .
*            CONDENSE es_plpo-validitystartdate              .
*            CONDENSE es_plpo-validityenddate                .

            APPEND es_plpo TO es_response_plpo-items.
            clear es_plpo.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_plpo-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_plpo )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'RESB'  OR 'resb' .
        SELECT i_mfgorderoperationcomponent~*,
               I_ManufacturingOrderItem~PlannedOrder
        FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS
        LEFT JOIN I_ManufacturingOrderItem WITH PRIVILEGED ACCESS
        on i_mfgorderoperationcomponent~ManufacturingOrder = I_ManufacturingOrderItem~ManufacturingOrder
        WHERE (lv_where)
        INTO TABLE @DATA(lt_resb).

        IF lt_resb IS NOT INITIAL.
          LOOP  AT lt_resb INTO DATA(ls_resb).
          lv_count = lv_count + 1.
          MOVE-CORRESPONDING ls_resb-i_mfgorderoperationcomponent to es_resb.
          es_resb-PlannedOrder = ls_resb-PlannedOrder  .
*            es_resb-reservation                        = ls_resb-reservation                       .
*            es_resb-reservationitem                    = ls_resb-reservationitem                   .
*            es_resb-recordtype                         = ls_resb-recordtype                        .
*            es_resb-materialgroup                      = ls_resb-materialgroup                     .
*            es_resb-material                           = ls_resb-material                          .
*            es_resb-plant                              = ls_resb-plant                             .
*            es_resb-manufacturingordercategory         = ls_resb-manufacturingordercategory        .
*            es_resb-manufacturingordertype             = ls_resb-manufacturingordertype            .
*            es_resb-manufacturingorder                 = ls_resb-manufacturingorder                .
*            es_resb-manufacturingordersequence         = ls_resb-manufacturingordersequence        .
*            es_resb-mfgordersequencecategory           = ls_resb-mfgordersequencecategory          .
**            es_resb-manufacturingorderoperation        = ls_resb-manufacturingorderoperation       .
*            es_resb-manufacturingorderoperation_2      = ls_resb-manufacturingorderoperation_2     .
*            es_resb-productionplant                    = ls_resb-productionplant                   .
*            es_resb-orderinternalbillofoperations      = ls_resb-orderinternalbillofoperations     .
*            es_resb-orderintbillofoperationsitem       = ls_resb-orderintbillofoperationsitem      .
*            es_resb-assemblymrpcontroller              = ls_resb-assemblymrpcontroller             .
*            es_resb-productionsupervisor               = ls_resb-productionsupervisor              .
*            es_resb-orderobjectinternalid              = ls_resb-orderobjectinternalid             .
*            es_resb-matlcomprequirementdate            = ls_resb-matlcomprequirementdate           .
*            es_resb-matlcomprequirementtime            = ls_resb-matlcomprequirementtime           .
*            es_resb-latestrequirementdate              = ls_resb-latestrequirementdate             .
*            es_resb-mfgorderactualreleasedate          = ls_resb-mfgorderactualreleasedate         .
*            es_resb-reservationitemcreationcode        = ls_resb-reservationitemcreationcode       .
*            es_resb-reservationisfinallyissued         = ls_resb-reservationisfinallyissued        .
*            es_resb-matlcompismarkedfordeletion        = ls_resb-matlcompismarkedfordeletion       .
*            es_resb-materialcomponentismissing         = ls_resb-materialcomponentismissing        .
*            es_resb-isbulkmaterialcomponent            = ls_resb-isbulkmaterialcomponent           .
*            es_resb-matlcompismarkedforbackflush       = ls_resb-matlcompismarkedforbackflush      .
*            es_resb-matlcompistextitem                 = ls_resb-matlcompistextitem                .
*            es_resb-materialplanningrelevance          = ls_resb-materialplanningrelevance         .
*            es_resb-matlcompisconfigurable             = ls_resb-matlcompisconfigurable            .
*            es_resb-materialcomponentisclassified      = ls_resb-materialcomponentisclassified     .
*            es_resb-materialcompisintramaterial        = ls_resb-materialcompisintramaterial       .
*            es_resb-materialisdirectlyproduced         = ls_resb-materialisdirectlyproduced        .
*            es_resb-materialisdirectlyprocured         = ls_resb-materialisdirectlyprocured        .
*            es_resb-longtextlanguagecode               = ls_resb-longtextlanguagecode              .
*            es_resb-longtextexists                     = ls_resb-longtextexists                    .
*            es_resb-requirementtype                    = ls_resb-requirementtype                   .
*            es_resb-salesorder                         = ls_resb-salesorder                        .
*            es_resb-salesorderitem                     = ls_resb-salesorderitem                    .
**            es_resb-wbselementinternalid               = ls_resb-wbselementinternalid              .
*            es_resb-wbselementinternalid_2             = ls_resb-wbselementinternalid_2            .
*            es_resb-productconfiguration               = ls_resb-productconfiguration              .
*            es_resb-changenumber                       = ls_resb-changenumber                      .
*            es_resb-materialrevisionlevel              = ls_resb-materialrevisionlevel             .
*            es_resb-effectivityparametervariant        = ls_resb-effectivityparametervariant       .
**            es_resb-sortfield                          = ls_resb-sortfield                         .
*            es_resb-materialcomponentsorttext          = ls_resb-materialcomponentsorttext         .
*            es_resb-objectinternalid                   = ls_resb-objectinternalid                  .
*            es_resb-billofmaterialcategory             = ls_resb-billofmaterialcategory            .
**            es_resb-billofmaterialinternalid           = ls_resb-billofmaterialinternalid          .
*            es_resb-billofmaterialinternalid_2         = ls_resb-billofmaterialinternalid_2        .
*            es_resb-billofmaterialvariantusage         = ls_resb-billofmaterialvariantusage        .
*            es_resb-billofmaterialvariant              = ls_resb-billofmaterialvariant             .
*            es_resb-billofmaterial                     = ls_resb-billofmaterial                    .
*            es_resb-bomitem                            = ls_resb-bomitem                           .
*            es_resb-billofmaterialversion              = ls_resb-billofmaterialversion             .
*            es_resb-bomiteminternalchangecount         = ls_resb-bomiteminternalchangecount        .
*            es_resb-inheritedbomitemnode               = ls_resb-inheritedbomitemnode              .
*            es_resb-bomitemcategory                    = ls_resb-bomitemcategory                   .
**            es_resb-billofmaterialitemnumber           = ls_resb-billofmaterialitemnumber          .
*            es_resb-billofmaterialitemnumber_2         = ls_resb-billofmaterialitemnumber_2        .
*            es_resb-bomitemdescription                 = ls_resb-bomitemdescription                .
*            es_resb-bomitemtext2                       = ls_resb-bomitemtext2                      .
*            es_resb-bomexplosiondateid                 = ls_resb-bomexplosiondateid                .
*            es_resb-purchasinginforecord               = ls_resb-purchasinginforecord              .
*            es_resb-purchasinggroup                    = ls_resb-purchasinggroup                   .
*            es_resb-purchaserequisition                = ls_resb-purchaserequisition               .
*            es_resb-purchaserequisitionitem            = ls_resb-purchaserequisitionitem           .
*            es_resb-purchaseorder                      = ls_resb-purchaseorder                     .
*            es_resb-purchaseorderitem                  = ls_resb-purchaseorderitem                 .
*            es_resb-purchaseorderscheduleline          = ls_resb-purchaseorderscheduleline         .
*            es_resb-supplier                           = ls_resb-supplier                          .
*            es_resb-deliverydurationindays             = ls_resb-deliverydurationindays            .
*            es_resb-materialgoodsreceiptduration       = ls_resb-materialgoodsreceiptduration      .
*            es_resb-externalprocessingprice            = ls_resb-externalprocessingprice           .
*            es_resb-numberofoperationpriceunits        = ls_resb-numberofoperationpriceunits       .
*            es_resb-goodsmovementisallowed             = ls_resb-goodsmovementisallowed            .
*            es_resb-storagelocation                    = ls_resb-storagelocation                   .
*            es_resb-debitcreditcode                    = ls_resb-debitcreditcode                   .
*            es_resb-goodsmovementtype                  = ls_resb-goodsmovementtype                 .
*            es_resb-inventoryspecialstocktype          = ls_resb-inventoryspecialstocktype         .
*            es_resb-inventoryspecialstockvalntype      = ls_resb-inventoryspecialstockvalntype     .
*            es_resb-consumptionposting                 = ls_resb-consumptionposting                .
*            es_resb-supplyarea                         = ls_resb-supplyarea                        .
*            es_resb-goodsrecipientname                 = ls_resb-goodsrecipientname                .
*            es_resb-unloadingpointname                 = ls_resb-unloadingpointname                .
*            es_resb-stocksegment                       = ls_resb-stocksegment                      .
*            es_resb-requirementsegment                 = ls_resb-requirementsegment                .
*            es_resb-batch                              = ls_resb-batch                             .
*            es_resb-batchentrydeterminationcode        = ls_resb-batchentrydeterminationcode       .
*            es_resb-batchsplittype                     = ls_resb-batchsplittype                    .
*            es_resb-batchmasterreservationitem         = ls_resb-batchmasterreservationitem        .
*            es_resb-batchclassification                = ls_resb-batchclassification               .
*            es_resb-materialstaging                    = ls_resb-materialstaging                   .
*            es_resb-warehouse                          = ls_resb-warehouse                         .
*            es_resb-storagetype                        = ls_resb-storagetype                       .
*            es_resb-storagebin                         = ls_resb-storagebin                        .
*            es_resb-materialcompiscostrelevant         = ls_resb-materialcompiscostrelevant        .
*            es_resb-businessarea                       = ls_resb-businessarea                      .
*            es_resb-companycode                        = ls_resb-companycode                       .
*            es_resb-glaccount                          = ls_resb-glaccount                         .
*            es_resb-functionalarea                     = ls_resb-functionalarea                    .
*            es_resb-controllingarea                    = ls_resb-controllingarea                   .
*            es_resb-accountassignmentcategory          = ls_resb-accountassignmentcategory         .
**            es_resb-commitmentitem                     = ls_resb-commitmentitem                    .
*            es_resb-commitmentitemshortid              = ls_resb-commitmentitemshortid             .
*            es_resb-fundscenter                        = ls_resb-fundscenter                       .
*            es_resb-materialcompisvariablesized        = ls_resb-materialcompisvariablesized       .
**            es_resb-numberofvariablesizecomponents     = ls_resb-numberofvariablesizecomponents    .
*            es_resb-variablesizeitemunit               = ls_resb-variablesizeitemunit              .
*            es_resb-variablesizeitemquantity           = ls_resb-variablesizeitemquantity          .
*            es_resb-variablesizecomponentunit          = ls_resb-variablesizecomponentunit         .
*            es_resb-variablesizecomponentquantity      = ls_resb-variablesizecomponentquantity     .
*            es_resb-variablesizedimensionunit          = ls_resb-variablesizedimensionunit         .
*            es_resb-variablesizedimension1             = ls_resb-variablesizedimension1            .
*            es_resb-variablesizedimension2             = ls_resb-variablesizedimension2            .
*            es_resb-variablesizedimension3             = ls_resb-variablesizedimension3            .
*            es_resb-formulakey                         = ls_resb-formulakey                        .
*            es_resb-materialcompisalternativeitem      = ls_resb-materialcompisalternativeitem     .
*            es_resb-alternativeitemgroup               = ls_resb-alternativeitemgroup              .
*            es_resb-alternativeitemstrategy            = ls_resb-alternativeitemstrategy           .
*            es_resb-alternativeitempriority            = ls_resb-alternativeitempriority           .
*            es_resb-usageprobabilitypercent            = ls_resb-usageprobabilitypercent           .
*            es_resb-alternativemstrreservationitem     = ls_resb-alternativemstrreservationitem    .
*            es_resb-materialcomponentisphantomitem     = ls_resb-materialcomponentisphantomitem    .
*            es_resb-orderpathvalue                     = ls_resb-orderpathvalue                    .
*            es_resb-orderlevelvalue                    = ls_resb-orderlevelvalue                   .
*            es_resb-assembly                           = ls_resb-assembly                          .
*            es_resb-assemblyorderpathvalue             = ls_resb-assemblyorderpathvalue            .
*            es_resb-assemblyorderlevelvalue            = ls_resb-assemblyorderlevelvalue           .
*            es_resb-discontinuationgroup               = ls_resb-discontinuationgroup              .
*            es_resb-matlcompdiscontinuationtype        = ls_resb-matlcompdiscontinuationtype       .
*            es_resb-matlcompisfollowupmaterial         = ls_resb-matlcompisfollowupmaterial        .
*            es_resb-followupgroup                      = ls_resb-followupgroup                     .
*            es_resb-followupmaterial                   = ls_resb-followupmaterial                  .
**            es_resb-followupmaterialisnotactive        = ls_resb-followupmaterialisnotactive       .
*            es_resb-followupmaterialisactive           = ls_resb-followupmaterialisactive          .
*            es_resb-discontinuationmasterresvnitem     = ls_resb-discontinuationmasterresvnitem    .
*            es_resb-materialprovisiontype              = ls_resb-materialprovisiontype             .
*            es_resb-matlcomponentspareparttype         = ls_resb-matlcomponentspareparttype        .
*            es_resb-leadtimeoffset                     = ls_resb-leadtimeoffset                    .
*            es_resb-operationleadtimeoffsetunit        = ls_resb-operationleadtimeoffsetunit       .
*            es_resb-operationleadtimeoffset            = ls_resb-operationleadtimeoffset           .
*            es_resb-quantityisfixed                    = ls_resb-quantityisfixed                   .
*            es_resb-isnetscrap                         = ls_resb-isnetscrap                        .
*            es_resb-componentscrapinpercent            = ls_resb-componentscrapinpercent           .
*            es_resb-operationscrapinpercent            = ls_resb-operationscrapinpercent           .
*            es_resb-materialqtytobaseqtynmrtr          = ls_resb-materialqtytobaseqtynmrtr         .
*            es_resb-materialqtytobaseqtydnmntr         = ls_resb-materialqtytobaseqtydnmntr        .
*            es_resb-baseunit                           = ls_resb-baseunit                          .
*            es_resb-requiredquantity                   = ls_resb-requiredquantity                  .
*            es_resb-withdrawnquantity                  = ls_resb-withdrawnquantity                 .
*            es_resb-confirmedavailablequantity         = ls_resb-confirmedavailablequantity        .
*            es_resb-materialcomporiginalquantity       = ls_resb-materialcomporiginalquantity      .
*            es_resb-entryunit                          = ls_resb-entryunit                         .
*            es_resb-goodsmovemententryqty              = ls_resb-goodsmovemententryqty             .
*            es_resb-currency                           = ls_resb-currency                          .
*            es_resb-withdrawnquantityamount            = ls_resb-withdrawnquantityamount           .
*            es_resb-criticalcomponenttype              = ls_resb-criticalcomponenttype             .
*            es_resb-criticalcomponentlevel             = ls_resb-criticalcomponentlevel            .
*            .
*
*            CONDENSE es_resb-reservation                       .
*            CONDENSE es_resb-reservationitem                   .
*            CONDENSE es_resb-recordtype                        .
*            CONDENSE es_resb-materialgroup                     .
*            CONDENSE es_resb-material                          .
*            CONDENSE es_resb-plant                             .
*            CONDENSE es_resb-manufacturingordercategory        .
*            CONDENSE es_resb-manufacturingordertype            .
*            CONDENSE es_resb-manufacturingorder                .
*            CONDENSE es_resb-manufacturingordersequence        .
*            CONDENSE es_resb-mfgordersequencecategory          .
*            CONDENSE es_resb-manufacturingorderoperation       .
*            CONDENSE es_resb-manufacturingorderoperation_2     .
*            CONDENSE es_resb-productionplant                   .
*            CONDENSE es_resb-orderinternalbillofoperations     .
*            CONDENSE es_resb-orderintbillofoperationsitem      .
*            CONDENSE es_resb-assemblymrpcontroller             .
*            CONDENSE es_resb-productionsupervisor              .
*            CONDENSE es_resb-orderobjectinternalid             .
*            CONDENSE es_resb-matlcomprequirementdate           .
*            CONDENSE es_resb-matlcomprequirementtime           .
*            CONDENSE es_resb-latestrequirementdate             .
*            CONDENSE es_resb-mfgorderactualreleasedate         .
*            CONDENSE es_resb-reservationitemcreationcode       .
*            CONDENSE es_resb-reservationisfinallyissued        .
*            CONDENSE es_resb-matlcompismarkedfordeletion       .
*            CONDENSE es_resb-materialcomponentismissing        .
*            CONDENSE es_resb-isbulkmaterialcomponent           .
*            CONDENSE es_resb-matlcompismarkedforbackflush      .
*            CONDENSE es_resb-matlcompistextitem                .
*            CONDENSE es_resb-materialplanningrelevance         .
*            CONDENSE es_resb-matlcompisconfigurable            .
*            CONDENSE es_resb-materialcomponentisclassified     .
*            CONDENSE es_resb-materialcompisintramaterial       .
*            CONDENSE es_resb-materialisdirectlyproduced        .
*            CONDENSE es_resb-materialisdirectlyprocured        .
*            CONDENSE es_resb-longtextlanguagecode              .
*            CONDENSE es_resb-longtextexists                    .
*            CONDENSE es_resb-requirementtype                   .
*            CONDENSE es_resb-salesorder                        .
*            CONDENSE es_resb-salesorderitem                    .
*            CONDENSE es_resb-wbselementinternalid              .
*            CONDENSE es_resb-wbselementinternalid_2            .
*            CONDENSE es_resb-productconfiguration              .
*            CONDENSE es_resb-changenumber                      .
*            CONDENSE es_resb-materialrevisionlevel             .
*            CONDENSE es_resb-effectivityparametervariant       .
*            CONDENSE es_resb-sortfield                         .
*            CONDENSE es_resb-materialcomponentsorttext         .
*            CONDENSE es_resb-objectinternalid                  .
*            CONDENSE es_resb-billofmaterialcategory            .
*            CONDENSE es_resb-billofmaterialinternalid          .
*            CONDENSE es_resb-billofmaterialinternalid_2        .
*            CONDENSE es_resb-billofmaterialvariantusage        .
*            CONDENSE es_resb-billofmaterialvariant             .
*            CONDENSE es_resb-billofmaterial                    .
*            CONDENSE es_resb-bomitem                           .
*            CONDENSE es_resb-billofmaterialversion             .
*            CONDENSE es_resb-bomiteminternalchangecount        .
*            CONDENSE es_resb-inheritedbomitemnode              .
*            CONDENSE es_resb-bomitemcategory                   .
*            CONDENSE es_resb-billofmaterialitemnumber          .
*            CONDENSE es_resb-billofmaterialitemnumber_2        .
*            CONDENSE es_resb-bomitemdescription                .
*            CONDENSE es_resb-bomitemtext2                      .
*            CONDENSE es_resb-bomexplosiondateid                .
*            CONDENSE es_resb-purchasinginforecord              .
*            CONDENSE es_resb-purchasinggroup                   .
*            CONDENSE es_resb-purchaserequisition               .
*            CONDENSE es_resb-purchaserequisitionitem           .
*            CONDENSE es_resb-purchaseorder                     .
*            CONDENSE es_resb-purchaseorderitem                 .
*            CONDENSE es_resb-purchaseorderscheduleline         .
*            CONDENSE es_resb-supplier                          .
*            CONDENSE es_resb-deliverydurationindays            .
*            CONDENSE es_resb-materialgoodsreceiptduration      .
*            CONDENSE es_resb-externalprocessingprice           .
*            CONDENSE es_resb-numberofoperationpriceunits       .
*            CONDENSE es_resb-goodsmovementisallowed            .
*            CONDENSE es_resb-storagelocation                   .
*            CONDENSE es_resb-debitcreditcode                   .
*            CONDENSE es_resb-goodsmovementtype                 .
*            CONDENSE es_resb-inventoryspecialstocktype         .
*            CONDENSE es_resb-inventoryspecialstockvalntype     .
*            CONDENSE es_resb-consumptionposting                .
*            CONDENSE es_resb-supplyarea                        .
*            CONDENSE es_resb-goodsrecipientname                .
*            CONDENSE es_resb-unloadingpointname                .
*            CONDENSE es_resb-stocksegment                      .
*            CONDENSE es_resb-requirementsegment                .
*            CONDENSE es_resb-batch                             .
*            CONDENSE es_resb-batchentrydeterminationcode       .
*            CONDENSE es_resb-batchsplittype                    .
*            CONDENSE es_resb-batchmasterreservationitem        .
*            CONDENSE es_resb-batchclassification               .
*            CONDENSE es_resb-materialstaging                   .
*            CONDENSE es_resb-warehouse                         .
*            CONDENSE es_resb-storagetype                       .
*            CONDENSE es_resb-storagebin                        .
*            CONDENSE es_resb-materialcompiscostrelevant        .
*            CONDENSE es_resb-businessarea                      .
*            CONDENSE es_resb-companycode                       .
*            CONDENSE es_resb-glaccount                         .
*            CONDENSE es_resb-functionalarea                    .
*            CONDENSE es_resb-controllingarea                   .
*            CONDENSE es_resb-accountassignmentcategory         .
*            CONDENSE es_resb-commitmentitem                    .
*            CONDENSE es_resb-commitmentitemshortid             .
*            CONDENSE es_resb-fundscenter                       .
*            CONDENSE es_resb-materialcompisvariablesized       .
*            CONDENSE es_resb-numberofvariablesizecomponents    .
*            CONDENSE es_resb-variablesizeitemunit              .
*            CONDENSE es_resb-variablesizeitemquantity          .
*            CONDENSE es_resb-variablesizecomponentunit         .
*            CONDENSE es_resb-variablesizecomponentquantity     .
*            CONDENSE es_resb-variablesizedimensionunit         .
*            CONDENSE es_resb-variablesizedimension1            .
*            CONDENSE es_resb-variablesizedimension2            .
*            CONDENSE es_resb-variablesizedimension3            .
*            CONDENSE es_resb-formulakey                        .
*            CONDENSE es_resb-materialcompisalternativeitem     .
*            CONDENSE es_resb-alternativeitemgroup              .
*            CONDENSE es_resb-alternativeitemstrategy           .
*            CONDENSE es_resb-alternativeitempriority           .
*            CONDENSE es_resb-usageprobabilitypercent           .
*            CONDENSE es_resb-alternativemstrreservationitem    .
*            CONDENSE es_resb-materialcomponentisphantomitem    .
*            CONDENSE es_resb-orderpathvalue                    .
*            CONDENSE es_resb-orderlevelvalue                   .
*            CONDENSE es_resb-assembly                          .
*            CONDENSE es_resb-assemblyorderpathvalue            .
*            CONDENSE es_resb-assemblyorderlevelvalue           .
*            CONDENSE es_resb-discontinuationgroup              .
*            CONDENSE es_resb-matlcompdiscontinuationtype       .
*            CONDENSE es_resb-matlcompisfollowupmaterial        .
*            CONDENSE es_resb-followupgroup                     .
*            CONDENSE es_resb-followupmaterial                  .
*            CONDENSE es_resb-followupmaterialisnotactive       .
*            CONDENSE es_resb-followupmaterialisactive          .
*            CONDENSE es_resb-discontinuationmasterresvnitem    .
*            CONDENSE es_resb-materialprovisiontype             .
*            CONDENSE es_resb-matlcomponentspareparttype        .
*            CONDENSE es_resb-leadtimeoffset                    .
*            CONDENSE es_resb-operationleadtimeoffsetunit       .
*            CONDENSE es_resb-operationleadtimeoffset           .
*            CONDENSE es_resb-quantityisfixed                   .
*            CONDENSE es_resb-isnetscrap                        .
*            CONDENSE es_resb-componentscrapinpercent           .
*            CONDENSE es_resb-operationscrapinpercent           .
*            CONDENSE es_resb-materialqtytobaseqtynmrtr         .
*            CONDENSE es_resb-materialqtytobaseqtydnmntr        .
*            CONDENSE es_resb-baseunit                          .
*            CONDENSE es_resb-requiredquantity                  .
*            CONDENSE es_resb-withdrawnquantity                 .
*            CONDENSE es_resb-confirmedavailablequantity        .
*            CONDENSE es_resb-materialcomporiginalquantity      .
*            CONDENSE es_resb-entryunit                         .
*            CONDENSE es_resb-goodsmovemententryqty             .
*            CONDENSE es_resb-currency                          .
*            CONDENSE es_resb-withdrawnquantityamount           .
*            CONDENSE es_resb-criticalcomponenttype             .
*            CONDENSE es_resb-criticalcomponentlevel            .

            APPEND es_resb TO es_response_resb-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_resb-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_resb )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'AFVC'  OR 'afvc' .
*
      SELECT *
        from i_manufacturingorderoperation WITH PRIVILEGED ACCESS
       WHERE (lv_where)
        INTO TABLE @DATA(lt_afvc).

        IF lt_afvc IS NOT INITIAL.

          LOOP  AT lt_afvc INTO DATA(ls_afvc).
             lv_count = lv_count + 1.

        es_afvc-MfgOrderInternalID                 =    ls_afvc-MfgOrderInternalID             .
        es_afvc-OrderOperationInternalID           =    ls_afvc-OrderOperationInternalID       .
        es_afvc-ManufacturingOrder                 =    ls_afvc-ManufacturingOrder             .
        es_afvc-ManufacturingOrderSequence         =    ls_afvc-ManufacturingOrderSequence     .
*        es_afvc-ManufacturingOrderOperation        =    ls_afvc-ManufacturingOrderOperation    .
        es_afvc-ManufacturingOrderOperation_2      =    ls_afvc-ManufacturingOrderOperation_2  .
*        es_afvc-ManufacturingOrderSubOperation     =    ls_afvc-ManufacturingOrderSubOperation .
        es_afvc-ManufacturingOrdSubOperation_2     =    ls_afvc-ManufacturingOrdSubOperation_2 .
*        es_afvc-MfgOrderOperationOrSubOp           =    ls_afvc-MfgOrderOperationOrSubOp       .
        es_afvc-MfgOrderOperationOrSubOp_2         =    ls_afvc-MfgOrderOperationOrSubOp_2     .
        es_afvc-MfgOrderOperationIsPhase           =    ls_afvc-MfgOrderOperationIsPhase       .
        es_afvc-OrderIntBillOfOpItemOfPhase        =    ls_afvc-OrderIntBillOfOpItemOfPhase    .
*        es_afvc-MfgOrderPhaseSuperiorOperation     =    ls_afvc-MfgOrderPhaseSuperiorOperation .
        es_afvc-SuperiorOperation_2                =    ls_afvc-SuperiorOperation_2            .
        es_afvc-ManufacturingOrderCategory         =    ls_afvc-ManufacturingOrderCategory     .
        es_afvc-ManufacturingOrderType             =    ls_afvc-ManufacturingOrderType         .
        es_afvc-ProductionSupervisor               =    ls_afvc-ProductionSupervisor           .
        es_afvc-MRPController                      =    ls_afvc-MRPController                  .
        es_afvc-ResponsiblePlannerGroup            =    ls_afvc-ResponsiblePlannerGroup        .
        es_afvc-ProductConfiguration               =    ls_afvc-ProductConfiguration           .
        es_afvc-InspectionLot                      =    ls_afvc-InspectionLot                  .
        es_afvc-ManufacturingOrderImportance       =    ls_afvc-ManufacturingOrderImportance   .
        es_afvc-MfgOrderOperationText              =    ls_afvc-MfgOrderOperationText          .
        es_afvc-OperationStandardTextCode          =    ls_afvc-OperationStandardTextCode      .
        es_afvc-OperationHasLongText               =    ls_afvc-OperationHasLongText           .
        es_afvc-Language                           =    ls_afvc-Language                       .
        es_afvc-OperationIsToBeDeleted             =    ls_afvc-OperationIsToBeDeleted         .
        es_afvc-NumberOfCapacities                 =    ls_afvc-NumberOfCapacities             .
        es_afvc-NumberOfConfirmationSlips          =    ls_afvc-NumberOfConfirmationSlips      .
        es_afvc-OperationImportance                =    ls_afvc-OperationImportance            .
        es_afvc-SuperiorOperationInternalID        =    ls_afvc-SuperiorOperationInternalID    .
        es_afvc-Plant                              =    ls_afvc-Plant                          .
        es_afvc-WorkCenterInternalID               =    ls_afvc-WorkCenterInternalID           .
*        es_afvc-WorkCenterTypeCode                 =    ls_afvc-WorkCenterTypeCode             .

        es_afvc-WorkCenterTypeCode_2               =  ls_afvc-WorkCenterTypeCode_2               .
        es_afvc-OperationControlProfile            =  ls_afvc-OperationControlProfile            .
        es_afvc-ControlRecipeDestination           =  ls_afvc-ControlRecipeDestination           .
        es_afvc-OperationConfirmation              =  ls_afvc-OperationConfirmation              .
        es_afvc-NumberOfOperationConfirmations     =  ls_afvc-NumberOfOperationConfirmations     .
        es_afvc-FactoryCalendar                    =  ls_afvc-FactoryCalendar                    .
        es_afvc-CapacityRequirement                =  ls_afvc-CapacityRequirement                .
        es_afvc-CapacityRequirementItem            =  ls_afvc-CapacityRequirementItem            .
        es_afvc-ChangeNumber                       =  ls_afvc-ChangeNumber                       .
        es_afvc-ObjectInternalID                   =  ls_afvc-ObjectInternalID                   .
        es_afvc-OperationTrackingNumber            =  ls_afvc-OperationTrackingNumber            .
        es_afvc-BillOfOperationsType               =  ls_afvc-BillOfOperationsType               .
        es_afvc-BillOfOperationsGroup              =  ls_afvc-BillOfOperationsGroup              .
        es_afvc-BillOfOperationsVariant            =  ls_afvc-BillOfOperationsVariant            .
        es_afvc-BillOfOperationsSequence           =  ls_afvc-BillOfOperationsSequence           .
        es_afvc-BOOOperationInternalID             =  ls_afvc-BOOOperationInternalID             .
        es_afvc-BillOfOperationsVersion            =  ls_afvc-BillOfOperationsVersion            .
        es_afvc-BillOfMaterialCategory             =  ls_afvc-BillOfMaterialCategory             .
*        es_afvc-BillOfMaterialInternalID           =  ls_afvc-BillOfMaterialInternalID           .
        es_afvc-BillOfMaterialInternalID_2         =  ls_afvc-BillOfMaterialInternalID_2         .
        es_afvc-BillOfMaterialItemNodeNumber       =  ls_afvc-BillOfMaterialItemNodeNumber       .
        es_afvc-BOMItemNodeCount                   =  ls_afvc-BOMItemNodeCount                   .
        es_afvc-ExtProcgOperationHasSubcontrg      =  ls_afvc-ExtProcgOperationHasSubcontrg      .
        es_afvc-PurchasingOrganization             =  ls_afvc-PurchasingOrganization             .
        es_afvc-PurchasingGroup                    =  ls_afvc-PurchasingGroup                    .
        es_afvc-PurchaseRequisition                =  ls_afvc-PurchaseRequisition                .
        es_afvc-PurchaseRequisitionItem            =  ls_afvc-PurchaseRequisitionItem            .
        es_afvc-PurchaseOrder                      =  ls_afvc-PurchaseOrder                      .
        es_afvc-PurchaseOrderItem                  =  ls_afvc-PurchaseOrderItem                  .
        es_afvc-PurchasingInfoRecord               =  ls_afvc-PurchasingInfoRecord               .
        es_afvc-PurgInfoRecdDataIsFixed            =  ls_afvc-PurgInfoRecdDataIsFixed            .
        es_afvc-PurchasingInfoRecordCategory       =  ls_afvc-PurchasingInfoRecordCategory       .
        es_afvc-Supplier                           =  ls_afvc-Supplier                           .
        es_afvc-GoodsRecipientName                 =  ls_afvc-GoodsRecipientName                 .
        es_afvc-UnloadingPointName                 =  ls_afvc-UnloadingPointName                 .
        es_afvc-MaterialGroup                      =  ls_afvc-MaterialGroup                      .
        es_afvc-OpExternalProcessingCurrency       =  ls_afvc-OpExternalProcessingCurrency       .
        es_afvc-OpExternalProcessingPrice          =  ls_afvc-OpExternalProcessingPrice          .
        es_afvc-NumberOfOperationPriceUnits        =  ls_afvc-NumberOfOperationPriceUnits        .
        es_afvc-CompanyCode                        =  ls_afvc-CompanyCode                        .
        es_afvc-BusinessArea                       =  ls_afvc-BusinessArea                       .
        es_afvc-ControllingArea                    =  ls_afvc-ControllingArea                    .

        es_afvc-ProfitCenter                       =  ls_afvc-ProfitCenter                    .
        es_afvc-RequestingCostCenter               =  ls_afvc-RequestingCostCenter            .
        es_afvc-CostElement                        =  ls_afvc-CostElement                     .
        es_afvc-CostingVariant                     =  ls_afvc-CostingVariant                  .
        es_afvc-CostingSheet                       =  ls_afvc-CostingSheet                    .
        es_afvc-CostEstimate                       =  ls_afvc-CostEstimate                    .
        es_afvc-ControllingObjectCurrency          =  ls_afvc-ControllingObjectCurrency       .
        es_afvc-ControllingObjectClass             =  ls_afvc-ControllingObjectClass          .
        es_afvc-FunctionalArea                     =  ls_afvc-FunctionalArea                  .
        es_afvc-TaxJurisdiction                    =  ls_afvc-TaxJurisdiction                 .
        es_afvc-EmployeeWageType                   =  ls_afvc-EmployeeWageType                .
        es_afvc-EmployeeWageGroup                  =  ls_afvc-EmployeeWageGroup               .
        es_afvc-EmployeeSuitability                =  ls_afvc-EmployeeSuitability             .
        es_afvc-NumberOfTimeTickets                =  ls_afvc-NumberOfTimeTickets             .
        es_afvc-Personnel                          =  ls_afvc-Personnel                       .
        es_afvc-NumberOfEmployees                  =  ls_afvc-NumberOfEmployees               .
        es_afvc-OperationSetupGroupCategory        =  ls_afvc-OperationSetupGroupCategory     .
        es_afvc-OperationSetupGroup                =  ls_afvc-OperationSetupGroup             .
        es_afvc-OperationSetupType                 =  ls_afvc-OperationSetupType              .
        es_afvc-OperationOverlappingIsRequired     =  ls_afvc-OperationOverlappingIsRequired  .
        es_afvc-OperationOverlappingIsPossible     =  ls_afvc-OperationOverlappingIsPossible  .
        es_afvc-OperationsIsAlwaysOverlapping      =  ls_afvc-OperationsIsAlwaysOverlapping   .
        es_afvc-OperationSplitIsRequired           =  ls_afvc-OperationSplitIsRequired        .
        es_afvc-MaximumNumberOfSplits              =  ls_afvc-MaximumNumberOfSplits           .
        es_afvc-LeadTimeReductionStrategy          =  ls_afvc-LeadTimeReductionStrategy       .
        es_afvc-OpSchedldReductionLevel            =  ls_afvc-OpSchedldReductionLevel         .
        es_afvc-OpErlstSchedldExecStrtDte          =  ls_afvc-OpErlstSchedldExecStrtDte       .
        es_afvc-OpErlstSchedldExecStrtTme          =  ls_afvc-OpErlstSchedldExecStrtTme       .
        es_afvc-OpErlstSchedldProcgStrtDte         =  ls_afvc-OpErlstSchedldProcgStrtDte      .
        es_afvc-OpErlstSchedldProcgStrtTme         =  ls_afvc-OpErlstSchedldProcgStrtTme      .
        es_afvc-OpErlstSchedldTrdwnStrtDte         =  ls_afvc-OpErlstSchedldTrdwnStrtDte      .
        es_afvc-OpErlstSchedldTrdwnStrtTme         =  ls_afvc-OpErlstSchedldTrdwnStrtTme      .
        es_afvc-OpErlstSchedldExecEndDte           =  ls_afvc-OpErlstSchedldExecEndDte        .
        es_afvc-OpErlstSchedldExecEndTme           =  ls_afvc-OpErlstSchedldExecEndTme        .
        es_afvc-OpLtstSchedldExecStrtDte           =  ls_afvc-OpLtstSchedldExecStrtDte        .
        es_afvc-OpLtstSchedldExecStrtTme           =  ls_afvc-OpLtstSchedldExecStrtTme        .
        es_afvc-OpLtstSchedldProcgStrtDte          =  ls_afvc-OpLtstSchedldProcgStrtDte       .
        es_afvc-OpLtstSchedldProcgStrtTme          =  ls_afvc-OpLtstSchedldProcgStrtTme       .
        es_afvc-OpLtstSchedldTrdwnStrtDte          =  ls_afvc-OpLtstSchedldTrdwnStrtDte       .

        es_afvc-OpLtstSchedldTrdwnStrtTme          =   ls_afvc-OpLtstSchedldTrdwnStrtTme       .
        es_afvc-OpLtstSchedldExecEndDte            =   ls_afvc-OpLtstSchedldExecEndDte         .
        es_afvc-OpLtstSchedldExecEndTme            =   ls_afvc-OpLtstSchedldExecEndTme         .
        es_afvc-SchedldFcstdEarliestStartDate      =   ls_afvc-SchedldFcstdEarliestStartDate   .
        es_afvc-SchedldFcstdEarliestStartTime      =   ls_afvc-SchedldFcstdEarliestStartTime   .
        es_afvc-SchedldFcstdEarliestEndDate        =   ls_afvc-SchedldFcstdEarliestEndDate     .
        es_afvc-SchedldFcstdEarliestEndTime        =   ls_afvc-SchedldFcstdEarliestEndTime     .
        es_afvc-LatestSchedldFcstdStartDate        =   ls_afvc-LatestSchedldFcstdStartDate     .
        es_afvc-SchedldFcstdLatestStartTime        =   ls_afvc-SchedldFcstdLatestStartTime     .
        es_afvc-LatestSchedldFcstdEndDate          =   ls_afvc-LatestSchedldFcstdEndDate       .
        es_afvc-SchedldFcstdLatestEndTime          =   ls_afvc-SchedldFcstdLatestEndTime       .
        es_afvc-OperationConfirmedStartDate        =   ls_afvc-OperationConfirmedStartDate     .
        es_afvc-OperationConfirmedEndDate          =   ls_afvc-OperationConfirmedEndDate       .
        es_afvc-OpActualExecutionStartDate         =   ls_afvc-OpActualExecutionStartDate      .
        es_afvc-OpActualExecutionStartTime         =   ls_afvc-OpActualExecutionStartTime      .
        es_afvc-OpActualSetupEndDate               =   ls_afvc-OpActualSetupEndDate            .
        es_afvc-OpActualSetupEndTime               =   ls_afvc-OpActualSetupEndTime            .
        es_afvc-OpActualProcessingStartDate        =   ls_afvc-OpActualProcessingStartDate     .
        es_afvc-OpActualProcessingStartTime        =   ls_afvc-OpActualProcessingStartTime     .
        es_afvc-OpActualProcessingEndDate          =   ls_afvc-OpActualProcessingEndDate       .
        es_afvc-OpActualProcessingEndTime          =   ls_afvc-OpActualProcessingEndTime       .
        es_afvc-OpActualTeardownStartDate          =   ls_afvc-OpActualTeardownStartDate       .
        es_afvc-OpActualTeardownStartTme           =   ls_afvc-OpActualTeardownStartTme        .
        es_afvc-OpActualExecutionEndDate           =   ls_afvc-OpActualExecutionEndDate        .
        es_afvc-OpActualExecutionEndTime           =   ls_afvc-OpActualExecutionEndTime        .
        es_afvc-ActualForecastEndDate              =   ls_afvc-ActualForecastEndDate           .
        es_afvc-ActualForecastEndTime              =   ls_afvc-ActualForecastEndTime           .
        es_afvc-EarliestScheduledWaitStartDate     =   ls_afvc-EarliestScheduledWaitStartDate  .
        es_afvc-EarliestScheduledWaitStartTime     =   ls_afvc-EarliestScheduledWaitStartTime  .
        es_afvc-EarliestScheduledWaitEndDate       =   ls_afvc-EarliestScheduledWaitEndDate    .
        es_afvc-EarliestScheduledWaitEndTime       =   ls_afvc-EarliestScheduledWaitEndTime    .
        es_afvc-LatestScheduledWaitStartDate       =   ls_afvc-LatestScheduledWaitStartDate    .
        es_afvc-LatestScheduledWaitStartTime       =   ls_afvc-LatestScheduledWaitStartTime    .
        es_afvc-LatestScheduledWaitEndDate         =   ls_afvc-LatestScheduledWaitEndDate      .
        es_afvc-LatestScheduledWaitEndTime         =   ls_afvc-LatestScheduledWaitEndTime      .
        es_afvc-BreakDurationUnit                  =   ls_afvc-BreakDurationUnit               .
        es_afvc-PlannedBreakDuration               =   ls_afvc-PlannedBreakDuration            .
        es_afvc-ConfirmedBreakDuration             =   ls_afvc-ConfirmedBreakDuration          .
        es_afvc-OverlapMinimumDurationUnit         =   ls_afvc-OverlapMinimumDurationUnit      .
        es_afvc-OverlapMinimumDuration             =   ls_afvc-OverlapMinimumDuration          .
        es_afvc-MaximumWaitDurationUnit            =   ls_afvc-MaximumWaitDurationUnit         .
        es_afvc-MaximumWaitDuration                =   ls_afvc-MaximumWaitDuration             .
        es_afvc-MinimumWaitDurationUnit            =   ls_afvc-MinimumWaitDurationUnit         .
        es_afvc-MinimumWaitDuration                =   ls_afvc-MinimumWaitDuration             .
        es_afvc-StandardMoveDurationUnit           =   ls_afvc-StandardMoveDurationUnit        .
        es_afvc-StandardMoveDuration               =   ls_afvc-StandardMoveDuration            .
        es_afvc-StandardQueueDurationUnit          =   ls_afvc-StandardQueueDurationUnit       .


        es_afvc-StandardQueueDuration              = ls_afvc-StandardQueueDuration             .
        es_afvc-MinimumQueueDurationUnit           = ls_afvc-MinimumQueueDurationUnit          .
        es_afvc-MinimumQueueDuration               = ls_afvc-MinimumQueueDuration              .
        es_afvc-MinimumMoveDurationUnit            = ls_afvc-MinimumMoveDurationUnit           .
        es_afvc-MinimumMoveDuration                = ls_afvc-MinimumMoveDuration               .
        es_afvc-OperationStandardDuration          = ls_afvc-OperationStandardDuration         .
        es_afvc-OperationStandardDurationUnit      = ls_afvc-OperationStandardDurationUnit     .
        es_afvc-MinimumDuration                    = ls_afvc-MinimumDuration                   .
        es_afvc-MinimumDurationUnit                = ls_afvc-MinimumDurationUnit               .
        es_afvc-MinimumProcessingDuration          = ls_afvc-MinimumProcessingDuration         .
        es_afvc-MinimumProcessingDurationUnit      = ls_afvc-MinimumProcessingDurationUnit     .
        es_afvc-ScheduledMoveDuration              = ls_afvc-ScheduledMoveDuration             .
        es_afvc-ScheduledMoveDurationUnit          = ls_afvc-ScheduledMoveDurationUnit         .
        es_afvc-ScheduledQueueDuration             = ls_afvc-ScheduledQueueDuration            .
        es_afvc-ScheduledQueueDurationUnit         = ls_afvc-ScheduledQueueDurationUnit        .
        es_afvc-ScheduledWaitDuration              = ls_afvc-ScheduledWaitDuration             .
        es_afvc-ScheduledWaitDurationUnit          = ls_afvc-ScheduledWaitDurationUnit         .
        es_afvc-PlannedDeliveryDuration            = ls_afvc-PlannedDeliveryDuration           .
        es_afvc-OpPlannedSetupDurn                 = ls_afvc-OpPlannedSetupDurn                .
        es_afvc-OpPlannedSetupDurnUnit             = ls_afvc-OpPlannedSetupDurnUnit            .
        es_afvc-OpPlannedProcessingDurn            = ls_afvc-OpPlannedProcessingDurn           .
        es_afvc-OpPlannedProcessingDurnUnit        = ls_afvc-OpPlannedProcessingDurnUnit       .
        es_afvc-OpPlannedTeardownDurn              = ls_afvc-OpPlannedTeardownDurn             .
        es_afvc-OpPlannedTeardownDurnUnit          = ls_afvc-OpPlannedTeardownDurnUnit         .
        es_afvc-ActualForecastDuration             = ls_afvc-ActualForecastDuration            .
        es_afvc-ActualForecastDurationUnit         = ls_afvc-ActualForecastDurationUnit        .
        es_afvc-ForecastProcessingDuration         = ls_afvc-ForecastProcessingDuration        .
        es_afvc-ForecastProcessingDurationUnit     = ls_afvc-ForecastProcessingDurationUnit    .
        es_afvc-StartDateOffsetReferenceCode       = ls_afvc-StartDateOffsetReferenceCode      .
        es_afvc-StartDateOffsetDurationUnit        = ls_afvc-StartDateOffsetDurationUnit       .
        es_afvc-StartDateOffsetDuration            = ls_afvc-StartDateOffsetDuration           .
        es_afvc-EndDateOffsetReferenceCode         = ls_afvc-EndDateOffsetReferenceCode        .
        es_afvc-EndDateOffsetDurationUnit          = ls_afvc-EndDateOffsetDurationUnit         .
        es_afvc-EndDateOffsetDuration              = ls_afvc-EndDateOffsetDuration             .
        es_afvc-StandardWorkFormulaParamGroup      = ls_afvc-StandardWorkFormulaParamGroup     .
        es_afvc-OperationUnit                      = ls_afvc-OperationUnit                     .
        es_afvc-OpQtyToBaseQtyDnmntr               = ls_afvc-OpQtyToBaseQtyDnmntr              .
        es_afvc-OpQtyToBaseQtyNmrtr                = ls_afvc-OpQtyToBaseQtyNmrtr               .
        es_afvc-OperationScrapPercent              = ls_afvc-OperationScrapPercent             .
        es_afvc-OperationReferenceQuantity         = ls_afvc-OperationReferenceQuantity        .
        es_afvc-OpPlannedTotalQuantity             = ls_afvc-OpPlannedTotalQuantity            .
        es_afvc-OpPlannedScrapQuantity             = ls_afvc-OpPlannedScrapQuantity            .
        es_afvc-OpPlannedYieldQuantity             = ls_afvc-OpPlannedYieldQuantity            .
        es_afvc-OpTotalConfirmedYieldQty           = ls_afvc-OpTotalConfirmedYieldQty          .


        es_afvc-OpTotalConfirmedScrapQty           =  ls_afvc-OpTotalConfirmedScrapQty              .
        es_afvc-OperationConfirmedReworkQty        =  ls_afvc-OperationConfirmedReworkQty           .
        es_afvc-ProductionUnit                     =  ls_afvc-ProductionUnit                        .
        es_afvc-OpTotConfdYieldQtyInOrdQtyUnit     =  ls_afvc-OpTotConfdYieldQtyInOrdQtyUnit        .
        es_afvc-OpWorkQuantityUnit1                =  ls_afvc-OpWorkQuantityUnit1                   .
        es_afvc-OpConfirmedWorkQuantity1           =  ls_afvc-OpConfirmedWorkQuantity1              .
        es_afvc-NoFurtherOpWorkQuantity1IsExpd     =  ls_afvc-NoFurtherOpWorkQuantity1IsExpd        .
        es_afvc-OpWorkQuantityUnit2                =  ls_afvc-OpWorkQuantityUnit2                   .
        es_afvc-OpConfirmedWorkQuantity2           =  ls_afvc-OpConfirmedWorkQuantity2              .
        es_afvc-NoFurtherOpWorkQuantity2IsExpd     =  ls_afvc-NoFurtherOpWorkQuantity2IsExpd        .
        es_afvc-OpWorkQuantityUnit3                =  ls_afvc-OpWorkQuantityUnit3                   .
        es_afvc-OpConfirmedWorkQuantity3           =  ls_afvc-OpConfirmedWorkQuantity3              .
        es_afvc-NoFurtherOpWorkQuantity3IsExpd     =  ls_afvc-NoFurtherOpWorkQuantity3IsExpd        .
        es_afvc-OpWorkQuantityUnit4                =  ls_afvc-OpWorkQuantityUnit4                   .
        es_afvc-OpConfirmedWorkQuantity4           =  ls_afvc-OpConfirmedWorkQuantity4              .
        es_afvc-NoFurtherOpWorkQuantity4IsExpd     =  ls_afvc-NoFurtherOpWorkQuantity4IsExpd        .
        es_afvc-OpWorkQuantityUnit5                =  ls_afvc-OpWorkQuantityUnit5                   .
        es_afvc-OpConfirmedWorkQuantity5           =  ls_afvc-OpConfirmedWorkQuantity5              .
        es_afvc-NoFurtherOpWorkQuantity5IsExpd     =  ls_afvc-NoFurtherOpWorkQuantity5IsExpd        .
        es_afvc-OpWorkQuantityUnit6                =  ls_afvc-OpWorkQuantityUnit6                   .
        es_afvc-OpConfirmedWorkQuantity6           =  ls_afvc-OpConfirmedWorkQuantity6              .
        es_afvc-NoFurtherOpWorkQuantity6IsExpd     =  ls_afvc-NoFurtherOpWorkQuantity6IsExpd        .
        es_afvc-WorkCenterStandardWorkQtyUnit1     =  ls_afvc-WorkCenterStandardWorkQtyUnit1        .
        es_afvc-WorkCenterStandardWorkQty1         =  ls_afvc-WorkCenterStandardWorkQty1            .
        es_afvc-CostCtrActivityType1               =  ls_afvc-CostCtrActivityType1                  .
        es_afvc-WorkCenterStandardWorkQtyUnit2     =  ls_afvc-WorkCenterStandardWorkQtyUnit2        .
        es_afvc-WorkCenterStandardWorkQty2         =  ls_afvc-WorkCenterStandardWorkQty2            .
        es_afvc-CostCtrActivityType2               =  ls_afvc-CostCtrActivityType2                  .
        es_afvc-WorkCenterStandardWorkQtyUnit3     =  ls_afvc-WorkCenterStandardWorkQtyUnit3        .
        es_afvc-WorkCenterStandardWorkQty3         =  ls_afvc-WorkCenterStandardWorkQty3            .
        es_afvc-CostCtrActivityType3               =  ls_afvc-CostCtrActivityType3                  .
        es_afvc-WorkCenterStandardWorkQtyUnit4     =  ls_afvc-WorkCenterStandardWorkQtyUnit4        .
        es_afvc-WorkCenterStandardWorkQty4         =  ls_afvc-WorkCenterStandardWorkQty4            .
        es_afvc-CostCtrActivityType4               =  ls_afvc-CostCtrActivityType4                  .
        es_afvc-WorkCenterStandardWorkQtyUnit5     =  ls_afvc-WorkCenterStandardWorkQtyUnit5        .
        es_afvc-WorkCenterStandardWorkQty5         =  ls_afvc-WorkCenterStandardWorkQty5            .
        es_afvc-CostCtrActivityType5               =  ls_afvc-CostCtrActivityType5                  .
        es_afvc-WorkCenterStandardWorkQtyUnit6     =  ls_afvc-WorkCenterStandardWorkQtyUnit6        .
        es_afvc-WorkCenterStandardWorkQty6         =  ls_afvc-WorkCenterStandardWorkQty6            .
        es_afvc-CostCtrActivityType6               =  ls_afvc-CostCtrActivityType6                  .
        es_afvc-ForecastWorkQuantity1              =  ls_afvc-ForecastWorkQuantity1                 .
        es_afvc-ForecastWorkQuantity2              =  ls_afvc-ForecastWorkQuantity2                 .
        es_afvc-ForecastWorkQuantity3              =  ls_afvc-ForecastWorkQuantity3                 .
        es_afvc-ForecastWorkQuantity4              =  ls_afvc-ForecastWorkQuantity4                 .
        es_afvc-ForecastWorkQuantity5              =  ls_afvc-ForecastWorkQuantity5                 .
        es_afvc-ForecastWorkQuantity6              =  ls_afvc-ForecastWorkQuantity6                 .
        es_afvc-BusinessProcess                    =  ls_afvc-BusinessProcess                       .
        es_afvc-BusinessProcessEntryUnit           =  ls_afvc-BusinessProcessEntryUnit              .
        es_afvc-BusinessProcessConfirmedQty        =  ls_afvc-BusinessProcessConfirmedQty           .
        es_afvc-NoFurtherBusinessProcQtyIsExpd     =  ls_afvc-NoFurtherBusinessProcQtyIsExpd        .
        es_afvc-BusinessProcRemainingQtyUnit       =  ls_afvc-BusinessProcRemainingQtyUnit          .
        es_afvc-BusinessProcessRemainingQty        =  ls_afvc-BusinessProcessRemainingQty           .
        es_afvc-SetupOpActyNtwkInstance            =  ls_afvc-SetupOpActyNtwkInstance               .
        es_afvc-ProduceOpActyNtwkInstance          =  ls_afvc-ProduceOpActyNtwkInstance             .
        es_afvc-TeardownOpActyNtwkInstance         =  ls_afvc-TeardownOpActyNtwkInstance            .
        es_afvc-FreeDefinedTableFieldSemantic      =  ls_afvc-FreeDefinedTableFieldSemantic         .
        es_afvc-FreeDefinedAttribute01             =  ls_afvc-FreeDefinedAttribute01                .
        es_afvc-FreeDefinedAttribute02             =  ls_afvc-FreeDefinedAttribute02                .
        es_afvc-FreeDefinedAttribute03             =  ls_afvc-FreeDefinedAttribute03                .
        es_afvc-FreeDefinedAttribute04             =  ls_afvc-FreeDefinedAttribute04                .
        es_afvc-FreeDefinedQuantity1Unit           =  ls_afvc-FreeDefinedQuantity1Unit              .
        es_afvc-FreeDefinedQuantity1               =  ls_afvc-FreeDefinedQuantity1                  .
        es_afvc-FreeDefinedQuantity2Unit           =  ls_afvc-FreeDefinedQuantity2Unit              .
        es_afvc-FreeDefinedQuantity2               =  ls_afvc-FreeDefinedQuantity2                  .
        es_afvc-FreeDefinedAmount1Currency         =  ls_afvc-FreeDefinedAmount1Currency            .
        es_afvc-FreeDefinedAmount1                 =  ls_afvc-FreeDefinedAmount1                    .
        es_afvc-FreeDefinedAmount2Currency         =  ls_afvc-FreeDefinedAmount2Currency            .
        es_afvc-FreeDefinedAmount2                 =  ls_afvc-FreeDefinedAmount2                    .
        es_afvc-FreeDefinedDate1                   =  ls_afvc-FreeDefinedDate1                      .
        es_afvc-FreeDefinedDate2                   =  ls_afvc-FreeDefinedDate2                      .
        es_afvc-FreeDefinedIndicator1              =  ls_afvc-FreeDefinedIndicator1                 .
        es_afvc-FreeDefinedIndicator2              =  ls_afvc-FreeDefinedIndicator2                 .

        condense es_afvc-MfgOrderInternalID                .
        condense es_afvc-OrderOperationInternalID          .
        condense es_afvc-ManufacturingOrder                .
        condense es_afvc-ManufacturingOrderSequence        .
        condense es_afvc-ManufacturingOrderOperation       .
        condense es_afvc-ManufacturingOrderOperation_2     .
        condense es_afvc-ManufacturingOrderSubOperation    .
        condense es_afvc-ManufacturingOrdSubOperation_2    .
        condense es_afvc-MfgOrderOperationOrSubOp          .
        condense es_afvc-MfgOrderOperationOrSubOp_2        .
        condense es_afvc-MfgOrderOperationIsPhase          .
        condense es_afvc-OrderIntBillOfOpItemOfPhase       .
        condense es_afvc-MfgOrderPhaseSuperiorOperation    .
        condense es_afvc-SuperiorOperation_2               .
        condense es_afvc-ManufacturingOrderCategory        .
        condense es_afvc-ManufacturingOrderType            .
        condense es_afvc-ProductionSupervisor              .
        condense es_afvc-MRPController                     .
        condense es_afvc-ResponsiblePlannerGroup           .
        condense es_afvc-ProductConfiguration              .
        condense es_afvc-InspectionLot                     .
        condense es_afvc-ManufacturingOrderImportance      .
        condense es_afvc-MfgOrderOperationText             .
        condense es_afvc-OperationStandardTextCode         .
        condense es_afvc-OperationHasLongText              .
        condense es_afvc-Language                          .
        condense es_afvc-OperationIsToBeDeleted            .
        condense es_afvc-NumberOfCapacities                .
        condense es_afvc-NumberOfConfirmationSlips         .
        condense es_afvc-OperationImportance               .
        condense es_afvc-SuperiorOperationInternalID       .
        condense es_afvc-Plant                             .
        condense es_afvc-WorkCenterInternalID              .
        condense es_afvc-WorkCenterTypeCode                .

        condense es_afvc-WorkCenterTypeCode_2              .
        condense es_afvc-OperationControlProfile           .
        condense es_afvc-ControlRecipeDestination          .
        condense es_afvc-OperationConfirmation             .
        condense es_afvc-NumberOfOperationConfirmations    .
        condense es_afvc-FactoryCalendar                   .
        condense es_afvc-CapacityRequirement               .
        condense es_afvc-CapacityRequirementItem           .
        condense es_afvc-ChangeNumber                      .
        condense es_afvc-ObjectInternalID                  .
        condense es_afvc-OperationTrackingNumber           .
        condense es_afvc-BillOfOperationsType              .
        condense es_afvc-BillOfOperationsGroup             .
        condense es_afvc-BillOfOperationsVariant           .
        condense es_afvc-BillOfOperationsSequence          .
        condense es_afvc-BOOOperationInternalID            .
        condense es_afvc-BillOfOperationsVersion           .
        condense es_afvc-BillOfMaterialCategory            .
        condense es_afvc-BillOfMaterialInternalID          .
        condense es_afvc-BillOfMaterialInternalID_2        .
        condense es_afvc-BillOfMaterialItemNodeNumber      .
        condense es_afvc-BOMItemNodeCount                  .
        condense es_afvc-ExtProcgOperationHasSubcontrg     .
        condense es_afvc-PurchasingOrganization            .
        condense es_afvc-PurchasingGroup                   .
        condense es_afvc-PurchaseRequisition               .
        condense es_afvc-PurchaseRequisitionItem           .
        condense es_afvc-PurchaseOrder                     .
        condense es_afvc-PurchaseOrderItem                 .
        condense es_afvc-PurchasingInfoRecord              .
        condense es_afvc-PurgInfoRecdDataIsFixed           .
        condense es_afvc-PurchasingInfoRecordCategory      .
        condense es_afvc-Supplier                          .
        condense es_afvc-GoodsRecipientName                .
        condense es_afvc-UnloadingPointName                .
        condense es_afvc-MaterialGroup                     .
        condense es_afvc-OpExternalProcessingCurrency      .
        condense es_afvc-OpExternalProcessingPrice         .
        condense es_afvc-NumberOfOperationPriceUnits       .
        condense es_afvc-CompanyCode                       .
        condense es_afvc-BusinessArea                      .
        condense es_afvc-ControllingArea                   .

        condense es_afvc-ProfitCenter                       .
        condense es_afvc-RequestingCostCenter               .
        condense es_afvc-CostElement                        .
        condense es_afvc-CostingVariant                     .
        condense es_afvc-CostingSheet                       .
        condense es_afvc-CostEstimate                       .
        condense es_afvc-ControllingObjectCurrency          .
        condense es_afvc-ControllingObjectClass             .
        condense es_afvc-FunctionalArea                     .
        condense es_afvc-TaxJurisdiction                    .
        condense es_afvc-EmployeeWageType                   .
        condense es_afvc-EmployeeWageGroup                  .
        condense es_afvc-EmployeeSuitability                .
        condense es_afvc-NumberOfTimeTickets                .
        condense es_afvc-Personnel                          .
        condense es_afvc-NumberOfEmployees                  .
        condense es_afvc-OperationSetupGroupCategory        .
        condense es_afvc-OperationSetupGroup                .
        condense es_afvc-OperationSetupType                 .
        condense es_afvc-OperationOverlappingIsRequired     .
        condense es_afvc-OperationOverlappingIsPossible     .
        condense es_afvc-OperationsIsAlwaysOverlapping      .
        condense es_afvc-OperationSplitIsRequired           .
        condense es_afvc-MaximumNumberOfSplits              .
        condense es_afvc-LeadTimeReductionStrategy          .
        condense es_afvc-OpSchedldReductionLevel            .
        condense es_afvc-OpErlstSchedldExecStrtDte          .
        condense es_afvc-OpErlstSchedldExecStrtTme          .
        condense es_afvc-OpErlstSchedldProcgStrtDte         .
        condense es_afvc-OpErlstSchedldProcgStrtTme         .
        condense es_afvc-OpErlstSchedldTrdwnStrtDte         .
        condense es_afvc-OpErlstSchedldTrdwnStrtTme         .
        condense es_afvc-OpErlstSchedldExecEndDte           .
        condense es_afvc-OpErlstSchedldExecEndTme           .
        condense es_afvc-OpLtstSchedldExecStrtDte           .
        condense es_afvc-OpLtstSchedldExecStrtTme           .
        condense es_afvc-OpLtstSchedldProcgStrtDte          .
        condense es_afvc-OpLtstSchedldProcgStrtTme          .
        condense es_afvc-OpLtstSchedldTrdwnStrtDte           .

        condense es_afvc-OpLtstSchedldTrdwnStrtTme          .
        condense es_afvc-OpLtstSchedldExecEndDte            .
        condense es_afvc-OpLtstSchedldExecEndTme            .
        condense es_afvc-SchedldFcstdEarliestStartDate      .
        condense es_afvc-SchedldFcstdEarliestStartTime      .
        condense es_afvc-SchedldFcstdEarliestEndDate        .
        condense es_afvc-SchedldFcstdEarliestEndTime        .
        condense es_afvc-LatestSchedldFcstdStartDate        .
        condense es_afvc-SchedldFcstdLatestStartTime        .
        condense es_afvc-LatestSchedldFcstdEndDate          .
        condense es_afvc-SchedldFcstdLatestEndTime          .
        condense es_afvc-OperationConfirmedStartDate        .
        condense es_afvc-OperationConfirmedEndDate          .
        condense es_afvc-OpActualExecutionStartDate         .
        condense es_afvc-OpActualExecutionStartTime         .
        condense es_afvc-OpActualSetupEndDate               .
        condense es_afvc-OpActualSetupEndTime               .
        condense es_afvc-OpActualProcessingStartDate        .
        condense es_afvc-OpActualProcessingStartTime        .
        condense es_afvc-OpActualProcessingEndDate          .
        condense es_afvc-OpActualProcessingEndTime          .
        condense es_afvc-OpActualTeardownStartDate          .
        condense es_afvc-OpActualTeardownStartTme           .
        condense es_afvc-OpActualExecutionEndDate           .
        condense es_afvc-OpActualExecutionEndTime           .
        condense es_afvc-ActualForecastEndDate              .
        condense es_afvc-ActualForecastEndTime              .
        condense es_afvc-EarliestScheduledWaitStartDate     .
        condense es_afvc-EarliestScheduledWaitStartTime     .
        condense es_afvc-EarliestScheduledWaitEndDate       .
        condense es_afvc-EarliestScheduledWaitEndTime       .
        condense es_afvc-LatestScheduledWaitStartDate       .
        condense es_afvc-LatestScheduledWaitStartTime       .
        condense es_afvc-LatestScheduledWaitEndDate         .
        condense es_afvc-LatestScheduledWaitEndTime         .
        condense es_afvc-BreakDurationUnit                  .
        condense es_afvc-PlannedBreakDuration               .
        condense es_afvc-ConfirmedBreakDuration             .
        condense es_afvc-OverlapMinimumDurationUnit         .
        condense es_afvc-OverlapMinimumDuration             .
        condense es_afvc-MaximumWaitDurationUnit            .
        condense es_afvc-MaximumWaitDuration                .
        condense es_afvc-MinimumWaitDurationUnit            .
        condense es_afvc-MinimumWaitDuration                .
        condense es_afvc-StandardMoveDurationUnit           .
        condense es_afvc-StandardMoveDuration               .
        condense es_afvc-StandardQueueDurationUnit          .


        condense es_afvc-StandardQueueDuration              .
        condense es_afvc-MinimumQueueDurationUnit           .
        condense es_afvc-MinimumQueueDuration               .
        condense es_afvc-MinimumMoveDurationUnit            .
        condense es_afvc-MinimumMoveDuration                .
        condense es_afvc-OperationStandardDuration          .
        condense es_afvc-OperationStandardDurationUnit      .
        condense es_afvc-MinimumDuration                    .
        condense es_afvc-MinimumDurationUnit                .
        condense es_afvc-MinimumProcessingDuration          .
        condense es_afvc-MinimumProcessingDurationUnit      .
        condense es_afvc-ScheduledMoveDuration              .
        condense es_afvc-ScheduledMoveDurationUnit          .
        condense es_afvc-ScheduledQueueDuration             .
        condense es_afvc-ScheduledQueueDurationUnit         .
        condense es_afvc-ScheduledWaitDuration              .
        condense es_afvc-ScheduledWaitDurationUnit          .
        condense es_afvc-PlannedDeliveryDuration            .
        condense es_afvc-OpPlannedSetupDurn                 .
        condense es_afvc-OpPlannedSetupDurnUnit             .
        condense es_afvc-OpPlannedProcessingDurn            .
        condense es_afvc-OpPlannedProcessingDurnUnit        .
        condense es_afvc-OpPlannedTeardownDurn              .
        condense es_afvc-OpPlannedTeardownDurnUnit          .
        condense es_afvc-ActualForecastDuration             .
        condense es_afvc-ActualForecastDurationUnit         .
        condense es_afvc-ForecastProcessingDuration         .
        condense es_afvc-ForecastProcessingDurationUnit     .
        condense es_afvc-StartDateOffsetReferenceCode       .
        condense es_afvc-StartDateOffsetDurationUnit        .
        condense es_afvc-StartDateOffsetDuration            .
        condense es_afvc-EndDateOffsetReferenceCode         .
        condense es_afvc-EndDateOffsetDurationUnit          .
        condense es_afvc-EndDateOffsetDuration              .
        condense es_afvc-StandardWorkFormulaParamGroup      .
        condense es_afvc-OperationUnit                      .
        condense es_afvc-OpQtyToBaseQtyDnmntr               .
        condense es_afvc-OpQtyToBaseQtyNmrtr                .
        condense es_afvc-OperationScrapPercent              .
        condense es_afvc-OperationReferenceQuantity         .
        condense es_afvc-OpPlannedTotalQuantity             .
        condense es_afvc-OpPlannedScrapQuantity             .
        condense es_afvc-OpPlannedYieldQuantity             .
        condense es_afvc-OpTotalConfirmedYieldQty           .


        condense es_afvc-OpTotalConfirmedScrapQty            .
        condense es_afvc-OperationConfirmedReworkQty         .
        condense es_afvc-ProductionUnit                      .
        condense es_afvc-OpTotConfdYieldQtyInOrdQtyUnit      .
        condense es_afvc-OpWorkQuantityUnit1                 .
        condense es_afvc-OpConfirmedWorkQuantity1            .
        condense es_afvc-NoFurtherOpWorkQuantity1IsExpd      .
        condense es_afvc-OpWorkQuantityUnit2                 .
        condense es_afvc-OpConfirmedWorkQuantity2            .
        condense es_afvc-NoFurtherOpWorkQuantity2IsExpd      .
        condense es_afvc-OpWorkQuantityUnit3                 .
        condense es_afvc-OpConfirmedWorkQuantity3            .
        condense es_afvc-NoFurtherOpWorkQuantity3IsExpd      .
        condense es_afvc-OpWorkQuantityUnit4                 .
        condense es_afvc-OpConfirmedWorkQuantity4            .
        condense es_afvc-NoFurtherOpWorkQuantity4IsExpd      .
        condense es_afvc-OpWorkQuantityUnit5                 .
        condense es_afvc-OpConfirmedWorkQuantity5            .
        condense es_afvc-NoFurtherOpWorkQuantity5IsExpd      .
        condense es_afvc-OpWorkQuantityUnit6                 .
        condense es_afvc-OpConfirmedWorkQuantity6            .
        condense es_afvc-NoFurtherOpWorkQuantity6IsExpd      .
        condense es_afvc-WorkCenterStandardWorkQtyUnit1      .
        condense es_afvc-WorkCenterStandardWorkQty1          .
        condense es_afvc-CostCtrActivityType1                .
        condense es_afvc-WorkCenterStandardWorkQtyUnit2      .
        condense es_afvc-WorkCenterStandardWorkQty2          .
        condense es_afvc-CostCtrActivityType2                .
        condense es_afvc-WorkCenterStandardWorkQtyUnit3      .
        condense es_afvc-WorkCenterStandardWorkQty3          .
        condense es_afvc-CostCtrActivityType3                .
        condense es_afvc-WorkCenterStandardWorkQtyUnit4      .
        condense es_afvc-WorkCenterStandardWorkQty4          .
        condense es_afvc-CostCtrActivityType4                .
        condense es_afvc-WorkCenterStandardWorkQtyUnit5      .
        condense es_afvc-WorkCenterStandardWorkQty5          .
        condense es_afvc-CostCtrActivityType5                .
        condense es_afvc-WorkCenterStandardWorkQtyUnit6      .
        condense es_afvc-WorkCenterStandardWorkQty6          .
        condense es_afvc-CostCtrActivityType6                .
        condense es_afvc-ForecastWorkQuantity1               .
        condense es_afvc-ForecastWorkQuantity2               .
        condense es_afvc-ForecastWorkQuantity3               .
        condense es_afvc-ForecastWorkQuantity4               .
        condense es_afvc-ForecastWorkQuantity5               .
        condense es_afvc-ForecastWorkQuantity6               .
        condense es_afvc-BusinessProcess                     .
        condense es_afvc-BusinessProcessEntryUnit            .
        condense es_afvc-BusinessProcessConfirmedQty        .
        condense es_afvc-NoFurtherBusinessProcQtyIsExpd     .
        condense es_afvc-BusinessProcRemainingQtyUnit       .
        condense es_afvc-BusinessProcessRemainingQty        .
        condense es_afvc-SetupOpActyNtwkInstance            .
        condense es_afvc-ProduceOpActyNtwkInstance          .
        condense es_afvc-TeardownOpActyNtwkInstance         .
        condense es_afvc-FreeDefinedTableFieldSemantic      .
        condense es_afvc-FreeDefinedAttribute01             .
        condense es_afvc-FreeDefinedAttribute02             .
        condense es_afvc-FreeDefinedAttribute03             .
        condense es_afvc-FreeDefinedAttribute04             .
        condense es_afvc-FreeDefinedQuantity1Unit           .
        condense es_afvc-FreeDefinedQuantity1               .
        condense es_afvc-FreeDefinedQuantity2Unit           .
        condense es_afvc-FreeDefinedQuantity2               .
        condense es_afvc-FreeDefinedAmount1Currency         .
        condense es_afvc-FreeDefinedAmount1                 .
        condense es_afvc-FreeDefinedAmount2Currency         .
        condense es_afvc-FreeDefinedAmount2                 .
        condense es_afvc-FreeDefinedDate1                   .
        condense es_afvc-FreeDefinedDate2                   .
        condense es_afvc-FreeDefinedIndicator1              .
        condense es_afvc-FreeDefinedIndicator2              .

            APPEND es_afvc TO es_response_afvc-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_afvc-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_afvc )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.
        ENDIF.

      WHEN 'MBEW'  OR 'mbew' .

        SELECT *
        FROM  I_ProductValuationBasic WITH PRIVILEGED ACCESS
        WHERE (lv_where)
        INTO TABLE @DATA(lt_mbew).

        IF lt_mbew IS NOT INITIAL.
          LOOP  AT lt_mbew INTO DATA(ls_mbew).
          lv_count = lv_count + 1.
            es_mbew-Product                            = ls_mbew-Product                            .
            es_mbew-ValuationArea                      = ls_mbew-ValuationArea                      .
            es_mbew-ValuationType                      = ls_mbew-ValuationType                      .
            es_mbew-ValuationClass                     = ls_mbew-ValuationClass                     .
            es_mbew-PriceDeterminationControl          = ls_mbew-PriceDeterminationControl          .
            es_mbew-FiscalMonthCurrentPeriod           = ls_mbew-FiscalMonthCurrentPeriod           .
            es_mbew-FiscalYearCurrentPeriod            = ls_mbew-FiscalYearCurrentPeriod            .
            es_mbew-StandardPrice                      = ls_mbew-StandardPrice                      .
            es_mbew-PriceUnitQty                       = ls_mbew-PriceUnitQty                       .
            es_mbew-InventoryValuationProcedure        = ls_mbew-InventoryValuationProcedure        .
            es_mbew-FuturePriceValidityStartDate       = ls_mbew-FuturePriceValidityStartDate       .
            es_mbew-PrevInvtryPriceInCoCodeCrcy        = ls_mbew-PrevInvtryPriceInCoCodeCrcy        .
            es_mbew-MovingAveragePrice                 = ls_mbew-MovingAveragePrice                 .
            es_mbew-ValuationCategory                  = ls_mbew-ValuationCategory                  .
            es_mbew-ProductUsageType                   = ls_mbew-ProductUsageType                   .
            es_mbew-ProductOriginType                  = ls_mbew-ProductOriginType                  .
            es_mbew-IsProducedInhouse                  = ls_mbew-IsProducedInhouse                  .
            es_mbew-ProdCostEstNumber                  = ls_mbew-ProdCostEstNumber                  .
            es_mbew-IsMarkedForDeletion                = ls_mbew-IsMarkedForDeletion                .
            es_mbew-ValuationMargin                    = ls_mbew-ValuationMargin                    .
            es_mbew-IsActiveEntity                     = ls_mbew-IsActiveEntity                     .
            es_mbew-CompanyCode                        = ls_mbew-CompanyCode                        .
            es_mbew-ValuationClassSalesOrderStock      = ls_mbew-ValuationClassSalesOrderStock      .
            es_mbew-ProjectStockValuationClass         = ls_mbew-ProjectStockValuationClass         .
            es_mbew-TaxBasedPricesPriceUnitQty         = ls_mbew-TaxBasedPricesPriceUnitQty         .
            es_mbew-PriceLastChangeDate                = ls_mbew-PriceLastChangeDate                .
            es_mbew-FuturePrice                        = ls_mbew-FuturePrice                        .
            es_mbew-MaintenanceStatus                  = ls_mbew-MaintenanceStatus                  .
            es_mbew-Currency                           = ls_mbew-Currency                           .
            es_mbew-BaseUnit                           = ls_mbew-BaseUnit                           .
            es_mbew-MLIsActiveAtProductLevel           = ls_mbew-MLIsActiveAtProductLevel           .

            CONDENSE es_mbew-Product                         .
            CONDENSE es_mbew-ValuationArea                   .
            CONDENSE es_mbew-ValuationType                   .
            CONDENSE es_mbew-ValuationClass                  .
            CONDENSE es_mbew-PriceDeterminationControl       .
            CONDENSE es_mbew-FiscalMonthCurrentPeriod        .
            CONDENSE es_mbew-FiscalYearCurrentPeriod         .
            CONDENSE es_mbew-StandardPrice                   .
            CONDENSE es_mbew-PriceUnitQty                    .
            CONDENSE es_mbew-InventoryValuationProcedure     .
            CONDENSE es_mbew-FuturePriceValidityStartDate    .
            CONDENSE es_mbew-PrevInvtryPriceInCoCodeCrcy     .
            CONDENSE es_mbew-MovingAveragePrice              .
            CONDENSE es_mbew-ValuationCategory               .
            CONDENSE es_mbew-ProductUsageType                .
            CONDENSE es_mbew-ProductOriginType               .
            CONDENSE es_mbew-IsProducedInhouse               .
            CONDENSE es_mbew-ProdCostEstNumber               .
            CONDENSE es_mbew-IsMarkedForDeletion             .
            CONDENSE es_mbew-ValuationMargin                 .
            CONDENSE es_mbew-IsActiveEntity                  .
            CONDENSE es_mbew-CompanyCode                     .
            CONDENSE es_mbew-ValuationClassSalesOrderStock   .
            CONDENSE es_mbew-ProjectStockValuationClass      .
            CONDENSE es_mbew-TaxBasedPricesPriceUnitQty      .
            CONDENSE es_mbew-PriceLastChangeDate             .
            CONDENSE es_mbew-FuturePrice                     .
            CONDENSE es_mbew-MaintenanceStatus               .
            CONDENSE es_mbew-Currency                        .
            CONDENSE es_mbew-BaseUnit                        .
            CONDENSE es_mbew-MLIsActiveAtProductLevel        .

            APPEND es_mbew TO es_response_mbew-items.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_mbew-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_mbew )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          lv_error = 'X'.
          lv_text = 'There is no data in table'.

        ENDIF.


      WHEN OTHERS.
        lv_error1 = 'X'.
        lv_text = 'The table entry was not found'.

    ENDCASE.

    IF lv_error IS NOT INITIAL.
      "propagate any errors raised
      response->set_status( '204' ).

    elseif lv_error1 is NOT INITIAL.
      response->set_status( '404' ).
      response->set_text( lv_text ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
