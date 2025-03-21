@EndUserText.label: 'BI006 Report CDS'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BI006_REPORT'
@Metadata.allowExtensions: true
define custom entity ZI_BI006_REPORT
{
      @Consumption.valueHelpDefinition: [{ entity: { element: 'CompanyCode', name: 'I_CompanyCode' } }]
  key CompanyCode      : bukrs;

      @Consumption.valueHelpDefinition: [{ entity: { element: 'Plant', name: 'I_Plant' } }]
  key Plant            : werks_d;
      @EndUserText.label:'Year Month'
  key FiscalYearMonth  : abap.char(6);

      @Consumption.valueHelpDefinition: [{ entity: { element: 'Product', name: 'ZI_PRODUCT_VH' } }]
  key Product          : matnr;
      FiscalYear       : gjahr;
      @EndUserText.label:'Fiscal Period'
      Period           : abap.char(2);
      FiscalPeriod     : poper;

      @EndUserText.label:'Type'
      Type             : abap.char(20);
      CompanyCodeName  : bktxt;

      @EndUserText.label:'Plant Name'
      PlantName        : abap.char(30);
      ProductName      : maktx;
      ProductType      : mtart;

      @EndUserText.label:'Product Type Name'
      ProductTypeName  : abap.char(25);
      ProfitCenter     : prctr;

      @EndUserText.label:'Profit Center Name'
      ProfitCenterName : abap.char(20);

      @Consumption.valueHelpDefinition: [{ entity: { element: 'Customer', name: 'ZC_CustomerVH' } }]
      Customer         : kunnr;

      @EndUserText.label:'Customer Name'
      CustomerName     : abap.char(80);
      Currency         : waers;
      ValuationArea    : bwkey;

      @EndUserText.label:'Quantity'
      Qty              : abap.dec(21, 3);

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label:'Actual Price'
      ActualPrice      : dmbtr;

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label:'Inventory Amount'
      InventoryAmount  : dmbtr;

      Age              : abap.numc(3);

}
