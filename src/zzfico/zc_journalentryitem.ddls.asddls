@AbapCatalog.sqlViewName: 'ZFINSCAL'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Journal Entries Item'
@Metadata.ignorePropagatedAnnotations: true
define view ZC_JOURNALENTRYITEM as select from I_JournalEntryItem as _JournalEntryItem
join I_GLAccountLineItem as c on 
_JournalEntryItem.AccountingDocument = c.AccountingDocument
{
  key _JournalEntryItem.CompanyCode,
  key _JournalEntryItem.FiscalYear,
  key _JournalEntryItem.AccountingDocument,
  key _JournalEntryItem.AccountingDocumentItem
  
  
  
  
}
