@EndUserText.label: 'LED Planned Order Component'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_LEDPLANNEDORDERCOMPONENT'
@UI: {
  headerInfo: {
    typeName: 'LED生産計画の構成品目提案',
    typeNamePlural: 'LED生産計画の構成品目提案'
    } }
define root custom entity ZR_LEDPLANNEDORDERCOMPONENT
{
      @UI                        : { lineItem: [ { position: 40, label: 'プラント' } ], selectionField: [ { position: 10 } ] }
      @Consumption.filter        : { selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PlantStdVH', element: 'Plant' } } ]
      @EndUserText.label         : 'プラント'
  key Plant                      : werks_d;

      @UI                        : { lineItem: [ { position: 160, label: 'MRP管理者' } ], selectionField: [ { position: 20 } ] }
      @Consumption.filter        : { selectionType: #HIERARCHY_NODE, multipleSelections: false, mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_MRPControllerVH', element: 'MRPController' } } ]
      @EndUserText.label         : 'MRP管理者'
  key MRPController              : dispo;

      @UI                        : { lineItem: [ { position: 170, label: '製造責任者' } ], selectionField: [ { position: 30 } ] }
      @Consumption.filter        : { selectionType: #HIERARCHY_NODE, multipleSelections: false }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_ProductionSupervisorVH', element: 'ProductionSupervisor' } } ]
      @EndUserText.label         : '製造責任者'
  key ProductionSupervisor       : abap.char( 3 );

      @UI                        : { lineItem: [ { position: 90, label: '構成品目' } ], selectionField: [ { position: 40 } ] }
      @Consumption.filter        : { selectionType: #HIERARCHY_NODE, multipleSelections: false }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZI_PRODUCT_VH', element: 'Product' } } ]
      @EndUserText.label         : '品目'
  key Material                   : matnr;

      @UI                        : { lineItem: [ { position: 70, label: '所要日付' } ], selectionField: [ { position: 50 } ] }
      @Consumption.filter        : { selectionType: #SINGLE, multipleSelections: false }
      @EndUserText.label         : '所要日付'
  key MatlCompRequirementDate    : bdter;

      @UI                        : { lineItem: [ { position: 30, label: '計画手配' } ], selectionField: [ { position: 60 } ] }
      @Consumption.filter        : { selectionType: #HIERARCHY_NODE, multipleSelections: false }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_PlannedOrderVH', element: 'PlannedOrder' } } ]
      @EndUserText.label         : '計画手配番号'
  key PlannedOrder               : abap.char( 10 );

      @UI                        : { lineItem: [ { position: 50, label: '組立品目' } ] }
      @Consumption.filter.hidden : true
  key Assembly                   : matnr;

      @Semantics.unitOfMeasure   : true
      @Consumption.filter.hidden : true
  key BaseUnit                   : meins;

      @UI                        : { lineItem: [ { position: 60, label: '計画手配数量合計' } ] }
      @Consumption.filter.hidden : true
  key PlannedTotalQtyInBaseUnit  : abap.dec( 13, 3 );

      @UI                        : { lineItem: [ { position: 80, label: 'BOM明細番号' } ] }
      @Consumption.filter.hidden : true
  key BillOfMaterialItemNumber   : posnr;

      @UI                        : { lineItem: [ { position: 100, label: '使用頻度' } ] }
      @Consumption.filter.hidden : true
  key UsageProbabilityPercent    : abap.dec( 3, 0 );

      @UI                        : { lineItem: [ { position: 110, label: '代替明細グループ' } ] }
      @Consumption.filter.hidden : true
  key AlternativeItemGroup       : abap.char( 2 );

      @UI                        : { lineItem: [ { position: 120, label: '方針' } ] }
      @Consumption.filter.hidden : true
  key AlternativeItemStrategy    : abap.char( 1 );

      @UI                        : { lineItem: [ { position: 130, label: '優先順位' } ] }
      @Consumption.filter.hidden : true
  key AlternativeItemPriority    : abap.numc( 2 );

      @UI                        : { lineItem: [ { position: 140, label: '所要量' } ] }
      @Consumption.filter.hidden : true
      RequiredQuantity           : abap.dec( 13, 3 );

      @UI                        : { lineItem: [ { position: 150, label: '利用可能数量' } ] }
      @Consumption.filter.hidden : true
      ConfirmedAvailableQuantity : abap.dec( 13, 3 );

      @UI                        : { lineItem: [ { position: 180, label: '入出庫予定' } ] }
      @Consumption.filter.hidden : true
      Reservation                : rsnum;

      @UI                        : { lineItem: [ { position: 190, label: '入出庫予定明細' } ] }
      @Consumption.filter.hidden : true
      ReservationItem            : rspos;

      @UI                        : { lineItem: [ { position: 20, label: 'メッセージ' } ] }
      @Consumption.filter.hidden : true
      Message                    : msgtx;
      @Consumption.filter.hidden : true
      Status                     : msgty;
      @UI                        : { lineItem: [ { position: 10, label: 'ステータス' } ] }
      @Consumption.filter.hidden : true
      StatusText                 : abap.char( 8 );
}
