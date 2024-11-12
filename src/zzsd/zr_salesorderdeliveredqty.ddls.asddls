@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '统计SO行项目维度的已交货数量'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
define view entity ZR_SalesOrderDeliveredQty
  as select from I_SalesDocumentScheduleLine
{
  key SalesDocument,
  key SalesDocumentItem,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum( DeliveredQtyInOrderQtyUnit ) as DeliveredQtyInOrderQtyUnit,
      OrderQuantityUnit
}
where
  IsConfirmedDelivSchedLine = 'X'
group by
  SalesDocument,
  SalesDocumentItem,
  OrderQuantityUnit
