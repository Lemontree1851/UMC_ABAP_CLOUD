@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Version Upload'
define root view entity ZC_PRODUCTIONVERSION
  provider contract transactional_query
  as projection on ZR_PRODUCTIONVERSION
{
  key UUID,
      Material,                   // 品目
      Plant,                      // プラント
      ProductionVersion,          // 製造バージョン
      ProductionVersionText,      // 製造バージョンテキスト
      ValidityStartDate,          // 有効開始日付
      ValidityEndDate,            // 有効終了日
      BillOfOperationsType,       // タスクリストタイプ
      BillOfOperationsGroup,      // グループ
      BillOfOperationsVariant,    // グループカウンタ
      BillOfMaterialVariantUsage, // BOM用途
      BillOfMaterialVariant,      // 代替BOM
      ProductionLine,             // 生産ライン
      IssuingStorageLocation,     // 出庫保管場所
      ReceivingStorageLocation,   // 入庫保管場所
      Status,                     // ステータス
      Message,                    // メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
