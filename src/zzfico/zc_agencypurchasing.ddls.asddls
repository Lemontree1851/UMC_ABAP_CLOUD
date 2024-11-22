@ObjectModel.query.implementedBy: 'ABAP:ZCL_AGENCYPURCHASING'
@EndUserText.label: '代理購買仕訳生成'
@UI: {
  headerInfo: {
    typeName: '代理購買仕訳生成',
    typeNamePlural: '代理購買仕訳生成'
    } }
define root custom entity ZC_AGENCYPURCHASING
{

      //      @UI.selectionField: [{ position: 10 }]
      //      @EndUserText.label: '年度期間'
      //      @Consumption.filter.selectionType: #RANGE
      //      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      //      @Consumption.filter: { mandatory: true }
      //      @Consumption.filter.defaultValue: '20240101'
      @UI.lineItem        : [{ position: 10, label: '年度期間' }]
  key PostingDate         : abap.char( 6 );
      @UI.selectionField  : [{ position: 20 }]
      @UI.lineItem        : [{ position: 20, label: '転記先会社コード' }]
      @EndUserText.label  : '転記先会社コード'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      @Consumption.filter : { mandatory: true }
  key CompanyCode         : abap.char( 4 );

      @UI.lineItem        : [{ position: 40, label: '通貨' }]
  key CompanyCodeCurrency : abap.cuky;
      @UI.lineItem        : [{ position: 50, label: '税コード' }]
  key TaxCode             : abap.char(16);
      @UI.selectionField  : [{ position: 10 }]
      @EndUserText.label  : '年度期間'
      @Consumption.filter.selectionType: #INTERVAL
      @Consumption.filter : { mandatory: true }
      ZPostingDate        : bldat;
      @UI.selectionField  : [{ position: 30 }]
      @UI.lineItem        : [{ position: 30, label: '決済対象会社コード' }]
      @EndUserText.label  : '決済対象会社コード'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      CompanyCode2        : abap.char( 4 );
      @UI.lineItem        : [{ position: 30, label: '会社間取引AP/AR科目' }]
      GLAccount           : abap.char(10);
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 60, label: '会社間取引税抜き額' }]
      Currency1           : abap.curr(23,2);
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 80, label: '会社間取引税込額' }]
      Currency2           : abap.curr(23,2);
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 70, label: '会社間取引消費税額' }]
      Currency3           : abap.curr(23,2);
      @UI.lineItem        : [{ position: 90, label: '転記先会社仕訳' }]
      accountingdocument1 : abap.char(10);
      @UI.lineItem        : [{ position: 100, label: '決済対象会社仕訳' }]
      accountingdocument2 : abap.char(10);
      @UI.lineItem        : [{ position: 110, label: 'メッセージ' }]
      message             : abap.char( 100 );
      uuid1               : sysuuid_x16;
      uuid2               : sysuuid_x16;
}
