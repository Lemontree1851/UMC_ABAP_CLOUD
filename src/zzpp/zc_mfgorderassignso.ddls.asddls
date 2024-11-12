@EndUserText.label: 'Manufacturing Order Assign SO'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_MFGORDERASSIGNSO
  provider contract transactional_query
  as projection on ZR_MFGORDERASSIGNSO
{
  key ProductionPlant,
  key ManufacturingOrder,
  key SalesOrder,
  key SalesOrderItem,
  key Sequence,
      MRPController,
      ProductionSupervisor,
      Material,
      ProductionVersion,
      MfgOrderPlannedStartDate,
      MfgOrderPlannedTotalQty,
      ProductionUnit,
      OrderIsReleased,
      AssignQty,
      PurchaseOrderByCustomer,
      RequestedQuantityInBaseUnit,
      AvailableAssignQty,

      /* Associations */
      _AssignSOItem : redirected to ZC_MFGORDERASSIGNSOITEM
}
