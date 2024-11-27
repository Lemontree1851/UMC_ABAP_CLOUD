@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '从标准cds中取出能用到的所有字段'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_SALESORDERBASIC
  as select from    I_SalesDocument     as vbak
    inner join      I_SalesDocumentItem as vbap             on vbap.SalesDocument = vbak.SalesDocument
    left outer join ZR_SalesOrderSLItem as vbep             on  vbap.SalesDocument     = vbep.SalesDocument
                                                            and vbap.SalesDocumentItem = vbep.SalesDocumentItem
//    left outer join ZR_DELIVERYEDQTY    as DeliveryedQty    on  DeliveryedQty.SalesOrder     = vbap.SalesDocument
//                                                            and DeliveryedQty.SalesOrderItem = vbap.SalesDocumentItem
//                                                            and DeliveryedQty.BaseUnit       = vbap.OrderQuantityUnit
//    left outer join I_RouteText         as _RouteText       on  _RouteText.Route    = vbap.Route
//                                                            and _RouteText.Language = $session.system_language
{
  key vbak.SalesDocument,
  key vbap.SalesDocumentItem,
      vbak.SalesOrganization,
      vbak.SalesDocumentType,
      vbak.YY1_SalesDocType_SDH, //受注伝票タイプ（Old）
      vbak.SalesOffice,
      vbak.SalesGroup,
      vbak.CreationDate,
      vbap.ShippingPoint,
      vbap._ShippingPointText[ Language = $session.system_language ].ShippingPointName,
      vbak.SoldToParty,
      vbak._SoldToParty.CustomerName,
      vbak._Partner[1: PartnerFunction = 'RE'].Customer    as BillingToParty,
      vbak._Partner[1: PartnerFunction = 'RE'].FullName    as BillingToPartyName,
      vbak._Partner[1: PartnerFunction = 'WE'].Customer    as ShipToParty,
      vbak._Partner[1: PartnerFunction = 'WE'].FullName    as ShipToPartyName,

      //客户PO
      vbak.PurchaseOrderByCustomer,
      // 客户PO行
      vbap.UnderlyingPurchaseOrderItem,
      //交货冻结码
      vbak.DeliveryBlockReason,
      //交货冻结原因
      vbak._DeliveryBlockReason._Text.DeliveryBlockReasonText,
      vbap.Material,
      vbap.MaterialByCustomer,
      vbap.Plant,
      vbap.TransitPlant,
      //库存地
      vbap.StorageLocation,
      vbap._StorageLocation.StorageLocationName,
      vbap.Route,
//      vbap._Route._Text.RouteName,
      //装运类型
      vbap.ShippingType,
      vbap._ShippingType._Text[ Language = $session.system_language ].ShippingTypeName,
      //指定納入日付（明細）
      vbap.RequestedDeliveryDate,
      //计划行最小的日期 計画出庫日付?
      vbep.DeliveryDate,
      vbap.OrderQuantity,
      vbap.OrderQuantityUnit,
      vbap.IncotermsClassification,
      vbap.IncotermsTransferLocation,
      //确定数量
      vbep.ConfdOrderQty,
      //已发货数量
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      vbep.DeliveredQty,
      //剩余数量
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      vbep.RemainingQty
}
where
       vbap.SalesDocumentRjcnReason = ''
  and(
       vbap.TotalDeliveryStatus     = 'A'
    or vbap.TotalDeliveryStatus     = 'B'
  )
//删除 确认数量为0的数据
