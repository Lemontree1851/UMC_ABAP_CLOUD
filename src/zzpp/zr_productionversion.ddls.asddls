@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Production Version Upload'
define root view entity ZR_PRODUCTIONVERSION
  as select from ztpp_1007 as ProductionVersion
{
  key uuid                       as UUID,
      material                   as Material,                   // 品目
      plant                      as Plant,                      // プラント
      productionversion          as ProductionVersion,          // 製造バージョン
      productionversiontext      as ProductionVersionText,      // 製造バージョンテキスト
      validitystartdate          as ValidityStartDate,          // 有効開始日付
      validityenddate            as ValidityEndDate,            // 有効終了日
      billofoperationstype       as BillOfOperationsType,       // タスクリストタイプ
      billofoperationsgroup      as BillOfOperationsGroup,      // グループ
      billofoperationsvariant    as BillOfOperationsVariant,    // グループカウンタ
      billofmaterialvariantusage as BillOfMaterialVariantUsage, // BOM用途
      billofmaterialvariant      as BillOfMaterialVariant,      // 代替BOM
      productionline             as ProductionLine,             // 生産ライン
      issuingstoragelocation     as IssuingStorageLocation,     // 出庫保管場所
      receivingstoragelocation   as ReceivingStorageLocation,   // 入庫保管場所
      status                     as Status,                     // ステータス
      message                    as Message,                    // メッセージ
      @Semantics.user.createdBy: true
      created_by                 as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                 as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by            as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at            as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at      as LocalLastChangedAt

}
