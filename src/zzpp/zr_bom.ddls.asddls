@ObjectModel.query.implementedBy: 'ABAP:ZCL_BOM'
@EndUserText.label: 'BOMのレポート'
@UI: {
  headerInfo: {
    typeName: 'BOMのレポート',
    typeNamePlural: 'BOMのレポート'
    } }
define root custom entity ZR_BOM
{
      @UI                           : { lineItem: [ { position: 10, label: '品目' } ], selectionField: [ { position: 20 } ] }
      @Consumption.filter           : { mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Material', name: 'ZC_BOMMaterialVH' } } ]
      @EndUserText.label            : '品目コード'
  key Material                      : abap.char( 40 );
      @UI                           : { lineItem: [ { position: 20, label: 'プラント' } ], selectionField: [ { position: 10 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Plant', name: 'I_PlantStdVH' } } ]
      @EndUserText.label            : 'プラント'
  key Plant                         : werks_d;
      @UI                           : { lineItem: [ { position: 21, label: '顶层代替BOM' } ] }
      @UI.hidden                    : true
      @EndUserText.label            : '顶层代替BOM'
  key BillOfMaterialVariantRoot     : abap.char( 2 );
      @UI                           : { lineItem: [ { position: 30, label: '品目2' } ] }
      @EndUserText.label            : '品目2'
  key HeaderMaterial                : matnr;
      @UI                           : { lineItem: [ { position: 40, label: 'レベル' } ] }
      @EndUserText.label            : 'レベル'
  key ExplodeBOMLevelValue          : abap.dec( 2 );
      @UI                           : { lineItem: [ { position: 50, label: '明細番号' } ] }
      @EndUserText.label            : '明細番号'
  key BillOfMaterialItemNumber      : abap.char( 4 );
      @UI                           : { lineItem: [ { position: 90, label: '代替BOM' } ], selectionField: [ { position: 50 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false }
      @EndUserText.label            : '代替BOM'
  key BillOfMaterialVariant         : abap.char( 2 );
      @UI.hidden                    : true
  key bomsubitemnumbervalue         : abap.char( 4 );
      @UI                           : { lineItem: [ { position: 60, label: '明細カテゴリ' } ] }
      @EndUserText.label            : '明細カテゴリ'
      BillOfMaterialItemCategory    : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 70, label: '構成品目' } ] }
      @EndUserText.label            : '構成品目'
      BillOfMaterialComponent       : matnr;
      @UI                           : { lineItem: [ { position: 80, label: '構成品目テキスト' } ] }
      @EndUserText.label            : '構成品目テキスト'
      ComponentDescription          : maktx;
      @UI                           : { selectionField: [ { position: 40 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, mandatory: true, defaultValue: 'PP01' }
      @EndUserText.label            : 'BOMアプリケーション'
      BOMExplosionApplication       : abap.char( 4 );
      @UI                           : { selectionField: [ { position: 60 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label            : '有効開始日'
      HeaderValidityStartDate       : datuv;
      @UI                           : { selectionField: [ { position: 70 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label            : '所要量'
      RequiredQuantity              : abap.dec( 13, 3 );
      //      @UI                           : { selectionField: [ { position: 80 } ] }
      //      @Consumption.filter           : { defaultValue: 'X' }
      //      @EndUserText.label            : '代替優先度'
      //      BOMExplosionIsAlternatePrio   : abap_boolean;

      @UI                           : { selectionField: [ { position: 81 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, defaultValue: '1'  }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'value_low', name: 'ZC_ExplodeTypeVH' } } ]
      @EndUserText.label            : '展開方式'
      BOMExplosionType              : ze_explodetype;

      //      @UI                           : { selectionField: [ { position: 90 } ] }
      //      @Consumption.filter           : { defaultValue: 'X' }
      //      @EndUserText.label            : '多段階展開'
      BOMExplosionIsMultilevel      : abap_boolean;
      @UI                           : { selectionField: [ { position: 100 } ] }
      @Consumption.filter           : { defaultValue: 'X' }
      @EndUserText.label            : 'サブパーツ表示'
      ShowSubParts                  : abap_boolean;
      @UI                           : { selectionField: [ { position: 110 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, defaultValue: '' }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'value_low', name: 'ZC_PositionVH' } } ]
      @EndUserText.label            : '設置ポイント表示'
      LocalPosition                 : ze_position;
      @UI                           : { lineItem: [ { position: 100, label: '代替明細グループ' } ]}
      @EndUserText.label            : '代替明細グループ'
      AlternativeItemGroup          : abap.char( 6 );
      @UI                           : { lineItem: [ { position: 110, label: '優先度' } ]}
      @EndUserText.label            : '優先度'
      AlternativeItemPriority       : abap.numc( 2 );
      @UI                           : { lineItem: [ { position: 120, label: '方針' } ]}
      @EndUserText.label            : '方針'
      AlternativeItemStrategy       : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 130, label: '使用頻度%' } ]}
      @EndUserText.label            : '使用頻度%'
      UsageProbabilityPercent       : abap.dec( 3, 0 );
      @UI                           : { lineItem: [ { position: 140, label: '打切-フォローアップ区分' } ]}
      @EndUserText.label            : '打切-フォローアップ区分'
      DiscontinuationFollowUpGroup  : abap.char( 10 );
      @UI                           : { lineItem: [ { position: 150, label: '打切区分' } ]}
      @EndUserText.label            : '打切区分'
      BOMItemIsDiscontinued         : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 160, label: '打切グループ' } ]}
      @EndUserText.label            : '打切グループ'
      DiscontinuationGroup          : abap.char( 2 );
      @UI                           : { lineItem: [ { position: 170, label: 'フォローアップ Group' } ]}
      @EndUserText.label            : 'フォローアップ Group'
      FollowUpGroup                 : abap.char( 2 );
      @UI                           : { lineItem: [ { position: 180, label: 'MPN' } ]}
      @EndUserText.label            : 'MPN'
      ProductManufacturerNumber     : abap.char( 40 );
      @UI                           : { lineItem: [ { position: 190, label: 'メーカー' } ]}
      @EndUserText.label            : 'メーカー'
      BusinessPartnerFullName       : abap.char( 80 );
      @UI                           : { lineItem: [ { position: 200, label: 'BOM構成品目単位' } ]}
      @EndUserText.label            : 'BOM構成品目単位'
      @Semantics.unitOfMeasure      : true
      BillOfMaterialItemUnit        : abap.unit( 3 );
      @UI                           : { lineItem: [ { position: 210, label: 'BOMテキスト' } ]}
      @EndUserText.label            : 'BOMテキスト'
      BOMHeaderText                 : abap.char( 40 );
      @UI                           : { lineItem: [ { position: 220, label: 'BOM構成品目単位数量' } ]}
      @EndUserText.label            : 'BOM構成品目単位数量'
      //@Semantics.quantity.unitOfMeasure: 'BillOfMaterialItemUnit'
      ComponentQuantityInCompUoM    : abap.quan( 13, 3 );
      @UI                           : { lineItem: [ { position: 230, label: '取付位置' } ]}
      @EndUserText.label            : '取付位置'
      BOMItemSorter                 : abap.char( 10 );
      @UI                           : { lineItem: [ { position: 240, label: '支給区分' } ]}
      @EndUserText.label            : '支給区分'
      IsMaterialProvision           : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 250, label: 'ECO NO' } ]}
      @EndUserText.label            : 'ECO NO'
      ChangeNumber                  : abap.char( 12 );
      @UI                           : { lineItem: [ { position: 260, label: '設置ポイント' } ]}
      @EndUserText.label            : '設置ポイント'
      BOMSubItemInstallationPoint   : abap.char( 900 );
      @UI                           : { lineItem: [ { position: 270, label: '副明細数量' } ]}
      @EndUserText.label            : '副明細数量'
      //@Semantics.quantity.unitOfMeasure: 'BillOfMaterialItemUnit'
      BillOfMaterialSubItemQuantity : abap.quan( 13, 3 );
      @UI                           : { lineItem: [ { position: 280, label: '備考' } ]}
      @EndUserText.label            : '備考'
      BOMItemText2                  : abap.char( 40 );
      @UI                           : { lineItem: [ { position: 290, label: '得意先品目' } ]}
      @EndUserText.label            : '得意先品目'
      BOMItemDescription            : abap.char( 40 );
      @UI                           : { lineItem: [ { position: 300, label: 'バルク区分' } ]}
      @EndUserText.label            : 'バルク区分'
      IsBulkMaterial                : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 310, label: '原価計算関連' } ]}
      @EndUserText.label            : '原価計算関連'
      BOMItemIsCostingRelevant      : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 320, label: '改訂レベル' } ]}
      @EndUserText.label            : '改訂レベル'
      RevisionLevel                 : abap.char( 4 );
      @UI                           : { lineItem: [ { position: 330, label: '購買情報' } ]}
      @EndUserText.label            : '購買情報'
      IsPurConditionRecord          : abap.char( 10 );
      @UI                           : { lineItem: [ { position: 340, label: '正味重量' } ]}
      @EndUserText.label            : '正味重量'
      //@Semantics.quantity.unitOfMeasure: 'WeightUnit'
      NetWeight                     : abap.quan( 13, 3 );
      @UI                           : { lineItem: [ { position: 350, label: '重量単位' } ]}
      @EndUserText.label            : '重量単位'
      WeightUnit                    : abap.unit( 3 );
      @UI                           : { lineItem: [ { position: 360, label: '品目グループ' } ]}
      @EndUserText.label            : '品目グループ'
      MaterialGroup                 : abap.char( 9 );
      @UI                           : { lineItem: [ { position: 370, label: 'グループテキスト' } ]}
      @EndUserText.label            : 'グループテキスト'
      ProductGroupName              : abap.char( 20 );
      @UI                           : { lineItem: [ { position: 380, label: 'BOM構成品目基本単位' } ]}
      @EndUserText.label            : 'BOM構成品目単位'
      BillOfMaterialItemBaseUnit    : abap.unit( 3 );
      @UI                           : { lineItem: [ { position: 390, label: 'BOM構成品目基本単位数量' } ]}
      @EndUserText.label            : 'BOM構成品目単位数量'
      //@Semantics.quantity.unitOfMeasure: 'BillOfMaterialItemBaseUnit'
      ComponentQuantityInBaseUoM    : abap.quan( 13, 3 );
      @UI                           : { lineItem: [ { position: 400, label: '発注可否' } ]}
      @EndUserText.label            : '発注可否'
      ProfileCode                   : abap.char( 20 );
      @UI                           : { lineItem: [ { position: 410, label: 'MRP管理者' } ],selectionField: [ { position: 30 } ] }
      @EndUserText.label            : 'MRP管理者'
      MRPResponsible                : abap.char( 3 );
      @UI                           : { lineItem: [ { position: 420, label: '予備部品区分' } ]}
      @EndUserText.label            : '予備部品区分'
      BOMItemIsSparePart            : abap.char( 1 );
      @UI                           : { lineItem: [ { position: 430, label: '生産場所' } ]}
      @EndUserText.label            : '生産場所'
      ProdOrderIssueLocation        : abap.char( 4 );
}
