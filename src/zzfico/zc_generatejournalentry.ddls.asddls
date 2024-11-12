@EndUserText.label: 'Generate Journal Entry'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_GenerateJournalEntry
  provider contract transactional_query
  as projection on ZR_GenerateJournalEntry
{
  key Uuid,
      CompanyCode,
      FiscalYear,
      AccountingDocument,
      JsonData,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
