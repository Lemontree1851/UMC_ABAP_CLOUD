@EndUserText.label: 'Sales Document List'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_SALESDOCUMENTLIST'
define root custom entity ZC_SALESDOCUMENTLIST
{
  key SalesDocument                  : vbeln_va;
  key SalesDocumentItem              : posnr_va;
  key ScheduleLine                   : abap.char(4);
      SalesOrganization              : vkorg;
      SalesDocumentType              : auart;
      SalesDocumentTypeName          : abap.char(20);
      SalesDocApprovalStatus         : abap.char(1);
      SalesDocApprovalStatusDesc     : val_text;
      PurchaseOrderByCustomer        : bstkd;
      IncotermsClassification        : abap.char(3);
      IncotermsLocation1             : abap.char(70);
      SoldToParty                    : kunag;
      SoldToPartyName                : abap.char(80);
      SoldToPartySearchTerm1         : abap.char(20);
      SoldToPartySearchTerm2         : abap.char(20);
      BillToParty                    : kunnr;
      BillToPartyName                : abap.char(80);
      BillToPartySearchTerm1         : abap.char(20);
      BillToPartySearchTerm2         : abap.char(20);
      ShipToParty                    : kunnr;
      ShipToPartyName                : abap.char(80);
      ShipToPartySearchTerm1         : abap.char(20);
      ShipToPartySearchTerm2         : abap.char(20);
      Product                        : matnr;
      SalesDocumentItemText          : arktx;
      MaterialByCustomer             : abap.char(35);
      PurchaseOrderByCustomerItem    : bstkd;
      UnderlyingPurchaseOrderItem    : posex;
      @Semantics.quantity.unitOfMeasure : 'OrderQuantityUnit'
      OrderQuantity                  : kwmeng;
      OrderQuantityUnit              : vrkme;
      BaseUnit                       : meins;
      Plant                          : werks_d;
      YY1_CustomerLotNo_SDI          : abap.char(25);
      PurchaseOrderByShipToParty     : bstkd;
      ProfitCenter                   : prctr;
      ProfitCenterLongName           : abap.char(40);
      CustomerPaymentTerms           : dzterm;
      PaymentTermsName               : abap.char(30);
      ShippingType                   : abap.char(2);
      ShippingTypeName               : abap.char(20);
      IsConfirmedDelivSchedLine      : abap.char(1);
      ScheduleLineCategory           : abap.char(2);
      ScheduleLineCategoryName       : abap.char(20);
      DeliveryDate                   : abap.dats;
      ConfirmedDeliveryDate          : abap.dats;
      TransactionCurrency            : waerk;
      PriceDetnExchangeRate          : abap.dec( 9, 5 );
      ExchangeRateDate               : wwert_d;
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyPPR0'
      ConditionRateValuePPR0         : abap.dec( 24, 2 );
      ConditionCurrencyPPR0          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountPPR0            : abap.dec( 15, 2 );
      ConditionRateValueTTX1         : abap.dec( 24, 2 );
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountTTX1            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPFC'
      ConditionRateValueZPFC         : abap.dec( 24, 2 );
      ConditionCurrencyZPFC          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPFC            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPST'
      ConditionRateValueZPST         : abap.dec( 24, 2 );
      ConditionCurrencyZPST          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPST            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPIN'
      ConditionRateValueZPIN         : abap.dec( 24, 2 );
      ConditionCurrencyZPIN          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPIN            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPSB'
      ConditionRateValueZPSB         : abap.dec( 24, 2 );
      ConditionCurrencyZPSB          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPSB            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPSS'
      ConditionRateValueZPSS         : abap.dec( 24, 2 );
      ConditionCurrencyZPSS          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPSS            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPCM'
      ConditionRateValueZPCM         : abap.dec( 24, 2 );
      ConditionCurrencyZPCM          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPCM            : abap.dec( 15, 2 );
      //      @Semantics.amount.currencyCode : 'ConditionCurrencyZPGP'
      ConditionRateValueZPGP         : abap.dec( 24, 2 );
      ConditionCurrencyZPGP          : waers;
      @Semantics.amount.currencyCode : 'TransactionCurrency'
      ConditionAmountZPGP            : abap.dec( 15, 2 );
      YY1_ItemRemarks_1_SDI          : abap.char(70);
      @Semantics.quantity.unitOfMeasure : 'OrderQuantityUnit'
      DeliveredQtyInOrderQtyUnit     : menge_d;
      @Semantics.quantity.unitOfMeasure : 'OrderQuantityUnit'
      OpenConfdDelivQtyInOrdQtyUnit  : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      ComplDeliveredQtyInBaseUnit    : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      NoComplDeliveredQtyInBaseUnit  : menge_d;
      InternalTansferQtyInBaseUnit   : abap.char(20); //menge_d;
      NoInternalTansferQtyInBaseUnit : abap.char(20); //menge_d;
      ExternalTansferQtyInBaseUnit   : abap.char(20); //menge_d;
      NoExternalTansferQtyInBaseUnit : abap.char(20); //menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      BillingQuantityInBaseUnit      : menge_d;
      @Semantics.quantity.unitOfMeasure : 'BaseUnit'
      NoBillingQuantityInBaseUnit    : menge_d;
      CreationDate                   : erdat;
      CreationDateItem               : erdat;
      LastChangeDate                 : aedat;
      CreatedByUser                  : ernam;
      SalesDocumentRjcnReason        : abap.char(2);
      SalesDocumentRjcnReasonName    : bezei40;
      YY1_SalesDocType_SDH           : abap.char(4);
      YY1_ManagementNo_SDI           : abap.char(18);
      YY1_ManagementNo_1_SDI         : abap.char(18);
      YY1_ManagementNo_2_SDI         : abap.char(18);
      YY1_ManagementNo_3_SDI         : abap.char(18);

      //filter field
      RequestedDeliveryDate          : abap.dats;
      SalesDocumentDate              : abap.dats;
      Indicator1                     : abap_boolean; //DN未発行
      Indicator2                     : abap_boolean; //DN未出庫
      Indicator3                     : abap_boolean; //外部移転未記載
      Indicator4                     : abap_boolean; //未請求
      Indicator5                     : abap_boolean; //請求済
      Indicator6                     : abap_boolean; //拒否項目の表示
      UserEmail                      : abap.char(241);
}
