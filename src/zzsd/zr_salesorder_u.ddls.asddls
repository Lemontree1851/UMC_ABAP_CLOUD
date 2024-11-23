@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '用于创建DN的SO信息'
define root view entity ZR_SALESORDER_U
  as select from    ZR_SALESORDERBASIC          as basic
    left outer join ZTF_SALESORDERSTORLOC(
                        clnt: $session.client ) as SalesStorLoc on  SalesStorLoc.SalesDocument     = basic.SalesDocument
                                                                and SalesStorLoc.SalesDocumentItem = basic.SalesDocumentItem
{
  key basic.SalesDocument,
  key basic.SalesDocumentItem,
      basic.SalesOrganization,
      basic.SalesGroup,
      basic.SalesDocumentType,
      basic.CreationDate,
      basic.ShippingPoint,
      basic.ShippingPointName,
      basic.SoldToParty,
      basic.CustomerName,
      basic.BillingToParty,
      basic.BillingToPartyName,
      basic.PurchaseOrderByCustomer,
      basic.UnderlyingPurchaseOrderItem,
      basic.DeliveryBlockReason,
      basic.DeliveryBlockReasonText,
      basic.Material,
      basic.MaterialByCustomer,
      basic.Plant,
      basic.TransitPlant,
      basic.StorageLocation,
      basic.StorageLocationName,
      basic.Route,
      basic.ShippingType,
      basic.ShippingTypeName,
      basic.ShipToParty,
      basic.ShipToPartyName,
      basic.RequestedDeliveryDate,
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
