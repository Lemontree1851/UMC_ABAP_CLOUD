@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '用于创建DN的SO信息'
define root view entity ZR_SALESORDER_U
  as select from    ZR_SALESORDERBASIC          as basic
    left outer join ZTF_SALESORDERSTORLOC(
                        clnt: $session.client ) as SalesStorLoc on  SalesStorLoc.SalesOrder     = basic.SalesOrder
                                                                and SalesStorLoc.SalesOrderItem = basic.SalesOrderItem
{
  key basic.SalesOrder,
  key basic.SalesOrderItem,
      basic.SalesOrganization,
      basic.SalesOrderType,
      basic.CreationDate,
      basic.ShippingPoint,
      basic.DeliveryType,
      basic.DeliveryTypeDesc,
      basic.SoldToParty,
      basic.CustomerName,
      basic.BillingToParty,
      basic.PurchaseOrderByCustomer,
      basic.UnderlyingPurchaseOrderItem,
      basic.DeliveryBlockReason,
      basic.DeliveryBlockReasonText,
      basic.Material,
      basic.MaterialByCustomer,
      basic.Plant,
      basic.ShippingType,
      basic.ShipToParty,
      basic.ShipToPartyName,
      SalesStorLoc.StorageLocation,
      basic.DeliveryDate,
      basic.OrderQuantity,
      basic.OrderQuantityUnit,
      basic.IncotermsClassification,
      basic.IncotermsTransferLocation,
      basic.ConfdOrderQty,
      basic.DeliveredQty,
      basic.RemainingQty,
      basic.CurrDeliveryQty,
      SalesStorLoc.StorageLocation as ShippingStorLoc,
      basic.DeliveryDocument
}
// where 删除 确认数量为0的数据
