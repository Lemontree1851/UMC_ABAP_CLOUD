@EndUserText.label: '生産計画立案プラットフォーム'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_PRODUCTIONPLAN'
    }
}

define root custom entity ZR_PRODUCTIONPLAN
{
      @UI                  : { selectionField: [ { position: 1 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
  key Plant                : werks_d; //プラント

      @UI                  : { selectionField: [ { position: 2 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_MRPControllerVH', element: 'MRPController' } }]
  key MRPResponsible       : dispo; //MRP Controller

      @UI                  : { selectionField: [ { position: 4 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
  key Product              : matnr; //品目

  key Idnrk                : matnr; //bom component

  key Stufe                : stufe; //层级

  key Verid                : verid; //production version
  key Mdv01                : arbpl; //Production Line
  key PlanType             : abap.char(1); //Plan type
      Project              : abap.char(20); //Project
      @UI                  : { selectionField: [ { position: 3 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlndOrderProdnSupervisorVH', element: 'ProductionSupervisor' } }]
      ProductionSupervisor : abap.char(3); //Production Supervisor
      @UI                  : { selectionField: [ { position: 5 } ] }
      zday                 : abap.numc(2);

      Expand               : abap.char(1); //BOM展開checkbox
      PlanCheck            : abap.char(1); //計画手配検査checkbox
      Theory               : abap.char(1); //checkbox
      ECN                  : abap.char(1); //checkbox
      WO                   : abap.char(1); //checkbox
      exOut                  : abap.char(1); //checkbox

      Capacity             : abap.char(30); //capacity
      Remark               : abap.char(20); //Remark
      @Semantics.quantity.unitOfMeasure: 'Unit'
      StockQty             : labst;
      Rounding             : abap.char(30); //Rouding
      Delta                : abap.char(30);
      HistorySO            : abap.char(30); //This Month S/O
      FutureSO             : abap.char(30); //Furtrue S/O
      @Semantics.quantity.unitOfMeasure: 'Unit'
      BalanceQTY           : abap.quan(15,3); //Balance QTY
      Unit                 : meins;
      //@Semantics.quantity.unitOfMeasure: 'Unit'
      Summary              : abap.char(20); //Summary
      D001                 : abap.char(20);
      D002                 : abap.char(20);
      D003                 : abap.char(20);
      D004                 : abap.char(20);
      D005                 : abap.char(20);
      D006                 : abap.char(20);
      D007                 : abap.char(20);
      D008                 : abap.char(20);
      D009                 : abap.char(20);
      D010                 : abap.char(20);
      D011                 : abap.char(20);
      D012                 : abap.char(20);
      D013                 : abap.char(20);
      D014                 : abap.char(20);
      D015                 : abap.char(20);
      D016                 : abap.char(20);
      D017                 : abap.char(20);
      D018                 : abap.char(20);
      D019                 : abap.char(20);
      D020                 : abap.char(20);
      D021                 : abap.char(20);
      D022                 : abap.char(20);
      D023                 : abap.char(20);
      D024                 : abap.char(20);
      D025                 : abap.char(20);
      D026                 : abap.char(20);
      D027                 : abap.char(20);
      D028                 : abap.char(20);
      D029                 : abap.char(20);
      D030                 : abap.char(20);
      D031                 : abap.char(20);
      D032                 : abap.char(20);
      D033                 : abap.char(20);
      D034                 : abap.char(20);
      D035                 : abap.char(20);
      D036                 : abap.char(20);
      D037                 : abap.char(20);
      D038                 : abap.char(20);
      D039                 : abap.char(20);
      D040                 : abap.char(20);
      D041                 : abap.char(20);
      D042                 : abap.char(20);
      D043                 : abap.char(20);
      D044                 : abap.char(20);
      D045                 : abap.char(20);
      D046                 : abap.char(20);
      D047                 : abap.char(20);
      D048                 : abap.char(20);
      D049                 : abap.char(20);
      D050                 : abap.char(20);
      D051                 : abap.char(20);
      D052                 : abap.char(20);
      D053                 : abap.char(20);
      D054                 : abap.char(20);
      D055                 : abap.char(20);
      D056                 : abap.char(20);
      D057                 : abap.char(20);
      D058                 : abap.char(20);
      D059                 : abap.char(20);
      D060                 : abap.char(20);
      D061                 : abap.char(20);
      D062                 : abap.char(20);
      D063                 : abap.char(20);
      D064                 : abap.char(20);
      D065                 : abap.char(20);
      D066                 : abap.char(20);
      D067                 : abap.char(20);
      D068                 : abap.char(20);
      D069                 : abap.char(20);
      D070                 : abap.char(20);
      D071                 : abap.char(20);
      D072                 : abap.char(20);
      D073                 : abap.char(20);
      D074                 : abap.char(20);
      D075                 : abap.char(20);
      D076                 : abap.char(20);
      D077                 : abap.char(20);
      D078                 : abap.char(20);
      D079                 : abap.char(20);
      D080                 : abap.char(20);
      D081                 : abap.char(20);
      D082                 : abap.char(20);
      D083                 : abap.char(20);
      D084                 : abap.char(20);
      D085                 : abap.char(20);
      D086                 : abap.char(20);
      D087                 : abap.char(20);
      D088                 : abap.char(20);
      D089                 : abap.char(20);
      D090                 : abap.char(20);
      D091                 : abap.char(20);
      D092                 : abap.char(20);
      D093                 : abap.char(20);
      D094                 : abap.char(20);
      D095                 : abap.char(20);
      D096                 : abap.char(20);
      D097                 : abap.char(20);
      D098                 : abap.char(20);
      D099                 : abap.char(20);
      Status               : abap.char(1);
      Message              : zze_zzkey;
}
