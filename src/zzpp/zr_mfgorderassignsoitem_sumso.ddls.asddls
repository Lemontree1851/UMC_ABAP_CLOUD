@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Assign SO Item Sum SO'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MFGORDERASSIGNSOITEM_SUMSO
  as select from ztpp_1014
{
  key sales_order       as SalesOrder,
  key sales_order_item  as SalesOrderItem,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      sum( assign_qty ) as TotalAssignQty,
      production_unit   as ProductionUnit
}
group by
  sales_order,
  sales_order_item,
  production_unit
