@ObjectModel.query.implementedBy: 'ABAP:ZCL_CREDITMANTABLE'
define root custom entity ZR_CREDITMANTABLE
{
  key RowNo             : abap.numc(4);
      @Consumption.filter:{ mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_SalesOrganization', element: 'SalesOrganization' } } ]
      SalesOrganization : vkorg;
      zyear             : gjahr;
      //      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_Customer_VH', element: 'Customer' } } ]
      Customer          : abap.char( 10 );
      CustomerName      : abap.char( 81 );
      @Semantics.amount.currencyCode : 'currency'
      LimitAmount       : abap.curr(15,2);
      currency          : waerk;
      Terms1            : abap.char( 10 );
      Termstext1        : abap.char( 30 );
      Termstext2        : abap.char( 30 );
      @Semantics.amount.currencyCode : 'currency'
      zmonth1           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth2           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth3           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth4           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth5           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth6           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth7           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth8           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth9           : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth10          : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth11          : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      zmonth12          : abap.curr(15,2);
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
      zpercent1         : abap.char( 10 );
      zpercent2         : abap.char( 10 );
      zpercent3         : abap.char( 10 );
      zpercent4         : abap.char( 10 );
      zpercent5         : abap.char( 10 );
      zpercent6         : abap.char( 10 );
      zpercent7         : abap.char( 10 );
      zpercent8         : abap.char( 10 );
      zpercent9         : abap.char( 10 );
      zpercent10        : abap.char( 10 );
      zpercent11        : abap.char( 10 );
      zpercent12        : abap.char( 10 );

      UserEmail         : abap.char(241); // ADD BY XINLEI XU 2025/03/19
}
