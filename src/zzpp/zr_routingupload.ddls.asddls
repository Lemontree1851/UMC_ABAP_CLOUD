@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Routing Upload'
define root view entity ZR_ROUTINGUPLOAD
  as select from ztpp_1006 as RoutingUpload
{
  key uuid                      as UUID,
      product                   as Product,                   // 品目
      plant                     as Plant,                     // プラント
      validitystartdate         as ValidityStartDate,         // 有効開始日付
      billofoperationsdesc      as BillOfOperationsDesc,      // 作業手順テキスト
      productionrouting         as ProductionRouting,         // グループカウンタ
      billofoperationsusage     as BillOfOperationsUsage,     // 用途
      billofoperationsstatus    as BillOfOperationsStatus,    // 全体ステータス
      responsibleplannergroup   as ResponsiblePlannerGroup,   // 計画グループ
      operation                 as Operation,                 // 作業番号
      workcenter                as WorkCenter,                // 作業区
      operationcontrolprofile   as OperationControlProfile,   // 管理キー
      operationtext             as OperationText,             // 作業テキスト
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit1'
      standardworkquantity1     as StandardWorkQuantity1,     // パラメータ1：段取
      standardworkquantityunit1 as StandardWorkQuantityUnit1, // 単位1
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit2'
      standardworkquantity2     as StandardWorkQuantity2,     // パラメータ2：機械/作業サイクル
      standardworkquantityunit2 as StandardWorkQuantityUnit2, // 単位2
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit3'
      standardworkquantity3     as StandardWorkQuantity3,     // パラメータ3：作業工数
      standardworkquantityunit3 as StandardWorkQuantityUnit3, // 単位3
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit4'
      standardworkquantity4     as StandardWorkQuantity4,     // パラメータ4：面積
      standardworkquantityunit4 as StandardWorkQuantityUnit4, // 単位4
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit5'
      standardworkquantity5     as StandardWorkQuantity5,     // パラメータ5：電力
      standardworkquantityunit5 as StandardWorkQuantityUnit5, // 単位5
      @Semantics.quantity.unitOfMeasure: 'StandardWorkQuantityUnit6'
      standardworkquantity6     as StandardWorkQuantity6,     // パラメータ6：その他製造費用
      standardworkquantityunit6 as StandardWorkQuantityUnit6, // 単位6
      numberoftimetickets       as NumberOfTimeTickets,       // 作業記録票枚数（作業人数）
      status                    as Status,                    // ステータス
      message                   as Message,                   // メッセージ
      @Semantics.user.createdBy: true
      created_by                as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at                as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by           as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at           as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at     as LocalLastChangedAt

}
