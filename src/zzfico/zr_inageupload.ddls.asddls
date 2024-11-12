@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Aging Upload'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZR_INAGEUPLOAD
  as select from ztfi_1003
{
  key uuid                  as UUID,
      
      ledger as Ledger,
      companycode as CompanyCode,
      plant                 as Plant,
      material              as Material,
      age                   as Age,
      qty                   as Qty,
      calendaryear          as CalendarYear,
      calendarmonth         as CalendarMonth,
      
      status                as Status,  // ステータス
      message               as Message, // メッセージ
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
