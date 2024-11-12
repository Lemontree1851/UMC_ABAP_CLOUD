@EndUserText.label: 'Order Forecast Partition'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_OFPARTITION'
define root custom entity ZCE_OFPARTITION
  with parameters
    //      @Consumption.hidden: true
    SplitRange : char13
{
  key Customer           : kunnr;
  key Plant              : werks_d;
  key Material           : matnr;
  key RequirementDate    : abap.dats;
      MaterialByCustomer : matnr;
      MaterialName       : maktx;
      @Semantics.quantity.unitOfMeasure: 'Unit'
      RequirementQty     : menge_d;
      Unit               : meins;
      ProcessStart       : abap.char(8);
      ProcessEnd         : abap.char(8);

}
