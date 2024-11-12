@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Generate Journal Entry'
define root view entity ZR_GenerateJournalEntry
  as select from ztfi_1017
{
  key uuid                  as Uuid,
      company_code          as CompanyCode,
      fiscal_year           as FiscalYear,
      accounting_document   as AccountingDocument,
      json_data             as JsonData,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt
}
