@ObjectModel.query.implementedBy: 'ABAP:ZCL_CREDITMANTABLE'
define root custom entity ZR_CREDITMANTABLE
{
  key RowNo             : abap.numc(4);
      @Consumption.filter:{ mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' } } ]
      SalesOrganization : vkorg;
      zyear             : gjahr;
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      Customer          : abap.char( 10 );
      CustomerName      : abap.char( 81 );
      LimitAmount       : abap.char( 4 );
      Terms1            : abap.char( 10 );
      Termstext1        : abap.char( 30 );
      Termstext2        : abap.char( 30 );
      zmonth1           : abap.char( 10 );
      zmonth2           : abap.char( 10 );
      zmonth3           : abap.char( 10 );
      zmonth4           : abap.char( 10 );
      zmonth5           : abap.char( 10 );
      zmonth6           : abap.char( 10 );
      zmonth7           : abap.char( 10 );
      zmonth8           : abap.char( 10 );
      zmonth9           : abap.char( 10 );
      zmonth10          : abap.char( 10 );
      zmonth11          : abap.char( 10 );
      zmonth12          : abap.char( 10 );
      text1             : abap.char( 30 );
      zymonth1          : abap.char( 30 );
      zymonth2          : abap.char( 30 );
      zymonth3          : abap.char( 30 );
      zymonth4          : abap.char( 30 );
      zymonth5          : abap.char( 30 );
      zymonth6          : abap.char( 30 );
      zymonth7          : abap.char( 30 );
      zymonth8          : abap.char( 30 );
      zymonth9          : abap.char( 30 );
      zymonth10         : abap.char( 30 );
      zymonth11         : abap.char( 30 );
      zymonth12         : abap.char( 30 );
}
