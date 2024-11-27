@EndUserText.label: 'BI007 Long-Term Inventory Forcast'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_BI007_LONGTERM_FORCAST'
define custom entity ZI_BI007_LONGTERM_FORCAST
{
  key CompanyCode       : bukrs;
  key Plant             : werks_d;
      @EndUserText.label: '予測年月'
  key ForcastYearMonth  : abap.char( 6 );

      @EndUserText.label: '実際年月'
  key BaseYearMonth     : abap.char(6);
  key Product           : matnr;
      ForcastFiscalYear : gjahr;
      ForcastPeriod     : monat;
      @EndUserText.label: 'タイプ'
      Type              : abap.char(30);
      CompanyCodeName   : bktxt;
      PlantName         : abap.char(30);
      ProductName       : maktx;
      ProductType       : mtart;
      ProductTypeName   : abap.char(25);
      ProfitCenter      : prctr;
      ProfitCenterName  : ktext;
      Customer          : kunnr;
      CustomerName      : abap.char(80);

      @EndUserText.label: '実際原価'
      @Semantics.amount.currencyCode: 'Currency'
      ActualPrice       : dmbtr;

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: '長期滞留在庫金額'
      InventoryAmount   : dmbtr;
      Currency          : waers;

      @EndUserText.label: '長期滞留在庫金額'
      Qty               : abap.dec(20,3);

}
