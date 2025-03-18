@AbapCatalog.sqlViewName: 'ZPOITEMS01'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Purchase Order Items View'
define view ZC_POMM01
  as select from    I_PurchaseOrderItemAPI01      as b
    left outer join I_POSupplierConfirmationAPI01 as l on  l.PurchaseOrder     = b.PurchaseOrder
                                                       and l.PurchaseOrderItem = b.PurchaseOrderItem

  // MOD BEGIN BY XINLEI XU 2025/03/18
  //  association [1..1] to I_PurchaseOrderAPI01        as a on  $projection.PurchaseOrder = a.PurchaseOrder
    left outer join I_PurchaseOrderAPI01          as a on a.PurchaseOrder = b.PurchaseOrder
  // MOD END BY XINLEI XU 2025/03/18

  association [1..1] to I_Supplier                  as c on  $projection.Manufacturer = c.Supplier
  association [0..1] to I_ProductMRPArea            as d on  d.Product  = b.Material
                                                         and d.MRPPlant = b.Plant
  association [0..1] to I_ProductPlantBasic         as e on  e.Product = b.Material
                                                         and e.Plant   = b.Plant

  // MOD BEGIN BY XINLEI XU 2025/03/18
  //  association [0..1] to I_PurchasingInfoRecordApi01 as g on  g.PurchasingInfoRecord = b.PurchasingInfoRecord
  association [0..1] to I_PurchasingInfoRecordApi01 as g on  g.Supplier  = a.Supplier
                                                         and g.Material  = b.Material
                                                         and g.IsDeleted is initial
  // MOD END BY XINLEI XU 2025/03/18

  association [0..1] to I_StorageLocation           as h on  h.Plant           = b.Plant
                                                         and h.StorageLocation = b.StorageLocation
  association [0..1] to I_Product                   as i on  i.Product = b.Material
  association [0..1] to I_ProductSupplyPlanning     as k on  k.Product = b.Material
                                                         and k.Plant   = b.Plant
  association [0..1] to I_PurOrdScheduleLineAPI01   as m on  m.PurchaseOrder     = b.PurchaseOrder
                                                         and m.PurchaseOrderItem = b.PurchaseOrderItem
{
  key b.PurchaseOrder,
  key b.PurchaseOrderItem,
  key l.SequentialNmbrOfSuplrConf,

      concat(b.PurchaseOrder,b.PurchaseOrderItem)                         as popoitem,
      l.DeliveryDate,

      l.SupplierConfirmationExtNumber,
      l.OrderQuantityUnit,
      l.MRPRelevantQuantity,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      l.ConfirmedQuantity,
      a.PurchaseOrderType,
      a.Supplier,
      a.PurchasingGroup,
      a.PurchaseOrderDate,
      a.DocumentCurrency,
      a.PurchasingOrganization,
      a.CreatedByUser,
      a.CorrespncInternalReference,

      case when a.CorrespncExternalReference = ''  then ''
      else concat(a.CorrespncExternalReference,b.PurchaseOrderItem)   end as CorrespncExternalReference,
      b.Material,
      b.PurchaseOrderItemText,
      b.ManufacturerMaterial,
      b.ManufacturerPartNmbr,
      b.Manufacturer,
      b.AccountAssignmentCategory,
      c.SupplierName                                                      as SupplierName2,
      b.PlannedDeliveryDurationInDays,
      b.GoodsReceiptDurationInDays,
      b.OrderQuantity,
      b.PurchaseOrderQuantityUnit,
      b.PurchaseRequisition,
      b.PurchaseRequisitionItem,
      b.RequirementTracking,
      b.RequisitionerName,
      b.InternationalArticleNumber,
      b.MaterialGroup,
      b.NetAmount,
      b.Plant,
      b.StorageLocation,
      b.IsCompletelyDelivered,
      b.TaxCode,
      b.PricingDateControl,
      // b.IncotermsClassification, DEL BY XINLEI XU 2025/03/18 I_PurgInfoRecdOrgPlntDataApi01-IncotermsClassification
      b.NetPriceQuantity,
      b.NetPriceAmount,
      b.PurchaseOrderItemCategory,
      b.SupplierMaterialNumber,
      b.PurchasingDocumentDeletionCode,
      d.MRPArea,
      e.MRPResponsible,
      g.SupplierCertOriginCountry,
      g.PurchasingInfoRecord,
      g.SupplierSubrange,
      h.StorageLocationName,
      i.ProductionMemoPageFormat,
      i.ProductionOrInspectionMemoTxt,
      i.YY1_BPCODE_PRD_PRD,
      k.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      k.LotSizeRoundingQuantity,
      m.ScheduleLineDeliveryDate,
      m.RoughGoodsReceiptQty
}
where
  b.PurchasingDocumentDeletionCode = ''
