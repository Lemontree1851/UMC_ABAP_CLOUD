@EndUserText.label: 'Sales Acceptance'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_SALESACCEPTANCE
  provider contract transactional_query
  as projection on ZR_SALESACCEPTANCE
{
  key  UUID,
       SalesOrganization, //販売組織
       Customer, //得意先BPコード
       PeriodType, //時期区分
       AcceptPeriod, //検収期間
       CustomerPO, //得意先PO番号
       ItemNo, //明細番号
       AcceptPeriodFrom, //検収期間From
       AcceptPeriodTo, //AcceptPeriodTo
       UMCProductCode, //UMC品目コード
       CustomerMaterial, //得意先品番
       CustomerMaterialText, //得意先品名
       ReceiptDate, //納期(年月日)
       AcceptDate, //検収日(年月日)
       AcceptQty, //検収数
       ReceiptQty, //納入数
       UnqualifiedQty, //不合格数
       UndersupplyQty, //不足数
       AcceptPrice, //検収単価
       AccceptAmount, //検収金額
       Currency, //通貨
       TaxRate,  //消費税率
       OutsideData, //SAP外売上区分
       FinishStatus, //照合済み status
       Status, // ステータス
       Message, // メッセージ
       Unit,
       CreatedBy,
       CreatedAt,
       LastChangedBy,
       LastChangedAt,
       LocalLastChangedAt
}
