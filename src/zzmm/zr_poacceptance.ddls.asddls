@EndUserText.label: 'PO Acceptance Report'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_POACCEPTANCE_REPORT'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}

define root custom entity ZR_POACCEPTANCE
{


      //購買伝票
      @UI                            : { lineItem: [ { position: 90 } ],
                                         selectionField: [ { position: 5 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'PurchaseOrder', name: 'ZC_PurchaseOrderAPI'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>PurchaseOrder}'
  key PurchaseOrder                  : ebeln;

      //po item
      //@UI                            : { lineItem: [ { position: 100 } ] }
      //@EndUserText.label             : '{@i18n>PurchaseOrderItem}'
      @Consumption.filter.hidden     : true
      @UI.hidden                     : true
  key PurchaseOrderItem              : ebelp;

      @UI                            : { lineItem: [ { position: 100 } ],
                                         selectionField: [ { position: 6 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderItemUniqueID}'
  key PurchaseOrderItemUniqueID      : abap.char(15);
      //入出庫伝票
      @UI                            : { lineItem: [ { position: 310 } ] }
      @EndUserText.label             : '{@i18n>MaterialDocument}'
      @Consumption.filter.hidden     : true
  key MaterialDocument               : mblnr;

      //入出庫伝票明細
      @UI                            : { lineItem: [ { position: 320 } ] }
      @EndUserText.label             : '{@i18n>MaterialDocumentItem}'
      @Consumption.filter.hidden     : true
  key MaterialDocumentItem           : mblpo;

      //請求書伝票番号
      @UI                            : { lineItem: [ { position: 450 } ] }
      @EndUserText.label             : '{@i18n>SupplierInvoice}'
      @Consumption.filter.hidden     : true
  key SupplierInvoice                : re_belnr;

      //請求書伝票明細
      @UI                            : { lineItem: [ { position: 460 } ] }
      @EndUserText.label             : '{@i18n>SupplierInvoiceItem}'
      @Consumption.filter.hidden     : true
  key SupplierInvoiceItem            : rblgp;

      //Serial number in same PO/Item
      @Consumption.filter.hidden     : true
  key buzei                          : abap.numc(4);

      //旧購買発注番号明細
      @UI                            : { lineItem: [ { position: 101 } ],
                                         selectionField: [ { position: 7 } ] }
      @EndUserText.label             : '{@i18n>OldID}'
      OldID                          : abap.char(17);

      //会社コード
      @UI                            : { lineItem: [ { position: 10 } ] }
      @EndUserText.label             : '{@i18n>CompanyCode}'
      @Consumption.filter.hidden     : true
      CompanyCode                    : bukrs;


      //プラント
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Plant', name: 'I_PlantStdVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE, mandatory:true } }
      @UI                            : { lineItem: [ { position: 20 } ],
                                         selectionField: [ { position: 1 } ] }
      @EndUserText.label             : '{@i18n>Plant}'
      Plant                          : werks_d;

      //購買組織
      @UI                            : { lineItem: [ { position: 30 } ],
                                         selectionField: [ { position: 2 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'PurchasingOrganization', name: 'I_PurchasingOrganization'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>PurchasingOrganization}'
      PurchasingOrganization         : ekorg;

      //購買伝票タイプ
      @UI                            : { lineItem: [ { position: 40 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderType}'
      @Consumption.filter.hidden     : true
      PurchaseOrderType              : abap.char(4);

      //購買 Group
      @UI                            : { lineItem: [ { position: 50 } ],
                                         selectionField: [ { position: 3 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'PurchasingGroup', name: 'I_PurchasingGroup'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>PurchasingGroup}'
      PurchasingGroup                : ekgrp;

      //購買 Group名称
      @UI                            : { lineItem: [ { position: 60 } ] }
      @EndUserText.label             : '{@i18n>PurchasingGroupName}'
      @Consumption.filter.hidden     : true
      PurchasingGroupName            : eknam;

      //仕入先
      @UI                            : { lineItem: [ { position: 70 } ],
                                         selectionField: [ { position: 4 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Supplier', name: 'ZC_SupplierVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>Supplier}'
      Supplier                       : lifnr;

      //仕入先名称
      @UI                            : { lineItem: [ { position: 80 } ] }
      @EndUserText.label             : '{@i18n>SupplierName}'
      @Consumption.filter.hidden     : true
      SupplierName                   : abap.char(40);

      //品目 Group
      @UI                            : { lineItem: [ { position: 110 } ],
                                         selectionField: [ { position: 8 } ] }
      @Consumption.valueHelpDefinition:[{ entity: { name: 'ZC_PRODUCTGROUPVH', element: 'ProductGroup' } }]
      @EndUserText.label             : '{@i18n>MaterialGroup}'
      MaterialGroup                  : matkl;

      //品目
      @UI                            : { lineItem: [ { position: 120 } ],
                                         selectionField: [ { position: 9 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Product', name: 'ZI_PRODUCT_VH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>Material}'
      Material                       : matnr;

      //仕入先品目コード
      @UI                            : { lineItem: [ { position: 130 } ],
                                         selectionField: [ { position: 10 } ]}
      @EndUserText.label             : '{@i18n>SupplierMaterialNumber}'
      SupplierMaterialNumber         : abap.char(35);

      //顧客品番
      @UI                            : { lineItem: [ { position: 140 } ] }
      @EndUserText.label             : '{@i18n>CustomerMaterial}'
      @Consumption.filter.hidden     : true
      CustomerMaterial               : abap.char(40);

      //メーカー品番
      @UI                            : { lineItem: [ { position: 150 } ] }
      @EndUserText.label             : '{@i18n>ProductManufacturerNumber}'
      @Consumption.filter.hidden     : true
      ProductManufacturerNumber      : mfrpn;
      
      //メーカーCD
      @UI                            : { lineItem: [ { position: 151 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Supplier', name: 'ZC_SupplierVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>ManufacturerNumber}'
      ManufacturerNumber             : mfrnr;
      
      //メーカー名
      @UI                            : { lineItem: [ { position: 152 } ] }
      @EndUserText.label             : '{@i18n>ManufacturerNumberName}'
      ManufacturerNumberName         : abap.char(40);
      
      //テキスト (短)
      @UI                            : { lineItem: [ { position: 160 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderItemText}'
      @Consumption.filter.hidden     : true
      PurchaseOrderItemText          : txz01;

      //検収(発注)単価
      @UI                            : { lineItem: [ { position: 170 } ] }
      @EndUserText.label             : '{@i18n>NetPrice1}'
      @Consumption.filter.hidden     : true
      NetPrice1                      : abap.char(25);

      //取引通貨
      @UI                            : { lineItem: [ { position: 180 } ] }
      @Semantics.currencyCode        : true
      @EndUserText.label             : '{@i18n>DocumentCurrency}'
      @Consumption.filter.hidden     : true
      DocumentCurrency               : waers;

      //PO発行日
      @UI                            : { lineItem: [ { position: 190 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderDate}'
      @Consumption.filter.hidden     : true
      PurchaseOrderDate              : aedat;

      //納入期日
      @UI                            : { lineItem: [ { position: 200 } ] }
      @EndUserText.label             : '{@i18n>ScheduleLineDeliveryDate}'
      @Consumption.filter.hidden     : true
      ScheduleLineDeliveryDate       : eindt;


      //発注数量
      @UI                            : { lineItem: [ { position: 210 } ] }
      @EndUserText.label             : '{@i18n>OrderQuantity}'
      @Consumption.filter.hidden     : true
      OrderQuantity                  : menge_d;

      //発注単位
      @UI                            : { lineItem: [ { position: 220 } ] }
      @Semantics.unitOfMeasure       : true
      @EndUserText.label             : '{@i18n>PurchaseOrderQuantityUnit}'
      @Consumption.filter.hidden     : true
      PurchaseOrderQuantityUnit      : bstme;

      //正味発注価格
      @UI                            : { lineItem: [ { position: 230 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>NetAmount}'
      @Consumption.filter.hidden     : true
      NetAmount                      : abap.curr(23,2);

      //価格単位
      @UI                            : { lineItem: [ { position: 240 } ] }
      @EndUserText.label             : '{@i18n>NetPriceQuantity}'
      @Consumption.filter.hidden     : true
      NetPriceQuantity               : peinh;

      //基軸通貨
      @UI                            : { lineItem: [ { position: 241 } ] }
      @EndUserText.label             : '{@i18n>IncotermsClassification}'
      IncotermsClassification        : abap.char(3);

      //価格コントロール区分
      @UI                            : { lineItem: [ { position: 242 } ] }
      @EndUserText.label             : '{@i18n>SupplierMaterialGroup}'
      SupplierMaterialGroup          : abap.char(18);

      //勘定設定 Categ.
      @UI                            : { lineItem: [ { position: 250 } ] }
      @EndUserText.label             : '{@i18n>AccountAssignmentCategory}'
      @Consumption.filter.hidden     : true
      AccountAssignmentCategory      : knttp;

      //原価センタ
      @UI                            : { lineItem: [ { position: 260 } ] }
      @EndUserText.label             : '{@i18n>CostCenter}'
      @Consumption.filter.hidden     : true
      CostCenter                     : kostl;

      //G/L 勘定
      @UI                            : { lineItem: [ { position: 270 } ] }
      @EndUserText.label             : '{@i18n>GLAccount}'
      @Consumption.filter.hidden     : true
      GLAccount                      : saknr;

      //利益センタ
      @UI                            : { lineItem: [ { position: 280 } ] }
      @EndUserText.label             : '{@i18n>ProfitCenter}'
      @Consumption.filter.hidden     : true
      ProfitCenter                   : prctr;

      //購買依頼追跡番号
      @UI                            : { lineItem: [ { position: 290 } ] }
      @EndUserText.label             : '{@i18n>RequirementTracking}'
      @Consumption.filter.hidden     : true
      RequirementTracking            : bednr;

      //購買依頼者
      @UI                            : { lineItem: [ { position: 300 } ] }
      @EndUserText.label             : '{@i18n>RequisitionerName}'
      @Consumption.filter.hidden     : true
      RequisitionerName              : afnam;

      //受入数量
      @UI                            : { lineItem: [ { position: 330 } ] }
      @EndUserText.label             : '{@i18n>Quantity1}'
      @Consumption.filter.hidden     : true
      Quantity1                      : menge_d;

      //受入金額（税抜）
      @UI                            : { lineItem: [ { position: 340 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>TaxExcludedPrice}'
      @Consumption.filter.hidden     : true
      TaxExcludedPrice               : abap.curr(23,2);

      @UI                            : { lineItem: [ { position: 350 } ] }
      @EndUserText.label             : '{@i18n>TaxCode}'
      @Consumption.filter.hidden     : true
      TaxCode                        : mwskz;

      @UI                            : { lineItem: [ { position: 360 } ] }
      @EndUserText.label             : '{@i18n>TaxRate}'
      @Consumption.filter.hidden     : true
      TaxRate                        : abap.char(9);

      //入出庫伝票の登録日付
      @UI                            : { lineItem: [ { position: 370 } ] }
      @EndUserText.label             : '{@i18n>AccountingDocumentCreationDate}'
      @Consumption.filter.hidden     : true
      AccountingDocumentCreationDate : bldat;

      //入出庫伝票の伝票日付
      @UI                            : { lineItem: [ { position: 380 } ] }
      @EndUserText.label             : '{@i18n>DocumentDate}'
      DocumentDate                   : bldat;

      //入出庫伝票の転記日付
      @UI                            : { lineItem: [ { position: 390 } ] }
      @EndUserText.label             : '{@i18n>PostingDate}'
      PostingDate                    : budat;

      //入出庫伝票の登録時刻
      @UI                            : { lineItem: [ { position: 400 } ] }
      @EndUserText.label             : '{@i18n>PurgHistDocumentCreationTime}'
      @Consumption.filter.hidden     : true
      PurgHistDocumentCreationTime   : uzeit;

      //伝票ヘッダ Text
      @UI                            : { lineItem: [ { position: 410 } ] }
      @EndUserText.label             : '{@i18n>MaterialDocumentHeaderText}'
      @Consumption.filter.hidden     : true
      MaterialDocumentHeaderText     : bktxt;

      //会計年度
      @UI                            : { lineItem: [ { position: 420 } ] }
      @EndUserText.label             : '{@i18n>FiscalYear}'
      @Consumption.filter.hidden     : true
      FiscalYear                     : gjahr;

      //支払基準日
      @UI                            : { lineItem: [ { position: 430 } ] }
      @EndUserText.label             : '{@i18n>DueCalculationBaseDate}'
      @Consumption.filter.hidden     : true
      DueCalculationBaseDate         : dzfbdt;

      //請求元
      @UI                            : { lineItem: [ { position: 440 } ] }
      @EndUserText.label             : '{@i18n>InvoicingParty}'
      @Consumption.filter.hidden     : true
      InvoicingParty                 : lifnr;

      //检收数量
      @UI                            : { lineItem: [ { position: 470 } ] }
      @EndUserText.label             : '{@i18n>Quantity2}'
      @Consumption.filter.hidden     : true
      Quantity2                      : menge_d;

      //請求書総額
      @UI                            : { lineItem: [ { position: 480 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>InvoiceAmtInPurOrdTransacCrcy}'
      @Consumption.filter.hidden     : true
      InvoiceAmtInPurOrdTransacCrcy  : abap.curr(23,2);

      //消費税額
      @UI                            : { lineItem: [ { position: 490 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>VAT1}'
      @Consumption.filter.hidden     : true
      VAT1                           : abap.curr(23,2);

      //請求書金額（税込）
      @UI                            : { lineItem: [ { position: 500 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>InvoiceAmount}'
      @Consumption.filter.hidden     : true
      InvoiceAmount                  : abap.curr(23,2);

      //請求書伝票の転記日付
      @UI                            : { lineItem: [ { position: 510 } ] }
      @EndUserText.label             : '{@i18n>InvoiceDocumentPostingDate}'
      InvoiceDocumentPostingDate     : budat;

      //請求書伝票の伝票日付
      @UI                            : { lineItem: [ { position: 520 } ] }
      @EndUserText.label             : '{@i18n>InvoiceDocumentDate}'
      InvoiceDocumentDate            : bldat;

      //換算レート
      @UI                            : { lineItem: [ { position: 530 } ] }
      @EndUserText.label             : '{@i18n>ExchangeRate}'
      @Consumption.filter.hidden     : true
      ExchangeRate                   : abap.dec(9,5);

      //取引通貨単価
      @UI                            : { lineItem: [ { position: 540 } ] }
      @EndUserText.label             : '{@i18n>NetPrice2}'
      @Consumption.filter.hidden     : true
      NetPrice2                      : abap.char(25);

      //円換算後単価(PO)
      @UI                            : { lineItem: [ { position: 550 } ] }
      @EndUserText.label             : '{@i18n>NetPrice3}'
      @Consumption.filter.hidden     : true
      NetPrice3                      : abap.char(25);

      //円換算後税込金額（檢收）
      @UI                            : { lineItem: [ { position: 560 } ] }
      @EndUserText.label             : '{@i18n>NetAmount3}'
      @Consumption.filter.hidden     : true
      NetAmount3                     : abap.char(25);

      //円換算後税額（檢收）
      @UI                            : { lineItem: [ { position: 570 } ] }
      @EndUserText.label             : '{@i18n>VAT2}'
      @Consumption.filter.hidden     : true
      VAT2                           : abap.char(25);

      //参照伝票
      @UI                            : { lineItem: [ { position: 580 } ] }
      @EndUserText.label             : '{@i18n>AccountingDocument}'
      @Consumption.filter.hidden     : true
      AccountingDocument             : belnr_d;

      //納期回答
      @UI                            : { lineItem: [ { position: 590 } ] }
      @EndUserText.label             : '{@i18n>DeliveryDate}'
      @Consumption.filter.hidden     : true
      DeliveryDate                   : eindt;

      //回答数量
      @UI                            : { lineItem: [ { position: 610 } ] }
      @EndUserText.label             : '{@i18n>DlvQty}'
      @Consumption.filter.hidden     : true
      DlvQty                         : menge_d;

      //価格設定日付
      @EndUserText.label             : '{@i18n>PurgDocPriceDate}'
      @Consumption.filter.hidden     : true
      PurgDocPriceDate               : datum;

      //納入完了PO排除
      @EndUserText.label             : '{@i18n>IsCompletelyDelivered}'
      @Consumption.filter.hidden     : true
      IsCompletelyDelivered          : abap_boolean;

}
