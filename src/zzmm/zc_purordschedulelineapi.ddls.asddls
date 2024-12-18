@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Schedule Line in Purchase Order'
define root view entity ZC_PurOrdScheduleLineAPI
  as select from I_PurOrdScheduleLineAPI01

  association [0..*] to ZC_POSubcontractingCompAPI as _SubcontractingComponent on  $projection.PurchaseOrder             = _SubcontractingComponent.PurchaseOrder
                                                                               and $projection.PurchaseOrderItem         = _SubcontractingComponent.PurchaseOrderItem
                                                                               and $projection.PurchaseOrderScheduleLine = _SubcontractingComponent.PurchaseOrderScheduleLine
{
  key PurchaseOrder,
  key PurchaseOrderItem,
  key PurchaseOrderScheduleLine,
      PerformancePeriodStartDate,
      PerformancePeriodEndDate,
      DelivDateCategory,
      ScheduleLineDeliveryDate,
      SchedLineStscDeliveryDate,
      ScheduleLineDeliveryTime,
      ScheduleLineOrderQuantity,
      RoughGoodsReceiptQty,
      PurchaseOrderQuantityUnit,
      PurchaseRequisition,
      PurchaseRequisitionItem,
      SourceOfCreation,
      PrevDelivQtyOfScheduleLine,
      NoOfRemindersOfScheduleLine,
      ScheduleLineIsFixed,
      ScheduleLineCommittedQuantity,
      Reservation,
      ProductAvailabilityDate,
      MaterialStagingTime,
      TransportationPlanningDate,
      TransportationPlanningTime,
      LoadingDate,
      LoadingTime,
      GoodsIssueDate,
      GoodsIssueTime,
      STOLatestPossibleGRDate,
      STOLatestPossibleGRTime,
      StockTransferDeliveredQuantity,
      ScheduleLineIssuedQuantity,
      Batch,

      /* Associations */
      _SubcontractingComponent
}
