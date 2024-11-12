@EndUserText.label: 'Pur Info Record Header'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PURINFORECORDHEADER
  provider contract transactional_query
  as projection on ZR_PURINFORECORDHEADER
{
  key UUID,
      PurchasingInfoRecord,
      Supplier,
      Material,
      PurchasingOrganization,
      Plant,
      PurchasingInfoRecordCategory,
      SupplierMaterialNumber,
      SupplierSubrange,
      SupplierMaterialGroup,
      SupplierCertOriginCountry,
      SupplierCertOriginRegion,
      SuplrCertOriginClassfctnNumber,
      PurgDocOrderQuantityUnit,
      OrderItemQtyToBaseQtyDnmntr,
      OrderItemQtyToBaseQtyNmrtr,
      MaterialPlannedDeliveryDurn,
      StandardPurchaseOrderQuantity,
      MinimumPurchaseOrderQuantity,
      ShippingInstruction,
      UnlimitedOverdeliveryIsAllowed,
      InvoiceIsGoodsReceiptBased,
      SupplierConfirmationControlKey,
      TaxCode,
      Currency,
      NetPriceAmount,
      MaterialPriceUnitQty,
      PurchaseOrderPriceUnit,
      OrdPriceUnitToOrderUnitDnmntr,
      OrderPriceUnitToOrderUnitNmrtr,
      PricingDateControl,
      IncotermsClassification,
      IncotermsLocation1,
      IncotermsLocation2,
      ConditionValidityStartDate,
      PriceValidityEndDate,
      Xflag,
      Status,
      Message,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      /* Associations */
      _Item : redirected to composition child ZC_PURINFORECORDITEM

}
