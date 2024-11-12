@EndUserText.label: 'Query CDS2'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_MFGORDER_002'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}
define root custom entity ZC_MFGORDER_002
{
      @UI                            : {
        lineItem                     : [ { position: 10, label: '年月' } ] }
      @EndUserText.label             : '年月'
  key YearMonth                      : abap.char(7);
      @UI                            : {
        selectionField               : [ { position: 1 } ],
        lineItem                     : [ { position: 20, label: '会社コード' } ]
      }
      @EndUserText.label             : '会社コード'
  key Companycode                    : abap.char(4);
      @UI                            : {
      selectionField                 : [ { position: 2 } ],
      lineItem                       : [ { position: 30, label: 'プラント' } ] }
      @EndUserText.label             : 'プラント'
  key Plant                          : abap.char(4);
      @UI                            : {
      lineItem                       : [ { position: 50, label: '製品' } ] }
      @EndUserText.label             : '製品'
  key Product                        : abap.char(40);
      @UI                            : {
      lineItem                       : [ { position: 80, label: '得意先' } ] }
      @EndUserText.label             : '得意先'
  key SoldToParty                    : abap.char(10);
      @EndUserText.label             : 'OrderID'
  key orderid                        : abap.char(10);
      @EndUserText.label             : 'Orderitem'
  key orderitem                      : abap.char(10);
      @UI                            : {
        lineItem                     : [ { position: 20, label: '会社コードテキスト' } ] }
      @EndUserText.label             : '会社コードテキスト'
      CompanycodeText                : abap.char(25);

      @UI                            : {
      lineItem                       : [ { position: 40, label: 'プラントテキスト' } ] }
      @EndUserText.label             : 'プラントテキスト'
      PlantText                      : abap.char(30);

      @UI                            : {
      lineItem                       : [ { position: 60, label: '製品テキスト' } ] }
      @EndUserText.label             : '製品テキスト'
      ProductDescription             : abap.char(40);
      @UI                            : {
      lineItem                       : [ { position: 90, label: '得意先テキスト' } ] }
      @EndUserText.label             : '得意先テキスト'
      BusinessPartnerName            : abap.char(35);
      @UI                            : {
      lineItem                       : [ { position: 170, label: '実績数量' } ] }
      @EndUserText.label             : '実績数量'
      @Semantics.quantity.unitOfMeasure: 'SalesPerfActualQuantityUnit'
      SalesPerformanceActualQuantity : abap.quan( 23, 3 );
      @UI                            : {
      lineItem                       : [ { position: 180, label: '販売単位' } ] }
      @EndUserText.label             : '販売単位'
      SalesPerfActualQuantityUnit    : meins;
      @UI                            : {
      lineItem                       : [ { position: 190, label: '実績値' } ] }
      @EndUserText.label             : '実績値'
      @Semantics.amount.currencyCode : 'DisplayCurrency'
      SalesPerfActlAmtInDspCurrency  : abap.curr(20,2);
      @UI                            : {
      lineItem                       : [ { position: 200, label: '照会通貨' } ] }
      @EndUserText.label             : '照会通貨'
      DisplayCurrency                : waerk;
      @UI                            : {
      selectionField                 : [ { position: 3 } ] }
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label             : '会計年度'
      calendaryear                   : calendaryear;
      @UI                            : {
      selectionField                 : [ { position: 4 } ] }
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label             : '会計期間'
      calendarMonth                  : calendarmonth;

}
