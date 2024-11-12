@EndUserText.label: 'PP-012 用于在修改PIR时校验数据'
define abstract entity ZD_ORDERFORECAST_CHECK
//  with parameters parameter_name : parameter_type
{
    key Customer     : kunnr;
    key Plant        : werks_d;
    key Material     : matnr;
        Type         : abap.char( 1 );
        Message      : abap.string;
}
