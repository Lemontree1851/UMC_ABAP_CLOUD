@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_PRODUCTIONORDER'
@EndUserText.label: '製造指図一括発行'
@UI: {
  headerInfo: {
    typeName: '製造指図一括発行',
    typeNamePlural: '製造指図一括発行'
    } }
define root custom entity ZC_ProductionOrder
{
      @UI.lineItem             : [ { position: 30, label: 'プラント'} ]
      @UI.selectionField       : [ { position: 10 } ]
      @Consumption.filter      : { mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Plant', name: 'I_PlantStdVH' } } ]
      @EndUserText.label       : 'プラント'
  key Plant                    : werks_d;
      @UI.lineItem             : [ { position: 70, label: '指図番号'} ]
      @UI.selectionField       : [ { position: 80 } ]
      @Consumption.valueHelpDefinition: [ { entity: { element: 'ManufacturingOrder', name: 'I_MfgOrderStdVH' } } ]
      @EndUserText.label       : '指図番号'
  key ManufacturingOrder       : aufnr;
      @UI.lineItem             : [ { position: 40, label: '品目'} ]
      @UI.selectionField       : [ { position: 40 } ]
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_ProductStdVH' } } ]
      @EndUserText.label       : '品目'
      Material                 : abap.char( 40 );
      @UI.lineItem             : [ { position: 50, label: '品目テキスト'} ]
      @EndUserText.label       : '品目テキスト'
      ProductDescription       : maktx;
      @UI.lineItem             : [ { position: 60, label: '品目タイプ'} ]
      @EndUserText.label       : '品目タイプ'
      ProductType              : mtart;
      @UI.lineItem             : [ { position: 80, label: '計画開始日'} ]
      @UI.selectionField       : [ { position: 50 } ]
      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: false }
      @EndUserText.label       : '計画開始日'
      MfgOrderPlannedStartDate : abap.dats;
      @UI.lineItem             : [ { position: 90, label: '計画終了日'} ]
      @UI.selectionField       : [ { position: 60 } ]
      @Consumption.filter      : { selectionType: #SINGLE, multipleSelections: false }
      @EndUserText.label       : '計画終了日'
      MfgOrderPlannedEndDate   : abap.dats;
      @UI.lineItem             : [ { position: 100, label: '計画数量'} ]
      @EndUserText.label       : '計画数量'
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      MfgOrderPlannedTotalQty  : abap.quan( 13, 3 );
      @UI.lineItem             : [ { position: 110, label: '受注番号'} ]
      @EndUserText.label       : '受注番号'
      SalesOrder               : vbeln_va;
      @UI.lineItem             : [ { position: 120, label: '受注明細'} ]
      @EndUserText.label       : '受注明細'
      SalesOrderItem           : posnr_va;
      @UI.lineItem             : [ { position: 130, label: '指図タイプ'} ]
      @UI.selectionField       : [ { position: 70 } ]
      @Consumption.valueHelpDefinition: [ { entity: { element: 'ManufacturingOrderType', name: 'ZC_MfgOrderTypeVH' } } ]
      @EndUserText.label       : '指図タイプ'
      ManufacturingOrderType   : aufart;
      @UI.lineItem             : [ { position: 140, label: 'MRP管理者' } ]
      @UI.selectionField       : [ { position: 20 } ]
      @Consumption.valueHelpDefinition: [ { entity: { element: 'MRPController', name: 'ZC_MRPControllerVH' } } ]
      @EndUserText.label       : 'MRP管理者'
      MRPController            : co_dispo;
      @UI.lineItem             : [ { position: 150, label: '製造責任者' } ]
      @UI.selectionField       : [ { position: 30 } ]
      @Consumption.valueHelpDefinition: [ { entity: { element: 'ProductionSupervisor', name: 'ZC_ProductionSupervisorVH' } } ]
      @EndUserText.label       : '製造責任者'
      ProductionSupervisor     : abap.char( 3 );
      @UI.lineItem             : [ { position: 160, label: '製造バージョン' } ]
      @EndUserText.label       : '製造バージョン'
      ProductionVersion        : verid;
      @UI.hidden               : true
      PlanningStrategyGroup    : abap.char( 2 );
      @UI.lineItem             : [ { position: 10, label: 'ステータス' } ]
      @UI.lineItem             : [ { criticality: 'Criticality' } ]
      @EndUserText.label       : 'ステータス'
      MessageType              : abap.char( 1 );
      @UI.lineItem             : [ { position: 20, label: 'メッセージ' } ]
      @EndUserText.label       : 'メッセージ'
      Message                  : abap.char( 220 );

      @UI.hidden               : true
      ProductionUnit           : meins;
      @UI.hidden               : true
      Criticality              : abap.numc( 1 );
      @UI.hidden               : true
      LocalLastChangedAt       : abp_locinst_lastchange_tstmpl;
}
