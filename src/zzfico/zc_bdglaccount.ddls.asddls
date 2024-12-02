@EndUserText.label: 'Query CDS'
@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_BDGLACCOUNT'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}
define root custom entity ZC_BDGLACCOUNT
{
      @UI                            : {
        selectionField               : [ { position: 1 } ]
      }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'ZC_LedgerVH', element: 'Ledger'} }]
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label             : '元帳'
  key Ledger                         : abap.char(4);
      @UI                            : {
        selectionField               : [ { position: 2 } ]
      }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'I_CompanyCodeStdVH', element: 'CompanyCode'} }]
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label             : '会社コード'
  key Companycode                    : abap.char(4);
      @UI                            : {
      selectionField                 : [ { position: 3 } ] }
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label             : '会計年度'
  key calendaryear                   : calendaryear;
      @UI                            : {
      selectionField                 : [ { position: 4 } ] }
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label             : '会計期間'
  key calendarMonth                  : calendarmonth;
      @UI                            : {
      lineItem                       : [ { position: 10, label: '連結勘定' } ] }
      @EndUserText.label             : '連結勘定'
//@AnalyticsDetails.query.display: #KEY_TEXT
//@AnalyticsDetails.query.totals:#SHOW
  key FinancialStatementItem         : abap.char(10);
      @UI                            : {
     lineItem                       : [ { position: 30, label: 'G/L勘定' } ] }
      
      
      @EndUserText.label             : 'G/L勘定'
  key GLAccount                      : abap.char(10);
      @UI.hidden                     : true
  key lineid                         : abap.char( 20 );

      @UI                            : {
      lineItem                       : [ { position: 200, label: '開始残高（会社コード通貨）' } ] }
      @EndUserText.label             : '開始残高（会社コード通貨）'
      @Semantics.amount.currencyCode : 'StartingBalanceAmtInCoCode_E'
      StartingBalanceAmtInCoCodeCrcy  : abap.curr(22,2);
      StartingBalanceAmtInCoCode_E: waerk;
      @UI                            : {
      lineItem                       : [ { position: 210, label: '会社コード通貨の借方残高' } ] }
      @EndUserText.label             : '会社コード通貨の借方残高'
      //@Aggregation: { default: #SUM}
     // @AnalyticsDetails.query.display: #KEY_TEXT
    //  @AnalyticsDetails.query.totals:#SHOW
      @Semantics.amount.currencyCode : 'DebitAmountInCoCode_E'
      DebitAmountInCoCodeCrcy        : abap.curr(22,2);
      DebitAmountInCoCode_E        : waerk;
      @UI                            : {
      lineItem                       : [ { position: 220, label: '会社コード通貨の貸方残高' } ] }
      @EndUserText.label             : '会社コード通貨の貸方残高'
      @Semantics.amount.currencyCode : 'CreditAmountInCoCode_E'
      CreditAmountInCoCodeCrcy        : abap.curr(22,2);
      CreditAmountInCoCode_E        : waerk;
      @UI                            : {
      lineItem                       : [ { position: 230, label: '会社コード期末残高' } ] }
      @EndUserText.label             : '会社コード期末残高'
      @Semantics.amount.currencyCode : 'EndingBalanceAmtInCoCode_E'
      EndingBalanceAmtInCoCodeCrcy    : abap.curr(22,2);
      EndingBalanceAmtInCoCode_E        : waerk;
      
      
      @UI                            : {
      lineItem                       : [ { position: 20, label: '連結勘定テキスト' } ] }
      @EndUserText.label             : '連結勘定テキスト'
      FinancialStatementItemDesc     : abap.char(50);
      @UI                            : {
      lineItem                       : [ { position: 40, label: 'G/L勘定テキスト' } ] }
      @EndUserText.label             : 'G/L勘定テキスト'
      GLAccountDesc                  : abap.char(50);
}
