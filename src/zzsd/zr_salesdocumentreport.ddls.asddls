@ObjectModel.query.implementedBy: 'ABAP:ZCL_SALESDOCUMENTREPORT'
@EndUserText.label: '販売計画一覧'
@UI: {
  headerInfo: {
    typeName: '販売計画一覧',
    typeNamePlural: '販売計画一覧',
    title: { type: #STANDARD, value: 'SalesOrganization' }
        } }
        
define custom entity ZR_SALESDOCUMENTREPORT
{
      @UI                           : { selectionField: [ { position: 10 } ] }
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '販売組織'
  key SalesOrganization             : abap.char(10);
  
      @UI                           : { lineItem: [ { position: 20, label: '得意先' } ], selectionField: [ { position: 20 } ] }
      @EndUserText.label            : '得意先コード' 
  key Customer                      : abap.char(5);
  
      @UI                         : { lineItem: [ { position: 20, label: '年月' } ], selectionField: [ { position: 30 } ] }
      @EndUserText.label            : '年月' 
      @UI.hidden: true
  key YearDate                      : abap.numc(4);
  
      @UI                           : { lineItem: [ { position: 20, label: '計画タイプ' } ], selectionField: [ { position: 40 } ] }
      @EndUserText.label            : '計画タイプ' 
      @UI.hidden: true
  key plantype                      : abap.numc(4);
  
      @UI                           : { lineItem: [ { position: 20, label: '得意先名' } ]}
      @EndUserText.label            : '得意先名' 
      @UI.hidden: true
      CustomerName                  : abap.numc(4);
  
      @UI                           : { lineItem: [ { position: 30, label: '利益センター' } ]}
      @EndUserText.label            : '利益センター' 
      ProfitCenter                  : abap.char(4);
      
      @UI                           : { lineItem: [ { position: 40, label: '工場' } ]}
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '工場'
      PlantName                      :abap.char(15);
      
      @UI                           : { lineItem: [ { position: 50, label: '営業所' } ]}
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '営業所'      
      SalesOffice                      : abap.char(10);
      
      @UI                           : { lineItem: [ { position: 60, label: '営業担当' } ]}
      @EndUserText.label            : '営業担当'       
      SalesGroup                    : abap.char(80);
      
      @UI                           : { lineItem: [ { position: 70, label: '業務管理' } ]}
      @EndUserText.label            : '業務管理'
      CreatedByUser                 : abap.char(80);
      
      @UI                           : { lineItem: [ { position: 80, label: '管理区分' } ]}
      @EndUserText.label            : '管理区分'
      MatlAccountAssignmentGroup    : abap.char(10);
      
      @UI                           : { lineItem: [ { position: 90, label: '品目グループ' } ]}
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '品目グループ'      
      ProductGroup                  : abap.char(3);
      
      @UI                           : { lineItem: [ { position: 100, label: '品番' } ]}
      @EndUserText.label            : '品番'
      Product                       : abap.char(10);
      
      @UI                           : { lineItem: [ { position: 110, label: '品名' } ]}
      @EndUserText.label            : '品名'
      ProductName                   : abap.char(3);
      
    
      MRPControllerName             : abap.char(18);
      
      @UI                           : { lineItem: [ { position: 130, label: '材料費' } ]}
      @Consumption.filter           : { mandatory: false }
      @EndUserText.label            : '材料費'
      Material                      : abap.char(18);

      @UI                           : { lineItem: [ { position: 130, label: '貢献利益(単価)' } ]}
      @EndUserText.label            : '貢献利益(単価)'
      PurchaseOrderItemText         : abap.char(40);
      
      @UI                           : { lineItem: [ { position: 140, label: '加工費' } ]}
      @EndUserText.label            : '加工費'
      ManufacturerMaterial          : abap.char(40);
      
      @UI                           : { lineItem: [ { position: 150, label: '売上総利益(単価)' } ]}
      @EndUserText.label            : '売上総利益(単価)'
      ManufacturerPartNmbr          : abap.char(40);
      
      @UI                           : { lineItem: [ { position: 160, label: '予算' } ]}
      @EndUserText.label            : '予算'
      Manufacturer                  : abap.char(10);
      
      @UI                           : { lineItem: [ { position: 170, label: '年月' } ]}
      @EndUserText.label            : '年月'
      PlannedDeliveryDurationInDays : abap.dec(3);
      
      @UI                           : { lineItem: [ { position: 180, label: '見込み' } ]}
      @EndUserText.label            : '見込み'
      GoodsReceiptDurationInDays    : abap.dec(3);
      
      @UI                           : { lineItem: [ { position: 190, label: '年月' } ]}
      @EndUserText.label            : '年月'
      LotSizeRoundingQuantity       : abap.quan(13);
      
      @UI                           : { lineItem: [ { position: 200, label: '売上' } ]}
      @EndUserText.label            : '売上'
      OrderQuantity                 : abap.quan(13);
      
      @UI                           : { lineItem: [ { position: 210, label: '年月' } ]}
      @EndUserText.label            : '年月'
      @Semantics.unitOfMeasure      : true
      PurchaseOrderQuantityUnit     : abap.unit(3);
      
      @UI                           : { lineItem: [ { position: 220, label: '貢献利益' } ]}
      @EndUserText.label            : '貢献利益'
      ScheduleLineDeliveryDate      : abap.dats;
      
      @UI                           : { lineItem: [ { position: 230, label: '年月' } ]}
      @EndUserText.label            : '年月'
      PurchaseOrderDate             : abap.dats;
      
      @UI                           : { lineItem: [ { position: 230, label: '売上総利益' } ]}
      @EndUserText.label            : '売上総利益'
      NetPrice                      : abap.char(13);
      
      @UI                           : { lineItem: [ { position: 240, label: '年月' } ]}
      @EndUserText.label            : '年月'
      DocumentCurrency              : waers;
      
}
