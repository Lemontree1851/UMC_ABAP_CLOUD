@EndUserText.label: 'PO Change'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_POCHANGE
  provider contract transactional_query
  as projection on ZR_POCHANGE
{
  key UUID,
      PurchaseOrder, //購買発注
      PurchaseOrderItem, //購買発注明細
      CompanyCode, //会社コード
      PurchasingOrganization, //購買組織
      PurchasingGroup, //購買グループ
      Currency, //通貨
      PurchasingDocumentDeletionCode, //削除フラグ
      AccountAssignmentCategory, //勘定設定カテゴリ
      PurchaseOrderItemCategory, //明細カテゴリ
      Material, //品目
      PurchaseOrderItemText, //テキスト(短)
      MaterialGroup, //品目グループ
      OrderQuantity, //発注数量
      ScheduleLineDeliveryDate, //納入日付
      NetPriceAmount, //正味発注価格
      OrderPriceUnit, //発注価格単位
      Plant, //プラント
      StorageLocation, //保管場所
      RequisitionerName, //購買依頼者
      RequirementTracking, //購買依頼追跡番号
      IsReturnItem, //返品明細
      InternationalArticleNumber, //EAN/UPC
      DiscountInKindEligibility, //無償品対象
      TaxCode, //税コード
      IsCompletelyDelivered, //納入完了
      PricingDateControl, //価格設定日制御
      PurgDocPriceDate, //価格設定日
      GLAccount, //GL勘定科目
      CostCenter, //原価センタ
      MasterFixedAsset, //資産
      FixedAsset, //資産補助番号
      OrderID, //指図
      WBSElementInternalID_2, //WBS要素
      LongText, //項目テキスト
      Status,  //ステータス
      Message, //メッセージ
      PurchaseOrderUnit, //Purchase Order Unit
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
