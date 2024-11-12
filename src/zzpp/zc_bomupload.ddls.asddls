@EndUserText.label: 'BOM Upload'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_BOMUPLOAD
  provider contract transactional_query
  as projection on ZR_BOMUPLOAD
{
  key UUID,
      Material,                      // 品目
      Plant,                         // プラント
      BillOfMaterialVariantUsage,    // BOM用途
      BillOfMaterialVariant,         // 代替BOM
      HeaderValidityStartDate,       // 有効開始日
      BOMHeaderQuantityInBaseUnit,   // 基本数量
      BOMHeaderText,                 // BOMテキスト
      BOMAlternativeText,            // 代替テキスト
      BillOfMaterialStatus,          // BOMステータス
      BillOfMaterialItemNumber,      // 明細番号
      BillOfMaterialItemCategory,    // 明細カテゴリ
      BillOfMaterialComponent,       // 構成品目
      BillOfMaterialItemQuantity,    // 構成数量
      BillOfMaterialItemUnit,        // 単位
      BOMItemSorter,                 // ソート列
      ComponentScrapInPercent,       // 構成品不良率
      AlternativeItemGroup,          // 代替明細グループ
      AlternativeItemPriority,       // 優先順位
      AlternativeItemStrategy,       // 方針
      UsageProbabilityPercent,       // 使用頻度
      BOMItemDescription,            // 明細テキスト行1
      BOMItemText2,                  // 明細テキスト行2
      ProdOrderIssueLocation,        // 保管場所
      BOMItemIsCostingRelevant,      // 原価計算関連フラグ
      BOMSubItemInstallationPoint,   // 副明細設定ポイント
      BillOfMaterialSubItemQuantity, // 副明細数量
      Status,                        // ステータス
      Message,                       // メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
