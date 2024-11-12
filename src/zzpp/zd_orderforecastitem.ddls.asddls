@EndUserText.label: 'Order Forecast Item'
define abstract entity ZD_ORDERFORECASTITEM
  //  with parameters parameter_name : parameter_type
{
  key Customer        : kunnr;
  key Plant           : werks_d;
  key Material        : matnr;
  key RequirementDate : abap.numc(8);
      RequirementMonth: abap.numc( 6 );
      @Semantics.quantity.unitOfMeasure: 'Unit'
      RequirementQty  : menge_d;
      Unit            : meins;
      _Head           : association to parent ZD_ORDERFORECASTHEAD on  $projection.Customer = _Head.Customer
                                                                   and $projection.Plant    = _Head.Plant
                                                                   and $projection.Material = _Head.Material;

}
