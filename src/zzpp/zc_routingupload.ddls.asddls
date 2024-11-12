@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Routing Upload'
define root view entity ZC_ROUTINGUPLOAD
  provider contract transactional_query
  as projection on ZR_ROUTINGUPLOAD
{
  key UUID,
      Product,                   // 品目
      Plant,                     // プラント
      ValidityStartDate,         // 有効開始日付
      BillOfOperationsDesc,      // 作業手順テキスト
      ProductionRouting,         // グループカウンタ
      BillOfOperationsUsage,     // 用途
      BillOfOperationsStatus,    // 全体ステータス
      ResponsiblePlannerGroup,   // 計画グループ
      Operation,                 // 作業番号
      WorkCenter,                // 作業区
      OperationControlProfile,   // 管理キー
      OperationText,             // 作業テキスト
      StandardWorkQuantity1,     // パラメータ1：段取
      StandardWorkQuantityUnit1, // 単位1
      StandardWorkQuantity2,     // パラメータ2：機械/作業サイクル
      StandardWorkQuantityUnit2, // 単位2
      StandardWorkQuantity3,     // パラメータ3：作業工数
      StandardWorkQuantityUnit3, // 単位3
      StandardWorkQuantity4,     // パラメータ4：面積
      StandardWorkQuantityUnit4, // 単位4
      StandardWorkQuantity5,     // パラメータ5：電力
      StandardWorkQuantityUnit5, // 単位5
      StandardWorkQuantity6,     // パラメータ6：その他製造費用
      StandardWorkQuantityUnit6, // 単位6
      NumberOfTimeTickets,       // 作業記録票枚数（作業人数）
      Status,                    // ステータス
      Message,                   // メッセージ
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt
}
