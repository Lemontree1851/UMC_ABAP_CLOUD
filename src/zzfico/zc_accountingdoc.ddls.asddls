@EndUserText.label: 'Query CDS'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_ACCOUNTDOCHEADER'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: '仕訳'
}

define root custom entity ZC_ACCOUNTINGDOC
{

      @UI                            : {
        selectionField               : [ { position: 1 } ],
        lineItem                     : [ { position: 40, label: '会社コード' } ]
      }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'I_CompanyCodeStdVH', element: 'CompanyCode'} }]
      @EndUserText.label             : '会社コード'
  key Companycode                    : abap.char(4);
      @UI                            : {
      selectionField                 : [ { position: 6 } ] }
      @EndUserText.label             : '会計年度'
      @Consumption.filter.defaultValue: '2024'
  key fiscalyear                     : gjahr;
      @UI                            : {
      selectionField                 : [ { position: 3 } ],
      lineItem                       : [ { position: 10, label: '仕訳' } ]
      }
      @EndUserText.label             : '仕訳'
  key accountingdocument             : belnr_d;
      @UI                            : {
      selectionField                 : [ { position: 4 } ],
      lineItem                       : [ { position: 60, label: '仕訳日付' } ] }
      @EndUserText.label             : '仕訳日付'
      @Consumption.filter.selectionType: #INTERVAL
      documentdate                   : bldat;
      @UI                            : {
      selectionField                 : [ { position: 5 } ],
      lineItem                       : [ { position: 70, label: '転記日付' } ] }
      @EndUserText.label             : '転記日付'
 
      @Consumption.filter.selectionType: #INTERVAL
      postingdate                    : bldat;
      @UI                            : {
        lineItem                     : [ { position: 100, label: '伝票ヘッダテキスト' } ] }
      @EndUserText.label             : '伝票ヘッダテキスト'
      accountingdocumentheadertext   : butxt;
      @UI                            : {
      selectionField                 : [ { position: 8 } ],
      lineItem                       : [ { position: 110, label: '仕訳登録者' } ] }
      @EndUserText.label             : '仕訳登録者'
            @Consumption.valueHelpDefinition: [ 
        { entity:  { name:    'I_BusinessUserVH',
                     element: 'UserID' }
        }]  
      accountingdoccreatedbyuser     : usnam;
            @UI                            : {
      lineItem                       : [ { position: 120, label: '仕訳登録者テキスト' } ] }
      @EndUserText.label             : '仕訳登録者テキスト'
      accountingdoccreatedbyusern     : abap.char(30);
      @EndUserText.label             : '作成時間'
      creationtime                   : uzeit;
      @EndUserText.label             : '最終更新日'
      accountingdocumentcreationdate : bldat;
      
      @EndUserText.label             : '仕訳登録者'
      lastchangedate                 : bldat;
      @UI                            : {
      selectionField                 : [ { position: 2 } ] }
      @EndUserText.label             : '元帳グループ'
      @Consumption.valueHelpDefinition: [ 
        { entity:  { name:    'ZC_LedgerGroupVH',
                     element: 'LedgerGroup' }
        }]       
      LedgerGroup                    : abap.char(4);
      @UI                            : {
      selectionField                 : [ { position: 7 } ] }
      @EndUserText.label             : '会計期間'
      FiscalPeriod                   : monat;
      @UI                            : {
      selectionField                 : [ { position: 9 } ],
      lineItem                       : [ { position: 20, label: '仕訳タイプ' } ] }
      @EndUserText.label             : '仕訳タイプ'
      @Consumption.valueHelpDefinition: [ 
        { entity:  { name:    'ZC_AccountingDocumentTypeStdVH',
                     element: 'AccountingDocumentType' }
        }]      
      accountingdocumenttype         : blart;
      @UI                            : {
      lineItem                       : [ { position: 30, label: '仕訳タイプテキスト' } ] }
      @EndUserText.label             : '仕訳タイプテキスト'      
      AccountingDocumentTypeName: abap.char(20);
      @UI                            : {
      selectionField                 : [ { position: 10 } ] }
      @EndUserText.label             : '仕訳カテゴリ'
       @Consumption.valueHelpDefinition: [ 
        { entity:  { name:    'ZC_AccountingCategoryVH',
                     element: 'AccountingDocumentCategory' }
        }]       

      AccountingDocumentCategory     : abap.char(1);

      @UI                            : {
        lineItem                     : [ { position: 50, label: '会社コードテキスト' } ] }
      @EndUserText.label             : '会社コードテキスト'
      CompanycodeText                : abap.char(25);
      @UI                            : {
      lineItem                       : [ { position: 90, label: '会社コード通貨' } ] }
      @EndUserText.label             : '会社コード通貨'
      @UI.hidden: true
      companycodecurrency            : abap.cuky;
      @UI                            : {
      lineItem                       : [ { position: 80, label: '金額' } ] }
      @EndUserText.label             : '金額(会社コード通貨)'
      @Semantics                     : { amount : {currencyCode: 'companycodecurrency'} }
      amountincompanycodecurrency    : abap.curr(23,2);

}
