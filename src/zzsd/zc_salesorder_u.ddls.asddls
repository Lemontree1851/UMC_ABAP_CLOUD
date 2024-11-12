@EndUserText.label: '用于创建DN的SO信息'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_SALESORDER_U
  as projection on ZR_SALESORDER_U
{
  key SalesOrder,
  key SalesOrderItem,
      SalesOrganization,
      SalesOrderType,
      CreationDate,
      ShippingPoint,
      DeliveryType,
      DeliveryTypeDesc,
      SoldToParty,
      CustomerName,
      BillingToParty,
      PurchaseOrderByCustomer,
      UnderlyingPurchaseOrderItem,
      DeliveryBlockReason,
      DeliveryBlockReasonText,
      Material,
      MaterialByCustomer,
      Plant,
      ShippingType,
      ShipToParty,
      ShipToPartyName,
      StorageLocation,
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
