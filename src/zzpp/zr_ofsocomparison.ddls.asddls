@ObjectModel.query.implementedBy: 'ABAP:ZCL_OFSOCOMPARISON'
@EndUserText.label: 'OFとSO比較照会'
@UI: {
  headerInfo: {
    typeName: 'OFとSO比較照会',
    typeNamePlural: 'OFとSO比較照会'
    } }
define root custom entity ZR_OFSOCOMPARISON
{
  key RowNo              : abap.numc(4);
      @EndUserText.label : '所要期間'
      Duration           : abap.char( 6 );
      @EndUserText.label : '最新OFデータのみ'
      LatestOF           : abap.char( 20 );
      @EndUserText.label : '表示内容'
      Contents           : abap.char( 20 );
      @UI                : { lineItem: [ { position: 10, label: 'プラント' } ], selectionField: [ { position: 10 } ] }
      @EndUserText.label : 'プラント'
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Plant', name: 'I_PlantStdVH' } } ]
      Plant              : werks_d;
      @UI                : { lineItem: [ { position: 20, label: '受注先' } ], selectionField: [ { position: 20 } ] }
      @EndUserText.label : '受注先'
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_Customer_VH', element: 'Customer' } } ]
      Customer           : abap.char( 10 );
      @UI                : { lineItem: [ { position: 30, label: '品目' } ], selectionField: [ { position: 30 } ] }
      @EndUserText.label : '品目'
      @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_PRODUCTPLANTBASIC' } } ]
      Material           : matnr;
      @UI                : { lineItem: [ { position: 40, label: '品目テキスト' } ]}
      @EndUserText.label : '品目テキスト'
      MaterialName       : maktx;
      @UI                : { lineItem: [ { position: 50, label: '得意先品目' } ], selectionField: [ { position: 40 } ] }
      @EndUserText.label : '得意先品目'
      //      @Consumption.valueHelpDefinition: [ { entity: { element: 'Product', name: 'I_CustomerMaterial_2' } } ]
      MATERIALBYCUSTOMER : matnr;
      @UI                : { lineItem: [ { position: 60, label: '登録日付' } ]}
      @EndUserText.label : '登録日付'
      CREATED_AT         : abap.char( 8 );
      created_ats        : abp_creation_tstmpl;

      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 70, label: '所要数1' } ]}
      @EndUserText.label : '所要数1'
      Period1            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 80, label: '所要数2' } ]}
      @EndUserText.label : '所要数2'
      Period2            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 90, label: '所要数3' } ]}
      @EndUserText.label : '所要数3'
      Period3            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 100, label: '所要数4' } ]}
      @EndUserText.label : '所要数4'
      Period4            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 110, label: '所要数5' } ]}
      @EndUserText.label : '所要数5'
      Period5            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 120, label: '所要数6' } ]}
      @EndUserText.label : '所要数6'
      Period6            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 130, label: '所要数7' } ]}
      @EndUserText.label : '所要数7'
      Period7            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 140, label: '所要数8' } ]}
      @EndUserText.label : '所要数8'
      Period8            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 150, label: '所要数9' } ]}
      @EndUserText.label : '所要数9'
      Period9            : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 160, label: '所要数10' } ]}
      @EndUserText.label : '所要数10'
      Period10           : menge_d;

      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 170, label: '所要数11' } ]}
      @EndUserText.label : '所要数11'
      Period11           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 180, label: '所要数12' } ]}
      @EndUserText.label : '所要数12'
      Period12           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 190, label: '所要数13' } ]}
      @EndUserText.label : '所要数13'
      Period13           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 200, label: '所要数14' } ]}
      @EndUserText.label : '所要数14'
      Period14           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 210, label: '所要数15' } ]}
      @EndUserText.label : '所要数15'
      Period15           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 220, label: '所要数16' } ]}
      @EndUserText.label : '所要数16'
      Period16           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 230, label: '所要数17' } ]}
      @EndUserText.label : '所要数17'
      Period17           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 240, label: '所要数18' } ]}
      @EndUserText.label : '所要数18'
      Period18           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 250, label: '所要数19' } ]}
      @EndUserText.label : '所要数19'
      Period19           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 260, label: '所要数20' } ]}
      @EndUserText.label : '所要数20'
      Period20           : menge_d;

      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 270, label: '所要数21' } ]}
      @EndUserText.label : '所要数21'
      Period21           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 280, label: '所要数22' } ]}
      @EndUserText.label : '所要数22'
      Period22           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 290, label: '所要数23' } ]}
      @EndUserText.label : '所要数23'
      Period23           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 300, label: '所要数24' } ]}
      @EndUserText.label : '所要数24'
      Period24           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 310, label: '所要数25' } ]}
      @EndUserText.label : '所要数25'
      Period25           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 320, label: '所要数26' } ]}
      @EndUserText.label : '所要数26'
      Period26           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 330, label: '所要数27' } ]}
      @EndUserText.label : '所要数27'
      Period27           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 340, label: '所要数28' } ]}
      @EndUserText.label : '所要数28'
      Period28           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 350, label: '所要数29' } ]}
      @EndUserText.label : '所要数29'
      Period29           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 360, label: '所要数30' } ]}
      @EndUserText.label : '所要数30'
      Period30           : menge_d;

      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 370, label: '所要数31' } ]}
      @EndUserText.label : '所要数31'
      Period31           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 380, label: '所要数32' } ]}
      @EndUserText.label : '所要数32'
      Period32           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 390, label: '所要数33' } ]}
      @EndUserText.label : '所要数33'
      Period33           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 400, label: '所要数34' } ]}
      @EndUserText.label : '所要数34'
      Period34           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 410, label: '所要数35' } ]}
      @EndUserText.label : '所要数35'
      Period35           : menge_d;
      @Semantics.quantity.unitOfMeasure : 'unit_of_measure'
      @UI                : { lineItem: [ { position: 420, label: '所要数36' } ]}
      @EndUserText.label : '所要数36'
      Period36           : menge_d;

      unit_of_measure    : meins;
      PeriodT1           : abap.char( 6 );
      PeriodT2           : abap.char( 6 );
      PeriodT3           : abap.char( 6 );
      PeriodT4           : abap.char( 6 );
      PeriodT5           : abap.char( 6 );
      PeriodT6           : abap.char( 6 );
      PeriodT7           : abap.char( 6 );
      PeriodT8           : abap.char( 6 );
      PeriodT9           : abap.char( 6 );
      PeriodT10          : abap.char( 6 );
      PeriodT11          : abap.char( 6 );
      PeriodT12          : abap.char( 6 );
      PeriodT13          : abap.char( 6 );
      PeriodT14          : abap.char( 6 );
      PeriodT15          : abap.char( 6 );
      PeriodT16          : abap.char( 6 );
      PeriodT17          : abap.char( 6 );
      PeriodT18          : abap.char( 6 );
      PeriodT19          : abap.char( 6 );
      PeriodT20          : abap.char( 6 );
      PeriodT21          : abap.char( 6 );
      PeriodT22          : abap.char( 6 );
      PeriodT23          : abap.char( 6 );
      PeriodT24          : abap.char( 6 );
      PeriodT25          : abap.char( 6 );
      PeriodT26          : abap.char( 6 );
      PeriodT27          : abap.char( 6 );
      PeriodT28          : abap.char( 6 );
      PeriodT29          : abap.char( 6 );
      PeriodT30          : abap.char( 6 );
      PeriodT31          : abap.char( 6 );
      PeriodT32          : abap.char( 6 );
      PeriodT33          : abap.char( 6 );
      PeriodT34          : abap.char( 6 );
      PeriodT35          : abap.char( 6 );
      PeriodT36          : abap.char( 6 );

      UserEmail          : abap.char(241); // ADD BY XINLEI XU 2025/03/17
}
