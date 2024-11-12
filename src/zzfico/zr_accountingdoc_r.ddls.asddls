@AbapCatalog.sqlViewName: 'ZRACCDOC'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '仕訳印刷'
@Metadata.ignorePropagatedAnnotations: true
define view ZR_ACCOUNTINGDOC_R as select from I_JournalEntry
{
  key CompanyCode,
  key FiscalYear,
  key AccountingDocument
}
