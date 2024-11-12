@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Acceptance'
define root view entity ZR_SALESACCEPTANCE
  as select from ztsd_1002
{
  key uuid                  as UUID,
      salesorganization     as SalesOrganization, //販売組織
      customer              as Customer, //得意先BPコード
      periodtype            as PeriodType, //時期区分
      acceptperiod          as AcceptPeriod, //検収期間
      customerpo            as CustomerPO, //得意先PO番号
      itemno                as ItemNo, //明細番号
      acceptperiodfrom      as AcceptPeriodFrom, //検収期間From
      acceptperiodto        as AcceptPeriodTo, //AcceptPeriodTo
      umcproductcode        as UMCProductCode, //UMC品目コード
      customermaterial      as CustomerMaterial, //得意先品番
      customermaterialtext  as CustomerMaterialText, //得意先品名
      receiptdate           as ReceiptDate, //納期(年月日)
      acceptdate            as AcceptDate, //検収日(年月日)
      acceptqty             as AcceptQty, //検収数
      receiptqty            as ReceiptQty, //納入数
      unqualifiedqty        as UnqualifiedQty, //不合格数
      undersupplyqty        as UndersupplyQty, //不足数
      acceptprice           as AcceptPrice, //検収単価
      accceptamount         as AccceptAmount, //検収金額
      currency              as Currency, //通貨
      taxrate               as TaxRate,  //消費税率
      outsidedata           as OutsideData, //SAP外売上区分
      finishstatus          as FinishStatus, //照合済み status
      status                as Status, // ステータス
      message               as Message, // メッセージ
      unit                  as Unit,
      created_by            as CreatedBy,
      created_at            as CreatedAt,
      last_changed_by       as LastChangedBy,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt

}
