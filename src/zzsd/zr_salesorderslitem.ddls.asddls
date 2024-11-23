@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '合并SO计划行信息'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_SalesOrderSLItem
  as select from I_SalesDocumentScheduleLine
{
  key SalesDocument,
  key SalesDocumentItem,
      min(DeliveryDate)                  as DeliveryDate,
      @Semantics.quantity.unitOfMeasure: 'OrderQuantityUnit'
      sum(ConfdOrderQtyByMatlAvailCheck) as ConfdOrderQty,
      OrderQuantityUnit

}
where ConfdOrderQtyByMatlAvailCheck > 0
group by
  SalesDocument,
  SalesDocumentItem,
  OrderQuantityUnit
