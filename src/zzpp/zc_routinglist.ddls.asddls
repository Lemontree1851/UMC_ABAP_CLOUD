@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_ROUTINGLIST'
@Metadata.allowExtensions: true
@EndUserText.label: 'Routing List'
define custom entity ZC_ROUTINGLIST
{
      @UI.hidden                 : true
  key uuid                       : sysuuid_x16;
      Product                    : matnr;
      Plant                      : werks_d;
      BillOfOperationsGroup      : abap.char(8);
      BillOfOperationsVariant    : abap.char(2);
      Operation                  : abap.char(4);

      /* I_ProductPlantBasic */
      MRPResponsible             : dispo;
      ProcurementType            : beskz;
      SpecialProcurementType     : sobsl;
      ProductionSupervisor       : abap.char(3);
      ProductionInvtryManagedLoc : lgort_d;
      /* I_ProductPlantBasic */

      /* I_MfgBOOMaterialAssignment */
      BillOfOperationsType       : abap.char(1);
      /* I_MfgBOOMaterialAssignment */

      /* I_ProdnRoutingOperationTP_2 */
      OperationControlProfile    : steus;
      WorkCenter                 : arbpl;
      OperationText              : ltxa1;
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      CostingLotSize             : menge_d;

      //      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit1'
      StandardWorkQuantity1      : abap.dec(23,3); //abap.quan(9,3);
      CostCtrActivityType1       : lstar;

      //      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit2'
      StandardWorkQuantity2      : abap.dec(23,3); //abap.quan(9,3);
      CostCtrActivityType2       : lstar;

      //      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit3'
      StandardWorkQuantity3      : abap.dec(23,3); //abap.quan(9,3);
      CostCtrActivityType3       : lstar;

      //      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit4'
      StandardWorkQuantity4      : abap.dec(23,3); //abap.quan(9,3);
      CostCtrActivityType4       : lstar;

      //      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit5'
      StandardWorkQuantity5      : abap.dec(23,3); //abap.quan(9,3);
      CostCtrActivityType5       : lstar;

      //      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit6'
      StandardWorkQuantity6      : abap.dec(23,3); //abap.quan(9,3);
      CostCtrActivityType6       : lstar;

      NumberOfTimeTickets        : abap.dec(3,0);

      IsMarkedForDeletion        : lkenz;
      ValidityStartDate          : datum;
      ValidityEndDate            : datum;
      /* I_ProdnRoutingOperationTP_2 */

      StandardWorkQuantityUnit1  : meins;
      StandardWorkQuantityUnit2  : meins;
      StandardWorkQuantityUnit3  : meins;
      StandardWorkQuantityUnit4  : meins;
      StandardWorkQuantityUnit5  : meins;
      StandardWorkQuantityUnit6  : meins;

      @UI.hidden                 : true
      BOOToMaterialInternalID    : abap.numc(7);
      @UI.hidden                 : true
      WorkCenterInternalID       : abap.numc(8);
      @UI.hidden                 : true
      BaseUnit                   : meins;
}
