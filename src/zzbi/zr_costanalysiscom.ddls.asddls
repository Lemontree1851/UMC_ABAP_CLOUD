@ObjectModel.query.implementedBy: 'ABAP:ZCL_COSTANALYSISCOM'
define root custom entity ZR_COSTANALYSISCOM
{
  key zYear               : abap.numc( 4 );
  key zMonth              : abap.numc( 2 );
  key YearMonth           : abap.char( 6 );
      @Consumption.valueHelpDefinition: [ { entity: { element: 'CompanyCode', name: 'I_CompanyCodeStdVH' } } ]
  key Companycode         : abap.char( 4 );
  key Plant               : werks_d;
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'ZI_PRODUCT_VH' } } ]
  key Product             : matnr;
  key ProductDescription  : abap.char( 40 );
      //  @Consumption.valueHelpDefinition: [ { entity: { element: 'Material', name: 'ZC_BOMMaterialVH' } } ]
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'ZI_PRODUCT_VH' } } ]
  key Material            : matnr;
      CompanycodeText     : abap.char( 40 );
      PlantText           : abap.char( 40 );
      MaterialDescription : abap.char( 40 );
      Quantity            : abap.char( 6 );
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_CustomerVH', element: 'Customer' } } ]
      Customer            : kunnr;
      CustomerName        : abap.char( 40 );

      // MOD BEGIN BY XINLEI XU 2025/04/10
      //      @Semantics          : { amount : {currencyCode: 'Currency'} }
      //      EstimatedPrice      : abap.curr(15,2);
      //      @Semantics          : { amount : {currencyCode: 'Currency'} }
      //      FinalPrice          : abap.curr(15,2);
      EstimatedPrice      : abap.dec(15,2);
      FinalPrice          : abap.dec(15,2);
      // MOD END BY XINLEI XU 2025/04/10

      FinalPostingDate    : abap.char( 8 );
      FinalSupplier       : abap.char( 10 );
      FixedSupplier       : abap.char( 40 );
      StandardPrice       : abap.char( 40 );
      MovingAveragePrice  : abap.char( 40 );

      Currency            : waerk;
      BillingQuantity     : abap.char( 20 );
      BillingQuantityUnit : abap.char( 2 );
      sales_number        : abap.char(25);
      quo_version         : abap.char(25);
      sales_d_no          : abap.char(25);
      profitcenter        : abap.char(20);
      profitcentername    : abap.char(40);

      // ADD BEGIN BY XINLEI XU 2025/04/10
      FinalSupplierName   : abap.char(80);
      FinalPurchaseOrder  : ebeln;
      FixedSupplierName   : abap.char(1000);
      // ADD END BY XINLEI XU 2025/04/10
}
