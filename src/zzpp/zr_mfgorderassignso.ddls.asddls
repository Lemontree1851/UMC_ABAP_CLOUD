@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Assign SO'
define root view entity ZR_MFGORDERASSIGNSO
  as select from    I_ManufacturingOrderItem as _MfgOrder
    left outer join ztpp_1014                as _AssignItem  on  _AssignItem.plant               = _MfgOrder.ProductionPlant
                                                             and _AssignItem.manufacturing_order = _MfgOrder.ManufacturingOrder
                                                             and _AssignItem.assign_qty          > 0
    left outer join I_SalesDocumentItem      as _SOItem      on  _SOItem.SalesDocument     = _AssignItem.sales_order
                                                             and _SOItem.SalesDocumentItem = _AssignItem.sales_order_item

    inner join      ZR_TBC1006               as _AssignPlant on _AssignPlant.Plant = _MfgOrder.ProductionPlant
    inner join      ZC_BusinessUserEmail     as _User        on  _User.Email  = _AssignPlant.Mail
                                                             and _User.UserID = $session.user

  association [1..1] to ZR_MFGORDERASSIGNSOITEM_SUMMFG as _SumAssignQty on  $projection.ProductionPlant    = _SumAssignQty.Plant
                                                                        and $projection.ManufacturingOrder = _SumAssignQty.ManufacturingOrder

  association [1..*] to ZR_MFGORDERASSIGNSOITEM        as _AssignSOItem on  $projection.ProductionPlant    = _AssignSOItem.Plant
                                                                        and $projection.ManufacturingOrder = _AssignSOItem.ManufacturingOrder
                                                                        and _AssignSOItem.AssignQty        > 0
{
  key _MfgOrder.ProductionPlant,
  key _MfgOrder.ManufacturingOrder,
  key case when _AssignItem.sales_order is null
           then ''
           else _AssignItem.sales_order
           end                                                                as SalesOrder,
  key case when _AssignItem.sales_order_item is null
           then '000000'
           else _AssignItem.sales_order_item
           end                                                                as SalesOrderItem,
  key case when _AssignItem.sequence is null
           then '000'
           else _AssignItem.sequence end                                      as Sequence,
      _MfgOrder.MRPController,
      _MfgOrder.ProductionSupervisor,
      cast(_MfgOrder.Material as matnr preserving type)                       as Material,
      _MfgOrder.ProductionVersion,
      _MfgOrder.MfgOrderPlannedStartDate,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      _MfgOrder.MfgOrderPlannedTotalQty,
      _MfgOrder.ProductionUnit,

      case when _MfgOrder.OrderIsReleased is not initial then 'X' else '' end as OrderIsReleased,

      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      _AssignItem.assign_qty                                                  as AssignQty,

      _SOItem.PurchaseOrderByCustomer,
      cast(_SOItem.Material as matnr preserving type)                         as ItemMaterial,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      cast( _SOItem.RequestedQuantityInBaseUnit as abap.quan( 15, 3 ) )       as RequestedQuantityInBaseUnit,

      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      case when _SumAssignQty.TotalAssignQty is null
           then _MfgOrder.MfgOrderPlannedTotalQty
           else _MfgOrder.MfgOrderPlannedTotalQty - _SumAssignQty.TotalAssignQty
      end                                                                     as AvailableAssignQty,

      _AssignSOItem
}
where
      _MfgOrder.IsMarkedForDeletion          = ''
  and _MfgOrder.OrderItemIsNotRelevantForMRP = ''
