@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '用于创建DN的SO信息'
define root view entity ZR_SALESORDER_U
  as select from    ZR_SALESORDERBASIC          as basic
    left outer join ZTF_SALESORDERSTORLOC(
                        clnt: $session.client ) as SalesStorLoc on  SalesStorLoc.SalesDocument     = basic.SalesDocument
                                                                and SalesStorLoc.SalesDocumentItem = basic.SalesDocumentItem
  association [1..1] to I_SalesOrderItemTextTP as _Text on  _Text.SalesOrder     = $projection.SalesDocument
                                                        and _Text.SalesOrderItem = $projection.SalesDocumentItem
                                                        and _Text.Language       = $session.system_language
                                                        and _Text.LongTextID     = '0001'
{
  key basic.SalesDocument,
  key basic.SalesDocumentItem,
      basic.SalesOrganization,
      basic.SalesOffice,
      basic.SalesGroup,
      basic.SalesDocumentType,
      basic.YY1_SalesDocType_SDH, //受注伝票タイプ（Old）
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
      //本次交货数量（手动输入
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      cast(0 as menge_d)             as CurrDeliveryQty,
      @Consumption.valueHelpDefinition: [{  entity:{ name: 'I_StorageLocationStdVH', element: 'StorageLocation' },
                                            additionalBinding: [{ localElement: 'Plant', element: 'Plant', usage: #FILTER }] }]
      SalesStorLoc.StorageLocation   as CurrStorageLocation,
      @Consumption.valueHelpDefinition: [{  entity:{ name: 'I_ShippingTypeText', element: 'ShippingType' },
                                            additionalBinding: [{ localElement: 'Language', element: 'Language', usage: #FILTER }] }]
      cast( '' as abap.char(2) )     as CurrShippingType,
      cast( '00000000' as datum )    as CurrPlannedGoodsIssueDate,
      cast( '00000000' as datum )    as CurrDeliveryDate,
      // 生成的dn 可跳转至VL03N
      cast('' as vbeln_vl)           as DeliveryDocument,
      cast('' as posnr )             as DeliveryDocumentItem,
      cast('' as msgty )              as Type,
      cast('' as abap.char(10))      as Status,
      cast('' as abap.sstring(1000)) as Message,
      $session.system_language as Language,
      _Text
}
// where 删除 确认数量为0的数据
