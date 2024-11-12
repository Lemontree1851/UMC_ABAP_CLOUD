@EndUserText.label: 'Print Material Requisition Item'
@ObjectModel.query.implementedBy:'ABAP:ZCL_MATERIALREQUISITION_PRT'
define custom entity ZR_MATERIALREQUISITION_PRT_I
{
  key MaterialRequisitionNo : abap.char(15);
  key ItemNo                : abap.numc(4);
      ManufacturingOrder    : aufnr;
      Product               : matnr;
      Material              : matnr;
      StorageLocation       : lgort_d;
      BaseUnit              : meins;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      Quantity              : menge_d;
      Location              : abap.char(50);
      Remark                : abap.char(220);
      @Semantics.amount.currencyCode: 'Currency'
      StandardPrice         : stprs;
      PriceUnitQty          : peinh;
      Currency              : waers;
      @Semantics.amount.currencyCode: 'Currency'
      TotalAmount           : abap.curr( 23, 2 );

      ProductDescription    : abap.char(40);
      MaterialDescription   : abap.char(40);
}
