@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Assign SO Item Sum MfgOrder'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_MFGORDERASSIGNSOITEM_SUMMFG
  as select from ztpp_1014
{
  key plant               as Plant,
  key manufacturing_order as ManufacturingOrder,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      sum( assign_qty )   as TotalAssignQty,
      production_unit     as ProductionUnit
}
group by
  plant,
  manufacturing_order,
  production_unit
