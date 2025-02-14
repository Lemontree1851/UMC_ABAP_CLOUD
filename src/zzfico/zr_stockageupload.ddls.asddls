@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Inventory Aging Upload'
define root view entity ZR_STOCKAGEUPLOAD
  as select from ztfi_1004            as StockAge
    left outer join   ZR_TBC1006           as _AssignPlant   on _AssignPlant.Plant = StockAge.plant 
    left outer join   ZC_BusinessUserEmail as _User          on  _User.Email  = _AssignPlant.Mail
                                                        and _User.UserID = $session.user
    inner join   ZR_TBC1012           as _AssignCompany on _AssignCompany.CompanyCode = StockAge.companycode
    inner join   ZC_BusinessUserEmail as _UserCompany   on  _UserCompany.Email  = _AssignCompany.Mail
                                                        and _UserCompany.UserID = $session.user
  association [0..1] to I_BusinessUserVH as _CreateUser  on  $projection.CreatedBy = _CreateUser.UserID
  association [0..1] to I_BusinessUserVH as _UpdateUser  on  $projection.LastChangedBy = _UpdateUser.UserID
  association [0..1] to I_Product        as _Product     on  $projection.Material = _Product.Product
  association [0..1] to I_ProductText    as _ProductText on  $projection.Material  = _ProductText.Product
                                                         and _ProductText.Language = $session.system_language
  association [0..1] to I_CompanyCode    as _CompanyCode on  $projection.CompanyCode = _CompanyCode.CompanyCode
  association [0..1] to I_Plant          as _Plant       on  $projection.Plant = _Plant.Plant
{
  key StockAge.inventorytype         as InventoryType,
  key StockAge.ledger                as Ledger,
  key StockAge.calendaryear          as CalendarYear,
  key StockAge.calendarmonth         as CalendarMonth,
  key StockAge.companycode           as CompanyCode,
  key StockAge.plant                 as Plant,
  key StockAge.material              as Material,
  key StockAge.age                   as Age,

      StockAge.qty                   as Qty,

      //status                as Status,  // ステータス
      //message               as Message, // メッセージ
      @Semantics.user.createdBy: true
      StockAge.created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      StockAge.created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      StockAge.last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      StockAge.last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      StockAge.local_last_changed_at as LocalLastChangedAt,
      _Product,
      _ProductText,
      _CompanyCode,
      _Plant,
      _CreateUser,
      _UpdateUser
}where ( _User.UserID is not initial ) or ( _User.UserID is null and StockAge.inventorytype = 'B' )
