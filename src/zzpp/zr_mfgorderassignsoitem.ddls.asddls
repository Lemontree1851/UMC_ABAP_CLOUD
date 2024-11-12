@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Assign SO Item'
define root view entity ZR_MFGORDERASSIGNSOITEM
  as select from ztpp_1014

  association [1..1] to ZR_MFGORDERASSIGNSOITEM_SUMSO as _SumAssignQty on  $projection.SalesOrder     = _SumAssignQty.SalesOrder
                                                                       and $projection.SalesOrderItem = _SumAssignQty.SalesOrderItem
  association [1..1] to I_SalesDocumentItem           as _SOItem       on  $projection.SalesOrder     = _SOItem.SalesDocument
                                                                       and $projection.SalesOrderItem = _SOItem.SalesDocumentItem
  association [1..1] to I_SalesOrderScheduleLine      as _ScheduleLine on  $projection.SalesOrder     = _ScheduleLine.SalesOrder
                                                                       and $projection.SalesOrderItem = _ScheduleLine.SalesOrderItem
                                                                       and _ScheduleLine.ScheduleLine = '0001'
{
  key plant                                            as Plant,
  key manufacturing_order                              as ManufacturingOrder,
  key sales_order                                      as SalesOrder,
  key sales_order_item                                 as SalesOrderItem,
  key sequence                                         as Sequence,
      production_supervisor                            as ProductionSupervisor,
      m_r_p_controller                                 as MRPController,
      material                                         as Material,
      mfg_order_planned_start_date                     as MfgOrderPlannedStartDate,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      mfg_order_planned_total_qty                      as MfgOrderPlannedTotalQty,
      production_unit                                  as ProductionUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      assign_qty                                       as AssignQty,
      remark                                           as Remark,
      created_at                                       as CreatedAt,
      created_by                                       as CreatedBy,
      last_changed_at                                  as LastChangedAt,
      last_changed_by                                  as LastChangedBy,
      local_last_changed_at                            as LocalLastChangedAt,

      _SOItem.PurchaseOrderByCustomer,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      _SOItem.RequestedQuantityInBaseUnit,
      _SOItem.BaseUnit,
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      _SOItem.RequestedQuantityInBaseUnit - assign_qty as UnAssignQty,

      _SumAssignQty,
      _SOItem,
      _ScheduleLine
}
