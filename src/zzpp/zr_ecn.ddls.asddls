@ObjectModel.query.implementedBy: 'ABAP:ZCL_ECN'
@EndUserText.label: 'ECNのレポート'
@UI: {
  headerInfo: {
    typeName: 'ECNのレポート',
    typeNamePlural: 'ECNのレポート'
    } }
define root custom entity ZR_ECN
{
     @UI.hidden                    : true
 key seq :abap.int4;   

      @UI                           : { lineItem: [ { position: 10, label: 'プラント' } ], selectionField: [ { position: 10 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Plant', name: 'I_PlantStdVH' } } ]
      @EndUserText.label            : 'プラント'
  key Plant                         : werks_d;
  
  
      @UI                           : { selectionField: [ { position: 30 } ] }
      @Consumption.filter           : { mandatory: false }
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Material', name: 'ZC_BOMMaterialVH' } } ]
      @EndUserText.label            : '品目'
  key Material                      : abap.char( 40 );
  
      @UI                           : { lineItem: [ { position: 20, label: '変更前後' } ] }
      @EndUserText.label            : '変更前後'
      changediff                   : abap.char( 10 );
      
      
      @UI                           : { lineItem: [ { position: 1, label: 'No' } ]}
      @EndUserText.label            : 'No'
      serialnumber                  : abap.int4;  
       
      @UI                           : { lineItem: [ { position: 30, label: '変更番号' } ] , selectionField: [ { position: 70 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '変更番号'
      ECNNo                         : aennr;
      
      
      @UI                           : { lineItem: [ { position: 40, label: 'ECN登録日付' } ], selectionField: [ { position: 80 } ]}
      @Consumption.filter           : { mandatory: false }
      @Consumption.filter:          { selectionType: #INTERVAL, multipleSelections: false }
      @EndUserText.label            : 'ECN登録日付'
      ECNCreateAt                   : abap.dats;
      
      
      @UI                           : { lineItem: [ { position: 50, label: 'ECN有効開始日付' } ], selectionField: [ { position: 90 } ]}
      @Consumption.filter           : { mandatory: false }
      @Consumption.filter           : { selectionType: #INTERVAL, multipleSelections: false }
      @EndUserText.label            : 'ECN有効開始日付'
      ECNValidFrom                  : abap.dats;
           
      @UI                           : { lineItem: [ { position: 60, label: '改訂レベル' } ] }
      @EndUserText.label            : '改訂レベル'
      Revison                       : abap.char( 2 );      
      
      @UI                           : { lineItem: [ { position: 70, label: '対象品目' } ] }
      @EndUserText.label            : '対象品目'
      HeadMat                       : matnr;      
      
      @UI                           : { lineItem: [ { position: 80, label: '明細番号' } ] }
      @EndUserText.label            : '明細番号'
      ItemNo                        : abap.char( 4 );
      
      @UI                           : { lineItem: [ { position: 90, label: '構成品目' } ] , selectionField: [ { position: 40 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '構成品目'
      Component                     : abap.char( 40 );
      
      @UI                           : { lineItem: [ { position: 100, label: '構成数量' } ] }
      @EndUserText.label            : '構成数量'
      Qty                           : abap.quan(13);
      
      @UI                           : { lineItem: [ { position: 110, label: '単位' } ] }
      @EndUserText.label            : '単位'
       @Semantics.unitOfMeasure     : true
      Unit                          : abap.unit(3);
      
      @UI                           : { lineItem: [ { position: 120, label: '変更番号テキスト' } ] }
      @EndUserText.label            : '変更番号テキスト'
      ECNText                       : cc_aetxt;
      
      @UI                           : { lineItem: [ { position: 130, label: '変更理由' } ] }
      @EndUserText.label            : '変更理由'
      ECNReason                     : cc_aegru;      
      
      @UI                          : { lineItem: [ { position: 140, label: 'MRP管理者' } ],selectionField: [ { position: 20 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : 'MRP管理者'
      MRPResponsible                : dispo;
      
      @UI                           : { lineItem: [ { position: 150, label: 'BOM用途' } ],selectionField: [ { position: 50 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false }
      @EndUserText.label            : 'BOM用途'
      BillOfMaterialVariantUsage    : abap.char( 1 );
  
      @UI                           : { lineItem: [ { position: 160, label: '代替BOM' } ], selectionField: [ { position: 60 } ] }
      @Consumption.filter           : { selectionType: #SINGLE, multipleSelections: false }
      @EndUserText.label            : '代替BOM'
      BillOfMaterialVariant         : abap.char( 2 );
            
      @UI                           : { lineItem: [ { position: 170, label: '代替明細グループ' } ] }
      @EndUserText.label            : '代替明細グループ'
      AltGroup                      : abap.char( 2 );
      
      @UI                           : { lineItem: [ { position: 180, label: '打切りグループ' } ] }
      @EndUserText.label            : '打切りグループ'
      DiscontinuationGroup          : abap.char( 2 );
      
      @UI                           : { lineItem: [ { position: 190, label: 'フォローアップグループ' } ] }
      @EndUserText.label            : 'フォローアップグループ'
      FollowUpGroup                 : abap.char( 2 );
      
      @UI                           : { lineItem: [ { position: 200, label: '正味重量' } ] }
      @EndUserText.label            : '正味重量'
      Netweight                     : ntgew;
      
      @UI                           : { lineItem: [ { position: 210, label: '重要単位' } ] }
      @EndUserText.label            : '重要単位'
      WeightUnit                    : gewei;
      
      @UI                           : { lineItem: [ { position: 220, label: '設定ポイント' } ] }
      @EndUserText.label            : '設定ポイント'
      BOMSubItemInstallationPoint   : abap.char( 20 );
      

      
      @UI                           : { selectionField: [ { position: 100 } ] }
      @Consumption.filter.selectionType: #SINGLE
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_BOOLEAN_VH', element: 'value_low' } }]
      @EndUserText.label            : '副明細表示'
      subitem                       : abap.char( 1 );        
}
