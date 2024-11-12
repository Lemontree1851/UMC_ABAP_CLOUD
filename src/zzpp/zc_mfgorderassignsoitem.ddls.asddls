@EndUserText.label: 'Manufacturing Order Assign SO Item'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_MFGORDERASSIGNSOITEM
  provider contract transactional_query
  as projection on ZR_MFGORDERASSIGNSOITEM
{
  key Plant,
  key ManufacturingOrder,
  key SalesOrder,
  key SalesOrderItem,
  key Sequence,
      ProductionSupervisor,
      MRPController,
      Material,
      MfgOrderPlannedStartDate,
      MfgOrderPlannedTotalQty,
      ProductionUnit,
      AssignQty,
      Remark,
      CreatedAt,
      CreatedBy,
      LastChangedAt,
      LastChangedBy,
      LocalLastChangedAt,

      PurchaseOrderByCustomer,
      RequestedQuantityInBaseUnit,
      BaseUnit,

      UnAssignQty,
      _SumAssignQty.TotalAssignQty,

      _ScheduleLine.RequestedDeliveryDate,

      _SOItem,
      _ScheduleLine
}
