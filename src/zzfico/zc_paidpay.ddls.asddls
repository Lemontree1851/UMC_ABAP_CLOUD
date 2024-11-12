@EndUserText.label: '有償支給品の純額計算Upload'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_PAIDPAY
  provider contract transactional_query
  as projection on ZR_PAIDPAY
{
  key UUID,
      CompanyCode, //会社コード
      FiscalYear,   //会計年度
      Period,       //会計期間
      ProfitCenter, //利益センタ
      BusinessPartner, //得意先コード
      PurchasingGroup, //購買グループ
      PreStockAmt, //前期末在庫金額
      BegPurGrpAmt, //期首購買グループ仕入れ金額
      BegChgMaterialAmt, //期首有償支給品仕入れ金額
      BegCustomerRev,    //期首得意先の総売上高
      BegRev, //期首会社レベルの総売上高
      Currency, //通貨
      Status, //ステータス
      Message, //メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
