@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '有償支給品の純額計算Upload'
define root view entity ZR_PAIDPAY
  as select from ztfi_1007
{
  key uuid                  as UUID,
      companycode           as CompanyCode,  //会社コード
      fiscalyear            as FiscalYear,   //会計年度
      period                as Period,       //会計期間
      profitcenter          as ProfitCenter, //利益センタ
      businesspartner       as BusinessPartner, //得意先コード
      purchasinggroup       as PurchasingGroup, //購買グループ
      prestockamt           as PreStockAmt, //前期末在庫金額
      begpurgrpamt          as BegPurGrpAmt, //期首購買グループ仕入れ金額
      begchgmaterialamt     as BegChgMaterialAmt, //期首有償支給品仕入れ金額
      begcustomerrev        as BegCustomerRev, //期首得意先の総売上高
      begrev                as BegRev,  //期首会社レベルの総売上高
      currency              as Currency, //通貨
      status                as Status, //ステータス
      message               as Message, //メッセージ
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
