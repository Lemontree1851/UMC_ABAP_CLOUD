@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '从标准cds中取出能用到的所有字段'
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_SALESORDERBASIC
  as select from    I_SalesOrder                as vbak
    inner join      I_SalesOrderItem            as vbap          on vbap.SalesOrder = vbak.SalesOrder
    left outer join ZR_SalesOrderSLItem         as vbep          on  vbap.SalesOrder     = vbep.SalesOrder
                                                                 and vbap.SalesOrderItem = vbep.SalesOrderItem
    left outer join ZR_DELIVERYEDQTY            as DeliveryedQty on  DeliveryedQty.SalesOrder     = vbap.SalesOrder
                                                                 and DeliveryedQty.SalesOrderItem = vbap.SalesOrderItem
                                                                 and DeliveryedQty.BaseUnit       = vbap.OrderQuantityUnit
    left outer join ZTF_SALESORDERSTORLOC(
                        clnt: $session.client ) as SalesStorLoc  on  SalesStorLoc.SalesOrder     = vbap.SalesOrder
                                                                 and SalesStorLoc.SalesOrderItem = vbap.SalesOrderItem
{
  key vbak.SalesOrder,
  key vbak._Item.SalesOrderItem,
      vbak.SalesOrganization,
      vbak.SalesOrderType,
      vbak.CreationDate,
      vbak._Item.ShippingPoint,
      cast('' as abap.char(4))                             as DeliveryType, //tvak~lfarv"交货类型 delivery type
      //交货类型描述
      cast('' as abap.char(220))                           as DeliveryTypeDesc,
      vbak.SoldToParty,
      vbak._SoldToParty.CustomerName,
      vbak._Partner[1: PartnerFunction = 'RE'].Customer    as BillingToParty,

      //客户PO
      vbak.PurchaseOrderByCustomer,
      // 客户PO行
      vbak._Item.UnderlyingPurchaseOrderItem,
      //交货冻结码
      vbak.DeliveryBlockReason,
      //交货冻结原因
      vbak._DeliveryBlockReason._Text.DeliveryBlockReasonText,
      vbak._Item.Material,
      vbak._Item.MaterialByCustomer,
      vbak._Item.Plant,
      //装运类型
      vbak._Item.ShippingType,
      vbak._Partner[1: PartnerFunction = 'WE'].Customer    as ShipToParty,
      vbak._Partner[1: PartnerFunction = 'WE'].FullName    as ShipToPartyName,
      //库存地点 自定义逻辑
      SalesStorLoc.StorageLocation                         as StorageLocation, //lgort
      //计划行最小的日期
      vbep.DeliveryDate,
      vbak._Item.OrderQuantity,
      vbak._Item.OrderQuantityUnit,
      vbak._Item.IncotermsClassification,
      vbak._Item.IncotermsTransferLocation,

      //确定数量
      vbep.ConfdOrderQty,
      //已发货数量
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      // FIXME 当前CDS数量单位为订单单位，但取值的DN数量为基本单位，当两者不一致时会取不到值 by zoukun
      DeliveryedQty.DeliveredQuantity                      as DeliveredQty,
      //剩余数量
      //如果vbup-lfsta  = A 未发货 送货数量=0 剩余数量就等于确认数量,但vbup表根本没有值，所以当做不等于A处理？
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      vbep.ConfdOrderQty - DeliveryedQty.DeliveredQuantity as RemainingQty,

      //本次交货数量（手动输入
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      cast(0 as menge_d)                                   as CurrDeliveryQty,
      //新库存地点，默认和自定义逻辑的库存地点相同，可修改 搜索帮助 mard
      SalesStorLoc.StorageLocation                         as ShippingStorLoc,
      // 生成的dn 可跳转至VL03N
      cast('' as abap.numc( 10 ))                          as DeliveryDocument
      //message 执行结果
}
where
     vbak.SalesOrderType = 'SO-5'
  or vbak.SalesOrderType = 'SO-5'
  or vbak.SalesOrderType = 'SO-B'
//删除 确认数量为0的数据
