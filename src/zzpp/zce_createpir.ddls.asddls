@EndUserText.label: 'Create PIR'
define root custom entity ZCE_CREATEPIR
  // with parameters parameter_name : parameter_type
{
  key Customer        : kunnr;
  key Plant           : werks_d;
  key Material        : matnr;
  key RequirementDate : abap.dats;
      @Semantics.quantity.unitOfMeasure: 'Unit'
      RequirementQty  : menge_d;
      Unit            : meins;
      SplitStart      : datum;
      SplitEnd        : datum;

}
