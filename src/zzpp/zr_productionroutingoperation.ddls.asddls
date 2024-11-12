@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Routing Operation'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZR_PRODUCTIONROUTINGOPERATION
  as select distinct from I_MfgBOOOperationChangeState   as _Op
    inner join            I_MfgBillOfOperationsOperation as _Acty on  _Acty.BillOfOperationsType     = _Op.BillOfOperationsType
                                                                  and _Acty.BillOfOperationsGroup    = _Op.BillOfOperationsGroup
                                                                  and _Acty.BOOOperationInternalID   = _Op.BOOOperationInternalID
                                                                  and _Acty.BillOfOperationsSequence = _Op.BillOfOperationsSequence
{
  key _Op.BillOfOperationsType,
  key _Op.BillOfOperationsGroup,
  key _Op.BOOOperationInternalID,
  key _Op.BOOOpInternalVersionCounter,
  key _Op.BillOfOperationsSequence,
  key _Op.BillOfOperationsVariant,
      _Op.OperationExternalID,
      _Op.Operation_2 as Operation,
      _Op.CreationDate,
      _Op.CreatedByUser,
      _Op.LastChangeDate,
      _Op.LastChangedByUser,
      _Op.ChangeNumber,
      _Op.ValidityStartDate,
      _Op.ValidityEndDate,
      _Op.IsDeleted,
      _Op.IsImplicitlyDeleted,
      _Op.OperationText,
      _Op.LongTextLanguageCode,
      _Op.Plant,
      _Op.OperationControlProfile,
      _Op.OperationStandardTextCode,
      _Op.WorkCenterInternalID,
      _Op.WorkCenterTypeCode,
      _Op.FactoryCalendar,
      _Op.CapacityCategoryCode,
      _Op.CostElement,
      _Op.CompanyCode,
      _Op.OperationCostingRelevancyType,
      _Op.NumberOfTimeTickets,
      _Op.NumberOfConfirmationSlips,
      _Op.EmployeeWageGroup,
      _Op.EmployeeWageType,
      _Op.EmployeeSuitability,
      _Op.NumberOfEmployees,
      _Op.BillOfOperationsRefType,
      _Op.BillOfOperationsRefGroup,
      _Op.BillOfOperationsRefVariant,
      _Op.LineSegmentTakt,
      _Op.OperationStdWorkQtyGrpgCat,
      _Op.OrderHasNoSubOperations,
      _Op.OperationSetupType,
      _Op.OperationSetupGroupCategory,
      _Op.OperationSetupGroup,
      _Op.BOOOperationIsPhase,
      _Op.BOOPhaseSuperiorOpInternalID,
      _Op.ControlRecipeDestination,
      _Op.OpIsExtlyProcdWithSubcontrg,
      _Op.PurchasingInfoRecord,
      _Op.PurchasingOrganization,
      _Op.PurchaseContract,
      _Op.PurchaseContractItem,
      _Op.PurchasingInfoRecdAddlGrpgName,
      _Op.MaterialGroup,
      _Op.PurchasingGroup,
      _Op.Supplier,
      _Op.PlannedDeliveryDuration,
      _Op.NumberOfOperationPriceUnits,
      _Op.OpExternalProcessingCurrency,
      @Semantics.amount.currencyCode: 'OpExternalProcessingCurrency'
      _Op.OpExternalProcessingPrice,
      _Op.InspectionLotType,
      _Op.InspResultRecordingView,
      _Op.InspSbstCompletionConfirmation,
      _Op.InspSbstHasNoTimeOrQuantity,
      @Semantics.quantity.unitOfMeasure: 'OperationUnit'
      _Op.OperationReferenceQuantity,
      _Op.OperationUnit,
      _Op.OperationScrapPercent,
      _Op.OpQtyToBaseQtyNmrtr,
      _Op.OpQtyToBaseQtyDnmntr,
      _Op.StandardWorkFormulaParam1,
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit1'
      _Op.StandardWorkQuantity1,
      _Op.StandardWorkQuantityUnit1,
      _Op.CostCtrActivityType1,
      _Op.PerfEfficiencyRatioCode1,
      _Op.StandardWorkFormulaParam2,
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit2'
      _Op.StandardWorkQuantity2,
      _Op.StandardWorkQuantityUnit2,
      _Op.CostCtrActivityType2,
      _Op.PerfEfficiencyRatioCode2,
      _Op.StandardWorkFormulaParam3,
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit3'
      _Op.StandardWorkQuantity3,
      _Op.StandardWorkQuantityUnit3,
      _Op.CostCtrActivityType3,
      _Op.PerfEfficiencyRatioCode3,
      _Op.StandardWorkFormulaParam4,
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit4'
      _Op.StandardWorkQuantity4,
      _Op.StandardWorkQuantityUnit4,
      _Op.CostCtrActivityType4,
      _Op.PerfEfficiencyRatioCode4,
      _Op.StandardWorkFormulaParam5,
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit5'
      _Op.StandardWorkQuantity5,
      _Op.StandardWorkQuantityUnit5,
      _Op.CostCtrActivityType5,
      _Op.PerfEfficiencyRatioCode5,
      _Op.StandardWorkFormulaParam6,
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit6'
      _Op.StandardWorkQuantity6,
      _Op.StandardWorkQuantityUnit6,
      _Op.CostCtrActivityType6,
      _Op.PerfEfficiencyRatioCode6,
      _Op.BusinessProcess,
      _Op.LeadTimeReductionStrategy,
      _Op.TeardownAndWaitIsParallel,
      @Semantics.quantity.unitOfMeasure: 'BreakDurationUnit'
      _Op.BillOfOperationsBreakDuration,
      _Op.BreakDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'MaximumWaitDurationUnit'
      _Op.MaximumWaitDuration,
      _Op.MaximumWaitDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'MinimumWaitDurationUnit'
      _Op.MinimumWaitDuration,
      _Op.MinimumWaitDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'StandardQueueDurationUnit'
      _Op.StandardQueueDuration,
      _Op.StandardQueueDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'MinimumQueueDurationUnit'
      _Op.MinimumQueueDuration,
      _Op.MinimumQueueDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'StandardMoveDurationUnit'
      _Op.StandardMoveDuration,
      _Op.StandardMoveDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'MinimumMoveDurationUnit'
      _Op.MinimumMoveDuration,
      _Op.MinimumMoveDurationUnit,
      _Op.OperationSplitIsRequired,
      _Op.MaximumNumberOfSplits,
      @Semantics.quantity.unitOfMeasure: 'MinProcessingDurnPerSplitUnit'
      _Op.MinProcessingDurationPerSplit,
      _Op.MinProcessingDurnPerSplitUnit,
      _Op.OperationOverlappingIsRequired,
      _Op.OperationOverlappingIsPossible,
      _Op.OperationsIsAlwaysOverlapping,
      _Op.OperationHasNoOverlapping,
      @Semantics.quantity.unitOfMeasure: 'OverlapMinimumDurationUnit'
      _Op.OverlapMinimumDuration,
      _Op.OverlapMinimumDurationUnit,
      @Semantics.quantity.unitOfMeasure: 'OverlapMinimumTransferQtyUnit'
      _Op.OverlapMinimumTransferQty,
      _Op.OverlapMinimumTransferQtyUnit
}
