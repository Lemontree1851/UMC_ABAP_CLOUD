@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BOM Upload'
define root view entity ZR_BOMUPLOAD
  as select from ztpp_1002
{
  key uuid                          as UUID,
      material                      as Material,                      // 品目
      plant                         as Plant,                         // プラント
      billofmaterialvariantusage    as BillOfMaterialVariantUsage,    // BOM用途
      billofmaterialvariant         as BillOfMaterialVariant,         // 代替BOM
      headervaliditystartdate       as HeaderValidityStartDate,       // 有効開始日
      bomheaderquantityinbaseunit   as BOMHeaderQuantityInBaseUnit,   // 基本数量
      bomheadertext                 as BOMHeaderText,                 // BOMテキスト
      bomalternativetext            as BOMAlternativeText,            // 代替テキスト
      billofmaterialstatus          as BillOfMaterialStatus,          // BOMステータス
      billofmaterialitemnumber      as BillOfMaterialItemNumber,      // 明細番号
      billofmaterialitemcategory    as BillOfMaterialItemCategory,    // 明細カテゴリ
      billofmaterialcomponent       as BillOfMaterialComponent,       // 構成品目
      billofmaterialitemquantity    as BillOfMaterialItemQuantity,    // 構成数量
      billofmaterialitemunit        as BillOfMaterialItemUnit,        // 単位
      bomitemsorter                 as BOMItemSorter,                 // ソート列
      componentscrapinpercent       as ComponentScrapInPercent,       // 構成品不良率
      alternativeitemgroup          as AlternativeItemGroup,          // 代替明細グループ
      alternativeitempriority       as AlternativeItemPriority,       // 優先順位
      alternativeitemstrategy       as AlternativeItemStrategy,       // 方針
      usageprobabilitypercent       as UsageProbabilityPercent,       // 使用頻度
      bomitemdescription            as BOMItemDescription,            // 明細テキスト行1
      bomitemtext2                  as BOMItemText2,                  // 明細テキスト行2
      prodorderissuelocation        as ProdOrderIssueLocation,        // 保管場所
      bomitemiscostingrelevant      as BOMItemIsCostingRelevant,      // 原価計算関連フラグ
      bomsubiteminstallationpoint   as BOMSubItemInstallationPoint,   // 副明細設定ポイント
      billofmaterialsubitemquantity as BillOfMaterialSubItemQuantity, // 副明細数量
      status                        as Status,  // ステータス
      message                       as Message, // メッセージ
      @Semantics.user.createdBy: true
      created_by                    as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at         as LocalLastChangedAt
}
