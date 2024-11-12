@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'TWX21検収データ取込み機能 DN'
define root view entity ZC_SALESDOCUMENTFORDN
  as select from ZR_SALESDOCUMENTFORDN as main
  left outer join ZR_SalesOrderDeliveredQty as _DeliveredQty
    on main.SalesDocument = _DeliveredQty.SalesDocument
    and main.SalesDocumentItem = _DeliveredQty.SalesDocumentItem
{
  key main.SalesDocument,
  key main.SalesDocumentItem,
      main.SalesOrganization,
      cast('LF' as abap.char(4) )                                                       as DeliveryDocumentType,
      cast('出荷伝票' as abap.char(200))                                                 as DeliveryDocumentText,
      main.SoldToParty,
      concat(main._SoldToPartyName.OrganizationBPName1,main._SoldToPartyName.OrganizationBPName2) as SoldToPartyName,
      main.BillToParty,
      concat(main._BillToPartyName.OrganizationBPName1,main._BillToPartyName.OrganizationBPName2) as BillToPartyName,
      main.PurchaseOrderByCustomer,
      main.DeliveryBlockReason,
      main._DeliveryBlockReasonText.DeliveryBlockReasonText,

      main._Item.UnderlyingPurchaseOrderItem,
      main._Item.Product,
      main._Item.MaterialByCustomer,
      main._Item.Plant,
      main._Item.ShippingPoint,
      main.ShipToParty,
      concat(main._ShipToPartyName.OrganizationBPName1,main._ShipToPartyName.OrganizationBPName2) as ShipToPartyName,
      main._Item.StorageLocation,
      main._Item.CommittedDeliveryDate,
      main._Item.OrderQuantity,
      main._Item.OrderQuantityUnit,
      main._Item.IncotermsClassification,
      main._Item.IncotermsLocation1,
      //出荷数量
      _DeliveredQty.DeliveredQtyInOrderQtyUnit,
      //受注残 
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      main._Item.OrderQuantity - _DeliveredQty.DeliveredQtyInOrderQtyUnit as UnDeliveredQty
}
