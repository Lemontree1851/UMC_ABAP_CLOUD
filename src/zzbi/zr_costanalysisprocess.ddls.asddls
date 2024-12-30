@ObjectModel.query.implementedBy: 'ABAP:ZCL_COSTANALYSISPROCESS'
define root custom entity ZR_COSTANALYSISPROCESS
{
  key zYear               : abap.char( 4 );
  key zMonth              : abap.char( 2 );
  key YearMonth           : abap.char( 6 );
      @Consumption.valueHelpDefinition: [ { entity: { element: 'CompanyCode', name: 'I_CompanyCodeStdVH' } } ]
  key Companycode         : abap.char( 4 );
  key Plant               : werks_d;
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_ProductStdVH' } } ]
  key Product             : matnr;
  key ProductDescription  : abap.char( 40 );
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      Customer            : kunnr;
      CustomerName        : abap.char( 40 );
      CompanycodeText     : abap.char( 40 );
      PlantText           : abap.char( 40 );
      @Semantics          : { amount : {currencyCode: 'Currency'} }
      EstimatedPrice_SMT  : abap.curr(15,2);
      @Semantics          : { amount : {currencyCode: 'Currency'} }
      EstimatedPrice_AI   : abap.curr(15,2);
      @Semantics          : { amount : {currencyCode: 'Currency'} }
      EstimatedPrice_FAT  : abap.curr(15,2);
      @Semantics          : { amount : {currencyCode: 'Currency'} }
      ActualPrice_SMT     : abap.curr(15,2);
      @Semantics          : { amount : {currencyCode: 'Currency'} }
      ActualPrice_AI      : abap.curr(15,2);
      @Semantics          : { amount : {currencyCode: 'Currency'} }
      ActualPrice_FAT     : abap.curr(15,2);
      Currency            : waerk;
      BillingQuantity     : abap.char( 20 );
      BillingQuantityUnit : abap.char( 2 );
      sales_number        : abap.char(25);
      quo_version         : abap.char(25);
      sales_d_no          : abap.char(25);
      profitcenter        : abap.char(20);
      profitcentername    : abap.char(40);
      yieldqty            : abap.char(20);

}
