@EndUserText.label: 'Order Forecast Header'
define root abstract entity ZD_ORDERFORECASTHEAD
  //  with parameters parameter_name : parameter_type
{
  key Customer     : kunnr;
  key Plant        : werks_d;
  key Material     : matnr;
      ProcessStart : abap.char(8);
      ProcessEnd   : abap.char(8);
      Type         : abap.char( 1 );
      Message      : abap.string;
      _Item        : composition [0..*] of ZD_ORDERFORECASTITEM;

}
