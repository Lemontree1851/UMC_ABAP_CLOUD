@EndUserText.label: '用于创建DN的SO信息'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_SALESORDER_U
  as projection on ZR_SALESORDER_U
{
  key SalesDocument     as SalesOrder,
  key SalesDocumentItem as SalesOrderItem,
      SalesOrganization,
      SalesGroup,
      SalesDocumentType as SalesOrderType,
      CreationDate,
      ShippingPoint,
      ShippingPointName,
      SoldToParty,
      CustomerName,
      BillingToParty,
      BillingToPartyName,
      ShipToParty,
      ShipToPartyName,
      PurchaseOrderByCustomer,
      UnderlyingPurchaseOrderItem,
      DeliveryBlockReason,
      DeliveryBlockReasonText,
      Material,
      MaterialByCustomer,
      Plant,
      TransitPlant,
      StorageLocation,
      StorageLocationName,
      Route,
      ShippingType,
      ShippingTypeName,
      @EndUserText.label: '指定納入日付（明細）'
      RequestedDeliveryDate,
      @EndUserText.label: '計画出庫日付'
      DeliveryDate,
      OrderQuantity,
      OrderQuantityUnit,
      IncotermsClassification,
      IncotermsTransferLocation,
      ConfdOrderQty,
      DeliveredQty,
      RemainingQty,
      CurrDeliveryQty,
      ShippingStorLoc,
      DeliveryDocument
      //SO行项目的长文本 长文本id 0001
      //    @ObjectModel.virtualElementCalculatedBy: 'ZCL_SALESORDER_U_CALC'
      //    virtual ItemRemark : abap.string
}
