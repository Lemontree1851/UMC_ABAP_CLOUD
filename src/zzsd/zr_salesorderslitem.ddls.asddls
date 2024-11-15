@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '合并SO计划行信息'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SalesOrderSLItem as select from I_SalesOrderScheduleLine
{
    key SalesOrder,
    key SalesOrderItem,
    min(DeliveryDate) as DeliveryDate,
    @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
    sum(ConfdOrderQtyByMatlAvailCheck) as ConfdOrderQty,
    OrderQuantityUnit
   
}
group by
    SalesOrder,
    SalesOrderItem,
    OrderQuantityUnit
