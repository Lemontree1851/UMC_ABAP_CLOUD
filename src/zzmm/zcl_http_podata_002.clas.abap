CLASS zcl_http_podata_002 DEFINITION
  PUBLIC
  CREATE PUBLIC .

  PUBLIC SECTION.

    "　T024D、T001L、MARC、MKAL、AFKO、AFPO、PLPO、RESB、AFVC、ZPLAF
    " 20241010 MBEW
    TYPES:
      BEGIN OF ty_item,
        tablename    TYPE c    LENGTH 10,
        prametername TYPE c    LENGTH 10,
        value        TYPE      string,
      END OF ty_item,

      tt_item TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY,


      BEGIN OF ty_header,
        items TYPE tt_item,
      END OF ty_header,

      tt_header TYPE STANDARD TABLE OF ty_header WITH EMPTY KEY,

      "NO.1 購買発注
      BEGIN OF ty_ekko,
        purchaseorder                  TYPE c LENGTH  10,
        purchaseordertype              TYPE c LENGTH  4,
        purchaseordersubtype           TYPE c LENGTH  1,
        purchasingdocumentorigin       TYPE c LENGTH  1,
        createdbyuser                  TYPE c LENGTH  12,
        creationdate                   TYPE c LENGTH  8,
        purchaseorderdate              TYPE c LENGTH  8,
        language                       TYPE c LENGTH  1,
        correspncexternalreference     TYPE c LENGTH  12,
        correspncinternalreference     TYPE c LENGTH  12,
        purchasingdocumentdeletioncode TYPE c LENGTH  1,
        releaseisnotcompleted          TYPE c LENGTH  1,
        purchasingcompletenessstatus   TYPE c LENGTH  1,
        purchasingprocessingstatus     TYPE c LENGTH  2,
        purgreleasesequencestatus      TYPE c LENGTH  8,
        releasecode                    TYPE c LENGTH  1,
        companycode                    TYPE c LENGTH  4,
        purchasingorganization         TYPE c LENGTH  4,
        purchasinggroup                TYPE c LENGTH  3,
        supplier                       TYPE c LENGTH  10,
        manualsupplieraddressid        TYPE c LENGTH  10,
        supplierrespsalespersonname    TYPE c LENGTH  30,
        supplierphonenumber            TYPE c LENGTH  16,
        supplyingsupplier              TYPE c LENGTH  10,
        supplyingplant                 TYPE c LENGTH  4,
        invoicingparty                 TYPE c LENGTH  10,
        customer                       TYPE c LENGTH  10,
        supplierquotationexternalid    TYPE c LENGTH  10,
        paymentterms                   TYPE c LENGTH  4,
        cashdiscount1days              TYPE c LENGTH  3,
        cashdiscount2days              TYPE c LENGTH  3,
        netpaymentdays                 TYPE c LENGTH  3,
        cashdiscount1percent           TYPE c LENGTH  5,
        cashdiscount2percent           TYPE c LENGTH  5,
        downpaymenttype                TYPE c LENGTH  4,
        downpaymentpercentageoftotamt  TYPE c LENGTH  5,
        downpaymentamount              TYPE c LENGTH  11,
        downpaymentduedate             TYPE c LENGTH  8,
        incotermsclassification        TYPE c LENGTH  3,
        incotermstransferlocation      TYPE c LENGTH  28,
        incotermsversion               TYPE c LENGTH  4,
        incotermslocation1             TYPE c LENGTH  70,
        incotermslocation2             TYPE c LENGTH  70,
        isintrastatreportingrelevant   TYPE c LENGTH  1,
        isintrastatreportingexcluded   TYPE c LENGTH  1,
        pricingdocument                TYPE c LENGTH  10,
        pricingprocedure               TYPE c LENGTH  6,
        documentcurrency               TYPE c LENGTH  5,
        validitystartdate              TYPE c LENGTH  8,
        validityenddate                TYPE c LENGTH  8,
        exchangerate                   TYPE c LENGTH  9,
        exchangerateisfixed            TYPE c LENGTH  1,
        lastchangedatetime             TYPE c LENGTH  21,
        taxreturncountry               TYPE c LENGTH  3,
        vatregistrationcountry         TYPE c LENGTH  3,
        purgreasonfordoccancellation   TYPE c LENGTH  2,
        purgreleasetimetotalamount     TYPE c LENGTH  15,
        purgaggrgdprodcmplncsuplrsts   TYPE c LENGTH  1,
        purgaggrgdprodmarketabilitysts TYPE c LENGTH  1,
        purgaggrgdsftydatasheetstatus  TYPE c LENGTH  1,
        purgprodcmplnctotdngrsgoodssts TYPE c LENGTH  1,

      END OF ty_ekko,

      "NO.2 購買発注明細
      BEGIN OF ty_ekpo,
        purchaseorder                  TYPE c LENGTH                   10,
        purchaseorderitem              TYPE c LENGTH                   5,
        purchaseorderitemuniqueid      TYPE c LENGTH                   15,
        purchaseordercategory          TYPE c LENGTH                   1,
        documentcurrency               TYPE c LENGTH                   5,
        purchasingdocumentdeletioncode TYPE c LENGTH                   1,
        purchasingdocumentitemorigin   TYPE c LENGTH                   1,
        materialgroup                  TYPE c LENGTH                   9,
        material                       TYPE c LENGTH                   40,
        materialtype                   TYPE c LENGTH                   4,
        suppliermaterialnumber         TYPE c LENGTH                   35,
        suppliersubrange               TYPE c LENGTH                   6,
        manufacturerpartnmbr           TYPE c LENGTH                   40,
        manufacturer                   TYPE c LENGTH                   10,
        manufacturermaterial           TYPE c LENGTH                   40,
        purchaseorderitemtext          TYPE c LENGTH                   40,
        producttype                    TYPE c LENGTH                   2,
        companycode                    TYPE c LENGTH                   4,
        plant                          TYPE c LENGTH                   4,
        manualdeliveryaddressid        TYPE c LENGTH                   10,
        referencedeliveryaddressid     TYPE c LENGTH                   10,
        customer                       TYPE c LENGTH                   10,
        subcontractor                  TYPE c LENGTH                   10,
        supplierissubcontractor        TYPE c LENGTH                   1,
        crossplantconfigurableproduct  TYPE c LENGTH                   40,
        articlecategory                TYPE c LENGTH                   2,
        plndorderreplnmtelmnttype      TYPE c LENGTH                   1,
        productpurchasepointsqtyunit   TYPE c LENGTH                   3,
        productpurchasepointsqty       TYPE c LENGTH                   13,
        storagelocation                TYPE c LENGTH                   4,
        purchaseorderquantityunit      TYPE c LENGTH                   3,
        orderitemqtytobaseqtynmrtr     TYPE c LENGTH                   5,
        orderitemqtytobaseqtydnmntr    TYPE c LENGTH                   5,
        netpricequantity               TYPE c LENGTH                   5,
        iscompletelydelivered          TYPE c LENGTH                   1,
        isfinallyinvoiced              TYPE c LENGTH                   1,
        goodsreceiptisexpected         TYPE c LENGTH                   1,
        invoiceisexpected              TYPE c LENGTH                   1,
        invoiceisgoodsreceiptbased     TYPE c LENGTH                   1,
        purchasecontractitem           TYPE c LENGTH                   5,
        purchasecontract               TYPE c LENGTH                   10,
        purchaserequisition            TYPE c LENGTH                   10,
        requirementtracking            TYPE c LENGTH                   10,
        purchaserequisitionitem        TYPE c LENGTH                   5,
        evaldrcptsettlmtisallowed      TYPE c LENGTH                   1,
        unlimitedoverdeliveryisallowed TYPE c LENGTH                   1,
        overdelivtolrtdlmtratioinpct   TYPE c LENGTH                   3,
        underdelivtolrtdlmtratioinpct  TYPE c LENGTH                   3,
        requisitionername              TYPE c LENGTH                   12,
        planneddeliverydurationindays  TYPE c LENGTH                   3,
        goodsreceiptdurationindays     TYPE c LENGTH                   3,
        partialdeliveryisallowed       TYPE c LENGTH                   1,
        consumptionposting             TYPE c LENGTH                   1,
        serviceperformer               TYPE c LENGTH                   10,
        baseunit                       TYPE c LENGTH                   3,
        purchaseorderitemcategory      TYPE c LENGTH                   1,
        profitcenter                   TYPE c LENGTH                   10,
        orderpriceunit                 TYPE c LENGTH                   3,
        itemvolumeunit                 TYPE c LENGTH                   3,
        itemweightunit                 TYPE c LENGTH                   3,
        multipleacctassgmtdistribution TYPE c LENGTH                   1,
        partialinvoicedistribution     TYPE c LENGTH                   1,
        pricingdatecontrol             TYPE c LENGTH                   1,
        isstatisticalitem              TYPE c LENGTH                   1,
        purchasingparentitem           TYPE c LENGTH                   5,
        goodsreceiptlatestcreationdate TYPE c LENGTH                   8,
        isreturnsitem                  TYPE c LENGTH                   1,
        purchasingorderreason          TYPE c LENGTH                   3,
        incotermsclassification        TYPE c LENGTH                   3,
        incotermstransferlocation      TYPE c LENGTH                   28,
        incotermslocation1             TYPE c LENGTH                   70,
        incotermslocation2             TYPE c LENGTH                   70,
        priorsupplier                  TYPE c LENGTH                   10,
        internationalarticlenumber     TYPE c LENGTH                   18,
        intrastatservicecode           TYPE c LENGTH                   30,
        commoditycode                  TYPE c LENGTH                   30,
        materialfreightgroup           TYPE c LENGTH                   8,
        discountinkindeligibility      TYPE c LENGTH                   1,
        purgitemisblockedfordelivery   TYPE c LENGTH                   1,
        supplierconfirmationcontrolkey TYPE c LENGTH                   4,
        priceistobeprinted             TYPE c LENGTH                   1,
        accountassignmentcategory      TYPE c LENGTH                   1,
        purchasinginforecord           TYPE c LENGTH                   10,
        netamount                      TYPE c LENGTH                   13,
        grossamount                    TYPE c LENGTH                   13,
        effectiveamount                TYPE c LENGTH                   13,
        subtotal1amount                TYPE c LENGTH                   13,
        subtotal2amount                TYPE c LENGTH                   13,
        subtotal3amount                TYPE c LENGTH                   13,
        subtotal4amount                TYPE c LENGTH                   13,
        subtotal5amount                TYPE c LENGTH                   13,
        subtotal6amount                TYPE c LENGTH                   13,
        orderquantity                  TYPE c LENGTH                   13,
        netpriceamount                 TYPE c LENGTH                   11,
        itemvolume                     TYPE c LENGTH                   13,
        itemgrossweight                TYPE c LENGTH                   13,
        itemnetweight                  TYPE c LENGTH                   13,
        orderpriceunittoorderunitnmrtr TYPE c LENGTH                   5,
        ordpriceunittoorderunitdnmntr  TYPE c LENGTH                   5,
        goodsreceiptisnonvaluated      TYPE c LENGTH                   1,
        taxcode                        TYPE c LENGTH                   2,
        taxjurisdiction                TYPE c LENGTH                   15,
        shippinginstruction            TYPE c LENGTH                   2,
        shippingtype                   TYPE c LENGTH                   2,
        nondeductibleinputtaxamount    TYPE c LENGTH                   13,
        stocktype                      TYPE c LENGTH                   1,
        valuationtype                  TYPE c LENGTH                   10,
        valuationcategory              TYPE c LENGTH                   1,
        itemisrejectedbysupplier       TYPE c LENGTH                   1,
        purgdocpricedate               TYPE c LENGTH                   8,
        purgdocreleaseorderquantity    TYPE c LENGTH                   13,
        earmarkedfunds                 TYPE c LENGTH                   10,
        earmarkedfundsdocument         TYPE c LENGTH                   10,
        earmarkedfundsitem             TYPE c LENGTH                   3,
        earmarkedfundsdocumentitem     TYPE c LENGTH                   3,
        partnerreportedbusinessarea    TYPE c LENGTH                   4,
        inventoryspecialstocktype      TYPE c LENGTH                   1,
        deliverydocumenttype           TYPE c LENGTH                   4,
        issuingstoragelocation         TYPE c LENGTH                   4,
        allocationtable                TYPE c LENGTH                   10,
        allocationtableitem            TYPE c LENGTH                   5,
        retailpromotion                TYPE c LENGTH                   10,
        downpaymenttype                TYPE c LENGTH                   4,
        downpaymentpercentageoftotamt  TYPE c LENGTH                   5,
        downpaymentamount              TYPE c LENGTH                   11,
        downpaymentduedate             TYPE c LENGTH                   8,
        expectedoveralllimitamount     TYPE c LENGTH                   13,
        overalllimitamount             TYPE c LENGTH                   13,
        requirementsegment             TYPE c LENGTH                   40,
        purgprodcmplncdngrsgoodsstatus TYPE c LENGTH                   1,
        purgprodcmplncsupplierstatus   TYPE c LENGTH                   1,
        purgproductmarketabilitystatus TYPE c LENGTH                   1,
        purgsafetydatasheetstatus      TYPE c LENGTH                   1,
        subcontrgcompisrealtmecnsmd    TYPE c LENGTH                   1,
        br_materialorigin              TYPE c LENGTH                   1,
        br_materialusage               TYPE c LENGTH                   1,
        br_cfopcategory                TYPE c LENGTH                   2,
        br_ncm                         TYPE c LENGTH                   16,
        br_isproducedinhouse           TYPE c LENGTH                   1,

      END OF ty_ekpo,

      "NO.3 納入日程行
      BEGIN OF ty_eket,
        purchaseorder                  TYPE c LENGTH       10,
        purchaseorderitem              TYPE c LENGTH       5,
        purchaseorderscheduleline      TYPE c LENGTH       4,
        performanceperiodstartdate     TYPE c LENGTH       8,
        performanceperiodenddate       TYPE c LENGTH       8,
        delivdatecategory              TYPE c LENGTH       1,
        schedulelinedeliverydate       TYPE c LENGTH       8,
        schedulelinedeliverytime       TYPE c LENGTH       6,
        schedulelineorderquantity      TYPE c LENGTH       13,
        roughgoodsreceiptqty           TYPE c LENGTH       13,
        purchaseorderquantityunit      TYPE c LENGTH       3,
        purchaserequisition            TYPE c LENGTH       10,
        purchaserequisitionitem        TYPE c LENGTH       5,
        sourceofcreation               TYPE c LENGTH       1,
        prevdelivqtyofscheduleline     TYPE c LENGTH       13,
        noofremindersofscheduleline    TYPE c LENGTH       3,
        schedulelineisfixed            TYPE c LENGTH       1,
        schedulelinecommittedquantity  TYPE c LENGTH       13,
        reservation                    TYPE c LENGTH       10,
        productavailabilitydate        TYPE c LENGTH       8,
        materialstagingtime            TYPE c LENGTH       6,
        transportationplanningdate     TYPE c LENGTH       8,
        transportationplanningtime     TYPE c LENGTH       6,
        loadingdate                    TYPE c LENGTH      8,
        loadingtime                    TYPE c LENGTH      6,
        goodsissuedate                 TYPE c LENGTH      8,
        goodsissuetime                 TYPE c LENGTH      6,
        stolatestpossiblegrdate        TYPE c LENGTH      8,
        stolatestpossiblegrtime        TYPE c LENGTH      6,
        stocktransferdeliveredquantity TYPE c LENGTH      13,
        schedulelineissuedquantity     TYPE c LENGTH      13,
        batch                          TYPE c LENGTH      10,

      END OF ty_eket,

      "NO.4 購買発注履歴
      BEGIN OF ty_ekbe,
        purchaseorder                  TYPE c LENGTH   10,
        purchaseorderitem              TYPE c LENGTH   5,
        accountassignmentnumber        TYPE c LENGTH   2,
        purchasinghistorydocumenttype  TYPE c LENGTH   1,
        purchasinghistorydocumentyear  TYPE c LENGTH   4,
        purchasinghistorydocument      TYPE c LENGTH   10,
        purchasinghistorydocumentitem  TYPE c LENGTH   4,
        purchasinghistorycategory      TYPE c LENGTH   1,
        goodsmovementtype              TYPE c LENGTH   3,
        postingdate                    TYPE c LENGTH   8,
        currency                       TYPE c LENGTH   5,
        debitcreditcode                TYPE c LENGTH   1,
        iscompletelydelivered          TYPE c LENGTH   1,
        referencedocumentfiscalyear    TYPE c LENGTH   4,
        referencedocument              TYPE c LENGTH   10,
        referencedocumentitem          TYPE c LENGTH   4,
        material                       TYPE c LENGTH   40,
        plant                          TYPE c LENGTH   4,
        rvslofgoodsreceiptisallowed    TYPE c LENGTH   1,
        pricingdocument                TYPE c LENGTH   10,
        taxcode                        TYPE c LENGTH   2,
        documentdate                   TYPE c LENGTH   8,
        inventoryvaluationtype         TYPE c LENGTH   10,
        documentreferenceid            TYPE c LENGTH   16,
        deliveryquantityunit           TYPE c LENGTH   3,
        manufacturermaterial           TYPE c LENGTH   40,
        accountingdocumentcreationdate TYPE c LENGTH   8,
        purghistdocumentcreationtime   TYPE c LENGTH   6,
        quantity                       TYPE c LENGTH   13,
        purordamountincompanycodecrcy  TYPE c LENGTH   13,
        purchaseorderamount            TYPE c LENGTH   13,
        qtyinpurchaseorderpriceunit    TYPE c LENGTH   13,
        griracctclrgamtincocodecrcy    TYPE c LENGTH   13,
        gdsrcptblkdstkqtyinordqtyunit  TYPE c LENGTH   13,
        gdsrcptblkdstkqtyinordprcunit  TYPE c LENGTH   13,
        invoiceamtincocodecrcy         TYPE c LENGTH   13,
        shipginstrnsuppliercompliance  TYPE c LENGTH   2,
        invoiceamountinfrgncurrency    TYPE c LENGTH   13,
        quantityindeliveryqtyunit      TYPE c LENGTH   13,
        griracctclrgamtintransaccrcy   TYPE c LENGTH   13,
        quantityinbaseunit             TYPE c LENGTH   13,
        batch                          TYPE c LENGTH   10,
        griracctclrgamtinordtrnsaccrcy TYPE c LENGTH   13,
        invoiceamtinpurordtransaccrcy  TYPE c LENGTH   13,
        vltdgdsrcptblkdstkqtyinordunit TYPE c LENGTH   13,
        vltdgdsrcptblkdqtyinordprcunit TYPE c LENGTH   13,
        istobeacceptedatorigin         TYPE c LENGTH   1,
        exchangeratedifferenceamount   TYPE c LENGTH   13,
        exchangerate                   TYPE c LENGTH   9,
        deliverydocument               TYPE c LENGTH   10,
        deliverydocumentitem           TYPE c LENGTH   6,
        orderpriceunit                 TYPE c LENGTH   3,
        purchaseorderquantityunit      TYPE c LENGTH   3,
        baseunit                       TYPE c LENGTH   3,
        documentcurrency               TYPE c LENGTH   5,
        companycodecurrency            TYPE c LENGTH   5,

      END OF ty_ekbe,

      "NO.5 購買発注の勘定設定
      BEGIN OF ty_ekkn,
        purchaseorder                  TYPE c LENGTH    10,
        purchaseorderitem              TYPE c LENGTH    5,
        accountassignmentnumber        TYPE c LENGTH    2,
        costcenter                     TYPE c LENGTH    10,
        masterfixedasset               TYPE c LENGTH    12,
        projectnetwork                 TYPE c LENGTH    12,
        quantity                       TYPE c LENGTH    13,
        purchaseorderquantityunit      TYPE c LENGTH    3,
        multipleacctassgmtdistrpercent TYPE c LENGTH    3,
        purgdocnetamount               TYPE c LENGTH    13,
        documentcurrency               TYPE c LENGTH    5,
        isdeleted                      TYPE c LENGTH    1,
        glaccount                      TYPE c LENGTH    10,
        businessarea                   TYPE c LENGTH    4,
        salesorder                     TYPE c LENGTH    10,
        salesorderitem                 TYPE c LENGTH    6,
        salesorderscheduleline         TYPE c LENGTH    4,
        fixedasset                     TYPE c LENGTH    4,
        orderid                        TYPE c LENGTH    12,
        unloadingpointname             TYPE c LENGTH    25,
        controllingarea                TYPE c LENGTH    4,
        costobject                     TYPE c LENGTH    12,
        profitabilitysegment           TYPE c LENGTH    10,
        profitabilitysegment_2         TYPE c LENGTH    10,
        profitcenter                   TYPE c LENGTH    10,
        wbselementinternalid           TYPE c LENGTH    8,
        wbselementinternalid_2         TYPE c LENGTH    8,
        projectnetworkinternalid       TYPE c LENGTH    10,
        commitmentitem                 TYPE c LENGTH    14,
        commitmentitemshortid          TYPE c LENGTH    14,
        fundscenter                    TYPE c LENGTH   16,
        fund                           TYPE c LENGTH   10,
        functionalarea                 TYPE c LENGTH   16,
        goodsrecipientname             TYPE c LENGTH   12,
        isfinallyinvoiced              TYPE c LENGTH   1,
        realestateobject               TYPE c LENGTH   8,
        reinternalfinnumber            TYPE c LENGTH   8,
        networkactivityinternalid      TYPE c LENGTH   8,
        partneraccountnumber           TYPE c LENGTH   10,
        jointventurerecoverycode       TYPE c LENGTH   2,
        settlementreferencedate        TYPE c LENGTH   8,
        orderinternalid                TYPE c LENGTH   10,
        orderintbillofoperationsitem   TYPE c LENGTH   8,
        taxcode                        TYPE c LENGTH   2,
        taxjurisdiction                TYPE c LENGTH   15,
        nondeductibleinputtaxamount    TYPE c LENGTH   13,
        costctractivitytype            TYPE c LENGTH   6,
        businessprocess                TYPE c LENGTH   12,
        grantid                        TYPE c LENGTH   20,
        budgetperiod                   TYPE c LENGTH   10,
        earmarkedfundsdocument         TYPE c LENGTH   10,
        earmarkedfundsitem             TYPE c LENGTH   3,
        earmarkedfundsdocumentitem     TYPE c LENGTH   3,
        servicedocumenttype            TYPE c LENGTH   4,
        servicedocument                TYPE c LENGTH   10,
        servicedocumentitem            TYPE c LENGTH   6,
      END OF ty_ekkn,

      "NO.6 製品
      BEGIN OF ty_mara,
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

        product                       TYPE i_product-product,
        creationdate                  TYPE i_product-creationdate,
        ismarkedfordeletion           TYPE i_product-ismarkedfordeletion,
        producttype                   TYPE i_product-producttype,
        productgroup                  TYPE i_product-productgroup,
        productoldid                  TYPE i_product-productoldid,
        baseunit                      TYPE i_product-baseunit,
        purchaseorderquantityunit     TYPE i_product-purchaseorderquantityunit,
        productdocumentversion        TYPE i_product-productdocumentversion,
        productdocumentchangenumber   TYPE i_product-productdocumentchangenumber,
        productionorinspectionmemotxt TYPE i_product-productionorinspectionmemotxt,
        sizeordimensiontext           TYPE i_product-sizeordimensiontext,
        laboratoryordesignoffice      TYPE i_product-laboratoryordesignoffice,
        grossweight                   TYPE i_product-grossweight,
        netweight                     TYPE i_product-netweight,
        weightunit                    TYPE i_product-weightunit,
        transportationgroup           TYPE i_product-transportationgroup,
        division                      TYPE i_product-division,
        isbatchmanagementrequired     TYPE i_product-isbatchmanagementrequired,
        packagingmaterialgroup        TYPE i_product-packagingmaterialgroup,
        externalproductgroup          TYPE i_product-externalproductgroup,
        productmanufacturernumber     TYPE i_product-productmanufacturernumber,
        manufacturernumber            TYPE i_product-manufacturernumber,
        yy1_bpcode_prd_prd            TYPE i_product-yy1_bpcode_prd_prd,
        yy1_customermaterial_prd      TYPE i_product-yy1_customermaterial_prd,

        packagingmaterialtype         TYPE i_productsales-packagingmaterialtype,

        "end add by wang.z 20250207---------

      END OF ty_mara,

      "NO.7 製品テキスト
      BEGIN OF ty_makt,
        product     TYPE c LENGTH   40,
        language    TYPE c LENGTH   1,
        productname TYPE c LENGTH   40,
      END OF ty_makt,

      "N0.8 製品保管場所
      BEGIN OF ty_mard,
        material        TYPE c LENGTH   40,
        plant           TYPE c LENGTH   4,
        storagelocation TYPE c LENGTH   4,
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
        klabs           TYPE i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
        kinsm           TYPE i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
        insme           TYPE i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
        labst           TYPE i_materialstock_2-matlwrhsstkqtyinmatlbaseunit,
      END OF ty_mard,

      "NO.9 MRP 管理者
      BEGIN OF ty_t024d,
        plant                    TYPE c LENGTH    4,
        mrpcontroller            TYPE c LENGTH    3,
        mrpcontrollername        TYPE c LENGTH    18,
        mrpcontrollerphonenumber TYPE c LENGTH    12,
        purchasinggroup          TYPE c LENGTH    3,
        businessarea             TYPE c LENGTH    4,
        profitcenter             TYPE c LENGTH    10,
        userid                   TYPE c LENGTH    70,
      END OF ty_t024d,

      "NO.10 保管場所
      BEGIN OF ty_t001l,
        plant                      TYPE c LENGTH    4,
        storagelocation            TYPE c LENGTH    4,
        storagelocationname        TYPE c LENGTH    16,
        salesorganization          TYPE c LENGTH    4,
        distributionchannel        TYPE c LENGTH    2,
        division                   TYPE c LENGTH    2,
        isstorlocauthzncheckactive TYPE c LENGTH    1,
        handlingunitisrequired     TYPE c LENGTH    1,
        configdeprecationcode      TYPE c LENGTH    1,
      END OF ty_t001l,

      "NO.11 製品プラント
      BEGIN OF ty_marc,
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

        product                        TYPE i_productplantbasic-product,
        plant                          TYPE i_productplantbasic-plant,
        ismarkedfordeletion            TYPE i_productplantbasic-ismarkedfordeletion,
        profilecode                    TYPE i_productplantbasic-profilecode,
        productiscriticalprt           TYPE i_productplantbasic-productiscriticalprt,
        purchasinggroup                TYPE i_productplantbasic-purchasinggroup,
        goodsissueunit                 TYPE i_productplantbasic-goodsissueunit,
        mrptype                        TYPE i_productplantbasic-mrptype,
        mrpresponsible                 TYPE i_productplantbasic-mrpresponsible,
        planneddeliverydurationindays  TYPE i_productplantbasic-planneddeliverydurationindays,
        goodsreceiptduration           TYPE i_productplantbasic-goodsreceiptduration,
        procurementtype                TYPE i_productplantbasic-procurementtype,
        specialprocurementtype         TYPE i_productplantbasic-specialprocurementtype,
        safetystockquantity            TYPE i_productplantbasic-safetystockquantity,
        minimumlotsizequantity         TYPE i_productplantbasic-minimumlotsizequantity,
        maximumlotsizequantity         TYPE i_productplantbasic-maximumlotsizequantity,
        fixedlotsizequantity           TYPE i_productplantbasic-fixedlotsizequantity,
        productionsupervisor           TYPE i_productplantbasic-productionsupervisor,
        hasposttoinspectionstock       TYPE i_productplantbasic-hasposttoinspectionstock,
        isbatchmanagementrequired      TYPE i_productplantbasic-isbatchmanagementrequired,
        availabilitychecktype          TYPE i_productplantbasic-availabilitychecktype,
        profitcenter                   TYPE i_productplantbasic-profitcenter,
        productioninvtrymanagedloc     TYPE i_productplantbasic-productioninvtrymanagedloc,

        productproductionquantityunit  TYPE i_productworkscheduling-productproductionquantityunit,
        productionschedulingprofile    TYPE i_productworkscheduling-productionschedulingprofile,

        assemblyscrappercent           TYPE i_productplantsupplyplanning-assemblyscrappercent,
        lotsizingprocedure             TYPE i_productplantsupplyplanning-lotsizingprocedure,
        lotsizeroundingquantity        TYPE i_productplantsupplyplanning-lotsizeroundingquantity,
        dependentrequirementstype      TYPE i_productplantsupplyplanning-dependentrequirementstype,
        schedulingfloatprofile         TYPE i_productplantsupplyplanning-schedulingfloatprofile,
        productcomponentbackflushcode  TYPE i_productplantsupplyplanning-productcomponentbackflushcode,
        prodinhprodndurationinworkdays TYPE i_productplantsupplyplanning-prodinhprodndurationinworkdays,
        mrpplanningcalendar            TYPE i_productplantsupplyplanning-mrpplanningcalendar,
        planningtimefence              TYPE i_productplantsupplyplanning-planningtimefence,
        prodrqmtsconsumptionmode       TYPE i_productplantsupplyplanning-prodrqmtsconsumptionmode,
        backwardcnsmpnperiodinworkdays TYPE i_productplantsupplyplanning-backwardcnsmpnperiodinworkdays,
        fwdconsumptionperiodinworkdays TYPE i_productplantsupplyplanning-fwdconsumptionperiodinworkdays,
        mrpgroup                       TYPE i_productplantsupplyplanning-mrpgroup,
        componentscrapinpercent        TYPE i_productplantsupplyplanning-componentscrapinpercent,
        planningstrategygroup          TYPE i_productplantsupplyplanning-planningstrategygroup,
        dfltstoragelocationextprocmt   TYPE i_productplantsupplyplanning-dfltstoragelocationextprocmt,
        productisbulkcomponent         TYPE i_productplantsupplyplanning-productisbulkcomponent,
        productsafetytimemrprelevance  TYPE i_productplantsupplyplanning-productsafetytimemrprelevance,
        safetysupplydurationindays     TYPE i_productplantsupplyplanning-safetysupplydurationindays,

        loadinggroup                   TYPE i_productplantsales-loadinggroup,

        isautopurordcreationallowed    TYPE i_productplantprocurement-isautopurordcreationallowed,
        issourcelistrequired           TYPE i_productplantprocurement-issourcelistrequired,

        costinglotsize                 TYPE i_productplantcosting-costinglotsize,
        productiscostingrelevant       TYPE i_productplantcosting-productiscostingrelevant,

        "end add by wang.z 20250207--------------

      END OF ty_marc,

      "NO.12 製造バージョン
      BEGIN OF ty_mkal,

        material                   TYPE i_productionversion-material,
        plant                      TYPE i_productionversion-plant,
        productionversion          TYPE i_productionversion-productionversion,
        validitystartdate          TYPE i_productionversion-validitystartdate,
        validityenddate            TYPE i_productionversion-validityenddate,
        billofmaterialvariant      TYPE i_productionversion-billofmaterialvariant,
        procurementtype            TYPE i_productionversion-procurementtype,
        materialprocurementprofile TYPE i_productionversion-materialprocurementprofile,
        costinglotsize             TYPE i_productionversion-costinglotsize,
        productionversiontext      TYPE i_productionversion-productionversiontext,
        materialminlotsizequantity TYPE i_productionversion-materialminlotsizequantity,
        materialmaxlotsizequantity TYPE i_productionversion-materialmaxlotsizequantity,

*        material                       TYPE c LENGTH    40,
*        plant                          TYPE c LENGTH    4,
*        productionversion              TYPE c LENGTH    4,
*        productionversiontext          TYPE c LENGTH    40,
*        changehistorycount             TYPE c LENGTH    4,
*        changenumber                   TYPE c LENGTH    12,
*        creationdate                   TYPE c LENGTH    8,
*        createdbyuser                  TYPE c LENGTH    12,
*        lastchangedate                 TYPE c LENGTH    8,
*        lastchangedbyuser              TYPE c LENGTH    12,
*        billofoperationstype           TYPE c LENGTH    1,
*        billofoperationsgroup          TYPE c LENGTH    8,
*        billofoperationsvariant        TYPE c LENGTH    2,
*        billofmaterialvariantusage     TYPE c LENGTH    1,
*        billofmaterialvariant          TYPE c LENGTH    2,
*        productionline                 TYPE c LENGTH    8,
*        productionsupplyarea           TYPE c LENGTH    10,
*        productionversiongroup         TYPE c LENGTH    8,
*        mainproduct                    TYPE c LENGTH    40,
*        materialcostapportionmentstruc TYPE c LENGTH    4,
*        issuingstoragelocation         TYPE c LENGTH    4,
*        receivingstoragelocation       TYPE c LENGTH    4,
*        originalbatchreferencematerial TYPE c LENGTH    40,
*        quantitydistributionkey        TYPE c LENGTH    4,
*        productionversionstatus        TYPE c LENGTH    1,
*        productionversionlastcheckdate TYPE c LENGTH    8,
*        ratebasedplanningstatus        TYPE c LENGTH    1,
*        preliminaryplanningstatus      TYPE c LENGTH    1,
*        bomcheckstatus                 TYPE c LENGTH    1,
*        validitystartdate              TYPE c LENGTH    8,
*        validityenddate                TYPE c LENGTH    8,
*        productionversionislocked      TYPE c LENGTH    1,
*        prodnversisallowedforrptvmfg   TYPE c LENGTH    1,
*        hasversionctrldbomandrouting   TYPE c LENGTH    1,
*        planningandexecutionbomisdiff  TYPE c LENGTH    1,
*        execbillofmaterialvariantusage TYPE c LENGTH    1,
*        execbillofmaterialvariant      TYPE c LENGTH    2,
*        execbillofoperationstype       TYPE c LENGTH    1,
*        execbillofoperationsgroup      TYPE c LENGTH    8,
*        execbillofoperationsvariant    TYPE c LENGTH    2,
*        warehouse                      TYPE c LENGTH    4,
*        destinationstoragebin          TYPE c LENGTH    18,
*        procurementtype                TYPE c LENGTH    1,
*        materialprocurementprofile     TYPE c LENGTH    2,
*        usgeprobltywthversctrlinpct    TYPE c LENGTH    3,
*        materialbaseunit               TYPE c LENGTH    3,
*        materialminlotsizequantity     TYPE c LENGTH    13,
*        materialmaxlotsizequantity     TYPE c LENGTH    13,
*        costinglotsize                 TYPE c LENGTH    13,
*        distributionkey                TYPE c LENGTH    4,
*        targetproductionsupplyarea     TYPE c LENGTH    10,

      END OF ty_mkal,

      "NO.13 製造指図
      BEGIN OF ty_afko,
        manufacturingorder             TYPE c LENGTH   12,
        manufacturingorderitem         TYPE c LENGTH   4,
        manufacturingordercategory     TYPE c LENGTH   2,
        manufacturingordertype         TYPE c LENGTH   4,
        manufacturingordertext         TYPE c LENGTH   40,
        manufacturingorderhaslongtext  TYPE c LENGTH   1,
        longtextlanguagecode           TYPE c LENGTH   1,
        manufacturingorderimportance   TYPE c LENGTH   1,
        ismarkedfordeletion            TYPE c LENGTH   1,
        iscompletelydelivered          TYPE c LENGTH   1,
        mfgorderhasmultipleitems       TYPE c LENGTH   1,
        mfgorderispartofcollvorder     TYPE c LENGTH   1,
        mfgorderhierarchylevel         TYPE c LENGTH   2,
        mfgorderhierarchylevelvalue    TYPE c LENGTH   2,
        mfgorderhierarchypathvalue     TYPE c LENGTH   4,
        orderisnotcostedautomatically  TYPE c LENGTH   1,
        ordisnotschedldautomatically   TYPE c LENGTH   1,
        prodnprocgisflexible           TYPE c LENGTH   1,
        creationdate                   TYPE c LENGTH   8,
        creationtime                   TYPE c LENGTH   6,
        createdbyuser                  TYPE c LENGTH   12,
        lastchangedate                 TYPE c LENGTH   8,
        lastchangetime                 TYPE c LENGTH   6,
        lastchangedbyuser              TYPE c LENGTH   12,
        material                       TYPE c LENGTH   40,
        product                        TYPE c LENGTH   40,
        storagelocation                TYPE c LENGTH   4,
        batch                          TYPE c LENGTH   10,
        goodsrecipientname             TYPE c LENGTH   12,
        unloadingpointname             TYPE c LENGTH   25,
        inventoryusabilitycode         TYPE c LENGTH   1,
        materialgoodsreceiptduration   TYPE c LENGTH   3,
        quantitydistributionkey        TYPE c LENGTH   4,
        stocksegment                   TYPE c LENGTH   40,
        mfgorderinternalid             TYPE c LENGTH   10,
        referenceorder                 TYPE c LENGTH   12,
        leadingorder                   TYPE c LENGTH   12,
        superiororder                  TYPE c LENGTH   12,
        currency                       TYPE c LENGTH   5,
        productionplant                TYPE c LENGTH   4,
        planningplant                  TYPE c LENGTH   4,
        mrparea                        TYPE c LENGTH   10,
        mrpcontroller                  TYPE c LENGTH   3,
        productionsupervisor           TYPE c LENGTH   3,
        productionschedulingprofile    TYPE c LENGTH   6,
        responsibleplannergroup        TYPE c LENGTH   3,
        productionversion              TYPE c LENGTH   4,
        salesorder                     TYPE c LENGTH   10,
        salesorderitem                 TYPE c LENGTH   6,
        wbselementinternalid           TYPE c LENGTH   8,
        wbselementinternalid_2         TYPE c LENGTH   8,
        reservation                    TYPE c LENGTH   10,
        settlementreservation          TYPE c LENGTH   10,
        mfgorderconfirmation           TYPE c LENGTH   10,
        numberofmfgorderconfirmations  TYPE c LENGTH   8,
        plannedorder                   TYPE c LENGTH   10,
        capacityrequirement            TYPE c LENGTH   12,
        inspectionlot                  TYPE c LENGTH   12,
        changenumber                   TYPE c LENGTH   12,
        materialrevisionlevel          TYPE c LENGTH   2,
        materialrevisionlevel_2        TYPE c LENGTH   2,
        basicschedulingtype            TYPE c LENGTH   1,
        forecastschedulingtype         TYPE c LENGTH   1,
        objectinternalid               TYPE c LENGTH   22,
        productconfiguration           TYPE c LENGTH   18,
        effectivityparametervariant    TYPE c LENGTH   12,
        conditionapplication           TYPE c LENGTH   2,
        capacityactiveversion          TYPE c LENGTH   2,
        capacityrqmthasnottobecreated  TYPE c LENGTH   1,
        ordersequencenumber            TYPE c LENGTH   14,
        mfgordersplitstatus            TYPE c LENGTH   1,
        billofoperationsmaterial       TYPE c LENGTH   40,
        billofoperationstype           TYPE c LENGTH   1,
        billofoperations               TYPE c LENGTH   8,
        billofoperationsgroup          TYPE c LENGTH   8,
        billofoperationsvariant        TYPE c LENGTH   2,
        boointernalversioncounter      TYPE c LENGTH   8,
        billofoperationsapplication    TYPE c LENGTH   1,
        billofoperationsusage          TYPE c LENGTH   3,
        billofoperationsversion        TYPE c LENGTH   4,
        booexplosiondate               TYPE c LENGTH   8,
        boovaliditystartdate           TYPE c LENGTH   8,
        billofmaterialcategory         TYPE c LENGTH   1,
        billofmaterial                 TYPE c LENGTH   8,
        billofmaterialinternalid       TYPE c LENGTH   8,
        billofmaterialvariant          TYPE c LENGTH   2,
        billofmaterialvariantusage     TYPE c LENGTH   1,
        billofmaterialversion          TYPE c LENGTH   4,
        bomexplosiondate               TYPE c LENGTH   8,
        bomvaliditystartdate           TYPE c LENGTH   8,
        businessarea                   TYPE c LENGTH   4,
        companycode                    TYPE c LENGTH   4,
        controllingarea                TYPE c LENGTH   4,
        profitcenter                   TYPE c LENGTH   10,
        costcenter                     TYPE c LENGTH   10,
        responsiblecostcenter          TYPE c LENGTH   10,
        costelement                    TYPE c LENGTH   10,
        costingsheet                   TYPE c LENGTH   6,
        glaccount                      TYPE c LENGTH   10,
        productcostcollector           TYPE c LENGTH   12,
        actualcostscostingvariant      TYPE c LENGTH   4,
        plannedcostscostingvariant     TYPE c LENGTH   4,
        controllingobjectclass         TYPE c LENGTH   2,
        functionalarea                 TYPE c LENGTH   16,
        orderiseventbasedposting       TYPE c LENGTH   1,
        eventbasedpostingmethod        TYPE c LENGTH   1,
        eventbasedprocessingkey        TYPE c LENGTH   6,
        schedulingfloatprofile         TYPE c LENGTH   3,
        floatbeforeproductioninwrkdays TYPE c LENGTH   3,
        floatafterproductioninworkdays TYPE c LENGTH   3,
        releaseperiodinworkdays        TYPE c LENGTH   3,
        changetoscheduleddatesismade   TYPE c LENGTH   1,
        mfgorderplannedstartdate       TYPE c LENGTH   8,
        mfgorderplannedstarttime       TYPE c LENGTH   6,
        mfgorderplannedenddate         TYPE c LENGTH   8,
        mfgorderplannedendtime         TYPE c LENGTH   6,
        mfgorderplannedreleasedate     TYPE c LENGTH   8,
        mfgorderscheduledstartdate     TYPE c LENGTH   8,
        mfgorderscheduledstarttime     TYPE c LENGTH   6,
        mfgorderscheduledenddate       TYPE c LENGTH   8,
        mfgorderscheduledendtime       TYPE c LENGTH   6,
        mfgorderscheduledreleasedate   TYPE c LENGTH   8,
        mfgorderactualstartdate        TYPE c LENGTH   8,
        mfgorderactualstarttime        TYPE c LENGTH   6,
        mfgorderconfirmedenddate       TYPE c LENGTH   8,
        mfgorderconfirmedendtime       TYPE c LENGTH   6,
        mfgorderactualenddate          TYPE c LENGTH   8,
        mfgorderactualreleasedate      TYPE c LENGTH   8,
        mfgordertotalcommitmentdate    TYPE c LENGTH   8,
        mfgorderactualcompletiondate   TYPE c LENGTH   8,
        mfgorderitemactualdeliverydate TYPE c LENGTH   8,
        productionunit                 TYPE c LENGTH   3,
        mfgorderplannedtotalqty        TYPE c LENGTH   13,
        mfgorderplannedscrapqty        TYPE c LENGTH   13,
        mfgorderconfirmedyieldqty      TYPE c LENGTH   13,
        mfgorderconfirmedscrapqty      TYPE c LENGTH   13,
        mfgorderconfirmedreworkqty     TYPE c LENGTH   13,
        expecteddeviationquantity      TYPE c LENGTH   13,
        actualdeliveredquantity        TYPE c LENGTH   13,
        masterproductionorder          TYPE c LENGTH   12,
        productseasonyear              TYPE c LENGTH   4,
        productseason                  TYPE c LENGTH   10,
        productcollection              TYPE c LENGTH   10,
        producttheme                   TYPE c LENGTH   10,

        "add by wang.z 20250207-----------------------------------------------------------

        billofmaterialstatus           TYPE i_billofmaterialheaderdex_2-billofmaterialstatus,
        bomheaderquantityinbaseunit    TYPE i_billofmaterialheaderdex_2-bomheaderquantityinbaseunit,
        bomheaderbaseunit              TYPE i_billofmaterialheaderdex_2-bomheaderbaseunit,

        "end add by wang.z 20250207-------------------------------------------------------
      END OF ty_afko,

      "NO.14製造指図明細
      BEGIN OF ty_afpo,
        manufacturingorder             TYPE c LENGTH  12,
        manufacturingorderitem         TYPE c LENGTH  4,
        manufacturingordercategory     TYPE c LENGTH  2,
        manufacturingordertype         TYPE c LENGTH  4,
        orderisreleased                TYPE c LENGTH  1,
        ismarkedfordeletion            TYPE c LENGTH  1,
        orderitemisnotrelevantformrp   TYPE c LENGTH  1,
        material                       TYPE c LENGTH  40,
        product                        TYPE c LENGTH  40,
        productionplant                TYPE c LENGTH  4,
        planningplant                  TYPE c LENGTH  4,
        mrpcontroller                  TYPE c LENGTH  3,
        productionsupervisor           TYPE c LENGTH  3,
        reservation                    TYPE c LENGTH  10,
        productionversion              TYPE c LENGTH  4,
        mrparea                        TYPE c LENGTH  10,
        salesorder                     TYPE c LENGTH  10,
        salesorderitem                 TYPE c LENGTH  6,
        salesorderscheduleline         TYPE c LENGTH  4,
        wbselementinternalid           TYPE c LENGTH  8,
        wbselementinternalid_2         TYPE c LENGTH  8,
        quotaarrangement               TYPE c LENGTH  10,
        quotaarrangementitem           TYPE c LENGTH  3,
        settlementreservation          TYPE c LENGTH  10,
        settlementreservationitem      TYPE c LENGTH  4,
        coproductreservation           TYPE c LENGTH  10,
        coproductreservationitem       TYPE c LENGTH  4,
        materialprocurementcategory    TYPE c LENGTH  1,
        materialprocurementtype        TYPE c LENGTH  1,
        serialnumberassgmtprofile      TYPE c LENGTH  4,
        numberofserialnumbers          TYPE c LENGTH  10,
        mfgorderitemreplnmtelmnttype   TYPE c LENGTH  1,
        productconfiguration           TYPE c LENGTH  18,
        objectinternalid               TYPE c LENGTH  22,
        manufacturingobject            TYPE c LENGTH  22,
        quantitydistributionkey        TYPE c LENGTH  4,
        effectivityparametervariant    TYPE c LENGTH  12,
        goodsreceiptisexpected         TYPE c LENGTH  1,
        goodsreceiptisnonvaluated      TYPE c LENGTH  1,
        iscompletelydelivered          TYPE c LENGTH  1,
        materialgoodsreceiptduration   TYPE c LENGTH  3,
        underdelivtolrtdlmtratioinpct  TYPE c LENGTH  3,
        overdelivtolrtdlmtratioinpct   TYPE c LENGTH  3,
        unlimitedoverdeliveryisallowed TYPE c LENGTH  1,
        storagelocation                TYPE c LENGTH  4,
        batch                          TYPE c LENGTH  10,
        inventoryvaluationtype         TYPE c LENGTH  10,
        inventoryvaluationcategory     TYPE c LENGTH  1,
        inventoryusabilitycode         TYPE c LENGTH  1,
        inventoryspecialstocktype      TYPE c LENGTH  1,
        inventoryspecialstockvalntype  TYPE c LENGTH  1,
        consumptionposting             TYPE c LENGTH  1,
        goodsrecipientname             TYPE c LENGTH  12,
        unloadingpointname             TYPE c LENGTH  25,
        stocksegment                   TYPE c LENGTH  40,
        mfgorderplannedstartdate       TYPE c LENGTH  8,
        mfgorderplannedstarttime       TYPE c LENGTH  6,
        mfgorderscheduledstartdate     TYPE c LENGTH  8,
        mfgorderscheduledstarttime     TYPE c LENGTH  6,
        mfgorderactualstartdate        TYPE c LENGTH  8,
        mfgorderactualstarttime        TYPE c LENGTH  6,
        mfgorderplannedenddate         TYPE c LENGTH  8,
        mfgorderplannedendtime         TYPE c LENGTH  6,
        mfgorderscheduledenddate       TYPE c LENGTH  8,
        mfgorderscheduledendtime       TYPE c LENGTH  6,
        mfgorderconfirmedenddate       TYPE c LENGTH  8,
        mfgorderconfirmedendtime       TYPE c LENGTH  6,
        mfgorderactualenddate          TYPE c LENGTH  8,
        mfgorderscheduledreleasedate   TYPE c LENGTH  8,
        mfgorderactualreleasedate      TYPE c LENGTH  8,
        mfgorderitemplannedenddate     TYPE c LENGTH  8,
        mfgorderitemscheduledenddate   TYPE c LENGTH  8,
        mfgorderitemplnddeliverydate   TYPE c LENGTH  8,
        mfgorderitemactualdeliverydate TYPE c LENGTH  8,
        mfgorderitemtotalcmtmtdate     TYPE c LENGTH  8,
        productionunit                 TYPE c LENGTH  3,
        mfgorderitemplannedtotalqty    TYPE c LENGTH  13,
        mfgorderitemplannedscrapqty    TYPE c LENGTH  13,
        mfgorderitemplannedyieldqty    TYPE c LENGTH  13,
        mfgorderitemgoodsreceiptqty    TYPE c LENGTH  13,
        mfgorderitemactualdeviationqty TYPE c LENGTH  13,
        mfgorderitemopenyieldqty       TYPE c LENGTH  16,
        mfgorderconfirmedyieldqty      TYPE c LENGTH  13,
        mfgorderconfirmedscrapqty      TYPE c LENGTH  13,
        mfgorderconfirmedreworkqty     TYPE c LENGTH  13,
        mfgorderconfirmedtotalqty      TYPE c LENGTH  13,
        mfgorderplannedtotalqty        TYPE c LENGTH  13,
        mfgorderplannedscrapqty        TYPE c LENGTH  13,
        plannedorder                   TYPE c LENGTH  10,
        plndorderplannedstartdate      TYPE c LENGTH  8,
        plannedorderopeningdate        TYPE c LENGTH  8,
        baseunit                       TYPE c LENGTH  3,
        plndorderplannedtotalqty       TYPE c LENGTH  13,
        plndorderplannedscrapqty       TYPE c LENGTH  13,
        companycode                    TYPE c LENGTH  4,
        businessarea                   TYPE c LENGTH  4,
        accountassignmentcategory      TYPE c LENGTH  1,
        companycodecurrency            TYPE c LENGTH  5,
        goodsreceiptamountincocodecrcy TYPE c LENGTH  13,
        masterproductionorder          TYPE c LENGTH  12,
        productseasonyear              TYPE c LENGTH  4,
        productseason                  TYPE c LENGTH  10,
        productcollection              TYPE c LENGTH  10,
        producttheme                   TYPE c LENGTH  10,

      END OF ty_afpo,

      "NO.15 品質検査計画作業のバージョン
      BEGIN OF ty_plpo,
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
*        billofoperationstype           TYPE i_mfgboooperationchangestate-billofoperationstype,
*        billofoperationsgroup          TYPE i_mfgboooperationchangestate-billofoperationsgroup,
*        billofoperationsvariant        TYPE i_mfgboooperationchangestate-billofoperationsvariant,
*        billofoperationssequence       TYPE i_mfgboooperationchangestate-billofoperationssequence,
*        boooperationinternalid         TYPE i_mfgboooperationchangestate-boooperationinternalid,
*        boosqncopassgmtintversioncntr  TYPE i_mfgboooperationchangestate-boosqncopassgmtintversioncntr,
*        booopinternalversioncounter    TYPE i_mfgboooperationchangestate-booopinternalversioncounter,
*        operationexternalid            TYPE i_mfgboooperationchangestate-operationexternalid,
*        operation                      TYPE i_mfgboooperationchangestate-operation_2, " Operation,
*        operation_2                    TYPE i_mfgboooperationchangestate-operation_2,
*        creationdate                   TYPE i_mfgboooperationchangestate-creationdate,
*        createdbyuser                  TYPE i_mfgboooperationchangestate-createdbyuser,
*        lastchangedate                 TYPE i_mfgboooperationchangestate-lastchangedate,
*        lastchangedbyuser              TYPE i_mfgboooperationchangestate-lastchangedbyuser,
*        changenumber                   TYPE i_mfgboooperationchangestate-changenumber,
*        validitystartdate              TYPE i_mfgboooperationchangestate-validitystartdate,
*        validityenddate                TYPE i_mfgboooperationchangestate-validityenddate,
*        isdeleted                      TYPE i_mfgboooperationchangestate-isdeleted,
*        isimplicitlydeleted            TYPE i_mfgboooperationchangestate-isimplicitlydeleted,
*        operationtext                  TYPE i_mfgboooperationchangestate-operationtext,
*        longtextlanguagecode           TYPE i_mfgboooperationchangestate-longtextlanguagecode,
*        plant                          TYPE i_mfgboooperationchangestate-plant,
*        operationcontrolprofile        TYPE i_mfgboooperationchangestate-operationcontrolprofile,
*        operationstandardtextcode      TYPE i_mfgboooperationchangestate-operationstandardtextcode,
*        workcenterinternalid           TYPE i_mfgboooperationchangestate-workcenterinternalid,
*        workcentertypecode             TYPE i_mfgboooperationchangestate-workcentertypecode,
*        factorycalendar                TYPE i_mfgboooperationchangestate-factorycalendar,
*        capacitycategorycode           TYPE i_mfgboooperationchangestate-capacitycategorycode,
*        costelement                    TYPE i_mfgboooperationchangestate-costelement,
*        companycode                    TYPE i_mfgboooperationchangestate-companycode,
*        operationcostingrelevancytype  TYPE i_mfgboooperationchangestate-operationcostingrelevancytype,
*        numberoftimetickets            TYPE i_mfgboooperationchangestate-numberoftimetickets,
*        numberofconfirmationslips      TYPE i_mfgboooperationchangestate-numberofconfirmationslips,
*        employeewagegroup              TYPE i_mfgboooperationchangestate-employeewagegroup,
*        employeewagetype               TYPE i_mfgboooperationchangestate-employeewagetype,
*        employeesuitability            TYPE i_mfgboooperationchangestate-employeesuitability,
*        numberofemployees              TYPE i_mfgboooperationchangestate-numberofemployees,
*        billofoperationsreftype        TYPE i_mfgboooperationchangestate-billofoperationsreftype,
*        billofoperationsrefgroup       TYPE i_mfgboooperationchangestate-billofoperationsrefgroup,
*        billofoperationsrefvariant     TYPE i_mfgboooperationchangestate-billofoperationsrefvariant,
*        linesegmenttakt                TYPE i_mfgboooperationchangestate-linesegmenttakt,
*        operationstdworkqtygrpgcat     TYPE i_mfgboooperationchangestate-operationstdworkqtygrpgcat,
*        orderhasnosuboperations        TYPE i_mfgboooperationchangestate-orderhasnosuboperations,
*        operationsetuptype             TYPE i_mfgboooperationchangestate-operationsetuptype,
*        operationsetupgroupcategory    TYPE i_mfgboooperationchangestate-operationsetupgroupcategory,
*        operationsetupgroup            TYPE i_mfgboooperationchangestate-operationsetupgroup,
*        boooperationisphase            TYPE i_mfgboooperationchangestate-boooperationisphase,
*        boophasesuperioropinternalid   TYPE i_mfgboooperationchangestate-boophasesuperioropinternalid,
*        controlrecipedestination       TYPE i_mfgboooperationchangestate-controlrecipedestination,
*        opisextlyprocdwithsubcontrg    TYPE i_mfgboooperationchangestate-opisextlyprocdwithsubcontrg,
*        purchasinginforecord           TYPE i_mfgboooperationchangestate-purchasinginforecord,
*        purchasingorganization         TYPE i_mfgboooperationchangestate-purchasingorganization,
*        purchasecontract               TYPE i_mfgboooperationchangestate-purchasecontract,
*        purchasecontractitem           TYPE i_mfgboooperationchangestate-purchasecontractitem,
*        purchasinginforecdaddlgrpgname TYPE i_mfgboooperationchangestate-purchasinginforecdaddlgrpgname,
*        materialgroup                  TYPE i_mfgboooperationchangestate-materialgroup,
*        purchasinggroup                TYPE i_mfgboooperationchangestate-purchasinggroup,
*        supplier                       TYPE i_mfgboooperationchangestate-supplier,
*        planneddeliveryduration        TYPE i_mfgboooperationchangestate-planneddeliveryduration,
*        numberofoperationpriceunits    TYPE i_mfgboooperationchangestate-numberofoperationpriceunits,
*        opexternalprocessingcurrency   TYPE i_mfgboooperationchangestate-opexternalprocessingcurrency,
*        opexternalprocessingprice      TYPE i_mfgboooperationchangestate-opexternalprocessingprice,
*        inspectionlottype              TYPE i_mfgboooperationchangestate-inspectionlottype,
*        inspresultrecordingview        TYPE i_mfgboooperationchangestate-inspresultrecordingview,
*        inspsbstcompletionconfirmation TYPE i_mfgboooperationchangestate-inspsbstcompletionconfirmation,
*        inspsbsthasnotimeorquantity    TYPE i_mfgboooperationchangestate-inspsbsthasnotimeorquantity,
*        operationreferencequantity     TYPE i_mfgboooperationchangestate-operationreferencequantity,
*        operationunit                  TYPE i_mfgboooperationchangestate-operationunit,
*        operationscrappercent          TYPE i_mfgboooperationchangestate-operationscrappercent,
*        opqtytobaseqtynmrtr            TYPE i_mfgboooperationchangestate-opqtytobaseqtynmrtr,
*        opqtytobaseqtydnmntr           TYPE i_mfgboooperationchangestate-opqtytobaseqtydnmntr,
*        standardworkformulaparam1      TYPE i_mfgboooperationchangestate-standardworkformulaparam1,
*        standardworkquantity1          TYPE i_mfgboooperationchangestate-standardworkquantity1,
*        standardworkquantityunit1      TYPE i_mfgboooperationchangestate-standardworkquantityunit1,
*        costctractivitytype1           TYPE i_mfgboooperationchangestate-costctractivitytype1,
*        perfefficiencyratiocode1       TYPE i_mfgboooperationchangestate-perfefficiencyratiocode1,
*        standardworkformulaparam2      TYPE i_mfgboooperationchangestate-standardworkformulaparam2,
*        standardworkquantity2          TYPE i_mfgboooperationchangestate-standardworkquantity2,
*        standardworkquantityunit2      TYPE i_mfgboooperationchangestate-standardworkquantityunit2,
*        costctractivitytype2           TYPE i_mfgboooperationchangestate-costctractivitytype2,
*        perfefficiencyratiocode2       TYPE i_mfgboooperationchangestate-perfefficiencyratiocode2,
*        standardworkformulaparam3      TYPE i_mfgboooperationchangestate-standardworkformulaparam3,
*        standardworkquantity3          TYPE i_mfgboooperationchangestate-standardworkquantity3,
*        standardworkquantityunit3      TYPE i_mfgboooperationchangestate-standardworkquantityunit3,
*        costctractivitytype3           TYPE i_mfgboooperationchangestate-costctractivitytype3,
*        perfefficiencyratiocode3       TYPE i_mfgboooperationchangestate-perfefficiencyratiocode3,
*        standardworkformulaparam4      TYPE i_mfgboooperationchangestate-standardworkformulaparam4,
*        standardworkquantity4          TYPE i_mfgboooperationchangestate-standardworkquantity4,
*        standardworkquantityunit4      TYPE i_mfgboooperationchangestate-standardworkquantityunit4,
*        costctractivitytype4           TYPE i_mfgboooperationchangestate-costctractivitytype4,
*        perfefficiencyratiocode4       TYPE i_mfgboooperationchangestate-perfefficiencyratiocode4,
*        standardworkformulaparam5      TYPE i_mfgboooperationchangestate-standardworkformulaparam5,
*        standardworkquantity5          TYPE i_mfgboooperationchangestate-standardworkquantity5,
*        standardworkquantityunit5      TYPE i_mfgboooperationchangestate-standardworkquantityunit5,
*        costctractivitytype5           TYPE i_mfgboooperationchangestate-costctractivitytype5,
*        perfefficiencyratiocode5       TYPE i_mfgboooperationchangestate-perfefficiencyratiocode5,
*        standardworkformulaparam6      TYPE i_mfgboooperationchangestate-standardworkformulaparam6,
*        standardworkquantity6          TYPE i_mfgboooperationchangestate-standardworkquantity6,
*        standardworkquantityunit6      TYPE i_mfgboooperationchangestate-standardworkquantityunit6,
*        costctractivitytype6           TYPE i_mfgboooperationchangestate-costctractivitytype6,
*        perfefficiencyratiocode6       TYPE i_mfgboooperationchangestate-perfefficiencyratiocode6,
*        businessprocess                TYPE i_mfgboooperationchangestate-businessprocess,
*        leadtimereductionstrategy      TYPE i_mfgboooperationchangestate-leadtimereductionstrategy,
*        teardownandwaitisparallel      TYPE i_mfgboooperationchangestate-teardownandwaitisparallel,
*        billofoperationsbreakduration  TYPE i_mfgboooperationchangestate-billofoperationsbreakduration,
*        breakdurationunit              TYPE i_mfgboooperationchangestate-breakdurationunit,
*        maximumwaitduration            TYPE i_mfgboooperationchangestate-maximumwaitduration,
*        maximumwaitdurationunit        TYPE i_mfgboooperationchangestate-maximumwaitdurationunit,
*        minimumwaitduration            TYPE i_mfgboooperationchangestate-minimumwaitduration,
*        minimumwaitdurationunit        TYPE i_mfgboooperationchangestate-minimumwaitdurationunit,
*        standardqueueduration          TYPE i_mfgboooperationchangestate-standardqueueduration,
*        standardqueuedurationunit      TYPE i_mfgboooperationchangestate-standardqueuedurationunit,
*        minimumqueueduration           TYPE i_mfgboooperationchangestate-minimumqueueduration,
*        minimumqueuedurationunit       TYPE i_mfgboooperationchangestate-minimumqueuedurationunit,
*        standardmoveduration           TYPE i_mfgboooperationchangestate-standardmoveduration,
*        standardmovedurationunit       TYPE i_mfgboooperationchangestate-standardmovedurationunit,
*        minimummoveduration            TYPE i_mfgboooperationchangestate-minimummoveduration,
*        minimummovedurationunit        TYPE i_mfgboooperationchangestate-minimummovedurationunit,
*        operationsplitisrequired       TYPE i_mfgboooperationchangestate-operationsplitisrequired,
*        maximumnumberofsplits          TYPE i_mfgboooperationchangestate-maximumnumberofsplits,
*        minprocessingdurationpersplit  TYPE i_mfgboooperationchangestate-minprocessingdurationpersplit,
*        minprocessingdurnpersplitunit  TYPE i_mfgboooperationchangestate-minprocessingdurnpersplitunit,
*        operationoverlappingisrequired TYPE i_mfgboooperationchangestate-operationoverlappingisrequired,
*        operationoverlappingispossible TYPE i_mfgboooperationchangestate-operationoverlappingispossible,
*        operationsisalwaysoverlapping  TYPE i_mfgboooperationchangestate-operationsisalwaysoverlapping,
*        operationhasnooverlapping      TYPE i_mfgboooperationchangestate-operationhasnooverlapping,
*        overlapminimumduration         TYPE i_mfgboooperationchangestate-overlapminimumduration,
*        overlapminimumdurationunit     TYPE i_mfgboooperationchangestate-overlapminimumdurationunit,
*        overlapminimumtransferqty      TYPE i_mfgboooperationchangestate-overlapminimumtransferqty,
*        overlapminimumtransferqtyunit  TYPE i_mfgboooperationchangestate-overlapminimumtransferqtyunit,
        "end change by wang.z 20250207----------------------------------------------------
        billofoperationstype        TYPE i_mfgboooperationchangestate-billofoperationstype,
        billofoperationsgroup       TYPE i_mfgboooperationchangestate-billofoperationsgroup,
        boooperationinternalid      TYPE i_mfgboooperationchangestate-boooperationinternalid,
        booopinternalversioncounter TYPE i_mfgboooperationchangestate-booopinternalversioncounter,
        operation_2                 TYPE i_mfgboooperationchangestate-operation_2,
        costctractivitytype1        TYPE i_mfgboooperationchangestate-costctractivitytype1,
        standardworkquantityunit1   TYPE i_mfgboooperationchangestate-standardworkquantityunit1,
        standardworkquantity1       TYPE i_mfgboooperationchangestate-standardworkquantity1,
        costctractivitytype2        TYPE i_mfgboooperationchangestate-costctractivitytype2,
        standardworkquantityunit2   TYPE i_mfgboooperationchangestate-standardworkquantityunit2,
        standardworkquantity2       TYPE i_mfgboooperationchangestate-standardworkquantity2,
      END OF ty_plpo,

      "NO.16 入出庫予定伝票明細
      BEGIN OF ty_resb,
*        reservation                    TYPE c LENGTH   10,
*        reservationitem                TYPE c LENGTH   4,
*        recordtype                     TYPE c LENGTH   1,
*        materialgroup                  TYPE c LENGTH   9,
*        material                       TYPE c LENGTH   40,
*        plant                          TYPE c LENGTH   4,
*        manufacturingordercategory     TYPE c LENGTH   2,
*        manufacturingordertype         TYPE c LENGTH   4,
*        manufacturingorder             TYPE c LENGTH   12,
*        manufacturingordersequence     TYPE c LENGTH   6,
*        mfgordersequencecategory       TYPE c LENGTH   1,
*        manufacturingorderoperation    TYPE c LENGTH   4,
*        manufacturingorderoperation_2  TYPE c LENGTH   4,
*        productionplant                TYPE c LENGTH   4,
*        orderinternalbillofoperations  TYPE c LENGTH   10,
*        orderintbillofoperationsitem   TYPE c LENGTH   8,
*        assemblymrpcontroller          TYPE c LENGTH   3,
*        productionsupervisor           TYPE c LENGTH   3,
*        orderobjectinternalid          TYPE c LENGTH   22,
*        matlcomprequirementdate        TYPE c LENGTH   8,
*        matlcomprequirementtime        TYPE c LENGTH   6,
*        latestrequirementdate          TYPE c LENGTH   8,
*        mfgorderactualreleasedate      TYPE c LENGTH   8,
*        reservationitemcreationcode    TYPE c LENGTH   1,
*        reservationisfinallyissued     TYPE c LENGTH   1,
*        matlcompismarkedfordeletion    TYPE c LENGTH   1,
*        materialcomponentismissing     TYPE c LENGTH   1,
*        isbulkmaterialcomponent        TYPE c LENGTH   1,
*        matlcompismarkedforbackflush   TYPE c LENGTH   1,
*        matlcompistextitem             TYPE c LENGTH   1,
*        materialplanningrelevance      TYPE c LENGTH   1,
*        matlcompisconfigurable         TYPE c LENGTH   1,
*        materialcomponentisclassified  TYPE c LENGTH   1,
*        materialcompisintramaterial    TYPE c LENGTH   1,
*        materialisdirectlyproduced     TYPE c LENGTH   1,
*        materialisdirectlyprocured     TYPE c LENGTH   1,
*        longtextlanguagecode           TYPE c LENGTH   1,
*        longtextexists                 TYPE c LENGTH   1,
*        requirementtype                TYPE c LENGTH   2,
*        salesorder                     TYPE c LENGTH   10,
*        salesorderitem                 TYPE c LENGTH   6,
*        wbselementinternalid           TYPE c LENGTH   8,
*        wbselementinternalid_2         TYPE c LENGTH   8,
*        productconfiguration           TYPE c LENGTH   18,
*        changenumber                   TYPE c LENGTH   12,
*        materialrevisionlevel          TYPE c LENGTH   2,
*        effectivityparametervariant    TYPE c LENGTH   12,
*        sortfield                      TYPE c LENGTH   10,
*        materialcomponentsorttext      TYPE c LENGTH   10,
*        objectinternalid               TYPE c LENGTH   22,
*        billofmaterialcategory         TYPE c LENGTH   1,
*        billofmaterialinternalid       TYPE c LENGTH   8,
*        billofmaterialinternalid_2     TYPE c LENGTH   8,
*        billofmaterialvariantusage     TYPE c LENGTH   1,
*        billofmaterialvariant          TYPE c LENGTH   2,
*        billofmaterial                 TYPE c LENGTH   8,
*        bomitem                        TYPE c LENGTH   8,
*        billofmaterialversion          TYPE c LENGTH   4,
*        bomiteminternalchangecount     TYPE c LENGTH   8,
*        inheritedbomitemnode           TYPE c LENGTH   8,
*        bomitemcategory                TYPE c LENGTH   1,
*        billofmaterialitemnumber       TYPE c LENGTH   4,
*        billofmaterialitemnumber_2     TYPE c LENGTH   4,
*        bomitemdescription             TYPE c LENGTH   40,
*        bomitemtext2                   TYPE c LENGTH   40,
*        bomexplosiondateid             TYPE c LENGTH   8,
*        purchasinginforecord           TYPE c LENGTH   10,
*        purchasinggroup                TYPE c LENGTH   3,
*        purchaserequisition            TYPE c LENGTH   10,
*        purchaserequisitionitem        TYPE c LENGTH   5,
*        purchaseorder                  TYPE c LENGTH   10,
*        purchaseorderitem              TYPE c LENGTH   5,
*        purchaseorderscheduleline      TYPE c LENGTH   4,
*        supplier                       TYPE c LENGTH   10,
*        deliverydurationindays         TYPE c LENGTH   3,
*        materialgoodsreceiptduration   TYPE c LENGTH   3,
*        externalprocessingprice        TYPE c LENGTH   15,
*        numberofoperationpriceunits    TYPE c LENGTH   5,
*        goodsmovementisallowed         TYPE c LENGTH   1,
*        storagelocation                TYPE c LENGTH   4,
*        debitcreditcode                TYPE c LENGTH   1,
*        goodsmovementtype              TYPE c LENGTH   3,
*        inventoryspecialstocktype      TYPE c LENGTH   1,
*        inventoryspecialstockvalntype  TYPE c LENGTH   1,
*        consumptionposting             TYPE c LENGTH   1,
*        supplyarea                     TYPE c LENGTH   10,
*        goodsrecipientname             TYPE c LENGTH   12,
*        unloadingpointname             TYPE c LENGTH   25,
*        stocksegment                   TYPE c LENGTH   40,
*        requirementsegment             TYPE c LENGTH   40,
*        batch                          TYPE c LENGTH   10,
*        batchentrydeterminationcode    TYPE c LENGTH   1,
*        batchsplittype                 TYPE c LENGTH   1,
*        batchmasterreservationitem     TYPE c LENGTH   4,
*        batchclassification            TYPE c LENGTH   18,
*        materialstaging                TYPE c LENGTH   1,
*        warehouse                      TYPE c LENGTH   3,
*        storagetype                    TYPE c LENGTH   3,
*        storagebin                     TYPE c LENGTH   10,
*        materialcompiscostrelevant     TYPE c LENGTH   1,
*        businessarea                   TYPE c LENGTH   4,
*        companycode                    TYPE c LENGTH   4,
*        glaccount                      TYPE c LENGTH   10,
*        functionalarea                 TYPE c LENGTH   16,
*        controllingarea                TYPE c LENGTH   4,
*        accountassignmentcategory      TYPE c LENGTH   1,
*        commitmentitem                 TYPE c LENGTH   14,
*        commitmentitemshortid          TYPE c LENGTH   14,
*        fundscenter                    TYPE c LENGTH   16,
*        materialcompisvariablesized    TYPE c LENGTH   1,
*        numberofvariablesizecomponents TYPE c LENGTH   13,
*        variablesizeitemunit           TYPE c LENGTH   3,
*        variablesizeitemquantity       TYPE c LENGTH   13,
*        variablesizecomponentunit      TYPE c LENGTH   3,
*        variablesizecomponentquantity  TYPE c LENGTH   13,
*        variablesizedimensionunit      TYPE c LENGTH   3,
*        variablesizedimension1         TYPE c LENGTH   13,
*        variablesizedimension2         TYPE c LENGTH   13,
*        variablesizedimension3         TYPE c LENGTH   13,
*        formulakey                     TYPE c LENGTH   2,
*        materialcompisalternativeitem  TYPE c LENGTH   1,
*        alternativeitemgroup           TYPE c LENGTH   2,
*        alternativeitemstrategy        TYPE c LENGTH   1,
*        alternativeitempriority        TYPE c LENGTH   2,
*        usageprobabilitypercent        TYPE c LENGTH   3,
*        alternativemstrreservationitem TYPE c LENGTH   4,
*        materialcomponentisphantomitem TYPE c LENGTH   1,
*        orderpathvalue                 TYPE c LENGTH   2,
*        orderlevelvalue                TYPE c LENGTH   2,
*        assembly                       TYPE c LENGTH   40,
*        assemblyorderpathvalue         TYPE c LENGTH   2,
*        assemblyorderlevelvalue        TYPE c LENGTH   2,
*        discontinuationgroup           TYPE c LENGTH   2,
*        matlcompdiscontinuationtype    TYPE c LENGTH   1,
*        matlcompisfollowupmaterial     TYPE c LENGTH   1,
*        followupgroup                  TYPE c LENGTH   2,
*        followupmaterial               TYPE c LENGTH   40,
*        followupmaterialisnotactive    TYPE c LENGTH   1,
*        followupmaterialisactive       TYPE c LENGTH   1,
*        discontinuationmasterresvnitem TYPE c LENGTH   4,
*        materialprovisiontype          TYPE c LENGTH   1,
*        matlcomponentspareparttype     TYPE c LENGTH   1,
*        leadtimeoffset                 TYPE c LENGTH   3,
*        operationleadtimeoffsetunit    TYPE c LENGTH   3,
*        operationleadtimeoffset        TYPE c LENGTH   3,
*        quantityisfixed                TYPE c LENGTH   1,
*        isnetscrap                     TYPE c LENGTH   1,
*        componentscrapinpercent        TYPE c LENGTH   5,
*        operationscrapinpercent        TYPE c LENGTH   5,
*        materialqtytobaseqtynmrtr      TYPE c LENGTH   5,
*        materialqtytobaseqtydnmntr     TYPE c LENGTH   5,
*        baseunit                       TYPE c LENGTH   3,
*        requiredquantity               TYPE c LENGTH   13,
*        withdrawnquantity              TYPE c LENGTH   13,
*        confirmedavailablequantity     TYPE c LENGTH   15,
*        materialcomporiginalquantity   TYPE c LENGTH   13,
*        entryunit                      TYPE c LENGTH   3,
*        goodsmovemententryqty          TYPE c LENGTH   13,
*        currency                       TYPE c LENGTH   5,
*        withdrawnquantityamount        TYPE c LENGTH   13,
*        criticalcomponenttype          TYPE c LENGTH   1,
*        criticalcomponentlevel         TYPE c LENGTH   2,

        reservation                    TYPE i_mfgorderoperationcomponent-reservation,
        reservationitem                TYPE i_mfgorderoperationcomponent-reservationitem,
        matlcompismarkedfordeletion    TYPE i_mfgorderoperationcomponent-matlcompismarkedfordeletion,
        material                       TYPE i_mfgorderoperationcomponent-material,
        plant                          TYPE i_mfgorderoperationcomponent-plant,
        storagelocation                TYPE i_mfgorderoperationcomponent-storagelocation,
        requiredquantity               TYPE i_mfgorderoperationcomponent-requiredquantity,
        baseunit                       TYPE i_mfgorderoperationcomponent-baseunit,
        withdrawnquantity              TYPE i_mfgorderoperationcomponent-withdrawnquantity,
        manufacturingorder             TYPE i_mfgorderoperationcomponent-manufacturingorder,
        assembly                       TYPE i_mfgorderoperationcomponent-assembly,
        bomitemcategory                TYPE i_mfgorderoperationcomponent-bomitemcategory,
        billofmaterialitemnumber_2     TYPE i_mfgorderoperationcomponent-billofmaterialitemnumber_2,
        bomitemdescription             TYPE i_mfgorderoperationcomponent-bomitemdescription,
        bomitemtext2                   TYPE i_mfgorderoperationcomponent-bomitemtext2,
        materialqtytobaseqtynmrtr      TYPE i_mfgorderoperationcomponent-materialqtytobaseqtynmrtr,
        materialqtytobaseqtydnmntr     TYPE i_mfgorderoperationcomponent-materialqtytobaseqtydnmntr,
        materialcomponentsorttext      TYPE i_mfgorderoperationcomponent-materialcomponentsorttext,
        matlcompismarkedforbackflush   TYPE i_mfgorderoperationcomponent-matlcompismarkedforbackflush,
        materialcomponentisphantomitem TYPE i_mfgorderoperationcomponent-materialcomponentisphantomitem,
        recordtype                     TYPE i_mfgorderoperationcomponent-recordtype,
        goodsmovementisallowed         TYPE i_mfgorderoperationcomponent-goodsmovementisallowed,
        reservationisfinallyissued     TYPE i_mfgorderoperationcomponent-reservationisfinallyissued,
        isbulkmaterialcomponent        TYPE i_mfgorderoperationcomponent-isbulkmaterialcomponent,
        "add by wang.z 20250207
        plannedorder                   TYPE i_manufacturingorderitem-plannedorder,
        "end add by wang.z 20250207

      END OF ty_resb,

      "N0.17 指図内作業.
      BEGIN OF ty_afvc,
        mfgorderinternalid            TYPE i_manufacturingorderoperation-mfgorderinternalid,
        orderintbillofopitemofphase   TYPE i_manufacturingorderoperation-orderintbillofopitemofphase,
        billofoperationsvariant       TYPE i_manufacturingorderoperation-billofoperationsvariant,
        manufacturingorderoperation_2 TYPE i_manufacturingorderoperation-manufacturingorderoperation_2,
        plant                         TYPE i_manufacturingorderoperation-plant,
        operationstandardtextcode     TYPE i_manufacturingorderoperation-operationstandardtextcode,
        mfgorderoperationtext         TYPE i_manufacturingorderoperation-mfgorderoperationtext,
        billofoperationssequence      TYPE i_manufacturingorderoperation-billofoperationssequence,
        standardworkformulaparamgroup TYPE i_manufacturingorderoperation-standardworkformulaparamgroup,
        costctractivitytype1          TYPE i_manufacturingorderoperation-costctractivitytype1,
        costctractivitytype2          TYPE i_manufacturingorderoperation-costctractivitytype2,
        costctractivitytype3          TYPE i_manufacturingorderoperation-costctractivitytype3,
        costctractivitytype4          TYPE i_manufacturingorderoperation-costctractivitytype4,
        costctractivitytype5          TYPE i_manufacturingorderoperation-costctractivitytype5,
        costctractivitytype6          TYPE i_manufacturingorderoperation-costctractivitytype6,
        supplier                      TYPE i_manufacturingorderoperation-supplier,
        costelement                   TYPE i_manufacturingorderoperation-costelement,
        purchasingorganization        TYPE i_manufacturingorderoperation-purchasingorganization,
        purchasinggroup               TYPE i_manufacturingorderoperation-purchasinggroup,
        materialgroup                 TYPE i_manufacturingorderoperation-materialgroup,
        purchaserequisition           TYPE i_manufacturingorderoperation-purchaserequisition,
        purchaserequisitionitem       TYPE i_manufacturingorderoperation-purchaserequisitionitem,
        billofmaterialcategory        TYPE i_manufacturingorderoperation-billofmaterialcategory,
        billofmaterialinternalid_2    TYPE i_manufacturingorderoperation-billofmaterialinternalid_2,
        billofmaterialitemnodenumber  TYPE i_manufacturingorderoperation-billofmaterialitemnodenumber,
        billofoperationsversion       TYPE i_manufacturingorderoperation-billofoperationsversion,

*        mfgorderinternalid             TYPE c LENGTH 10,
*        orderoperationinternalid       TYPE c LENGTH 8,
*        manufacturingorder             TYPE c LENGTH 12,
*        manufacturingordersequence     TYPE c LENGTH 6,
*        manufacturingorderoperation    TYPE c LENGTH 4,
*        manufacturingorderoperation_2  TYPE c LENGTH 4,
*        manufacturingordersuboperation TYPE c LENGTH 4,
*        manufacturingordsuboperation_2 TYPE c LENGTH 4,
*        mfgorderoperationorsubop       TYPE c LENGTH 4,
*        mfgorderoperationorsubop_2     TYPE c LENGTH 4,
*        mfgorderoperationisphase       TYPE c LENGTH 1,
*        orderintbillofopitemofphase    TYPE c LENGTH 8,
*        mfgorderphasesuperioroperation TYPE c LENGTH 4,
*        superioroperation_2            TYPE c LENGTH 4,
*        manufacturingordercategory     TYPE c LENGTH 2,
*        manufacturingordertype         TYPE c LENGTH 4,
*        productionsupervisor           TYPE c LENGTH 3,
*        mrpcontroller                  TYPE c LENGTH 3,
*        responsibleplannergroup        TYPE c LENGTH 3,
*        productconfiguration           TYPE c LENGTH 18,
*        inspectionlot                  TYPE c LENGTH 12,
*        manufacturingorderimportance   TYPE c LENGTH 1,
*        mfgorderoperationtext          TYPE c LENGTH 40,
*        operationstandardtextcode      TYPE c LENGTH 7,
*        operationhaslongtext           TYPE c LENGTH 1,
*        language                       TYPE c LENGTH 1,
*        operationistobedeleted         TYPE c LENGTH 1,
*        numberofcapacities             TYPE c LENGTH 3,
*        numberofconfirmationslips      TYPE c LENGTH 3,
*        operationimportance            TYPE c LENGTH 1,
*        superioroperationinternalid    TYPE c LENGTH 8,
*        plant                          TYPE c LENGTH 4,
*        workcenterinternalid           TYPE c LENGTH 8,
*        workcentertypecode             TYPE c LENGTH 1,
*
*        workcentertypecode_2           TYPE c LENGTH 2,
*        operationcontrolprofile        TYPE c LENGTH 4,
*        controlrecipedestination       TYPE c LENGTH 2,
*        operationconfirmation          TYPE c LENGTH 10,
*        numberofoperationconfirmations TYPE c LENGTH 8,
*        factorycalendar                TYPE c LENGTH 2,
*        capacityrequirement            TYPE c LENGTH 12,
*        capacityrequirementitem        TYPE c LENGTH 8,
*        changenumber                   TYPE c LENGTH 12,
*        objectinternalid               TYPE c LENGTH 22,
*        operationtrackingnumber        TYPE c LENGTH 10,
*        billofoperationstype           TYPE c LENGTH 1,
*        billofoperationsgroup          TYPE c LENGTH 8,
*        billofoperationsvariant        TYPE c LENGTH 2,
*        billofoperationssequence       TYPE c LENGTH 6,
*        boooperationinternalid         TYPE c LENGTH 8,
*        billofoperationsversion        TYPE c LENGTH 4,
*        billofmaterialcategory         TYPE c LENGTH 1,
*        billofmaterialinternalid       TYPE c LENGTH 8,
*        billofmaterialinternalid_2     TYPE c LENGTH 8,
*        billofmaterialitemnodenumber   TYPE c LENGTH 8,
*        bomitemnodecount               TYPE c LENGTH 8,
*        extprocgoperationhassubcontrg  TYPE c LENGTH 1,
*        purchasingorganization         TYPE c LENGTH 4,
*        purchasinggroup                TYPE c LENGTH 3,
*        purchaserequisition            TYPE c LENGTH 10,
*        purchaserequisitionitem        TYPE c LENGTH 5,
*        purchaseorder                  TYPE c LENGTH 10,
*        purchaseorderitem              TYPE c LENGTH 5,
*        purchasinginforecord           TYPE c LENGTH 10,
*        purginforecddataisfixed        TYPE c LENGTH 1,
*        purchasinginforecordcategory   TYPE c LENGTH 1,
*        supplier                       TYPE c LENGTH 10,
*        goodsrecipientname             TYPE c LENGTH 12,
*        unloadingpointname             TYPE c LENGTH 25,
*        materialgroup                  TYPE c LENGTH 9,
*        opexternalprocessingcurrency   TYPE c LENGTH 5,
*        opexternalprocessingprice      TYPE c LENGTH 11,
*        numberofoperationpriceunits    TYPE c LENGTH 5,
*        companycode                    TYPE c LENGTH 4,
*        businessarea                   TYPE c LENGTH 4,
*        controllingarea                TYPE c LENGTH 4,
*
*        profitcenter                   TYPE c LENGTH 10,
*        requestingcostcenter           TYPE c LENGTH 10,
*        costelement                    TYPE c LENGTH 10,
*        costingvariant                 TYPE c LENGTH 4,
*        costingsheet                   TYPE c LENGTH 6,
*        costestimate                   TYPE c LENGTH 12,
*        controllingobjectcurrency      TYPE c LENGTH 5,
*        controllingobjectclass         TYPE c LENGTH 2,
*        functionalarea                 TYPE c LENGTH 16,
*        taxjurisdiction                TYPE c LENGTH 15,
*        employeewagetype               TYPE c LENGTH 4,
*        employeewagegroup              TYPE c LENGTH 3,
*        employeesuitability            TYPE c LENGTH 2,
*        numberoftimetickets            TYPE c LENGTH 3,
*        personnel                      TYPE c LENGTH 8,
*        numberofemployees              TYPE c LENGTH 5,
*        operationsetupgroupcategory    TYPE c LENGTH 10,
*        operationsetupgroup            TYPE c LENGTH 10,
*        operationsetuptype             TYPE c LENGTH 2,
*        operationoverlappingisrequired TYPE c LENGTH 1,
*        operationoverlappingispossible TYPE c LENGTH 1,
*        operationsisalwaysoverlapping  TYPE c LENGTH 1,
*        operationsplitisrequired       TYPE c LENGTH 1,
*        maximumnumberofsplits          TYPE c LENGTH 3,
*        leadtimereductionstrategy      TYPE c LENGTH 2,
*        opschedldreductionlevel        TYPE c LENGTH 1,
*        operlstschedldexecstrtdte      TYPE c LENGTH 8,
*        operlstschedldexecstrttme      TYPE c LENGTH 6,
*        operlstschedldprocgstrtdte     TYPE c LENGTH 8,
*        operlstschedldprocgstrttme     TYPE c LENGTH 6,
*        operlstschedldtrdwnstrtdte     TYPE c LENGTH 8,
*        operlstschedldtrdwnstrttme     TYPE c LENGTH 6,
*        operlstschedldexecenddte       TYPE c LENGTH 8,
*        operlstschedldexecendtme       TYPE c LENGTH 6,
*        opltstschedldexecstrtdte       TYPE c LENGTH 8,
*        opltstschedldexecstrttme       TYPE c LENGTH 6,
*        opltstschedldprocgstrtdte      TYPE c LENGTH 8,
*        opltstschedldprocgstrttme      TYPE c LENGTH 6,
*        opltstschedldtrdwnstrtdte      TYPE c LENGTH 8,
*
*        opltstschedldtrdwnstrttme      TYPE c LENGTH 6,
*        opltstschedldexecenddte        TYPE c LENGTH 8,
*        opltstschedldexecendtme        TYPE c LENGTH 6,
*        schedldfcstdearlieststartdate  TYPE c LENGTH 8,
*        schedldfcstdearlieststarttime  TYPE c LENGTH 6,
*        schedldfcstdearliestenddate    TYPE c LENGTH 8,
*        schedldfcstdearliestendtime    TYPE c LENGTH 6,
*        latestschedldfcstdstartdate    TYPE c LENGTH 8,
*        schedldfcstdlateststarttime    TYPE c LENGTH 6,
*        latestschedldfcstdenddate      TYPE c LENGTH 8,
*        schedldfcstdlatestendtime      TYPE c LENGTH 6,
*        operationconfirmedstartdate    TYPE c LENGTH 8,
*        operationconfirmedenddate      TYPE c LENGTH 8,
*        opactualexecutionstartdate     TYPE c LENGTH 8,
*        opactualexecutionstarttime     TYPE c LENGTH 6,
*        opactualsetupenddate           TYPE c LENGTH 8,
*        opactualsetupendtime           TYPE c LENGTH 6,
*        opactualprocessingstartdate    TYPE c LENGTH 8,
*        opactualprocessingstarttime    TYPE c LENGTH 6,
*        opactualprocessingenddate      TYPE c LENGTH 8,
*        opactualprocessingendtime      TYPE c LENGTH 6,
*        opactualteardownstartdate      TYPE c LENGTH 8,
*        opactualteardownstarttme       TYPE c LENGTH 6,
*        opactualexecutionenddate       TYPE c LENGTH 8,
*        opactualexecutionendtime       TYPE c LENGTH 6,
*        actualforecastenddate          TYPE c LENGTH 8,
*        actualforecastendtime          TYPE c LENGTH 6,
*        earliestscheduledwaitstartdate TYPE c LENGTH 8,
*        earliestscheduledwaitstarttime TYPE c LENGTH 6,
*        earliestscheduledwaitenddate   TYPE c LENGTH 8,
*        earliestscheduledwaitendtime   TYPE c LENGTH 6,
*        latestscheduledwaitstartdate   TYPE c LENGTH 8,
*        latestscheduledwaitstarttime   TYPE c LENGTH 6,
*        latestscheduledwaitenddate     TYPE c LENGTH 8,
*        latestscheduledwaitendtime     TYPE c LENGTH 6,
*        breakdurationunit              TYPE c LENGTH 3,
*        plannedbreakduration           TYPE c LENGTH 9,
*        confirmedbreakduration         TYPE c LENGTH 9,
*        overlapminimumdurationunit     TYPE c LENGTH 3,
*        overlapminimumduration         TYPE c LENGTH 9,
*        maximumwaitdurationunit        TYPE c LENGTH 3,
*        maximumwaitduration            TYPE c LENGTH 9,
*        minimumwaitdurationunit        TYPE c LENGTH 3,
*        minimumwaitduration            TYPE c LENGTH 9,
*        standardmovedurationunit       TYPE c LENGTH 3,
*        standardmoveduration           TYPE c LENGTH 9,
*        standardqueuedurationunit      TYPE c LENGTH 3,
*
*        standardqueueduration          TYPE c LENGTH 9,
*        minimumqueuedurationunit       TYPE c LENGTH 3,
*        minimumqueueduration           TYPE c LENGTH 9,
*        minimummovedurationunit        TYPE c LENGTH 3,
*        minimummoveduration            TYPE c LENGTH 9,
*        operationstandardduration      TYPE c LENGTH 5,
*        operationstandarddurationunit  TYPE c LENGTH 3,
*        minimumduration                TYPE c LENGTH 5,
*        minimumdurationunit            TYPE c LENGTH 3,
*        minimumprocessingduration      TYPE c LENGTH 9,
*        minimumprocessingdurationunit  TYPE c LENGTH 3,
*        scheduledmoveduration          TYPE c LENGTH 16,
*        scheduledmovedurationunit      TYPE c LENGTH 3,
*        scheduledqueueduration         TYPE c LENGTH 16,
*        scheduledqueuedurationunit     TYPE c LENGTH 3,
*        scheduledwaitduration          TYPE c LENGTH 16,
*        scheduledwaitdurationunit      TYPE c LENGTH 3,
*        planneddeliveryduration        TYPE c LENGTH 3,
*        opplannedsetupdurn             TYPE c LENGTH 16,
*        opplannedsetupdurnunit         TYPE c LENGTH 3,
*        opplannedprocessingdurn        TYPE c LENGTH 16,
*        opplannedprocessingdurnunit    TYPE c LENGTH 3,
*        opplannedteardowndurn          TYPE c LENGTH 16,
*        opplannedteardowndurnunit      TYPE c LENGTH 3,
*        actualforecastduration         TYPE c LENGTH 5,
*        actualforecastdurationunit     TYPE c LENGTH 3,
*        forecastprocessingduration     TYPE c LENGTH 16,
*        forecastprocessingdurationunit TYPE c LENGTH 3,
*        startdateoffsetreferencecode   TYPE c LENGTH 2,
*        startdateoffsetdurationunit    TYPE c LENGTH 3,
*        startdateoffsetduration        TYPE c LENGTH 5,
*        enddateoffsetreferencecode     TYPE c LENGTH 2,
*        enddateoffsetdurationunit      TYPE c LENGTH 3,
*        enddateoffsetduration          TYPE c LENGTH 5,
*        standardworkformulaparamgroup  TYPE c LENGTH 4,
*        operationunit                  TYPE c LENGTH 3,
*        opqtytobaseqtydnmntr           TYPE c LENGTH 5,
*        opqtytobaseqtynmrtr            TYPE c LENGTH 5,
*        operationscrappercent          TYPE c LENGTH 5,
*        operationreferencequantity     TYPE c LENGTH 13,
*        opplannedtotalquantity         TYPE c LENGTH 13,
*        opplannedscrapquantity         TYPE c LENGTH 13,
*        opplannedyieldquantity         TYPE c LENGTH 14,
*        optotalconfirmedyieldqty       TYPE c LENGTH 13,
*
*        optotalconfirmedscrapqty       TYPE c LENGTH 13,
*        operationconfirmedreworkqty    TYPE c LENGTH 13,
*        productionunit                 TYPE c LENGTH 3,
*        optotconfdyieldqtyinordqtyunit TYPE c LENGTH 13,
*        opworkquantityunit1            TYPE c LENGTH 3,
*        opconfirmedworkquantity1       TYPE c LENGTH 13,
*        nofurtheropworkquantity1isexpd TYPE c LENGTH 1,
*        opworkquantityunit2            TYPE c LENGTH 3,
*        opconfirmedworkquantity2       TYPE c LENGTH 13,
*        nofurtheropworkquantity2isexpd TYPE c LENGTH 1,
*        opworkquantityunit3            TYPE c LENGTH 3,
*        opconfirmedworkquantity3       TYPE c LENGTH 13,
*        nofurtheropworkquantity3isexpd TYPE c LENGTH 1,
*        opworkquantityunit4            TYPE c LENGTH 3,
*        opconfirmedworkquantity4       TYPE c LENGTH 13,
*        nofurtheropworkquantity4isexpd TYPE c LENGTH 1,
*        opworkquantityunit5            TYPE c LENGTH 3,
*        opconfirmedworkquantity5       TYPE c LENGTH 13,
*        nofurtheropworkquantity5isexpd TYPE c LENGTH 1,
*        opworkquantityunit6            TYPE c LENGTH 3,
*        opconfirmedworkquantity6       TYPE c LENGTH 13,
*        nofurtheropworkquantity6isexpd TYPE c LENGTH 1,
*        workcenterstandardworkqtyunit1 TYPE c LENGTH 3,
*        workcenterstandardworkqty1     TYPE c LENGTH 9,
*        costctractivitytype1           TYPE c LENGTH 6,
*        workcenterstandardworkqtyunit2 TYPE c LENGTH 3,
*        workcenterstandardworkqty2     TYPE c LENGTH 9,
*        costctractivitytype2           TYPE c LENGTH 6,
*        workcenterstandardworkqtyunit3 TYPE c LENGTH 3,
*        workcenterstandardworkqty3     TYPE c LENGTH 9,
*        costctractivitytype3           TYPE c LENGTH 6,
*        workcenterstandardworkqtyunit4 TYPE c LENGTH 3,
*        workcenterstandardworkqty4     TYPE c LENGTH 9,
*        costctractivitytype4           TYPE c LENGTH 6,
*        workcenterstandardworkqtyunit5 TYPE c LENGTH 3,
*        workcenterstandardworkqty5     TYPE c LENGTH 9,
*        costctractivitytype5           TYPE c LENGTH 6,
*        workcenterstandardworkqtyunit6 TYPE c LENGTH 3,
*        workcenterstandardworkqty6     TYPE c LENGTH 9,
*        costctractivitytype6           TYPE c LENGTH 6,
*        forecastworkquantity1          TYPE c LENGTH 9,
*        forecastworkquantity2          TYPE c LENGTH 9,
*        forecastworkquantity3          TYPE c LENGTH 9,
*        forecastworkquantity4          TYPE c LENGTH 9,
*        forecastworkquantity5          TYPE c LENGTH 9,
*        forecastworkquantity6          TYPE c LENGTH 9,
*
*        businessprocess                TYPE c LENGTH 12,
*        businessprocessentryunit       TYPE c LENGTH 3,
*        businessprocessconfirmedqty    TYPE c LENGTH 13,
*        nofurtherbusinessprocqtyisexpd TYPE c LENGTH 1,
*        businessprocremainingqtyunit   TYPE c LENGTH 3,
*        businessprocessremainingqty    TYPE c LENGTH 13,
*        setupopactyntwkinstance        TYPE c LENGTH 10,
*        produceopactyntwkinstance      TYPE c LENGTH 10,
*        teardownopactyntwkinstance     TYPE c LENGTH 10,
*        freedefinedtablefieldsemantic  TYPE c LENGTH 7,
*        freedefinedattribute01         TYPE c LENGTH 20,
*        freedefinedattribute02         TYPE c LENGTH 20,
*        freedefinedattribute03         TYPE c LENGTH 10,
*        freedefinedattribute04         TYPE c LENGTH 10,
*        freedefinedquantity1unit       TYPE c LENGTH 3,
*        freedefinedquantity1           TYPE c LENGTH 13,
*        freedefinedquantity2unit       TYPE c LENGTH 3,
*        freedefinedquantity2           TYPE c LENGTH 13,
*        freedefinedamount1currency     TYPE c LENGTH 5,
*        freedefinedamount1             TYPE c LENGTH 13,
*        freedefinedamount2currency     TYPE c LENGTH 5,
*        freedefinedamount2             TYPE c LENGTH 13,
*        freedefineddate1               TYPE c LENGTH 8,
*        freedefineddate2               TYPE c LENGTH 8,
*        freedefinedindicator1          TYPE c LENGTH 1,
*        freedefinedindicator2          TYPE c LENGTH 1,

      END OF ty_afvc,

      BEGIN OF ty_mbew,
        product                       TYPE c LENGTH      40,
        valuationarea                 TYPE c LENGTH      4,
        valuationtype                 TYPE c LENGTH      10,
        valuationclass                TYPE c LENGTH      4,
        pricedeterminationcontrol     TYPE c LENGTH      1,
        fiscalmonthcurrentperiod      TYPE c LENGTH      2,
        fiscalyearcurrentperiod       TYPE c LENGTH      4,
        standardprice                 TYPE c LENGTH      11,
        priceunitqty                  TYPE c LENGTH      5,
        inventoryvaluationprocedure   TYPE c LENGTH      1,
        futurepricevaliditystartdate  TYPE c LENGTH      8,
        previnvtrypriceincocodecrcy   TYPE c LENGTH      11,
        movingaverageprice            TYPE c LENGTH      11,
        valuationcategory             TYPE c LENGTH      1,
        productusagetype              TYPE c LENGTH      1,
        productorigintype             TYPE c LENGTH      1,
        isproducedinhouse             TYPE c LENGTH      1,
        prodcostestnumber             TYPE c LENGTH      12,
        ismarkedfordeletion           TYPE c LENGTH      1,
        valuationmargin               TYPE c LENGTH      6,
        isactiveentity                TYPE c LENGTH      1,
        companycode                   TYPE c LENGTH      4,
        valuationclasssalesorderstock TYPE c LENGTH      4,
        projectstockvaluationclass    TYPE c LENGTH      4,
        taxbasedpricespriceunitqty    TYPE c LENGTH      5,
        pricelastchangedate           TYPE c LENGTH      8,
        futureprice                   TYPE c LENGTH      11,
        maintenancestatus             TYPE c LENGTH      15,
        currency                      TYPE c LENGTH      5,
        baseunit                      TYPE c LENGTH      3,
        mlisactiveatproductlevel      TYPE c LENGTH      1,
      END OF ty_mbew.

    "传入参数（表名）
    TYPES:
      BEGIN OF ty_inputs,
        tablename TYPE c LENGTH 10,
        sql       TYPE string,
      END OF ty_inputs,

      "EKKO   購買発注
      BEGIN OF ty_output_ekko,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_ekko WITH EMPTY KEY,

      END OF ty_output_ekko,

      "EKPO   購買発注明細
      BEGIN OF ty_output_ekpo,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_ekpo WITH EMPTY KEY,

      END OF ty_output_ekpo,

      "EKET   納入日程行
      BEGIN OF ty_output_eket,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_eket WITH EMPTY KEY,

      END OF ty_output_eket,

      "EKBE 購買発注履歴
      BEGIN OF ty_output_ekbe,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_ekbe WITH EMPTY KEY,

      END OF ty_output_ekbe,

      "EKKN 購買発注の勘定設定
      BEGIN OF ty_output_ekkn,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_ekkn WITH EMPTY KEY,

      END OF ty_output_ekkn,

      "MARA 製品
      BEGIN OF ty_output_mara,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_mara WITH EMPTY KEY,

      END OF ty_output_mara,

      "MAKT 製品テキスト
      BEGIN OF ty_output_makt,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_makt WITH EMPTY KEY,

      END OF ty_output_makt,

      "MARD 製品保管場所
      BEGIN OF ty_output_mard,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_mard WITH EMPTY KEY,

      END OF ty_output_mard,

      "T024D MRP 管理者
      BEGIN OF ty_output_t024d,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_t024d WITH EMPTY KEY,

      END OF ty_output_t024d,

      "T001L 保管場所
      BEGIN OF ty_output_t001l,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_t001l WITH EMPTY KEY,

      END OF ty_output_t001l,

      "MARC 製品プラント
      BEGIN OF ty_output_marc,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_marc WITH EMPTY KEY,

      END OF ty_output_marc,

      "MKAL 製造バージョン
      BEGIN OF ty_output_mkal,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_mkal WITH EMPTY KEY,

      END OF ty_output_mkal,

      "AFKO 製造指図
      BEGIN OF ty_output_afko,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_afko WITH EMPTY KEY,

      END OF ty_output_afko,

      "AFPO 製造指図明細
      BEGIN OF ty_output_afpo,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_afpo WITH EMPTY KEY,

      END OF ty_output_afpo,

      "PLPO 品質検査計画作業のバージョン
      BEGIN OF ty_output_plpo,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_plpo WITH EMPTY KEY,

      END OF ty_output_plpo,

      "RESB 入出庫予定伝票明細
      BEGIN OF ty_output_resb,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_resb WITH EMPTY KEY,

      END OF ty_output_resb,

      "AFVC 指図内作業
      BEGIN OF ty_output_afvc,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_afvc WITH EMPTY KEY,

      END OF ty_output_afvc,

      "MBEW製品評価
      BEGIN OF ty_output_mbew,
        message TYPE string,
        items   TYPE STANDARD TABLE OF ty_mbew WITH EMPTY KEY,

      END OF ty_output_mbew,

*&--ADD BEGIN BY XINLEI XU 2025/02/17
      "MARM単位換算マスタ
      BEGIN OF ty_output_marm,
        message TYPE string,
        items   TYPE STANDARD TABLE OF i_productunitsofmeasure WITH EMPTY KEY,
      END OF ty_output_marm.
*&--ADD END BY XINLEI XU 2025/02/17

    INTERFACES if_http_service_extension .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA:
      "lt_req            TYPE tt_header,
      lt_req            TYPE tt_item,
      ls_req            TYPE ty_inputs,
      lr_ebeln          TYPE RANGE OF ebeln,
      lrs_ebeln         LIKE LINE OF lr_ebeln,
      lv_tablename(10)  TYPE c,
      lv_error(1)       TYPE c,
      lv_error1(1)      TYPE c,
      lv_error400(1)    TYPE c,
      lv_error404(1)    TYPE c,

      lv_text           TYPE string,
      lc_header_content TYPE string VALUE 'content-type',
      lc_content_type   TYPE string VALUE 'text/json',
      lv_where          TYPE string.
    DATA:
      lv_start_time TYPE sy-uzeit,
      lv_start_date TYPE sy-datum,
      lv_end_time   TYPE sy-uzeit,
      lv_end_date   TYPE sy-datum,
      lv_temp(14)   TYPE c,
      lv_starttime  TYPE p LENGTH 16 DECIMALS 0,
      lv_endtime    TYPE p LENGTH 16 DECIMALS 0,
      lv_count      TYPE i.

ENDCLASS.



CLASS zcl_http_podata_002 IMPLEMENTATION.


  METHOD if_http_service_extension~handle_request.
    "读取表名
    DATA(lv_req_body) = request->get_text( ).

    DATA(lv_header) = request->get_header_field( i_name = 'form' ).

    IF lv_header = 'XML'.

    ELSE.
*    将读取到的表名作为参数后面用
      IF lv_req_body IS NOT INITIAL.
        xco_cp_json=>data->from_string( lv_req_body )->apply( VALUE #(
            ( xco_cp_json=>transformation->underscore_to_pascal_case )
        ) )->write_to( REF #( ls_req ) ).
      ENDIF.
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
      es_response_marm  TYPE ty_output_marm, " ADD BY XINLEI XU 2025/02/17
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
      es_mbew           TYPE ty_mbew,
      es_marm           TYPE i_productunitsofmeasure. " ADD BY XINLEI XU 2025/02/17

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

        DATA:lv_error_message_ekko TYPE string.


        TRY.

            SELECT * FROM i_purchaseorderapi01 WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_ekko).

          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_ekko).
            lv_error400 = 'X'.
            lv_error_message_ekko = lo_sql_error_ekko->get_text( ).
            lv_text = lv_error_message_ekko.
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.

        ENDIF.

      WHEN `EKPO` OR 'ekpo'.

        DATA: lv_error_message_ekpo TYPE string.

        TRY.

            SELECT * FROM i_purchaseorderitemapi01 WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_ekpo).

          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_ekpo).
            lv_error400 = 'X'.
            lv_error_message_ekpo = lo_sql_error_ekpo->get_text( ).
            lv_text = lv_error_message_ekpo.
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN `EKET` OR 'eket'.
        DATA:lv_error_message_eket TYPE string.
        TRY.
            SELECT * FROM i_purordschedulelineapi01 WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_eket).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_eket).
            lv_error400 = 'X'.
            lv_error_message_eket = lo_sql_error_eket->get_text( ).
            lv_text = lv_error_message_eket.
        ENDTRY.


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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'EKBE'  OR 'ekbe' .
        DATA:lv_error_message_ekbe TYPE string.
        TRY.
            SELECT * FROM i_purchaseorderhistoryapi01 WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_ekbe).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_ekbe).
            lv_error400 = 'X'.
            lv_error_message_ekbe = lo_sql_error_ekbe->get_text( ).
            lv_text = lv_error_message_ekbe.
        ENDTRY.

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'EKKN'  OR 'ekkn' .
        DATA:lv_error_message_ekkn TYPE string.
        TRY.
            SELECT * FROM i_purordaccountassignmentapi01 WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_ekkn).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_ekkn).
            lv_error400 = 'X'.
            lv_error_message_ekkn = lo_sql_error_ekkn->get_text( ).
            lv_text = lv_error_message_ekkn.
        ENDTRY.

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'MARA'  OR 'mara' .
        DATA:lv_error_message_mara TYPE string.
        TRY.
            SELECT i_product~product,
                    i_product~creationdate,
                    i_product~ismarkedfordeletion,
                    i_product~producttype,
                    i_product~productgroup,
                    i_product~productoldid,
                    i_product~baseunit,
                    i_product~purchaseorderquantityunit,
                    i_product~productdocumentversion,
                    i_product~productdocumentchangenumber,
                    i_product~productionorinspectionmemotxt,
                    i_product~sizeordimensiontext,
                    i_product~laboratoryordesignoffice,
                    i_product~grossweight,
                    i_product~netweight,
                    i_product~weightunit,
                    i_product~transportationgroup,
                    i_product~division,
                    i_product~isbatchmanagementrequired,
                    i_productsales~packagingmaterialtype,
                    i_product~packagingmaterialgroup,
                    i_product~externalproductgroup,
                    i_product~productmanufacturernumber,
                    i_product~manufacturernumber,
                    i_product~yy1_bpcode_prd_prd,
                    i_product~yy1_customermaterial_prd
            FROM i_product WITH PRIVILEGED ACCESS
            LEFT JOIN i_productsales WITH PRIVILEGED ACCESS
            ON i_product~product = i_productsales~product
            "comment by w.z 20250402
*            WHERE (lv_where)
            "end comment

            INTO TABLE @DATA(lt_maraall).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_mara).
            lv_error400 = 'X'.
            lv_error_message_mara = lo_sql_error_mara->get_text( ).
            lv_text = lv_error_message_mara.
        ENDTRY.

        TRY.
            SELECT *
            FROM @lt_maraall AS a
            WHERE (lv_where)
            INTO TABLE @DATA(lt_mara).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_maraall).
            lv_error400 = 'X'.
            lv_error_message_mara = lo_sql_error_mara->get_text( ).
            lv_text = lv_error_message_mara.
        ENDTRY.

        IF lt_mara IS NOT INITIAL.
          LOOP AT lt_mara INTO DATA(ls_mara).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_mara TO es_mara.

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'MAKT'  OR 'makt' .
        DATA:lv_error_message_makt TYPE string.
        TRY.
            SELECT * FROM i_producttext WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_makt).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_makt).
            lv_error400 = 'X'.
            lv_error_message_makt = lo_sql_error_makt->get_text( ).
            lv_text = lv_error_message_makt.
        ENDTRY.

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'MARD'  OR 'mard' .
        DATA:
          lv_error_message TYPE string,                   " 错误信息
          lv_sql_statement TYPE string,                   " SQL 语句
          lt_mardbase      TYPE STANDARD TABLE OF ty_mard.

        TRY.
            SELECT     material,
                       plant,
                       storagelocation,
                       inventorystocktype,
                       inventoryspecialstocktype,
                       SUM( matlwrhsstkqtyinmatlbaseunit ) AS unit

            FROM i_materialstock_2 WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            GROUP BY material, plant, storagelocation, inventorystocktype, inventoryspecialstocktype
            INTO TABLE @DATA(lt_mard).

          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_mard).
            lv_error400 = 'X'.
            lv_error_message = lo_sql_error_mard->get_text( ).
            lv_text = lv_error_message.
        ENDTRY.

        IF lt_mard IS NOT INITIAL.

          DATA(lt_mard1) = lt_mard .

          SORT lt_mard1 BY material plant storagelocation.
          DELETE ADJACENT DUPLICATES FROM lt_mard1 COMPARING material plant storagelocation.

          MOVE-CORRESPONDING lt_mard1 TO lt_mardbase.

          LOOP AT lt_mardbase ASSIGNING FIELD-SYMBOL(<fs_mardbase>).

            LOOP AT lt_mard INTO DATA(lw_mard) WHERE material = <fs_mardbase>-material
                                               AND   plant = <fs_mardbase>-plant
                                               AND   storagelocation = <fs_mardbase>-storagelocation.

              CASE lw_mard-inventorystocktype.
*
                WHEN '01'.

                  IF lw_mard-inventoryspecialstocktype = 'K'.

                    <fs_mardbase>-klabs = lw_mard-unit.

                  ELSEIF lw_mard-inventoryspecialstocktype = ''.

                    <fs_mardbase>-labst = lw_mard-unit..
                  ENDIF.

                WHEN '02'.

                  IF lw_mard-inventoryspecialstocktype = 'K'.

                    <fs_mardbase>-kinsm = lw_mard-unit.

                  ELSEIF lw_mard-inventoryspecialstocktype = ''.

                    <fs_mardbase>-insme = lw_mard-unit.

                  ENDIF.

                WHEN OTHERS.

              ENDCASE.
            ENDLOOP.
          ENDLOOP.
        ENDIF.

        IF lt_mardbase IS NOT INITIAL.
          LOOP AT lt_mardbase INTO DATA(ls_mard1).
            lv_count = lv_count + 1.
            es_mard-material                           = ls_mard1-material                              .
            es_mard-plant                              = ls_mard1-plant                                .
            es_mard-storagelocation                    = ls_mard1-storagelocation                      .
            es_mard-klabs                              = ls_mard1-klabs.
            es_mard-labst                              = ls_mard1-labst.
            es_mard-kinsm                              = ls_mard1-kinsm.
            es_mard-insme                              = ls_mard1-insme.
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'T024D' OR 't024d'.
        DATA: lv_error_message_t024d TYPE string.

        TRY.
            SELECT *
              FROM i_mrpcontroller WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_t024d).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_t024d).
            lv_error400 = 'X'.
            lv_error_message_t024d = lo_sql_error_t024d->get_text( ).
            lv_text = lv_error_message_t024d.
        ENDTRY.

        IF lt_t024d IS NOT INITIAL.
          LOOP AT lt_t024d INTO DATA(ls_t024d).
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'T001L' OR 't001l'.
        DATA: lv_error_message_t001l TYPE string.

        TRY.
            SELECT *
              FROM i_storagelocation WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_t001l).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_t001l).
            lv_error400 = 'X'.
            lv_error_message_t001l = lo_sql_error_t001l->get_text( ).
            lv_text = lv_error_message_t001l.
        ENDTRY.

        IF lt_t001l IS NOT INITIAL.
          LOOP AT lt_t001l INTO DATA(ls_t001l).
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'MARC'  OR 'marc' .
        DATA: lv_error_message_marc TYPE string.

        TRY.
            SELECT i_productplantbasic~product,
                    i_productplantbasic~plant,
                    i_productplantbasic~ismarkedfordeletion,
                    i_productplantbasic~profilecode,
                    i_productplantbasic~productiscriticalprt,
                    i_productplantbasic~purchasinggroup,
                    i_productplantbasic~goodsissueunit,
                    i_productplantbasic~mrptype,
                    i_productplantbasic~mrpresponsible,
                    i_productplantbasic~planneddeliverydurationindays,
                    i_productplantbasic~goodsreceiptduration,
                    i_productplantbasic~procurementtype,
                    i_productplantbasic~specialprocurementtype,
                    i_productplantbasic~safetystockquantity,
                    i_productplantbasic~minimumlotsizequantity,
                    i_productplantbasic~maximumlotsizequantity,
                    i_productplantbasic~fixedlotsizequantity,
                    i_productplantbasic~productionsupervisor,
                    i_productplantbasic~hasposttoinspectionstock,
                    i_productplantbasic~isbatchmanagementrequired,
                    i_productplantbasic~availabilitychecktype,
                    i_productplantbasic~profitcenter,
                    i_productplantbasic~productioninvtrymanagedloc,

*                   \_GoodsMovementQuantity-productproductionquantityunit,
*                   \_GoodsMovementQuantity-productionschedulingprofile,
                   i_productworkscheduling~productproductionquantityunit,
                   i_productworkscheduling~productionschedulingprofile,
*                   i_productplantsupplyplanning~*,
                   i_productplantsupplyplanning~mrpplanningcalendar,
                   i_productplantsupplyplanning~planningtimefence,
                   i_productplantsupplyplanning~prodrqmtsconsumptionmode,
                   i_productplantsupplyplanning~backwardcnsmpnperiodinworkdays,
                   i_productplantsupplyplanning~fwdconsumptionperiodinworkdays,
                   i_productplantsales~loadinggroup,
                   i_productplantprocurement~isautopurordcreationallowed,
                   i_productplantprocurement~issourcelistrequired,
                   i_productplantcosting~costinglotsize,
                   i_productplantcosting~productiscostingrelevant

            FROM i_productplantbasic WITH PRIVILEGED ACCESS

            ##SELECT_WITH_PRIVILEGED_ACCESS[_GOODSMOVEMENTQUANTITY]


            LEFT JOIN i_productworkscheduling WITH PRIVILEGED ACCESS
              ON i_productplantbasic~product = i_productworkscheduling~product
             AND i_productplantbasic~plant = i_productworkscheduling~plant
            LEFT JOIN i_productplantsupplyplanning WITH PRIVILEGED ACCESS
              ON i_productplantbasic~product = i_productplantsupplyplanning~product
             AND i_productplantbasic~plant = i_productplantsupplyplanning~plant
            LEFT JOIN i_productplantsales WITH PRIVILEGED ACCESS
              ON i_productplantbasic~product = i_productplantsales~product
             AND i_productplantbasic~plant = i_productplantsales~plant
            LEFT JOIN i_productplantprocurement WITH PRIVILEGED ACCESS
              ON i_productplantbasic~product = i_productplantprocurement~product
             AND i_productplantbasic~plant = i_productplantprocurement~plant
            LEFT JOIN i_productplantcosting WITH PRIVILEGED ACCESS
              ON i_productplantbasic~product = i_productplantcosting~product
             AND i_productplantbasic~plant = i_productplantcosting~plant

            "comment by wz 20250402
*            WHERE (lv_where)
            "end comment
*            where i_productplantbasic~product = 'ZTEST_FG001'

            INTO TABLE @DATA(lt_marcall).

          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_marc).
            lv_error400 = 'X'.
            lv_error_message_marc = lo_sql_error_marc->get_text( ).
            lv_text = lv_error_message_marc.
        ENDTRY.

        TRY.
            SELECT *
              FROM @lt_marcall AS a
             WHERE (lv_where)
              INTO TABLE @DATA(lt_marc).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_marcall).
            lv_error400 = 'X'.
            lv_error_message_marc = lo_sql_error_marc->get_text( ).
            lv_text = lv_error_message_marc.
        ENDTRY.

        IF lt_marc IS NOT INITIAL.
          LOOP AT lt_marc INTO DATA(ls_marc).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_marc TO es_marc.
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'MKAL'  OR 'mkal' .
        DATA: lv_error_message_mkal TYPE string.

        TRY.
            SELECT *
              FROM i_productionversion WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_mkal).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_mkal).
            lv_error400 = 'X'.
            lv_error_message_mkal = lo_sql_error_mkal->get_text( ).
            lv_text = lv_error_message_mkal.
        ENDTRY.

        IF lt_mkal IS NOT INITIAL.
          LOOP AT lt_mkal INTO DATA(ls_mkal).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_mkal TO es_mkal.

*            es_mkal-material                                        = ls_mkal-material                           .
*            es_mkal-plant                                           = ls_mkal-plant                              .
*            es_mkal-productionversion                               = ls_mkal-productionversion                  .
*            es_mkal-productionversiontext                           = ls_mkal-productionversiontext              .
*            es_mkal-changehistorycount                              = ls_mkal-changehistorycount                 .
*            es_mkal-changenumber                                    = ls_mkal-changenumber                       .
*            es_mkal-creationdate                                    = ls_mkal-creationdate                       .
*            es_mkal-createdbyuser                                   = ls_mkal-createdbyuser                      .
*            es_mkal-lastchangedate                                  = ls_mkal-lastchangedate                     .
*            es_mkal-lastchangedbyuser                               = ls_mkal-lastchangedbyuser                  .
*            es_mkal-billofoperationstype                            = ls_mkal-billofoperationstype               .
*            es_mkal-billofoperationsgroup                           = ls_mkal-billofoperationsgroup              .
*            es_mkal-billofoperationsvariant                         = ls_mkal-billofoperationsvariant            .
*            es_mkal-billofmaterialvariantusage                      = ls_mkal-billofmaterialvariantusage         .
*            es_mkal-billofmaterialvariant                           = ls_mkal-billofmaterialvariant              .
*            es_mkal-productionline                                  = ls_mkal-productionline                     .
*            es_mkal-productionsupplyarea                            = ls_mkal-productionsupplyarea               .
*            es_mkal-productionversiongroup                          = ls_mkal-productionversiongroup             .
*            es_mkal-mainproduct                                     = ls_mkal-mainproduct                        .
*            es_mkal-materialcostapportionmentstruc                  = ls_mkal-materialcostapportionmentstruc     .
*            es_mkal-issuingstoragelocation                          = ls_mkal-issuingstoragelocation             .
*            es_mkal-receivingstoragelocation                        = ls_mkal-receivingstoragelocation           .
*            es_mkal-originalbatchreferencematerial                  = ls_mkal-originalbatchreferencematerial     .
*            es_mkal-quantitydistributionkey                         = ls_mkal-quantitydistributionkey            .
*            es_mkal-productionversionstatus                         = ls_mkal-productionversionstatus            .
*            es_mkal-productionversionlastcheckdate                  = ls_mkal-productionversionlastcheckdate     .
*            es_mkal-ratebasedplanningstatus                         = ls_mkal-ratebasedplanningstatus            .
*            es_mkal-preliminaryplanningstatus                       = ls_mkal-preliminaryplanningstatus          .
*            es_mkal-bomcheckstatus                                  = ls_mkal-bomcheckstatus                     .
*            es_mkal-validitystartdate                               = ls_mkal-validitystartdate                  .
*            es_mkal-validityenddate                                 = ls_mkal-validityenddate                    .
*            es_mkal-productionversionislocked                       = ls_mkal-productionversionislocked          .
*            es_mkal-prodnversisallowedforrptvmfg                    = ls_mkal-prodnversisallowedforrptvmfg       .
*            es_mkal-hasversionctrldbomandrouting                    = ls_mkal-hasversionctrldbomandrouting       .
*            es_mkal-planningandexecutionbomisdiff                   = ls_mkal-planningandexecutionbomisdiff      .
*            es_mkal-execbillofmaterialvariantusage                  = ls_mkal-execbillofmaterialvariantusage     .
*            es_mkal-execbillofmaterialvariant                       = ls_mkal-execbillofmaterialvariant          .
*            es_mkal-execbillofoperationstype                        = ls_mkal-execbillofoperationstype           .
*            es_mkal-execbillofoperationsgroup                       = ls_mkal-execbillofoperationsgroup          .
*            es_mkal-execbillofoperationsvariant                     = ls_mkal-execbillofoperationsvariant        .
*            es_mkal-warehouse                                       = ls_mkal-warehouse                          .
*            es_mkal-destinationstoragebin                           = ls_mkal-destinationstoragebin              .
*            es_mkal-procurementtype                                 = ls_mkal-procurementtype                    .
*            es_mkal-materialprocurementprofile                      = ls_mkal-materialprocurementprofile         .
*            es_mkal-usgeprobltywthversctrlinpct                     = ls_mkal-usgeprobltywthversctrlinpct        .
*            es_mkal-materialbaseunit                                = ls_mkal-materialbaseunit                   .
*            es_mkal-materialminlotsizequantity                      = ls_mkal-materialminlotsizequantity         .
*            es_mkal-materialmaxlotsizequantity                      = ls_mkal-materialmaxlotsizequantity         .
*            es_mkal-costinglotsize                                  = ls_mkal-costinglotsize                     .
*            es_mkal-distributionkey                                 = ls_mkal-distributionkey                    .
*            es_mkal-targetproductionsupplyarea                      = ls_mkal-targetproductionsupplyarea         .

*            CONDENSE es_mkal-material                              .
*            CONDENSE es_mkal-plant                                 .
*            CONDENSE es_mkal-productionversion                     .
*            CONDENSE es_mkal-productionversiontext                 .
*            CONDENSE es_mkal-changehistorycount                    .
*            CONDENSE es_mkal-changenumber                          .
*            CONDENSE es_mkal-creationdate                          .
*            CONDENSE es_mkal-createdbyuser                         .
*            CONDENSE es_mkal-lastchangedate                        .
*            CONDENSE es_mkal-lastchangedbyuser                     .
*            CONDENSE es_mkal-billofoperationstype                  .
*            CONDENSE es_mkal-billofoperationsgroup                 .
*            CONDENSE es_mkal-billofoperationsvariant               .
*            CONDENSE es_mkal-billofmaterialvariantusage            .
*            CONDENSE es_mkal-billofmaterialvariant                 .
*            CONDENSE es_mkal-productionline                        .
*            CONDENSE es_mkal-productionsupplyarea                  .
*            CONDENSE es_mkal-productionversiongroup                .
*            CONDENSE es_mkal-mainproduct                           .
*            CONDENSE es_mkal-materialcostapportionmentstruc        .
*            CONDENSE es_mkal-issuingstoragelocation                .
*            CONDENSE es_mkal-receivingstoragelocation              .
*            CONDENSE es_mkal-originalbatchreferencematerial        .
*            CONDENSE es_mkal-quantitydistributionkey               .
*            CONDENSE es_mkal-productionversionstatus               .
*            CONDENSE es_mkal-productionversionlastcheckdate        .
*            CONDENSE es_mkal-ratebasedplanningstatus               .
*            CONDENSE es_mkal-preliminaryplanningstatus             .
*            CONDENSE es_mkal-bomcheckstatus                        .
*            CONDENSE es_mkal-validitystartdate                     .
*            CONDENSE es_mkal-validityenddate                       .
*            CONDENSE es_mkal-productionversionislocked             .
*            CONDENSE es_mkal-prodnversisallowedforrptvmfg          .
*            CONDENSE es_mkal-hasversionctrldbomandrouting          .
*            CONDENSE es_mkal-planningandexecutionbomisdiff         .
*            CONDENSE es_mkal-execbillofmaterialvariantusage        .
*            CONDENSE es_mkal-execbillofmaterialvariant             .
*            CONDENSE es_mkal-execbillofoperationstype              .
*            CONDENSE es_mkal-execbillofoperationsgroup             .
*            CONDENSE es_mkal-execbillofoperationsvariant           .
*            CONDENSE es_mkal-warehouse                             .
*            CONDENSE es_mkal-destinationstoragebin                 .
*            CONDENSE es_mkal-procurementtype                       .
*            CONDENSE es_mkal-materialprocurementprofile            .
*            CONDENSE es_mkal-usgeprobltywthversctrlinpct           .
*            CONDENSE es_mkal-materialbaseunit                      .
*            CONDENSE es_mkal-materialminlotsizequantity            .
*            CONDENSE es_mkal-materialmaxlotsizequantity            .
*            CONDENSE es_mkal-costinglotsize                        .
*            CONDENSE es_mkal-distributionkey                       .
*            CONDENSE es_mkal-targetproductionsupplyarea            .
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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'AFKO'  OR 'afko' .
        DATA: lv_error_message_afko TYPE string.

        TRY.
            SELECT   *
*                    i_manufacturingorder~manufacturingorder,
*                    i_manufacturingorder~mfgorderplannedenddate,
*                    i_manufacturingorder~mfgorderplannedstartdate,
*                    i_manufacturingorder~mfgorderscheduledstartdate,
*                    i_manufacturingorder~mfgorderscheduledenddate,
*                    i_manufacturingorder~mfgorderactualstartdate,
*                    i_manufacturingorder~mfgorderitemactualdeliverydate AS mfgorderactualenddate,
*                    i_manufacturingorder~mfgorderitemactualdeliverydate,
*                    i_manufacturingorder~mfgorderplannedtotalqty,
*                    i_manufacturingorder~productionunit,
*                    i_manufacturingorder~material,
*                    i_manufacturingorder~billofoperationsgroup AS billofoperations,
*                    i_manufacturingorder~boovaliditystartdate,
*                    i_manufacturingorder~billofoperationsmaterial,
*                    i_billofmaterialheaderdex_2~billofmaterialstatus,
*                    i_billofmaterialheaderdex_2~bomheaderquantityinbaseunit,
*                    i_billofmaterialheaderdex_2~bomheaderbaseunit,
*                    i_manufacturingorder~billofmaterialvariant,
*                    i_manufacturingorder~billofmaterialvariantusage,
*                    i_manufacturingorder~mrpcontroller,
*                    i_manufacturingorder~mfgorderinternalid,
*                    i_manufacturingorder~productionsupervisor,
*                    i_manufacturingorder~manufacturingorderitem,
*                    i_manufacturingorder~superiororder,
*                    i_manufacturingorder~mfgorderispartofcollvorder,
*                    i_manufacturingorder~leadingorder,
*                    i_manufacturingorder~reservation
              FROM i_manufacturingorder WITH PRIVILEGED ACCESS

*              LEFT JOIN i_billofmaterialheaderdex_2 WITH PRIVILEGED ACCESS
*                ON i_manufacturingorder~billofmaterialcategory = i_billofmaterialheaderdex_2~billofmaterialcategory
*             " and i_manufacturingorder~BillOfMaterial = i_billofmaterialheaderdex_2~BillOfMaterial
*               AND i_manufacturingorder~billofmaterialinternalid = i_billofmaterialheaderdex_2~billofmaterial
*               AND i_manufacturingorder~billofmaterialvariant = i_billofmaterialheaderdex_2~billofmaterialvariant
*               AND i_manufacturingorder~billofmaterialvariantusage = i_billofmaterialheaderdex_2~billofmaterialvariantusage
            "comment by wz 20250403
            WHERE (lv_where)
            INTO TABLE @DATA(lt_afkoall).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_afko).
            lv_error400 = 'X'.
            lv_error_message_afko = lo_sql_error_afko->get_text( ).
            lv_text = lv_error_message_afko.
        ENDTRY.

        IF lt_afkoall IS NOT INITIAL.

          DATA(lt_afkoall_tmp) = lt_afkoall.
          SORT lt_afkoall_tmp BY billofmaterialcategory billofmaterialinternalid billofmaterialvariant billofmaterialvariantusage.
          DELETE ADJACENT DUPLICATES FROM lt_afkoall_tmp COMPARING billofmaterialcategory billofmaterialinternalid billofmaterialvariant billofmaterialvariantusage.

          TRY.
              SELECT billofmaterialcategory,
                     billofmaterial,
                     billofmaterialvariant,
                     billofmaterialvariantusage,
                     billofmaterialstatus,
                     bomheaderquantityinbaseunit,
                     bomheaderbaseunit
                FROM i_billofmaterialheaderdex_2
                FOR ALL ENTRIES IN @lt_afkoall_tmp
                WHERE billofmaterialcategory = @lt_afkoall_tmp-billofmaterialcategory
                  AND billofmaterial = @lt_afkoall_tmp-billofmaterialinternalid
                  AND billofmaterialvariant = @lt_afkoall_tmp-billofmaterialvariant
                  AND billofmaterialvariantusage = @lt_afkoall_tmp-billofmaterialvariantusage
                INTO TABLE @DATA(lt_afko_2).
            CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_afkoall).
              lv_error400 = 'X'.
              lv_error_message_afko = lo_sql_error_afko->get_text( ).
              lv_text = lv_error_message_afko.
          ENDTRY.
          SORT lt_afko_2 BY billofmaterialcategory billofmaterial billofmaterialvariant billofmaterialvariantusage.
        ENDIF.


        IF lt_afkoall IS NOT INITIAL.
          LOOP  AT lt_afkoall INTO DATA(ls_afko).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_afko TO es_afko.
            READ TABLE lt_afko_2 INTO DATA(ls_afko_2) WITH KEY billofmaterialcategory = ls_afko-billofmaterialcategory
                                                               billofmaterial = ls_afko-billofmaterialinternalid
                                                               billofmaterialvariant = ls_afko-billofmaterialvariant
                                                               billofmaterialvariantusage = ls_afko-billofmaterialvariantusage
                                                               BINARY SEARCH.
            IF sy-subrc = 0.
              es_afko-billofmaterialstatus = ls_afko_2-billofmaterialstatus.
              es_afko-bomheaderquantityinbaseunit = ls_afko_2-bomheaderquantityinbaseunit.
              es_afko-bomheaderbaseunit = ls_afko_2-bomheaderbaseunit.
            ENDIF.
            CLEAR ls_afko_2.
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
            CLEAR es_afko.

          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_afko-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_afko )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).

        ELSE.
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'AFPO'  OR 'afpo' .
        DATA:lv_error_message_afpo TYPE string.
        TRY.
            SELECT * FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS
            WHERE (lv_where)
            INTO TABLE @DATA(lt_afpo).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_afpo).
            lv_error400 = 'X'.
            lv_error_message_afpo = lo_sql_error_afpo->get_text( ).
            lv_text = lv_error_message_afpo.
        ENDTRY.


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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'PLPO'  OR 'plpo' .
        DATA: lv_error_message_plpo TYPE string.

        TRY.
            SELECT *
              FROM i_mfgboooperationchangestate WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_plpo).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_plpo).
            lv_error400 = 'X'.
            lv_error_message_plpo = lo_sql_error_plpo->get_text( ).
            lv_text = lv_error_message_plpo.
        ENDTRY.

        IF lt_plpo IS NOT INITIAL.
          LOOP AT lt_plpo INTO DATA(ls_plpo).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_plpo TO es_plpo.
            APPEND es_plpo TO es_response_plpo-items.
            CLEAR es_plpo.
          ENDLOOP.

          "respond with success payload
          response->set_status( '200' ).
          es_response_plpo-message = |{ lv_count }件は送信されました。|.

          lv_json_string = xco_cp_json=>data->from_abap( es_response_plpo )->to_string( ).
          response->set_text( lv_json_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).
        ELSE.
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'RESB'  OR 'resb' .
        DATA: lv_error_message_resb TYPE string.

        TRY.
            SELECT
                    reservation,
                    reservationitem,
                    matlcompismarkedfordeletion,
                    material,
                    plant,
                    storagelocation,
                    requiredquantity,
                    baseunit,
                    withdrawnquantity,
                    manufacturingorder,
                    assembly,
                    bomitemcategory,
                    billofmaterialitemnumber_2,
                    bomitemdescription,
                    bomitemtext2,
                    materialqtytobaseqtynmrtr,
                    materialqtytobaseqtydnmntr,
                    materialcomponentsorttext,
                    matlcompismarkedforbackflush,
                    materialcomponentisphantomitem,
                    recordtype,
                    goodsmovementisallowed,
                    reservationisfinallyissued,
                    isbulkmaterialcomponent
                   "comment by w.z 20250402
*                   i_manufacturingorderitem~plannedorder
                   "end comment
              FROM i_mfgorderoperationcomponent WITH PRIVILEGED ACCESS
*            LEFT JOIN i_manufacturingorderitem WITH PRIVILEGED ACCESS
*            ON i_mfgorderoperationcomponent~ls_resb = i_manufacturingorderitem~manufacturingorder
*            comment by w.z 20250403
             WHERE (lv_where)
              INTO TABLE @DATA(lt_resb).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_resb).
            lv_error400 = 'X'.
            lv_error_message_resb = lo_sql_error_resb->get_text( ).
            lv_text = lv_error_message_resb.
        ENDTRY.

        IF lt_resb IS NOT INITIAL.
          SELECT manufacturingorder,
                 plannedorder
            FROM i_manufacturingorderitem WITH PRIVILEGED ACCESS
             FOR ALL ENTRIES IN @lt_resb
           WHERE manufacturingorder = @lt_resb-manufacturingorder
            INTO TABLE @DATA(lt_manufactitem).     "#EC CI_NO_TRANSFORM

          SORT lt_manufactitem BY manufacturingorder.

          LOOP  AT lt_resb INTO DATA(ls_resb).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_resb TO es_resb.

            READ TABLE lt_manufactitem INTO DATA(ls_manufactitem) WITH KEY manufacturingorder = ls_resb-manufacturingorder BINARY SEARCH.
            IF sy-subrc = 0.
              es_resb-plannedorder = ls_manufactitem-plannedorder .
            ENDIF.

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'AFVC'  OR 'afvc' .
        DATA: lv_error_message_afvc TYPE string.
        TRY.
            SELECT *
              FROM i_manufacturingorderoperation WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_afvc).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_afvc).
            lv_error400 = 'X'.
            lv_error_message_afvc = lo_sql_error_afvc->get_text( ).
            lv_text = lv_error_message_afvc.
        ENDTRY.

        IF lt_afvc IS NOT INITIAL.

          LOOP  AT lt_afvc INTO DATA(ls_afvc).
            lv_count = lv_count + 1.
            MOVE-CORRESPONDING ls_afvc TO es_afvc.

*            es_afvc-mfgorderinternalid                 =    ls_afvc-mfgorderinternalid             .
*            es_afvc-orderoperationinternalid           =    ls_afvc-orderoperationinternalid       .
*            es_afvc-manufacturingorder                 =    ls_afvc-manufacturingorder             .
*            es_afvc-manufacturingordersequence         =    ls_afvc-manufacturingordersequence     .
**        es_afvc-ManufacturingOrderOperation        =    ls_afvc-ManufacturingOrderOperation    .
*            es_afvc-manufacturingorderoperation_2      =    ls_afvc-manufacturingorderoperation_2  .
**        es_afvc-ManufacturingOrderSubOperation     =    ls_afvc-ManufacturingOrderSubOperation .
*            es_afvc-manufacturingordsuboperation_2     =    ls_afvc-manufacturingordsuboperation_2 .
**        es_afvc-MfgOrderOperationOrSubOp           =    ls_afvc-MfgOrderOperationOrSubOp       .
*            es_afvc-mfgorderoperationorsubop_2         =    ls_afvc-mfgorderoperationorsubop_2     .
*            es_afvc-mfgorderoperationisphase           =    ls_afvc-mfgorderoperationisphase       .
*            es_afvc-orderintbillofopitemofphase        =    ls_afvc-orderintbillofopitemofphase    .
**        es_afvc-MfgOrderPhaseSuperiorOperation     =    ls_afvc-MfgOrderPhaseSuperiorOperation .
*            es_afvc-superioroperation_2                =    ls_afvc-superioroperation_2            .
*            es_afvc-manufacturingordercategory         =    ls_afvc-manufacturingordercategory     .
*            es_afvc-manufacturingordertype             =    ls_afvc-manufacturingordertype         .
*            es_afvc-productionsupervisor               =    ls_afvc-productionsupervisor           .
*            es_afvc-mrpcontroller                      =    ls_afvc-mrpcontroller                  .
*            es_afvc-responsibleplannergroup            =    ls_afvc-responsibleplannergroup        .
*            es_afvc-productconfiguration               =    ls_afvc-productconfiguration           .
*            es_afvc-inspectionlot                      =    ls_afvc-inspectionlot                  .
*            es_afvc-manufacturingorderimportance       =    ls_afvc-manufacturingorderimportance   .
*            es_afvc-mfgorderoperationtext              =    ls_afvc-mfgorderoperationtext          .
*            es_afvc-operationstandardtextcode          =    ls_afvc-operationstandardtextcode      .
*            es_afvc-operationhaslongtext               =    ls_afvc-operationhaslongtext           .
*            es_afvc-language                           =    ls_afvc-language                       .
*            es_afvc-operationistobedeleted             =    ls_afvc-operationistobedeleted         .
*            es_afvc-numberofcapacities                 =    ls_afvc-numberofcapacities             .
*            es_afvc-numberofconfirmationslips          =    ls_afvc-numberofconfirmationslips      .
*            es_afvc-operationimportance                =    ls_afvc-operationimportance            .
*            es_afvc-superioroperationinternalid        =    ls_afvc-superioroperationinternalid    .
*            es_afvc-plant                              =    ls_afvc-plant                          .
*            es_afvc-workcenterinternalid               =    ls_afvc-workcenterinternalid           .
**        es_afvc-WorkCenterTypeCode                 =    ls_afvc-WorkCenterTypeCode             .
*
*            es_afvc-workcentertypecode_2               =  ls_afvc-workcentertypecode_2               .
*            es_afvc-operationcontrolprofile            =  ls_afvc-operationcontrolprofile            .
*            es_afvc-controlrecipedestination           =  ls_afvc-controlrecipedestination           .
*            es_afvc-operationconfirmation              =  ls_afvc-operationconfirmation              .
*            es_afvc-numberofoperationconfirmations     =  ls_afvc-numberofoperationconfirmations     .
*            es_afvc-factorycalendar                    =  ls_afvc-factorycalendar                    .
*            es_afvc-capacityrequirement                =  ls_afvc-capacityrequirement                .
*            es_afvc-capacityrequirementitem            =  ls_afvc-capacityrequirementitem            .
*            es_afvc-changenumber                       =  ls_afvc-changenumber                       .
*            es_afvc-objectinternalid                   =  ls_afvc-objectinternalid                   .
*            es_afvc-operationtrackingnumber            =  ls_afvc-operationtrackingnumber            .
*            es_afvc-billofoperationstype               =  ls_afvc-billofoperationstype               .
*            es_afvc-billofoperationsgroup              =  ls_afvc-billofoperationsgroup              .
*            es_afvc-billofoperationsvariant            =  ls_afvc-billofoperationsvariant            .
*            es_afvc-billofoperationssequence           =  ls_afvc-billofoperationssequence           .
*            es_afvc-boooperationinternalid             =  ls_afvc-boooperationinternalid             .
*            es_afvc-billofoperationsversion            =  ls_afvc-billofoperationsversion            .
*            es_afvc-billofmaterialcategory             =  ls_afvc-billofmaterialcategory             .
**        es_afvc-BillOfMaterialInternalID           =  ls_afvc-BillOfMaterialInternalID           .
*            es_afvc-billofmaterialinternalid_2         =  ls_afvc-billofmaterialinternalid_2         .
*            es_afvc-billofmaterialitemnodenumber       =  ls_afvc-billofmaterialitemnodenumber       .
*            es_afvc-bomitemnodecount                   =  ls_afvc-bomitemnodecount                   .
*            es_afvc-extprocgoperationhassubcontrg      =  ls_afvc-extprocgoperationhassubcontrg      .
*            es_afvc-purchasingorganization             =  ls_afvc-purchasingorganization             .
*            es_afvc-purchasinggroup                    =  ls_afvc-purchasinggroup                    .
*            es_afvc-purchaserequisition                =  ls_afvc-purchaserequisition                .
*            es_afvc-purchaserequisitionitem            =  ls_afvc-purchaserequisitionitem            .
*            es_afvc-purchaseorder                      =  ls_afvc-purchaseoutlineagreement.     "PurchaseOrder      MOD BY XINLEI XU 2025/02/16
*            es_afvc-purchaseorderitem                  =  ls_afvc-purchaseoutlineagreementitem. "PurchaseOrderItem  MOD BY XINLEI XU 2025/02/16
*            es_afvc-purchasinginforecord               =  ls_afvc-purchasinginforecord               .
*            es_afvc-purginforecddataisfixed            =  ls_afvc-purginforecddataisfixed            .
*            es_afvc-purchasinginforecordcategory       =  ls_afvc-purchasinginforecordcategory       .
*            es_afvc-supplier                           =  ls_afvc-supplier                           .
*            es_afvc-goodsrecipientname                 =  ls_afvc-goodsrecipientname                 .
*            es_afvc-unloadingpointname                 =  ls_afvc-unloadingpointname                 .
*            es_afvc-materialgroup                      =  ls_afvc-materialgroup                      .
*            es_afvc-opexternalprocessingcurrency       =  ls_afvc-opexternalprocessingcurrency       .
*            es_afvc-opexternalprocessingprice          =  ls_afvc-opexternalprocessingprice          .
*            es_afvc-numberofoperationpriceunits        =  ls_afvc-numberofoperationpriceunits        .
*            es_afvc-companycode                        =  ls_afvc-companycode                        .
*            es_afvc-businessarea                       =  ls_afvc-businessarea                       .
*            es_afvc-controllingarea                    =  ls_afvc-controllingarea                    .
*
*            es_afvc-profitcenter                       =  ls_afvc-profitcenter                    .
*            es_afvc-requestingcostcenter               =  ls_afvc-requestingcostcenter            .
*            es_afvc-costelement                        =  ls_afvc-costelement                     .
*            es_afvc-costingvariant                     =  ls_afvc-costingvariant                  .
*            es_afvc-costingsheet                       =  ls_afvc-costingsheet                    .
*            es_afvc-costestimate                       =  ls_afvc-costestimate                    .
*            es_afvc-controllingobjectcurrency          =  ls_afvc-controllingobjectcurrency       .
*            es_afvc-controllingobjectclass             =  ls_afvc-controllingobjectclass          .
*            es_afvc-functionalarea                     =  ls_afvc-functionalarea                  .
*            es_afvc-taxjurisdiction                    =  ls_afvc-taxjurisdiction                 .
*            es_afvc-employeewagetype                   =  ls_afvc-employeewagetype                .
*            es_afvc-employeewagegroup                  =  ls_afvc-employeewagegroup               .
*            es_afvc-employeesuitability                =  ls_afvc-employeesuitability             .
*            es_afvc-numberoftimetickets                =  ls_afvc-numberoftimetickets             .
*            es_afvc-personnel                          =  ls_afvc-personnel                       .
*            es_afvc-numberofemployees                  =  ls_afvc-numberofemployees               .
*            es_afvc-operationsetupgroupcategory        =  ls_afvc-operationsetupgroupcategory     .
*            es_afvc-operationsetupgroup                =  ls_afvc-operationsetupgroup             .
*            es_afvc-operationsetuptype                 =  ls_afvc-operationsetuptype              .
*            es_afvc-operationoverlappingisrequired     =  ls_afvc-operationoverlappingisrequired  .
*            es_afvc-operationoverlappingispossible     =  ls_afvc-operationoverlappingispossible  .
*            es_afvc-operationsisalwaysoverlapping      =  ls_afvc-operationsisalwaysoverlapping   .
*            es_afvc-operationsplitisrequired           =  ls_afvc-operationsplitisrequired        .
*            es_afvc-maximumnumberofsplits              =  ls_afvc-maximumnumberofsplits           .
*            es_afvc-leadtimereductionstrategy          =  ls_afvc-leadtimereductionstrategy       .
*            es_afvc-opschedldreductionlevel            =  ls_afvc-opschedldreductionlevel         .
*            es_afvc-operlstschedldexecstrtdte          =  ls_afvc-operlstschedldexecstrtdte       .
*            es_afvc-operlstschedldexecstrttme          =  ls_afvc-operlstschedldexecstrttme       .
*            es_afvc-operlstschedldprocgstrtdte         =  ls_afvc-operlstschedldprocgstrtdte      .
*            es_afvc-operlstschedldprocgstrttme         =  ls_afvc-operlstschedldprocgstrttme      .
*            es_afvc-operlstschedldtrdwnstrtdte         =  ls_afvc-operlstschedldtrdwnstrtdte      .
*            es_afvc-operlstschedldtrdwnstrttme         =  ls_afvc-operlstschedldtrdwnstrttme      .
*            es_afvc-operlstschedldexecenddte           =  ls_afvc-operlstschedldexecenddte        .
*            es_afvc-operlstschedldexecendtme           =  ls_afvc-operlstschedldexecendtme        .
*            es_afvc-opltstschedldexecstrtdte           =  ls_afvc-opltstschedldexecstrtdte        .
*            es_afvc-opltstschedldexecstrttme           =  ls_afvc-opltstschedldexecstrttme        .
*            es_afvc-opltstschedldprocgstrtdte          =  ls_afvc-opltstschedldprocgstrtdte       .
*            es_afvc-opltstschedldprocgstrttme          =  ls_afvc-opltstschedldprocgstrttme       .
*            es_afvc-opltstschedldtrdwnstrtdte          =  ls_afvc-opltstschedldtrdwnstrtdte       .
*
*            es_afvc-opltstschedldtrdwnstrttme          =   ls_afvc-opltstschedldtrdwnstrttme       .
*            es_afvc-opltstschedldexecenddte            =   ls_afvc-opltstschedldexecenddte         .
*            es_afvc-opltstschedldexecendtme            =   ls_afvc-opltstschedldexecendtme         .
*            es_afvc-schedldfcstdearlieststartdate      =   ls_afvc-schedldfcstdearlieststartdate   .
*            es_afvc-schedldfcstdearlieststarttime      =   ls_afvc-schedldfcstdearlieststarttime   .
*            es_afvc-schedldfcstdearliestenddate        =   ls_afvc-schedldfcstdearliestenddate     .
*            es_afvc-schedldfcstdearliestendtime        =   ls_afvc-schedldfcstdearliestendtime     .
*            es_afvc-latestschedldfcstdstartdate        =   ls_afvc-latestschedldfcstdstartdate     .
*            es_afvc-schedldfcstdlateststarttime        =   ls_afvc-schedldfcstdlateststarttime     .
*            es_afvc-latestschedldfcstdenddate          =   ls_afvc-latestschedldfcstdenddate       .
*            es_afvc-schedldfcstdlatestendtime          =   ls_afvc-schedldfcstdlatestendtime       .
*            es_afvc-operationconfirmedstartdate        =   ls_afvc-operationconfirmedstartdate     .
*            es_afvc-operationconfirmedenddate          =   ls_afvc-operationconfirmedenddate       .
*            es_afvc-opactualexecutionstartdate         =   ls_afvc-opactualexecutionstartdate      .
*            es_afvc-opactualexecutionstarttime         =   ls_afvc-opactualexecutionstarttime      .
*            es_afvc-opactualsetupenddate               =   ls_afvc-opactualsetupenddate            .
*            es_afvc-opactualsetupendtime               =   ls_afvc-opactualsetupendtime            .
*            es_afvc-opactualprocessingstartdate        =   ls_afvc-opactualprocessingstartdate     .
*            es_afvc-opactualprocessingstarttime        =   ls_afvc-opactualprocessingstarttime     .
*            es_afvc-opactualprocessingenddate          =   ls_afvc-opactualprocessingenddate       .
*            es_afvc-opactualprocessingendtime          =   ls_afvc-opactualprocessingendtime       .
*            es_afvc-opactualteardownstartdate          =   ls_afvc-opactualteardownstartdate       .
*            es_afvc-opactualteardownstarttme           =   ls_afvc-opactualteardownstarttme        .
*            es_afvc-opactualexecutionenddate           =   ls_afvc-opactualexecutionenddate        .
*            es_afvc-opactualexecutionendtime           =   ls_afvc-opactualexecutionendtime        .
*            es_afvc-actualforecastenddate              =   ls_afvc-actualforecastenddate           .
*            es_afvc-actualforecastendtime              =   ls_afvc-actualforecastendtime           .
*            es_afvc-earliestscheduledwaitstartdate     =   ls_afvc-earliestscheduledwaitstartdate  .
*            es_afvc-earliestscheduledwaitstarttime     =   ls_afvc-earliestscheduledwaitstarttime  .
*            es_afvc-earliestscheduledwaitenddate       =   ls_afvc-earliestscheduledwaitenddate    .
*            es_afvc-earliestscheduledwaitendtime       =   ls_afvc-earliestscheduledwaitendtime    .
*            es_afvc-latestscheduledwaitstartdate       =   ls_afvc-latestscheduledwaitstartdate    .
*            es_afvc-latestscheduledwaitstarttime       =   ls_afvc-latestscheduledwaitstarttime    .
*            es_afvc-latestscheduledwaitenddate         =   ls_afvc-latestscheduledwaitenddate      .
*            es_afvc-latestscheduledwaitendtime         =   ls_afvc-latestscheduledwaitendtime      .
*            es_afvc-breakdurationunit                  =   ls_afvc-breakdurationunit               .
*            es_afvc-plannedbreakduration               =   ls_afvc-plannedbreakduration            .
*            es_afvc-confirmedbreakduration             =   ls_afvc-confirmedbreakduration          .
*            es_afvc-overlapminimumdurationunit         =   ls_afvc-overlapminimumdurationunit      .
*            es_afvc-overlapminimumduration             =   ls_afvc-overlapminimumduration          .
*            es_afvc-maximumwaitdurationunit            =   ls_afvc-maximumwaitdurationunit         .
*            es_afvc-maximumwaitduration                =   ls_afvc-maximumwaitduration             .
*            es_afvc-minimumwaitdurationunit            =   ls_afvc-minimumwaitdurationunit         .
*            es_afvc-minimumwaitduration                =   ls_afvc-minimumwaitduration             .
*            es_afvc-standardmovedurationunit           =   ls_afvc-standardmovedurationunit        .
*            es_afvc-standardmoveduration               =   ls_afvc-standardmoveduration            .
*            es_afvc-standardqueuedurationunit          =   ls_afvc-standardqueuedurationunit       .
*
*
*            es_afvc-standardqueueduration              = ls_afvc-standardqueueduration             .
*            es_afvc-minimumqueuedurationunit           = ls_afvc-minimumqueuedurationunit          .
*            es_afvc-minimumqueueduration               = ls_afvc-minimumqueueduration              .
*            es_afvc-minimummovedurationunit            = ls_afvc-minimummovedurationunit           .
*            es_afvc-minimummoveduration                = ls_afvc-minimummoveduration               .
*            es_afvc-operationstandardduration          = ls_afvc-operationstandardduration         .
*            es_afvc-operationstandarddurationunit      = ls_afvc-operationstandarddurationunit     .
*            es_afvc-minimumduration                    = ls_afvc-minimumduration                   .
*            es_afvc-minimumdurationunit                = ls_afvc-minimumdurationunit               .
*            es_afvc-minimumprocessingduration          = ls_afvc-minimumprocessingduration         .
*            es_afvc-minimumprocessingdurationunit      = ls_afvc-minimumprocessingdurationunit     .
*            es_afvc-scheduledmoveduration              = ls_afvc-scheduledmoveduration             .
*            es_afvc-scheduledmovedurationunit          = ls_afvc-scheduledmovedurationunit         .
*            es_afvc-scheduledqueueduration             = ls_afvc-scheduledqueueduration            .
*            es_afvc-scheduledqueuedurationunit         = ls_afvc-scheduledqueuedurationunit        .
*            es_afvc-scheduledwaitduration              = ls_afvc-scheduledwaitduration             .
*            es_afvc-scheduledwaitdurationunit          = ls_afvc-scheduledwaitdurationunit         .
*            es_afvc-planneddeliveryduration            = ls_afvc-planneddeliveryduration           .
*            es_afvc-opplannedsetupdurn                 = ls_afvc-opplannedsetupdurn                .
*            es_afvc-opplannedsetupdurnunit             = ls_afvc-opplannedsetupdurnunit            .
*            es_afvc-opplannedprocessingdurn            = ls_afvc-opplannedprocessingdurn           .
*            es_afvc-opplannedprocessingdurnunit        = ls_afvc-opplannedprocessingdurnunit       .
*            es_afvc-opplannedteardowndurn              = ls_afvc-opplannedteardowndurn             .
*            es_afvc-opplannedteardowndurnunit          = ls_afvc-opplannedteardowndurnunit         .
*            es_afvc-actualforecastduration             = ls_afvc-actualforecastduration            .
*            es_afvc-actualforecastdurationunit         = ls_afvc-actualforecastdurationunit        .
*            es_afvc-forecastprocessingduration         = ls_afvc-forecastprocessingduration        .
*            es_afvc-forecastprocessingdurationunit     = ls_afvc-forecastprocessingdurationunit    .
*            es_afvc-startdateoffsetreferencecode       = ls_afvc-startdateoffsetreferencecode      .
*            es_afvc-startdateoffsetdurationunit        = ls_afvc-startdateoffsetdurationunit       .
*            es_afvc-startdateoffsetduration            = ls_afvc-startdateoffsetduration           .
*            es_afvc-enddateoffsetreferencecode         = ls_afvc-enddateoffsetreferencecode        .
*            es_afvc-enddateoffsetdurationunit          = ls_afvc-enddateoffsetdurationunit         .
*            es_afvc-enddateoffsetduration              = ls_afvc-enddateoffsetduration             .
*            es_afvc-standardworkformulaparamgroup      = ls_afvc-standardworkformulaparamgroup     .
*            es_afvc-operationunit                      = ls_afvc-operationunit                     .
*            es_afvc-opqtytobaseqtydnmntr               = ls_afvc-opqtytobaseqtydnmntr              .
*            es_afvc-opqtytobaseqtynmrtr                = ls_afvc-opqtytobaseqtynmrtr               .
*            es_afvc-operationscrappercent              = ls_afvc-operationscrappercent             .
*            es_afvc-operationreferencequantity         = ls_afvc-operationreferencequantity        .
*            es_afvc-opplannedtotalquantity             = ls_afvc-opplannedtotalquantity            .
*            es_afvc-opplannedscrapquantity             = ls_afvc-opplannedscrapquantity            .
*            es_afvc-opplannedyieldquantity             = ls_afvc-opplannedyieldquantity            .
*            es_afvc-optotalconfirmedyieldqty           = ls_afvc-optotalconfirmedyieldqty          .
*
*
*            es_afvc-optotalconfirmedscrapqty           =  ls_afvc-optotalconfirmedscrapqty              .
*            es_afvc-operationconfirmedreworkqty        =  ls_afvc-operationconfirmedreworkqty           .
*            es_afvc-productionunit                     =  ls_afvc-productionunit                        .
*            es_afvc-optotconfdyieldqtyinordqtyunit     =  ls_afvc-optotconfdyieldqtyinordqtyunit        .
*            es_afvc-opworkquantityunit1                =  ls_afvc-opworkquantityunit1                   .
*            es_afvc-opconfirmedworkquantity1           =  ls_afvc-opconfirmedworkquantity1              .
*            es_afvc-nofurtheropworkquantity1isexpd     =  ls_afvc-nofurtheropworkquantity1isexpd        .
*            es_afvc-opworkquantityunit2                =  ls_afvc-opworkquantityunit2                   .
*            es_afvc-opconfirmedworkquantity2           =  ls_afvc-opconfirmedworkquantity2              .
*            es_afvc-nofurtheropworkquantity2isexpd     =  ls_afvc-nofurtheropworkquantity2isexpd        .
*            es_afvc-opworkquantityunit3                =  ls_afvc-opworkquantityunit3                   .
*            es_afvc-opconfirmedworkquantity3           =  ls_afvc-opconfirmedworkquantity3              .
*            es_afvc-nofurtheropworkquantity3isexpd     =  ls_afvc-nofurtheropworkquantity3isexpd        .
*            es_afvc-opworkquantityunit4                =  ls_afvc-opworkquantityunit4                   .
*            es_afvc-opconfirmedworkquantity4           =  ls_afvc-opconfirmedworkquantity4              .
*            es_afvc-nofurtheropworkquantity4isexpd     =  ls_afvc-nofurtheropworkquantity4isexpd        .
*            es_afvc-opworkquantityunit5                =  ls_afvc-opworkquantityunit5                   .
*            es_afvc-opconfirmedworkquantity5           =  ls_afvc-opconfirmedworkquantity5              .
*            es_afvc-nofurtheropworkquantity5isexpd     =  ls_afvc-nofurtheropworkquantity5isexpd        .
*            es_afvc-opworkquantityunit6                =  ls_afvc-opworkquantityunit6                   .
*            es_afvc-opconfirmedworkquantity6           =  ls_afvc-opconfirmedworkquantity6              .
*            es_afvc-nofurtheropworkquantity6isexpd     =  ls_afvc-nofurtheropworkquantity6isexpd        .
*            es_afvc-workcenterstandardworkqtyunit1     =  ls_afvc-workcenterstandardworkqtyunit1        .
*            es_afvc-workcenterstandardworkqty1         =  ls_afvc-workcenterstandardworkqty1            .
*            es_afvc-costctractivitytype1               =  ls_afvc-costctractivitytype1                  .
*            es_afvc-workcenterstandardworkqtyunit2     =  ls_afvc-workcenterstandardworkqtyunit2        .
*            es_afvc-workcenterstandardworkqty2         =  ls_afvc-workcenterstandardworkqty2            .
*            es_afvc-costctractivitytype2               =  ls_afvc-costctractivitytype2                  .
*            es_afvc-workcenterstandardworkqtyunit3     =  ls_afvc-workcenterstandardworkqtyunit3        .
*            es_afvc-workcenterstandardworkqty3         =  ls_afvc-workcenterstandardworkqty3            .
*            es_afvc-costctractivitytype3               =  ls_afvc-costctractivitytype3                  .
*            es_afvc-workcenterstandardworkqtyunit4     =  ls_afvc-workcenterstandardworkqtyunit4        .
*            es_afvc-workcenterstandardworkqty4         =  ls_afvc-workcenterstandardworkqty4            .
*            es_afvc-costctractivitytype4               =  ls_afvc-costctractivitytype4                  .
*            es_afvc-workcenterstandardworkqtyunit5     =  ls_afvc-workcenterstandardworkqtyunit5        .
*            es_afvc-workcenterstandardworkqty5         =  ls_afvc-workcenterstandardworkqty5            .
*            es_afvc-costctractivitytype5               =  ls_afvc-costctractivitytype5                  .
*            es_afvc-workcenterstandardworkqtyunit6     =  ls_afvc-workcenterstandardworkqtyunit6        .
*            es_afvc-workcenterstandardworkqty6         =  ls_afvc-workcenterstandardworkqty6            .
*            es_afvc-costctractivitytype6               =  ls_afvc-costctractivitytype6                  .
*            es_afvc-forecastworkquantity1              =  ls_afvc-forecastworkquantity1                 .
*            es_afvc-forecastworkquantity2              =  ls_afvc-forecastworkquantity2                 .
*            es_afvc-forecastworkquantity3              =  ls_afvc-forecastworkquantity3                 .
*            es_afvc-forecastworkquantity4              =  ls_afvc-forecastworkquantity4                 .
*            es_afvc-forecastworkquantity5              =  ls_afvc-forecastworkquantity5                 .
*            es_afvc-forecastworkquantity6              =  ls_afvc-forecastworkquantity6                 .
*            es_afvc-businessprocess                    =  ls_afvc-businessprocess                       .
*            es_afvc-businessprocessentryunit           =  ls_afvc-businessprocessentryunit              .
*            es_afvc-businessprocessconfirmedqty        =  ls_afvc-businessprocessconfirmedqty           .
*            es_afvc-nofurtherbusinessprocqtyisexpd     =  ls_afvc-nofurtherbusinessprocqtyisexpd        .
*            es_afvc-businessprocremainingqtyunit       =  ls_afvc-businessprocremainingqtyunit          .
*            es_afvc-businessprocessremainingqty        =  ls_afvc-businessprocessremainingqty           .
*            es_afvc-setupopactyntwkinstance            =  ls_afvc-setupopactyntwkinstance               .
*            es_afvc-produceopactyntwkinstance          =  ls_afvc-produceopactyntwkinstance             .
*            es_afvc-teardownopactyntwkinstance         =  ls_afvc-teardownopactyntwkinstance            .
*            es_afvc-freedefinedtablefieldsemantic      =  ls_afvc-freedefinedtablefieldsemantic         .
*            es_afvc-freedefinedattribute01             =  ls_afvc-freedefinedattribute01                .
*            es_afvc-freedefinedattribute02             =  ls_afvc-freedefinedattribute02                .
*            es_afvc-freedefinedattribute03             =  ls_afvc-freedefinedattribute03                .
*            es_afvc-freedefinedattribute04             =  ls_afvc-freedefinedattribute04                .
*            es_afvc-freedefinedquantity1unit           =  ls_afvc-freedefinedquantity1unit              .
*            es_afvc-freedefinedquantity1               =  ls_afvc-freedefinedquantity1                  .
*            es_afvc-freedefinedquantity2unit           =  ls_afvc-freedefinedquantity2unit              .
*            es_afvc-freedefinedquantity2               =  ls_afvc-freedefinedquantity2                  .
*            es_afvc-freedefinedamount1currency         =  ls_afvc-freedefinedamount1currency            .
*            es_afvc-freedefinedamount1                 =  ls_afvc-freedefinedamount1                    .
*            es_afvc-freedefinedamount2currency         =  ls_afvc-freedefinedamount2currency            .
*            es_afvc-freedefinedamount2                 =  ls_afvc-freedefinedamount2                    .
*            es_afvc-freedefineddate1                   =  ls_afvc-freedefineddate1                      .
*            es_afvc-freedefineddate2                   =  ls_afvc-freedefineddate2                      .
*            es_afvc-freedefinedindicator1              =  ls_afvc-freedefinedindicator1                 .
*            es_afvc-freedefinedindicator2              =  ls_afvc-freedefinedindicator2                 .
*
*            CONDENSE es_afvc-mfgorderinternalid                .
*            CONDENSE es_afvc-orderoperationinternalid          .
*            CONDENSE es_afvc-manufacturingorder                .
*            CONDENSE es_afvc-manufacturingordersequence        .
*            CONDENSE es_afvc-manufacturingorderoperation       .
*            CONDENSE es_afvc-manufacturingorderoperation_2     .
*            CONDENSE es_afvc-manufacturingordersuboperation    .
*            CONDENSE es_afvc-manufacturingordsuboperation_2    .
*            CONDENSE es_afvc-mfgorderoperationorsubop          .
*            CONDENSE es_afvc-mfgorderoperationorsubop_2        .
*            CONDENSE es_afvc-mfgorderoperationisphase          .
*            CONDENSE es_afvc-orderintbillofopitemofphase       .
*            CONDENSE es_afvc-mfgorderphasesuperioroperation    .
*            CONDENSE es_afvc-superioroperation_2               .
*            CONDENSE es_afvc-manufacturingordercategory        .
*            CONDENSE es_afvc-manufacturingordertype            .
*            CONDENSE es_afvc-productionsupervisor              .
*            CONDENSE es_afvc-mrpcontroller                     .
*            CONDENSE es_afvc-responsibleplannergroup           .
*            CONDENSE es_afvc-productconfiguration              .
*            CONDENSE es_afvc-inspectionlot                     .
*            CONDENSE es_afvc-manufacturingorderimportance      .
*            CONDENSE es_afvc-mfgorderoperationtext             .
*            CONDENSE es_afvc-operationstandardtextcode         .
*            CONDENSE es_afvc-operationhaslongtext              .
*            CONDENSE es_afvc-language                          .
*            CONDENSE es_afvc-operationistobedeleted            .
*            CONDENSE es_afvc-numberofcapacities                .
*            CONDENSE es_afvc-numberofconfirmationslips         .
*            CONDENSE es_afvc-operationimportance               .
*            CONDENSE es_afvc-superioroperationinternalid       .
*            CONDENSE es_afvc-plant                             .
*            CONDENSE es_afvc-workcenterinternalid              .
*            CONDENSE es_afvc-workcentertypecode                .
*
*            CONDENSE es_afvc-workcentertypecode_2              .
*            CONDENSE es_afvc-operationcontrolprofile           .
*            CONDENSE es_afvc-controlrecipedestination          .
*            CONDENSE es_afvc-operationconfirmation             .
*            CONDENSE es_afvc-numberofoperationconfirmations    .
*            CONDENSE es_afvc-factorycalendar                   .
*            CONDENSE es_afvc-capacityrequirement               .
*            CONDENSE es_afvc-capacityrequirementitem           .
*            CONDENSE es_afvc-changenumber                      .
*            CONDENSE es_afvc-objectinternalid                  .
*            CONDENSE es_afvc-operationtrackingnumber           .
*            CONDENSE es_afvc-billofoperationstype              .
*            CONDENSE es_afvc-billofoperationsgroup             .
*            CONDENSE es_afvc-billofoperationsvariant           .
*            CONDENSE es_afvc-billofoperationssequence          .
*            CONDENSE es_afvc-boooperationinternalid            .
*            CONDENSE es_afvc-billofoperationsversion           .
*            CONDENSE es_afvc-billofmaterialcategory            .
*            CONDENSE es_afvc-billofmaterialinternalid          .
*            CONDENSE es_afvc-billofmaterialinternalid_2        .
*            CONDENSE es_afvc-billofmaterialitemnodenumber      .
*            CONDENSE es_afvc-bomitemnodecount                  .
*            CONDENSE es_afvc-extprocgoperationhassubcontrg     .
*            CONDENSE es_afvc-purchasingorganization            .
*            CONDENSE es_afvc-purchasinggroup                   .
*            CONDENSE es_afvc-purchaserequisition               .
*            CONDENSE es_afvc-purchaserequisitionitem           .
*            CONDENSE es_afvc-purchaseorder                     .
*            CONDENSE es_afvc-purchaseorderitem                 .
*            CONDENSE es_afvc-purchasinginforecord              .
*            CONDENSE es_afvc-purginforecddataisfixed           .
*            CONDENSE es_afvc-purchasinginforecordcategory      .
*            CONDENSE es_afvc-supplier                          .
*            CONDENSE es_afvc-goodsrecipientname                .
*            CONDENSE es_afvc-unloadingpointname                .
*            CONDENSE es_afvc-materialgroup                     .
*            CONDENSE es_afvc-opexternalprocessingcurrency      .
*            CONDENSE es_afvc-opexternalprocessingprice         .
*            CONDENSE es_afvc-numberofoperationpriceunits       .
*            CONDENSE es_afvc-companycode                       .
*            CONDENSE es_afvc-businessarea                      .
*            CONDENSE es_afvc-controllingarea                   .
*
*            CONDENSE es_afvc-profitcenter                       .
*            CONDENSE es_afvc-requestingcostcenter               .
*            CONDENSE es_afvc-costelement                        .
*            CONDENSE es_afvc-costingvariant                     .
*            CONDENSE es_afvc-costingsheet                       .
*            CONDENSE es_afvc-costestimate                       .
*            CONDENSE es_afvc-controllingobjectcurrency          .
*            CONDENSE es_afvc-controllingobjectclass             .
*            CONDENSE es_afvc-functionalarea                     .
*            CONDENSE es_afvc-taxjurisdiction                    .
*            CONDENSE es_afvc-employeewagetype                   .
*            CONDENSE es_afvc-employeewagegroup                  .
*            CONDENSE es_afvc-employeesuitability                .
*            CONDENSE es_afvc-numberoftimetickets                .
*            CONDENSE es_afvc-personnel                          .
*            CONDENSE es_afvc-numberofemployees                  .
*            CONDENSE es_afvc-operationsetupgroupcategory        .
*            CONDENSE es_afvc-operationsetupgroup                .
*            CONDENSE es_afvc-operationsetuptype                 .
*            CONDENSE es_afvc-operationoverlappingisrequired     .
*            CONDENSE es_afvc-operationoverlappingispossible     .
*            CONDENSE es_afvc-operationsisalwaysoverlapping      .
*            CONDENSE es_afvc-operationsplitisrequired           .
*            CONDENSE es_afvc-maximumnumberofsplits              .
*            CONDENSE es_afvc-leadtimereductionstrategy          .
*            CONDENSE es_afvc-opschedldreductionlevel            .
*            CONDENSE es_afvc-operlstschedldexecstrtdte          .
*            CONDENSE es_afvc-operlstschedldexecstrttme          .
*            CONDENSE es_afvc-operlstschedldprocgstrtdte         .
*            CONDENSE es_afvc-operlstschedldprocgstrttme         .
*            CONDENSE es_afvc-operlstschedldtrdwnstrtdte         .
*            CONDENSE es_afvc-operlstschedldtrdwnstrttme         .
*            CONDENSE es_afvc-operlstschedldexecenddte           .
*            CONDENSE es_afvc-operlstschedldexecendtme           .
*            CONDENSE es_afvc-opltstschedldexecstrtdte           .
*            CONDENSE es_afvc-opltstschedldexecstrttme           .
*            CONDENSE es_afvc-opltstschedldprocgstrtdte          .
*            CONDENSE es_afvc-opltstschedldprocgstrttme          .
*            CONDENSE es_afvc-opltstschedldtrdwnstrtdte           .
*
*            CONDENSE es_afvc-opltstschedldtrdwnstrttme          .
*            CONDENSE es_afvc-opltstschedldexecenddte            .
*            CONDENSE es_afvc-opltstschedldexecendtme            .
*            CONDENSE es_afvc-schedldfcstdearlieststartdate      .
*            CONDENSE es_afvc-schedldfcstdearlieststarttime      .
*            CONDENSE es_afvc-schedldfcstdearliestenddate        .
*            CONDENSE es_afvc-schedldfcstdearliestendtime        .
*            CONDENSE es_afvc-latestschedldfcstdstartdate        .
*            CONDENSE es_afvc-schedldfcstdlateststarttime        .
*            CONDENSE es_afvc-latestschedldfcstdenddate          .
*            CONDENSE es_afvc-schedldfcstdlatestendtime          .
*            CONDENSE es_afvc-operationconfirmedstartdate        .
*            CONDENSE es_afvc-operationconfirmedenddate          .
*            CONDENSE es_afvc-opactualexecutionstartdate         .
*            CONDENSE es_afvc-opactualexecutionstarttime         .
*            CONDENSE es_afvc-opactualsetupenddate               .
*            CONDENSE es_afvc-opactualsetupendtime               .
*            CONDENSE es_afvc-opactualprocessingstartdate        .
*            CONDENSE es_afvc-opactualprocessingstarttime        .
*            CONDENSE es_afvc-opactualprocessingenddate          .
*            CONDENSE es_afvc-opactualprocessingendtime          .
*            CONDENSE es_afvc-opactualteardownstartdate          .
*            CONDENSE es_afvc-opactualteardownstarttme           .
*            CONDENSE es_afvc-opactualexecutionenddate           .
*            CONDENSE es_afvc-opactualexecutionendtime           .
*            CONDENSE es_afvc-actualforecastenddate              .
*            CONDENSE es_afvc-actualforecastendtime              .
*            CONDENSE es_afvc-earliestscheduledwaitstartdate     .
*            CONDENSE es_afvc-earliestscheduledwaitstarttime     .
*            CONDENSE es_afvc-earliestscheduledwaitenddate       .
*            CONDENSE es_afvc-earliestscheduledwaitendtime       .
*            CONDENSE es_afvc-latestscheduledwaitstartdate       .
*            CONDENSE es_afvc-latestscheduledwaitstarttime       .
*            CONDENSE es_afvc-latestscheduledwaitenddate         .
*            CONDENSE es_afvc-latestscheduledwaitendtime         .
*            CONDENSE es_afvc-breakdurationunit                  .
*            CONDENSE es_afvc-plannedbreakduration               .
*            CONDENSE es_afvc-confirmedbreakduration             .
*            CONDENSE es_afvc-overlapminimumdurationunit         .
*            CONDENSE es_afvc-overlapminimumduration             .
*            CONDENSE es_afvc-maximumwaitdurationunit            .
*            CONDENSE es_afvc-maximumwaitduration                .
*            CONDENSE es_afvc-minimumwaitdurationunit            .
*            CONDENSE es_afvc-minimumwaitduration                .
*            CONDENSE es_afvc-standardmovedurationunit           .
*            CONDENSE es_afvc-standardmoveduration               .
*            CONDENSE es_afvc-standardqueuedurationunit          .
*
*
*            CONDENSE es_afvc-standardqueueduration              .
*            CONDENSE es_afvc-minimumqueuedurationunit           .
*            CONDENSE es_afvc-minimumqueueduration               .
*            CONDENSE es_afvc-minimummovedurationunit            .
*            CONDENSE es_afvc-minimummoveduration                .
*            CONDENSE es_afvc-operationstandardduration          .
*            CONDENSE es_afvc-operationstandarddurationunit      .
*            CONDENSE es_afvc-minimumduration                    .
*            CONDENSE es_afvc-minimumdurationunit                .
*            CONDENSE es_afvc-minimumprocessingduration          .
*            CONDENSE es_afvc-minimumprocessingdurationunit      .
*            CONDENSE es_afvc-scheduledmoveduration              .
*            CONDENSE es_afvc-scheduledmovedurationunit          .
*            CONDENSE es_afvc-scheduledqueueduration             .
*            CONDENSE es_afvc-scheduledqueuedurationunit         .
*            CONDENSE es_afvc-scheduledwaitduration              .
*            CONDENSE es_afvc-scheduledwaitdurationunit          .
*            CONDENSE es_afvc-planneddeliveryduration            .
*            CONDENSE es_afvc-opplannedsetupdurn                 .
*            CONDENSE es_afvc-opplannedsetupdurnunit             .
*            CONDENSE es_afvc-opplannedprocessingdurn            .
*            CONDENSE es_afvc-opplannedprocessingdurnunit        .
*            CONDENSE es_afvc-opplannedteardowndurn              .
*            CONDENSE es_afvc-opplannedteardowndurnunit          .
*            CONDENSE es_afvc-actualforecastduration             .
*            CONDENSE es_afvc-actualforecastdurationunit         .
*            CONDENSE es_afvc-forecastprocessingduration         .
*            CONDENSE es_afvc-forecastprocessingdurationunit     .
*            CONDENSE es_afvc-startdateoffsetreferencecode       .
*            CONDENSE es_afvc-startdateoffsetdurationunit        .
*            CONDENSE es_afvc-startdateoffsetduration            .
*            CONDENSE es_afvc-enddateoffsetreferencecode         .
*            CONDENSE es_afvc-enddateoffsetdurationunit          .
*            CONDENSE es_afvc-enddateoffsetduration              .
*            CONDENSE es_afvc-standardworkformulaparamgroup      .
*            CONDENSE es_afvc-operationunit                      .
*            CONDENSE es_afvc-opqtytobaseqtydnmntr               .
*            CONDENSE es_afvc-opqtytobaseqtynmrtr                .
*            CONDENSE es_afvc-operationscrappercent              .
*            CONDENSE es_afvc-operationreferencequantity         .
*            CONDENSE es_afvc-opplannedtotalquantity             .
*            CONDENSE es_afvc-opplannedscrapquantity             .
*            CONDENSE es_afvc-opplannedyieldquantity             .
*            CONDENSE es_afvc-optotalconfirmedyieldqty           .
*
*
*            CONDENSE es_afvc-optotalconfirmedscrapqty            .
*            CONDENSE es_afvc-operationconfirmedreworkqty         .
*            CONDENSE es_afvc-productionunit                      .
*            CONDENSE es_afvc-optotconfdyieldqtyinordqtyunit      .
*            CONDENSE es_afvc-opworkquantityunit1                 .
*            CONDENSE es_afvc-opconfirmedworkquantity1            .
*            CONDENSE es_afvc-nofurtheropworkquantity1isexpd      .
*            CONDENSE es_afvc-opworkquantityunit2                 .
*            CONDENSE es_afvc-opconfirmedworkquantity2            .
*            CONDENSE es_afvc-nofurtheropworkquantity2isexpd      .
*            CONDENSE es_afvc-opworkquantityunit3                 .
*            CONDENSE es_afvc-opconfirmedworkquantity3            .
*            CONDENSE es_afvc-nofurtheropworkquantity3isexpd      .
*            CONDENSE es_afvc-opworkquantityunit4                 .
*            CONDENSE es_afvc-opconfirmedworkquantity4            .
*            CONDENSE es_afvc-nofurtheropworkquantity4isexpd      .
*            CONDENSE es_afvc-opworkquantityunit5                 .
*            CONDENSE es_afvc-opconfirmedworkquantity5            .
*            CONDENSE es_afvc-nofurtheropworkquantity5isexpd      .
*            CONDENSE es_afvc-opworkquantityunit6                 .
*            CONDENSE es_afvc-opconfirmedworkquantity6            .
*            CONDENSE es_afvc-nofurtheropworkquantity6isexpd      .
*            CONDENSE es_afvc-workcenterstandardworkqtyunit1      .
*            CONDENSE es_afvc-workcenterstandardworkqty1          .
*            CONDENSE es_afvc-costctractivitytype1                .
*            CONDENSE es_afvc-workcenterstandardworkqtyunit2      .
*            CONDENSE es_afvc-workcenterstandardworkqty2          .
*            CONDENSE es_afvc-costctractivitytype2                .
*            CONDENSE es_afvc-workcenterstandardworkqtyunit3      .
*            CONDENSE es_afvc-workcenterstandardworkqty3          .
*            CONDENSE es_afvc-costctractivitytype3                .
*            CONDENSE es_afvc-workcenterstandardworkqtyunit4      .
*            CONDENSE es_afvc-workcenterstandardworkqty4          .
*            CONDENSE es_afvc-costctractivitytype4                .
*            CONDENSE es_afvc-workcenterstandardworkqtyunit5      .
*            CONDENSE es_afvc-workcenterstandardworkqty5          .
*            CONDENSE es_afvc-costctractivitytype5                .
*            CONDENSE es_afvc-workcenterstandardworkqtyunit6      .
*            CONDENSE es_afvc-workcenterstandardworkqty6          .
*            CONDENSE es_afvc-costctractivitytype6                .
*            CONDENSE es_afvc-forecastworkquantity1               .
*            CONDENSE es_afvc-forecastworkquantity2               .
*            CONDENSE es_afvc-forecastworkquantity3               .
*            CONDENSE es_afvc-forecastworkquantity4               .
*            CONDENSE es_afvc-forecastworkquantity5               .
*            CONDENSE es_afvc-forecastworkquantity6               .
*            CONDENSE es_afvc-businessprocess                     .
*            CONDENSE es_afvc-businessprocessentryunit            .
*            CONDENSE es_afvc-businessprocessconfirmedqty        .
*            CONDENSE es_afvc-nofurtherbusinessprocqtyisexpd     .
*            CONDENSE es_afvc-businessprocremainingqtyunit       .
*            CONDENSE es_afvc-businessprocessremainingqty        .
*            CONDENSE es_afvc-setupopactyntwkinstance            .
*            CONDENSE es_afvc-produceopactyntwkinstance          .
*            CONDENSE es_afvc-teardownopactyntwkinstance         .
*            CONDENSE es_afvc-freedefinedtablefieldsemantic      .
*            CONDENSE es_afvc-freedefinedattribute01             .
*            CONDENSE es_afvc-freedefinedattribute02             .
*            CONDENSE es_afvc-freedefinedattribute03             .
*            CONDENSE es_afvc-freedefinedattribute04             .
*            CONDENSE es_afvc-freedefinedquantity1unit           .
*            CONDENSE es_afvc-freedefinedquantity1               .
*            CONDENSE es_afvc-freedefinedquantity2unit           .
*            CONDENSE es_afvc-freedefinedquantity2               .
*            CONDENSE es_afvc-freedefinedamount1currency         .
*            CONDENSE es_afvc-freedefinedamount1                 .
*            CONDENSE es_afvc-freedefinedamount2currency         .
*            CONDENSE es_afvc-freedefinedamount2                 .
*            CONDENSE es_afvc-freedefineddate1                   .
*            CONDENSE es_afvc-freedefineddate2                   .
*            CONDENSE es_afvc-freedefinedindicator1              .
*            CONDENSE es_afvc-freedefinedindicator2              .

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN 'MBEW'  OR 'mbew' .
        DATA lv_error_message_mbew TYPE string.

        TRY.
            SELECT *
              FROM i_productvaluationbasic WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_mbew).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_mbew).
            lv_error400 = 'X'.
            lv_error_message_mbew = lo_sql_error_mbew->get_text( ).
            lv_text = lv_error_message_mbew.
        ENDTRY.

        IF lt_mbew IS NOT INITIAL.
          LOOP  AT lt_mbew INTO DATA(ls_mbew).
            lv_count = lv_count + 1.
            es_mbew-product                            = ls_mbew-product                            .
            es_mbew-valuationarea                      = ls_mbew-valuationarea                      .
            es_mbew-valuationtype                      = ls_mbew-valuationtype                      .
            es_mbew-valuationclass                     = ls_mbew-valuationclass                     .
            es_mbew-pricedeterminationcontrol          = ls_mbew-pricedeterminationcontrol          .
            es_mbew-fiscalmonthcurrentperiod           = ls_mbew-fiscalmonthcurrentperiod           .
            es_mbew-fiscalyearcurrentperiod            = ls_mbew-fiscalyearcurrentperiod            .
            es_mbew-standardprice                      = ls_mbew-standardprice                      .
            es_mbew-priceunitqty                       = ls_mbew-priceunitqty                       .
            es_mbew-inventoryvaluationprocedure        = ls_mbew-inventoryvaluationprocedure        .
            es_mbew-futurepricevaliditystartdate       = ls_mbew-futurepricevaliditystartdate       .
            es_mbew-previnvtrypriceincocodecrcy        = ls_mbew-previnvtrypriceincocodecrcy        .
            es_mbew-movingaverageprice                 = ls_mbew-movingaverageprice                 .
            es_mbew-valuationcategory                  = ls_mbew-valuationcategory                  .
            es_mbew-productusagetype                   = ls_mbew-productusagetype                   .
            es_mbew-productorigintype                  = ls_mbew-productorigintype                  .
            es_mbew-isproducedinhouse                  = ls_mbew-isproducedinhouse                  .
            es_mbew-prodcostestnumber                  = ls_mbew-prodcostestnumber                  .
            es_mbew-ismarkedfordeletion                = ls_mbew-ismarkedfordeletion                .
            es_mbew-valuationmargin                    = ls_mbew-valuationmargin                    .
            es_mbew-isactiveentity                     = ls_mbew-isactiveentity                     .
            es_mbew-companycode                        = ls_mbew-companycode                        .
            es_mbew-valuationclasssalesorderstock      = ls_mbew-valuationclasssalesorderstock      .
            es_mbew-projectstockvaluationclass         = ls_mbew-projectstockvaluationclass         .
            es_mbew-taxbasedpricespriceunitqty         = ls_mbew-taxbasedpricespriceunitqty         .
            es_mbew-pricelastchangedate                = ls_mbew-pricelastchangedate                .
            es_mbew-futureprice                        = ls_mbew-futureprice                        .
            es_mbew-maintenancestatus                  = ls_mbew-maintenancestatus                  .
            es_mbew-currency                           = ls_mbew-currency                           .
            es_mbew-baseunit                           = ls_mbew-baseunit                           .
            es_mbew-mlisactiveatproductlevel           = ls_mbew-mlisactiveatproductlevel           .

            CONDENSE es_mbew-product                         .
            CONDENSE es_mbew-valuationarea                   .
            CONDENSE es_mbew-valuationtype                   .
            CONDENSE es_mbew-valuationclass                  .
            CONDENSE es_mbew-pricedeterminationcontrol       .
            CONDENSE es_mbew-fiscalmonthcurrentperiod        .
            CONDENSE es_mbew-fiscalyearcurrentperiod         .
            CONDENSE es_mbew-standardprice                   .
            CONDENSE es_mbew-priceunitqty                    .
            CONDENSE es_mbew-inventoryvaluationprocedure     .
            CONDENSE es_mbew-futurepricevaliditystartdate    .
            CONDENSE es_mbew-previnvtrypriceincocodecrcy     .
            CONDENSE es_mbew-movingaverageprice              .
            CONDENSE es_mbew-valuationcategory               .
            CONDENSE es_mbew-productusagetype                .
            CONDENSE es_mbew-productorigintype               .
            CONDENSE es_mbew-isproducedinhouse               .
            CONDENSE es_mbew-prodcostestnumber               .
            CONDENSE es_mbew-ismarkedfordeletion             .
            CONDENSE es_mbew-valuationmargin                 .
            CONDENSE es_mbew-isactiveentity                  .
            CONDENSE es_mbew-companycode                     .
            CONDENSE es_mbew-valuationclasssalesorderstock   .
            CONDENSE es_mbew-projectstockvaluationclass      .
            CONDENSE es_mbew-taxbasedpricespriceunitqty      .
            CONDENSE es_mbew-pricelastchangedate             .
            CONDENSE es_mbew-futureprice                     .
            CONDENSE es_mbew-maintenancestatus               .
            CONDENSE es_mbew-currency                        .
            CONDENSE es_mbew-baseunit                        .
            CONDENSE es_mbew-mlisactiveatproductlevel        .

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
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

*&--ADD BEGIN BY XINLEI XU 2025/02/17
      WHEN 'MARM' OR 'marm'.
        DATA: lv_error_message_marm TYPE string.

        TRY.
            SELECT *
              FROM i_productunitsofmeasure WITH PRIVILEGED ACCESS
             WHERE (lv_where)
              INTO TABLE @DATA(lt_marm).
          CATCH cx_sy_dynamic_osql_error INTO DATA(lo_sql_error_marm).
            lv_error400 = 'X'.
            lv_error_message_marm = lo_sql_error_marm->get_text( ).
            lv_text = lv_error_message_marm.

        ENDTRY.

        IF lt_marm IS NOT INITIAL.
          lv_count = lines( lt_marm ).
          LOOP AT lt_marm INTO DATA(ls_marm).
            APPEND INITIAL LINE TO es_response_marm-items ASSIGNING FIELD-SYMBOL(<lfs_marm_item>).
            <lfs_marm_item> = CORRESPONDING #( ls_marm ).
            TRY.
                <lfs_marm_item>-alternativeunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_marm_item>-alternativeunit ).
                <lfs_marm_item>-volumeunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_marm_item>-volumeunit ).
                <lfs_marm_item>-weightunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_marm_item>-weightunit ).
                <lfs_marm_item>-productmeasurementunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_marm_item>-productmeasurementunit ).
                <lfs_marm_item>-lowerlevelpackagingunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_marm_item>-lowerlevelpackagingunit ).
                <lfs_marm_item>-baseunit = zzcl_common_utils=>conversion_cunit( iv_alpha = zzcl_common_utils=>lc_alpha_out iv_input = <lfs_marm_item>-baseunit ).
                ##NO_HANDLER
              CATCH zzcx_custom_exception.
                " handle exception
            ENDTRY.
          ENDLOOP.

          response->set_status( '200' ).
          es_response_marm-message = |{ lv_count }件は送信されました。|.

          DATA(lv_marm_string) = xco_cp_json=>data->from_abap( es_response_marm )->to_string( ).

          response->set_text( lv_marm_string ).
          response->set_header_field( i_name  = lc_header_content
                                      i_value = lc_content_type ).
        ELSE.
          IF lv_error400 <> 'X'.
            lv_error = 'X'.  "204 no data
          ENDIF.
        ENDIF.

      WHEN OTHERS.
        lv_error400 = 'X'. "没有找到资源。
        lv_text = 'The table entry was not found'.
    ENDCASE.

    IF lv_error IS NOT INITIAL.
      response->set_status( '204' ).  "no data
      EXIT.

    ELSEIF lv_error400 IS NOT INITIAL.
      response->set_status( '400' ).  "bad request
      response->set_text( lv_text ).
      EXIT.

    ENDIF.

  ENDMETHOD.
ENDCLASS.
