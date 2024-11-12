@EndUserText.label: 'Query CDS3'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_MFGORDER_003'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}
define root custom entity ZC_MFGORDER_003

{
      @UI                    : {
        lineItem             : [ { position: 10, label: '年月' } ] }
      @EndUserText.label     : '年月'
  key YearMonth              : abap.char(7);
      @UI                    : {
        selectionField       : [ { position: 1 } ],
        lineItem             : [ { position: 20, label: '会社コード' } ]
      }
      @EndUserText.label     : '会社コード'
  key Companycode            : abap.char(4);
      @UI                    : {
      selectionField         : [ { position: 2 } ],
      lineItem               : [ { position: 40, label: 'プラント' } ] }
      @EndUserText.label     : 'プラント'
  key Plant                  : abap.char(4);
      @UI                    : {
      lineItem               : [ { position: 60, label: '製品' } ] }
      @EndUserText.label     : '製品'
  key Product                : abap.char(40);
      @UI                    : {
      lineItem               : [ { position: 100, label: '得意先' } ] }
      @EndUserText.label     : '得意先'
  key SoldToParty            : abap.char(10);
      @EndUserText.label     : 'AccountingDocument'
  key AccountingDocument     : abap.char(10);
      @EndUserText.label     : 'LedgerGLLineItem'
  key LedgerGLLineItem       : abap.char(6);
      @UI                    : {
        lineItem             : [ { position: 30, label: '会社コードテキスト' } ] }
      @EndUserText.label     : '会社コードテキスト'
      CompanycodeText        : abap.char(25);

      @UI                    : {
      lineItem               : [ { position: 50, label: 'プラントテキスト' } ] }
      @EndUserText.label     : 'プラントテキスト'
      PlantText              : abap.char(30);

      @UI                    : {
      lineItem               : [ { position: 70, label: '製品テキスト' } ] }
      @EndUserText.label     : '製品テキスト'
      ProductDescription     : abap.char(40);
      @UI                    : {
      lineItem               : [ { position: 110, label: '得意先テキスト' } ] }
      @EndUserText.label     : '得意先テキスト'
      BusinessPartnerName    : abap.char(35);
      @UI                    : {
      lineItem               : [ { position: 80, label: '利益センタ' } ] }
      @EndUserText.label     : '利益センタ'
      ProfitCenter           : abap.char(10);
      @UI                    : {
      lineItem               : [ { position: 90, label: '利益センタテキスト' } ] }
      @EndUserText.label     : '利益センタテキスト'
      ProfitCenterLongName   : abap.char(40);
      @UI                    : {
      lineItem               : [ { position: 120, label: '主材費' } ] }
      @EndUserText.label     : '主材費'
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      Zamount1               : abap.curr(22,2);
      @UI                    : {
      lineItem               : [ { position: 130, label: '副資材費' } ] }
      @EndUserText.label     : '副資材費'
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      Zamount2               : abap.curr(22,2);
      @UI                    : {
      lineItem               : [ { position: 140, label: '照会通貨' } ] }
      @EndUserText.label     : '照会通貨'
      DisplayCurrency        : waerk;
      @UI                    : {
      selectionField         : [ { position: 3 } ] }
      @Consumption.filter    : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label     : '会計年度'
      calendaryear           : calendaryear;
      @UI                    : {
      selectionField         : [ { position: 4 } ] }
      @Consumption.filter    : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label     : '会計期間'
      calendarMonth          : calendarmonth;
      @EndUserText.label     : '凭证类型'
      AccountingDocumentType : abap.char(4);


}