@EndUserText.label: 'BI007 Long Term Forcast Custom CDS Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BI007_REPORT'
@Metadata.allowExtensions: true
define custom entity ZI_BI007_REPORT
{
      @Consumption.valueHelpDefinition: [{ entity: { element: 'CompanyCode', name: 'I_CompanyCode' } }]
  key CompanyCode         : bukrs;

      @Consumption.valueHelpDefinition: [{ entity: { element: 'Plant', name: 'I_Plant' } }]
  key Plant               : werks_d;
      @EndUserText.label  : 'Forcast Year Month'
  key FiscalYearMonth     : abap.char(6);

      @EndUserText.label  : 'Base Year Month'
  key BaseFiscalYearMonth : abap.char(6);

      @Consumption.valueHelpDefinition: [{ entity: { element: 'Product', name: 'ZI_PRODUCT_VH' } }]
  key Product             : matnr;
      ForcastFiscalYear   : gjahr;
      @EndUserText.label  : 'Fiscal Period'
      ForcastPeriod       : abap.char(2);
      ForcastFiscalPeriod : poper;

      BaseFiscalYear      : gjahr;
      BasePeriod          : abap.char(2);

      @EndUserText.label  : 'Type'
      Type                : abap.char(20);
      CompanyCodeName     : bktxt;

      @EndUserText.label  : 'Plant Name'
      PlantName           : abap.char(30);
      ProductName         : maktx;
      ProductType         : mtart;

      @EndUserText.label  : 'Product Type Name'
      ProductTypeName     : abap.char(25);
      ProfitCenter        : prctr;

      @EndUserText.label  : 'Profit Center Name'
      ProfitCenterName    : abap.char(20);

      @Consumption.valueHelpDefinition: [{ entity: { element: 'Customer', name: 'I_Customer' } }]
      Customer            : kunnr;

      @EndUserText.label  : 'Customer Name'
      CustomerName        : abap.char(80);
      Currency            : waers;
      ValuationArea       : bwkey;

      @EndUserText.label  : 'Quantity'
      Qty                 : abap.dec(21, 3);

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label  : 'Actual Price'
      ActualPrice         : dmbtr;

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label  : 'Inventory Amount'
      InventoryAmount     : dmbtr;



}
