@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '代理購買仕訳生成'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_AGENCYPURCHASING
  provider contract transactional_query
  as projection on ZR_AGENCYPURCHASING
{
      @UI.selectionField: [{ position: 10 }]
      @UI.lineItem: [{ position: 10, label: '年度期間' }]
      @EndUserText.label: '年度期間'
      @Consumption.filter.selectionType: #RANGE
//      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @Consumption.filter: { mandatory: true }
//      @Consumption.filter.defaultValue: '20240101'
  key PostingDate,
      @UI.selectionField: [{ position: 20 }]
      @UI.lineItem: [{ position: 20, label: '転記先会社コード' }]
      @EndUserText.label: '転記先会社コード'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      @Consumption.filter: { mandatory: true }
  key CompanyCode,

      @UI.lineItem: [{ position: 40, label: '通貨' }]
  key CompanyCodeCurrency,
      @UI.lineItem: [{ position: 50, label: '税コード' }]
  key TaxCode,
      @UI.selectionField: [{ position: 30 }]
      @UI.lineItem: [{ position: 30, label: '決済対象会社コード' }]
      @EndUserText.label: '決済対象会社コード'
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
      CompanyCode2,
//      Ledger,
      @UI.lineItem: [{ position: 30, label: '会社間取引AP/AR科目' }]
      GLAccount,
//      AccountingDocument,
//      FiscalYear,
//      FiscalYearPeriod,
//      ReferenceDocumentContext,
//      ReferenceDocument,
//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem: [{ position: 60, label: '会社間取引税抜き額' }]
      Currency1,

//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem: [{ position: 80, label: '会社間取引税込額' }]
      Currency2,
//      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      @Semantics                  : { amount : {currencyCode: 'CompanyCodeCurrency'} }
      @UI.lineItem: [{ position: 70, label: '会社間取引消費税額' }]
      Currency3,
      @UI.lineItem: [{ position: 90, label: '転記先会社仕訳' }]
      accountingdocument1,
      @UI.lineItem: [{ position: 100, label: '決済対象会社仕訳' }]
      accountingdocument2,
      @UI.lineItem: [{ position: 110, label: 'メッセージ' }]
      message,
      uuid1,
      uuid2
}
