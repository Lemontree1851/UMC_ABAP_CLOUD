@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Aging Upload'

define root view entity ZR_STOCKAGEUPLOAD
  as select from ztfi_1004
  association [0..1] to I_BusinessUserVH as _CreateUser  on  $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser  on  $projection.LastChangedBy = _UpdateUser.UserID
  association [0..1] to I_ProductText    as _ProductText on  $projection.Material  = _ProductText.Product
                                                         and _ProductText.Language = $session.system_language
  association [0..1] to I_CompanyCode    as _CompanyCode on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_Plant          as _Plant       on  $projection.Plant = _Plant.Plant
{

  key ledger                as Ledger,
  key calendaryear          as CalendarYear,
  key calendarmonth         as CalendarMonth,
  key companycode           as CompanyCode,
  key plant                 as Plant,
  key material              as Material,
  key age                   as Age,

      qty                   as Qty,

      //status                as Status,  // ステータス
      //message               as Message, // メッセージ
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,
      _ProductText,
      _CompanyCode,
      _Plant,
      _CreateUser,
      _UpdateUser
}
