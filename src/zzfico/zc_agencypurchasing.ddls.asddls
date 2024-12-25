@ObjectModel.query.implementedBy: 'ABAP:ZCL_AGENCYPURCHASING'
@EndUserText.label: '代理購買仕訳生成'
@UI: {
  headerInfo: {
    typeName: '代理購買仕訳生成',
    typeNamePlural: '代理購買仕訳生成'
    } }
define root custom entity ZC_AGENCYPURCHASING
{
      @UI.lineItem        : [{ position: 10, label: '年度期間' }]
      @Consumption.filter.hidden: true
  key PostingDate         : abap.char( 6 );
      @UI.selectionField  : [{ position: 20 }]
      @UI.lineItem        : [{ position: 20, label: '転記先会社コード', cssDefault.width: '10rem' }]
      @EndUserText.label  : '転記先会社コード'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      @Consumption.filter : { mandatory: true }
  key CompanyCode         : abap.char( 4 );
      @UI.lineItem        : [{ position: 40, label: '通貨' }]
      @Consumption.filter.hidden: true
  key CompanyCodeCurrency : abap.cuky;
      @UI.lineItem        : [{ position: 50, label: '税コード', cssDefault.width: '6rem' }]
      @Consumption.filter.hidden: true
  key TaxCode             : abap.char(16);
      @UI.selectionField  : [{ position: 10 }]
      @EndUserText.label  : '年度期間'
      @Consumption.filter.selectionType: #INTERVAL
      @Consumption.filter : { mandatory: true }
      ZPostingDate        : bldat;
      @UI.selectionField  : [{ position: 30 }]
      @UI.lineItem        : [{ position: 30, label: '決済対象会社コード', cssDefault.width: '10rem' }]
      @EndUserText.label  : '決済対象会社コード'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      CompanyCode2        : abap.char( 4 );
      @Consumption.filter.hidden: true
      @UI.lineItem        : [{ position: 30, label: '会社間取引AP/AR科目', cssDefault.width: '10rem' }]
      GLAccount           : abap.char(10);
      @Consumption.filter.hidden: true
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 60, label: '会社間取引税抜き額' }]
      Currency1           : abap.curr(23,2);
      @Consumption.filter.hidden: true
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 80, label: '会社間取引税込額' }]
      Currency2           : abap.curr(23,2);
      @Consumption.filter.hidden: true
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 70, label: '会社間取引消費税額' }]
      Currency3           : abap.curr(23,2);
      @Consumption.filter.hidden: true
      @UI.lineItem        : [{ position: 90, label: '転記先会社仕訳' }]
      accountingdocument1 : abap.char(10);
      @Consumption.filter.hidden: true
      @UI.lineItem        : [{ position: 100, label: '決済対象会社仕訳' }]
      accountingdocument2 : abap.char(10);
      @Consumption.filter.hidden: true
      @Semantics          : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem        : [{ position: 105, label: '確定会社間取引税込額' }]
      Currency4           : abap.curr(23,2);
      @Consumption.filter.hidden: true
      @UI.lineItem        : [{ position: 110, label: 'メッセージ' }]
      message             : abap.char( 100 );
      @Consumption.filter.hidden: true
      @UI.lineItem        : [{ position: 01, label: 'ステータス' }]
      Status              : abap.char( 10 );

      @UI.hidden          : true
      UserEmail           : zze_emailaddress;
}
