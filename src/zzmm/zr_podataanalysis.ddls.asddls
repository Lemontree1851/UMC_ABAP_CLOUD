@ObjectModel.query.implementedBy: 'ABAP:ZCL_PODATAANALYSIS'
@EndUserText.label: 'PO状況分析レポート'
@UI: {
  headerInfo: {
    typeName: 'PO状況分析レポート',
    typeNamePlural: 'PO状況分析レポート',
    title: { type: #STANDARD, value: 'PurchaseOrder' }
        } }
define custom entity ZR_PODATAANALYSIS
{
  key UUID                          : sysuuid_x16;
      @UI                           : { lineItem: [ { position: 90, label: '購買発注番号' } ], selectionField: [ { position: 30 } ] }
      @Consumption                  : { valueHelpDefinition: [{ entity:{ element: 'PurchaseOrder', name: 'ZC_PurchaseOrderAPI' } }] }
      @EndUserText.label            : '購買発注番号'
      PurchaseOrder                 : abap.char(10);

      @UI                           : { lineItem: [ { position: 100, label: '行明細番号 ' } ]}
      @EndUserText.label            : '行明細番号 '
      PurchaseOrderItem             : abap.char(5);

      @UI                           : { lineItem: [ { position: 900, label: '行明細番号 ' } ]}
      @EndUserText.label            : '行明細番号 '
      @UI.hidden                    : true
      SequentialNmbrOfSuplrConf     : abap.numc(4);

      @UI                           : { lineItem: [ { position: 10, label: '伝票タイプ' } ]}
      @EndUserText.label            : '伝票タイプ'
      PurchaseOrderType             : abap.char(4);

      @UI                           : { lineItem: [ { position: 20, label: '購買グループ' } ], selectionField: [ { position: 10 } ] }
      @Consumption                  : { valueHelpDefinition: [{ entity:{ element: 'PurchasingGroup', name: 'I_PurchasingGroup' } }] }
      @EndUserText.label            : '購買グループ'
      PurchasingGroup               : abap.char(3);

      @UI                           : { lineItem: [ { position: 30, label: '購買グループ名称' } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '購買グループ名称'
      PurchasingGroupName           : abap.char(40);

      @UI                           : { lineItem: [ { position: 40, label: 'MRPエリア' } ]}
      @EndUserText.label            : 'MRPエリア'
      MRPArea                       : abap.char(10);

      @UI                           : { lineItem: [ { position: 50, label: 'MRPコントロール' } ], selectionField: [ { position: 20 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_MRPControllerVH', element: 'MRPController' } }]
      @EndUserText.label            : 'MRPコントロール'
      MRPResponsible                : abap.char(3);

      @UI                           : { lineItem: [ { position: 60, label: 'コントロール名称' } ]}
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : 'コントロール名称'
      MRPControllerName             : abap.char(18);

      @UI                           : { lineItem: [ { position: 70, label: 'Header REMARK' } ]}
      @EndUserText.label            : 'Header REMARK'
      PlainLongText                 : abap.char(255);

      @UI                           : { lineItem: [ { position: 80, label: '項目テキスト' } ]}
      @EndUserText.label            : '項目テキスト'
      PlainLongText1                : abap.char(255);

      @UI                           : { lineItem: [ { position: 110, label: '交番発注番号ー行明細' } ], selectionField: [ { position: 40 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '交番発注番号ー行明細'
      POPOItem                      : abap.char(15);

      @UI                           : { lineItem: [ { position: 120, label: '勘定設定 Categ.' } ], selectionField: [ { position: 50 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '勘定設定 Categ.'
      AccountAssignmentCategory     : abap.char(1);

      @UI                           : { lineItem: [ { position: 130, label: '購買依頼' } ]}
      @EndUserText.label            : '購買依頼'
      PurchaseRequisition           : abap.char(10);

      @UI                           : { lineItem: [ { position: 140, label: '購買依頼（＃） ' } ]}
      @EndUserText.label            : '購買依頼（＃） '
      PurchaseRequisitionItem       : abap.numc(5);

      @UI                           : { lineItem: [ { position: 150, label: '購買依頼者' } ]}
      @EndUserText.label            : '購買依頼者'
      RequisitionerName             : abap.char(12);

      @UI                           : { lineItem: [ { position: 160, label: '購買依頼追跡番号' } ]}
      @EndUserText.label            : '購買依頼追跡番号'
      RequirementTracking           : abap.char(10);

      @UI                           : { lineItem: [ { position: 170, label: '海外PO番号/回収管理番号' } ], selectionField: [ { position: 55 } ]}
      @EndUserText.label            : '海外PO番号/回収管理番号'
      InternationalArticleNumber    : abap.char(18);

      @UI                           : { lineItem: [ { position: 180, label: '得意先コード' } ]}
      @EndUserText.label            : '得意先コード'
      YY1_BPCODE_PRD_PRD            : abap.char(10);

      @UI                           : { lineItem: [ { position: 190, label: '得意先名称' } ]}
      @EndUserText.label            : '得意先名称'
      Customer                      : abap.char(10);

      @UI                           : { lineItem: [ { position: 200, label: '仕入先コード' } ], selectionField: [ { position: 60 } ] }
      @Consumption                  : { valueHelpDefinition: [{ entity:{ element: 'Supplier', name: 'ZC_SupplierVH' } }] }
      @EndUserText.label            : '仕入先コード'
      Supplier                      : abap.char(10);

      @UI                           : { lineItem: [ { position: 210, label: '仕入先名称' } ]}
      @EndUserText.label            : '仕入先名称'
      SupplierName1                 : abap.char(80);

      @UI                           : { lineItem: [ { position: 220, label: '供給者部門' } ]}
      @EndUserText.label            : '供給者部門'
      SupplierSubrange              : abap.char(6);

      @UI                           : { lineItem: [ { position: 230, label: '供給者部門テキスト' } ]}
      @EndUserText.label            : '供給者部門テキスト'
      SupplierSubrangeText          : abap.char(50);

      @UI                           : { lineItem: [ { position: 240, label: '品目グループ' } ]}
      @EndUserText.label            : '品目グループ'
      MaterialGroup                 : abap.char(9);

      @UI                           : { lineItem: [ { position: 250, label: '品目コード' } ], selectionField: [ { position: 70 } ] }
      @Consumption                  : { valueHelpDefinition: [{ entity:{ element: 'Product', name: 'ZI_PRODUCT_VH' } }] }
      @EndUserText.label            : '品目コード'
      Material                      : abap.char(40);

      @UI                           : { lineItem: [ { position: 260, label: '品目テキスト' } ]}
      @EndUserText.label            : '品目テキスト'
      PurchaseOrderItemText         : abap.char(40);

      @UI                           : { lineItem: [ { position: 270, label: '仕入先品目コード' } ], selectionField: [ { position: 80 } ] }
      @EndUserText.label            : '仕入先品目コード'
      SupplierMaterialNumber        : abap.char(35);

      @UI                           : { lineItem: [ { position: 280, label: '内部品目' } ]}
      @EndUserText.label            : '内部品目'
      ManufacturerMaterial          : abap.char(40);

      @UI                           : { lineItem: [ { position: 290, label: 'MPN番号' } ]}
      @EndUserText.label            : 'MPN番号'
      ManufacturerPartNmbr          : abap.char(40);

      @UI                           : { lineItem: [ { position: 300, label: 'Manufacturer code' } ]}
      @EndUserText.label            : 'Manufacturer code'
      Manufacturer                  : abap.char(10);

      @UI                           : { lineItem: [ { position: 310, label: 'Name of manufacturer' } ]}
      @EndUserText.label            : 'Name of manufacturer'
      SupplierName2                 : abap.char(80);

      @UI                           : { lineItem: [ { position: 320, label: 'L/T' } ]}
      @EndUserText.label            : 'L/T'
      PlannedDeliveryDurationInDays : abap.dec(3);

      @UI                           : { lineItem: [ { position: 330, label: '入庫処理時間' } ]}
      @EndUserText.label            : '入庫処理時間'
      GoodsReceiptDurationInDays    : abap.dec(3);

      @UI                           : { lineItem: [ { position: 340, label: '丸め数量' } ]}
      @EndUserText.label            : '丸め数量'
      LotSizeRoundingQuantity       : abap.quan(13);

      @UI                           : { lineItem: [ { position: 350, label: 'PO単価' } ]}
      @EndUserText.label            : 'PO単価'
      NetPrice                      : abap.char(20);

      @UI                           : { lineItem: [ { position: 360, label: '通貨' } ]}
      @EndUserText.label            : '通貨'
      @Semantics.currencyCode       : true
      DocumentCurrency              : waers;

      @UI                           : { lineItem: [ { position: 370, label: 'PO発行日' } ],selectionField: [ { position: 90 } ]}
      @Consumption.filter           : { mandatory: false }
      @Consumption.filter           : { selectionType: #INTERVAL, multipleSelections: false }
      @EndUserText.label            : 'PO発行日'
      PurchaseOrderDate             : abap.dats;

      @UI                           : { lineItem: [ { position: 380, label: 'PO納期' } ], selectionField: [ { position: 100 } ]}
      @Consumption.filter           : { mandatory: false }
      @Consumption.filter           : { selectionType: #INTERVAL, multipleSelections: false }
      @EndUserText.label            : 'PO納期'
      ScheduleLineDeliveryDate      : abap.dats;

      @UI                           : { lineItem: [ { position: 390, label: 'PO発注数量' } ]}
      @EndUserText.label            : 'PO発注数量'
      OrderQuantity                 : abap.quan(13,3);

      @UI                           : { lineItem: [ { position: 400, label: 'PO残' } ]}
      @EndUserText.label            : 'PO残'
      PoNokoru                      : abap.quan(13);

      @UI                           : { lineItem: [ { position: 410, label: '発注単位' } ]}
      @EndUserText.label            : '発注単位'
      @Semantics.unitOfMeasure      : true
      PurchaseOrderQuantityUnit     : abap.unit(3);

      @UI                           : { lineItem: [ { position: 420, label: 'MC要求' } ]}
      @EndUserText.label            : 'MC要求'
      McRequire                     : abap.char(20);

      @UI                           : { lineItem: [ { position: 430, label: '注意' } ]}
      @EndUserText.label            : '注意'
      Attention                     : abap.char(20);

      @UI                           : { lineItem: [ { position: 440, label: '購買納入日付' } ]}
      @EndUserText.label            : '購買納入日付'
      MRPDeliveryDate               : abap.dats;

      @UI                           : { lineItem: [ { position: 450, label: ' 生産計画日付' } ]}
      @EndUserText.label            : ' 生産計画日付'
      MRPElementReschedulingDate    : abap.dats;

      @UI                           : { lineItem: [ { position: 460, label: '例外' } ]}
      @EndUserText.label            : '例外'
      Exception1                    : abap.char(2);

      @UI                           : { lineItem: [ { position: 470, label: '回答納期' } ] , selectionField: [ { position: 110 } ]}
      @Consumption.filter           : { mandatory: false }
      @Consumption.filter           : { selectionType: #INTERVAL, multipleSelections: false }
      @EndUserText.label            : '回答納期'
      DeliveryDate                  : abap.dats;

      @UI                           : { lineItem: [ { position: 480, label: '生産可能日付' } ]}
      @EndUserText.label            : '生産可能日付'
      PossibleProductionDate        : abap.dats;

      @UI                           : { lineItem: [ { position: 490, label: '納期回答数' } ]}
      @EndUserText.label            : '納期回答数'
      ConfirmedQuantity             : abap.quan(13);

      @UI                           : { lineItem: [ { position: 500, label: '金額' } ]}
      @EndUserText.label            : '金額'
      NetAmount                     : abap.curr(13,2);

      @UI                           : { lineItem: [ { position: 510, label: '参照' } ]}
      @EndUserText.label            : '参照'
      SupplierConfirmationExtNumber : abap.char(35);

      @UI                           : { lineItem: [ { position: 520, label: '原産国' } ]}
      @EndUserText.label            : '原産国'
      SupplierCertOriginCountry     : abap.char(3);

      @UI                           : { lineItem: [ { position: 530, label: '入庫済数量' } ]}
      @EndUserText.label            : '入庫済数量'
      RoughGoodsReceiptQty          : abap.quan(13);

      @UI                           : { lineItem: [ { position: 540, label: '承認サイン' } ], selectionField: [ { position: 120 } ] }
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_POAPPROVEVH', element: 'Zvalue1' } }]
      @EndUserText.label            : '承認サイン'
      WorkflowTaskResult            : abap.char(1);

      @UI                           : { lineItem: [ { position: 550, label: '承認テキスト' } ]}
      @EndUserText.label            : '承認テキスト'
      TaskResultText                : abap.char(15);

      @UI                           : { lineItem: [ { position: 560, label: 'PO登録者' } ], selectionField: [ { position: 130 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : 'PO登録者'
      CreatedByUser                 : abap.char(12);

      @UI                           : { lineItem: [ { position: 570, label: 'PO連携担当者' } ], selectionField: [ { position: 140 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : 'PO連携担当者'
      CorrespncInternalReference    : abap.char(12);

      @UI                           : { lineItem: [ { position: 580, label: 'プラント' } ], selectionField: [ { position: 150 } ] }
      @Consumption                  : { valueHelpDefinition: [{ entity:{ element: 'Plant', name: 'I_PlantStdVH'}}],
                  filter            : { multipleSelections: false, selectionType: #SINGLE } }
      @EndUserText.label            : 'プラント'
      Plant                         : werks_d;

      @UI                           : { lineItem: [ { position: 590, label: '保管場所' } ], selectionField: [ { position: 160 } ]}
      @Consumption                  : { valueHelpDefinition: [{ entity:{ element: 'StorageLocation', name: 'I_StorageLocationStdVH' } }] }
      @EndUserText.label            : '保管場所'
      StorageLocation               : lgort_d;

      @UI                           : { lineItem: [ { position: 600, label: '保管場所テキスト' } ]}
      @EndUserText.label            : '保管場所テキスト'
      StorageLocationName           : abap.char(16);

      @UI                           : { lineItem: [ { position: 610, label: '納入完了' } ]}
      @EndUserText.label            : '納入完了'
      IsCompletelyDelivered         : abap.char(1);

      @UI                           : { lineItem: [ { position: 620, label: '下請対象' } ]}
      @EndUserText.label            : '下請対象'
      SupplierRespSalesPersonName   : abap.char(30);

      @UI                           : { lineItem: [ { position: 630, label: '税コード' } ]}
      @EndUserText.label            : '税コード'
      TaxCode                       : abap.char(2);

      @UI                           : { lineItem: [ { position: 640, label: '基軸通貨' } ], selectionField: [ { position: 170 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '基軸通貨'
      IncotermsClassification       : abap.char(35);

      @UI                           : { lineItem: [ { position: 650, label: '注文書発行' } ]}
      @EndUserText.label            : '注文書発行'
      PORelease                     : abap.char(10);

      @UI                           : { lineItem: [ { position: 660, label: '価格設定日制御' } ]}
      @EndUserText.label            : '価格設定日制御'
      PricingDateControl            : abap.char(1);

      @UI                           : { lineItem: [ { position: 670, label: 'NCNR、CANCELルール' } ]}
      @EndUserText.label            : 'NCNR、CANCELルール'
      ShippingInstructionName       : abap.char(30);

      @UI                           : { lineItem: [ { position: 680, label: '基板取り数' } ]}
      @EndUserText.label            : '基板取り数'
      productionmemopageformat      : abap.char(4);

      @UI                           : { lineItem: [ { position: 690, label: '減少数量' } ]}
      @EndUserText.label            : '減少数量'
      MRPRelevantQuantity           : abap.quan(13,3);

      @UI                           : { lineItem: [ { position: 700, label: '旧購買発注番号明細' } ], selectionField: [ { position: 180 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '旧購買発注番号明細'
      CorrespncExternalReference    : abap.char(15);

      @UI                           : { lineItem: [ { position: 710, label: '基板取数(製造/検査メモ)' } ]}
      @EndUserText.label            : '基板取数(製造/検査メモ)'
      ProductionOrInspectionMemoTxt : abap.char(18);

      @UI                           : { selectionField: [ { position: 190 } ] }
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_POREMAINVH', element: 'Zvalue1' } }]
      @EndUserText.label            : 'PO残⁼0 制限'
      ponokodis                     : abap.char(1);

      @UI                           : { lineItem: [ { position: 720, label: '価格単位' } ]}
      @UI.hidden                    : true
      NetPriceQuantity              : abap.dec(5);

      @UI                           : { lineItem: [ { position: 730, label: '单价计算' } ]}
      @EndUserText.label            : '单价计算'
      @UI.hidden                    : true
      NetPriceAmount                : abap.curr(13,2);

      @UI                           : { lineItem: [ { position: 740, label: 'PurchaseOrderItemCategory' } ]}
      @EndUserText.label            : 'PurchaseOrderItemCategory'
      @UI.hidden                    : true
      PurchaseOrderItemCategory     : abap.char(1);

      // ADD BEGIN BY XINLEI XU 2025/04/09
      FromMRPTable                  : abap_boolean; // 同期済のMRPデータ使用
      DynamicData                   : abap.string;
      // ADD END BY XINLEI XU 2025/04/09
}
