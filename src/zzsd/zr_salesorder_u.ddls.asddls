@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '用于创建DN的SO信息'
define root view entity ZR_SALESORDER_U
  as select from    ZR_SALESORDERBASIC          as basic
  //权限控制
    inner join      ZR_TBC1006                  as _AssignPlant     on _AssignPlant.Plant = basic.Plant
    inner join      ZR_TBC1013                  as _AssignSalesOrg  on _AssignSalesOrg.SalesOrganization = basic.SalesOrganization
    inner join      ZR_TBC1018                  as _AssignShipPoint on _AssignShipPoint.ShippingPoint = basic.ShippingPoint
    inner join      ZC_BusinessUserEmail        as _User            on  _User.Email  = _AssignPlant.Mail
                                                                    and _User.Email  = _AssignSalesOrg.Mail
                                                                    and _User.Email  = _AssignShipPoint.Mail
                                                                    and _User.UserID = $session.user
    left outer join ZTF_SALESORDERSTORLOC(
                        clnt: $session.client ) as SalesStorLoc     on  SalesStorLoc.SalesDocument     = basic.SalesDocument
                                                                    and SalesStorLoc.SalesDocumentItem = basic.SalesDocumentItem
  association [1..1] to I_SalesOrderItemTextTP as _Text on  _Text.SalesOrder     = $projection.SalesDocument
                                                        and _Text.SalesOrderItem = $projection.SalesDocumentItem
                                                        and _Text.Language       = $session.system_language
                                                        and _Text.LongTextID     = '0001'
{
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_SalesDocumentStdVH', element: 'SalesDocument' } }]
  key basic.SalesDocument,
      @Consumption.filter.hidden: true
  key basic.SalesDocumentItem,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZC_SalesOrganization_VH', element: 'SalesOrganization' } }]
      basic.SalesOrganization,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZR_SalesOfficeVH', element: 'SalesOffice' } }]
      basic.SalesOffice,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'ZR_SalesGroupVH', element: 'SalesGroup' } }]
      basic.SalesGroup,
      @Consumption.filter.hidden: true
      basic.SalesDocumentType,
      basic.YY1_SalesDocType_SDH, //受注伝票タイプ（Old）
      basic.CreationDate,
      @EndUserText.label: '出荷ポイント'
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_ShippingPointStdVH', element: 'ShippingPoint' } }]
      cast( basic.ShippingPoint as abap.char(4) ) as ShippingPoint,
      @Consumption.filter.hidden: true
      basic.ShippingPointName,
      basic.SoldToParty,
      @Consumption.filter.hidden: true
      basic.CustomerName,
      @Consumption.filter.hidden: true
      basic.BillingToParty,
      @Consumption.filter.hidden: true
      basic.BillingToPartyName,
      basic.PurchaseOrderByCustomer,
      @Consumption.filter.hidden: true
      basic.UnderlyingPurchaseOrderItem,
      @Consumption.filter.hidden: true
      basic.DeliveryBlockReason,
      @Consumption.filter.hidden: true
      basic.DeliveryBlockReasonText,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_Product', element: 'Product' } }]
      basic.Material,
      @Consumption.filter.hidden: true
      basic.MaterialByCustomer,
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_Plant', element: 'Plant' } }]
      basic.Plant,
      @Consumption.filter.hidden: true
      basic.TransitPlant,
      @Consumption.filter.hidden: true
      @Consumption.valueHelpDefinition: [{ entity:{ name: 'I_StorageLocationStdVH', element: 'StorageLocation' },
                                           additionalBinding: [{ localElement: 'Plant', element: 'Plant', usage: #FILTER }] }]
      basic.StorageLocation,
      @Consumption.filter.hidden: true
      basic.StorageLocationName,
      @Consumption.filter.hidden: true
      basic.Route,
      @Consumption.filter.hidden: true
      basic.ShippingType,
      @Consumption.filter.hidden: true
      basic.ShippingTypeName,
      basic.ShipToParty,
      @Consumption.filter.hidden: true
      basic.ShipToPartyName,
      basic.RequestedDeliveryDate,
      basic.GoodsIssueDate,
      @Consumption.filter.hidden: true
      basic.OrderQuantity,
      @Consumption.filter.hidden: true
      basic.OrderQuantityUnit,
      @Consumption.filter.hidden: true
      basic.IncotermsClassification,
      @Consumption.filter.hidden: true
      basic.IncotermsTransferLocation,
      @Consumption.filter.hidden: true
      basic.ConfdOrderQty,
      @Consumption.filter.hidden: true
      basic.DeliveredQty,
      @Consumption.filter.hidden: true
      basic.RemainingQty,
      //本次交货数量（手动输入
      @Consumption.filter.hidden: true
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      cast(0 as menge_d)                          as CurrDeliveryQty,
      @Consumption.filter.hidden: true
      @Consumption.valueHelpDefinition: [{  entity:{ name: 'I_StorageLocationStdVH', element: 'StorageLocation' },
                                            additionalBinding: [{ localElement: 'Plant', element: 'Plant', usage: #FILTER }] }]
      SalesStorLoc.StorageLocation                as CurrStorageLocation,
      @Consumption.valueHelpDefinition: [{  entity:{ name: 'ZR_ShippingTypeVH', element: 'ShippingType' } }]
      @Consumption.filter.hidden: true
      cast( '' as abap.char(2) )                  as CurrShippingType,
      @Semantics.dateTime: false
      @Consumption.filter.hidden: true
      cast( '00000000' as datum )                 as CurrPlannedGoodsIssueDate,
      @Consumption.filter.hidden: true
      cast( '00000000' as datum )                 as CurrDeliveryDate,
      // 生成的dn 可跳转至VL03N
      @Consumption.filter.hidden: true
      cast('' as vbeln_vl)                        as DeliveryDocument,
      @Consumption.filter.hidden: true
      // MOD BEGIN BY XINLEI XU 2025/03/18 BUG Fix
      // cast('' as posnr )                    as DeliveryDocumentItem,
      cast('000000' as posnr )                    as DeliveryDocumentItem,
      // MOD END BY XINLEI XU 2025/03/18
      @Consumption.filter.hidden: true
      cast('' as msgty )                          as Type,
      @Consumption.filter.hidden: true
      cast('' as abap.char(10))                   as Status,
      @Consumption.filter.hidden: true
      cast('' as abap.sstring(1000))              as Message,
      //      $session.system_language as Language,
      _Text
}
// where 删除 确认数量为0的数据
