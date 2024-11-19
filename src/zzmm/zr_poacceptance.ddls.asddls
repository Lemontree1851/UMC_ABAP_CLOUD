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
                                         selectionField: [ { position: 1 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'PurchasingDocument', name: 'I_PurchasingDocumentStdVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>PurchaseOrder}'
  key PurchaseOrder                  : ebeln;

      //po item
      @UI                            : { lineItem: [ { position: 100 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderItem}'
  key PurchaseOrderItem              : ebelp;

      //入出庫伝票
      @UI                            : { lineItem: [ { position: 310 } ] }
      @EndUserText.label             : '{@i18n>MaterialDocument}'
  key MaterialDocument               : mblnr;

      //入出庫伝票明細
      @UI                            : { lineItem: [ { position: 320 } ] }
      @EndUserText.label             : '{@i18n>MaterialDocumentItem}'
  key MaterialDocumentItem           : mblpo;

      //請求書伝票番号
      @UI                            : { lineItem: [ { position: 450 } ] }
      @EndUserText.label             : '{@i18n>SupplierInvoice}'
  key SupplierInvoice                : re_belnr;

      //請求書伝票明細
      @UI                            : { lineItem: [ { position: 460 } ] }
      @EndUserText.label             : '{@i18n>SupplierInvoiceItem}'
  key SupplierInvoiceItem            : rblgp;

      //Serial number in same PO/Item
  key buzei                          : abap.numc(4);


      //会社コード
      @UI                            : { lineItem: [ { position: 10 } ] }
      @EndUserText.label             : '{@i18n>CompanyCode}'
      CompanyCode                    : bukrs;


      //プラント
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Plant', name: 'I_PlantStdVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @UI                            : { lineItem: [ { position: 20 } ],
                                         selectionField: [ { position: 5 } ] }
      @EndUserText.label             : '{@i18n>Plant}'
      Plant                          : werks_d;

      //購買組織
      @UI                            : { lineItem: [ { position: 30 } ] }
      @EndUserText.label             : '{@i18n>PurchasingOrganization}'
      PurchasingOrganization         : ekorg;

      //購買伝票タイプ
      @UI                            : { lineItem: [ { position: 40 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderType}'
      PurchaseOrderType              : abap.char(4);

      //購買 Group
      @UI                            : { lineItem: [ { position: 50 } ],
                                         selectionField: [ { position: 3 } ] }
      @EndUserText.label             : '{@i18n>PurchasingGroup}'
      PurchasingGroup                : ekgrp;

      //購買 Group名称
      @UI                            : { lineItem: [ { position: 60 } ] }
      @EndUserText.label             : '{@i18n>PurchasingGroupName}'
      PurchasingGroupName            : eknam;

      //仕入先
      @UI                            : { lineItem: [ { position: 70 } ],
                                         selectionField: [ { position: 2 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Supplier', name: 'I_Supplier_VH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>Supplier}'
      Supplier                       : lifnr;

      //仕入先名称
      @UI                            : { lineItem: [ { position: 80 } ] }
      @EndUserText.label             : '{@i18n>SupplierName}'
      SupplierName                   : abap.char(40);

      //品目 Group
      @UI                            : { lineItem: [ { position: 110 } ] }
      @EndUserText.label             : '{@i18n>MaterialGroup}'
      MaterialGroup                  : matkl;

      //品目
      @UI                            : { lineItem: [ { position: 120 } ],
                                         selectionField: [ { position: 4 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Product', name: 'I_ProductStdVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE } }
      @EndUserText.label             : '{@i18n>Material}'
      Material                       : matnr;

      //仕入先品目コード
      @UI                            : { lineItem: [ { position: 130 } ] }
      @EndUserText.label             : '{@i18n>SupplierMaterialNumber}'
      SupplierMaterialNumber         : abap.char(35);

      //顧客品番

      //メーカー品番
      @UI                            : { lineItem: [ { position: 150 } ] }
      @EndUserText.label             : '{@i18n>ProductManufacturerNumber}'
      ProductManufacturerNumber      : mfrpn;

      //テキスト (短)
      @UI                            : { lineItem: [ { position: 160 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderItemText}'
      PurchaseOrderItemText          : txz01;

      //検収(発注)単価
      @UI                            : { lineItem: [ { position: 170 } ] }
      @EndUserText.label             : '{@i18n>NetPrice1}'
      NetPrice1                      : abap.char(13);

      //取引通貨
      @UI                            : { lineItem: [ { position: 180 } ],
                                         selectionField: [ { position: 9 } ] }
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Currency', name: 'I_CurrencyStdVH'}}],
                  filter             : { multipleSelections: true, selectionType: #SINGLE, defaultValue: 'JPY' } }
      @Semantics.currencyCode        : true      
      @EndUserText.label             : '{@i18n>DocumentCurrency}'
      DocumentCurrency               : waers;

      //PO発行日
      @UI                            : { lineItem: [ { position: 190 } ] }
      @EndUserText.label             : '{@i18n>PurchaseOrderDate}'
      PurchaseOrderDate              : aedat;

      //納入期日
      @UI                            : { lineItem: [ { position: 200 } ] }
      @EndUserText.label             : '{@i18n>ScheduleLineDeliveryDate}'
      ScheduleLineDeliveryDate       : eindt;


      //発注数量
      @UI                            : { lineItem: [ { position: 210 } ] }
      @EndUserText.label             : '{@i18n>OrderQuantity}'
      OrderQuantity                  : menge_d;

      //発注単位
      @UI                            : { lineItem: [ { position: 220 } ] }
      @Semantics.unitOfMeasure       : true
      @EndUserText.label             : '{@i18n>PurchaseOrderQuantityUnit}'
      PurchaseOrderQuantityUnit      : bstme;

      //正味発注価格
      @UI                            : { lineItem: [ { position: 230 } ],
                                         selectionField: [ { position: 8 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>NetAmount}'
      NetAmount                      : abap.curr(13,2);

      //価格単位
      @UI                            : { lineItem: [ { position: 240 } ] }
      @EndUserText.label             : '{@i18n>NetPriceQuantity}'
      NetPriceQuantity               : peinh;

      //勘定設定 Categ.
      @UI                            : { lineItem: [ { position: 250 } ] }
      @EndUserText.label             : '{@i18n>AccountAssignmentCategory}'
      AccountAssignmentCategory      : knttp;

      //原価センタ
      @UI                            : { lineItem: [ { position: 260 } ] }
      @EndUserText.label             : '{@i18n>CostCenter}'
      CostCenter                     : kostl;

      //G/L 勘定
      @UI                            : { lineItem: [ { position: 270 } ] }
      @EndUserText.label             : '{@i18n>GLAccount}'
      GLAccount                      : saknr;

      //利益センタ
      @UI                            : { lineItem: [ { position: 280 } ] }
      @EndUserText.label             : '{@i18n>ProfitCenter}'
      ProfitCenter                   : prctr;

      //購買依頼追跡番号
      @UI                            : { lineItem: [ { position: 290 } ] }
      @EndUserText.label             : '{@i18n>RequirementTracking}'
      RequirementTracking            : bednr;

      //購買依頼者
      @UI                            : { lineItem: [ { position: 300 } ] }
      @EndUserText.label             : '{@i18n>RequisitionerName}'
      RequisitionerName              : afnam;

      //受入数量
      @UI                            : { lineItem: [ { position: 330 } ] }
      @EndUserText.label             : '{@i18n>Quantity1}'
      Quantity1                      : menge_d;

      //受入金額（税抜）
      @UI                            : { lineItem: [ { position: 340 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>TaxExcludedPrice}'
      TaxExcludedPrice               : abap.curr(13,2);

      @UI                            : { lineItem: [ { position: 350 } ] }
      @EndUserText.label             : '{@i18n>TaxCode}'
      TaxCode                        : mwskz;

      @UI                            : { lineItem: [ { position: 360 } ] }
      @EndUserText.label             : '{@i18n>TaxRate}'
      TaxRate                        : abap.char(9);

      //入出庫伝票の登録日付
      @UI                            : { lineItem: [ { position: 370 } ] }
      @EndUserText.label             : '{@i18n>AccountingDocumentCreationDate}'
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
      PurgHistDocumentCreationTime   : uzeit;

      //伝票ヘッダ Text
      @UI                            : { lineItem: [ { position: 410 } ] }
      @EndUserText.label             : '{@i18n>MaterialDocumentHeaderText}'
      MaterialDocumentHeaderText     : bktxt;

      //会計年度
      @UI                            : { lineItem: [ { position: 420 } ] }
      @EndUserText.label             : '{@i18n>FiscalYear}'
      FiscalYear                     : gjahr;

      //支払基準日
      @UI                            : { lineItem: [ { position: 430 } ] }
      @EndUserText.label             : '{@i18n>DueCalculationBaseDate}'
      DueCalculationBaseDate         : dzfbdt;

      //請求元
      @UI                            : { lineItem: [ { position: 440 } ] }
      @EndUserText.label             : '{@i18n>InvoicingParty}'
      InvoicingParty                 : lifnr;

      //检收数量
      @UI                            : { lineItem: [ { position: 470 } ] }
      @EndUserText.label             : '{@i18n>Quantity2}'
      Quantity2                      : menge_d;

      //請求書総額
      @UI                            : { lineItem: [ { position: 480 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>InvoiceAmtInPurOrdTransacCrcy}'
      InvoiceAmtInPurOrdTransacCrcy  : abap.curr(13,2);

      //消費税額
      @UI                            : { lineItem: [ { position: 490 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>VAT1}'
      VAT1                           : abap.curr(13,2);

      //請求書金額（税込）
      @UI                            : { lineItem: [ { position: 500 } ] }
      @Semantics.amount.currencyCode : 'DocumentCurrency'
      @EndUserText.label             : '{@i18n>InvoiceAmount}'
      InvoiceAmount                  : abap.curr(13,2);

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
      ExchangeRate                   : abap.dec(9,5);

      //取引通貨単価
      @UI                            : { lineItem: [ { position: 540 } ] }
      @EndUserText.label             : '{@i18n>NetPrice2}'
      NetPrice2                      : abap.char(13);

      //円換算後単価(PO)
      @UI                            : { lineItem: [ { position: 550 } ] }
      @EndUserText.label             : '{@i18n>NetPrice3}'
      NetPrice3                      : abap.char(13);

      //円換算後税込金額（檢收）
      @UI                            : { lineItem: [ { position: 560 } ] }
      @EndUserText.label             : '{@i18n>NetAmount3}'
      NetAmount3                     : abap.char(13);

      //円換算後税額（檢收）
      @UI                            : { lineItem: [ { position: 570 } ] }
      @EndUserText.label             : '{@i18n>VAT2}'
      VAT2                           : abap.char(13);

      //参照伝票
      @UI                            : { lineItem: [ { position: 580 } ] }
      @EndUserText.label             : '{@i18n>AccountingDocument}'
      AccountingDocument             : belnr_d;

      //納期回答
      @UI                            : { lineItem: [ { position: 590 } ] }
      @EndUserText.label             : '{@i18n>DeliveryDate}'
      DeliveryDate                   : eindt;
      
      //回答数量
      @UI                            : { lineItem: [ { position: 610 } ] }
      @EndUserText.label             : '{@i18n>DlvQty}'
      DlvQty                         : menge_d;
      
      //価格設定日付
      @UI                            : { selectionField: [ { position: 6 } ] }
      @EndUserText.label             : '{@i18n>PurgDocPriceDate}'
      PurgDocPriceDate               : datum;
      
      //納入完了PO排除
      @UI                            : { selectionField: [ { position: 7 } ] }
      @EndUserText.label             : '{@i18n>IsCompletelyDelivered}'
      IsCompletelyDelivered          : abap_boolean;
      
}
