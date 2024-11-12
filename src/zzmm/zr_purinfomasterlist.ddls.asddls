@ObjectModel.query.implementedBy: 'ABAP:ZCL_PURINFOMASTERLIST'
@EndUserText.label: 'MM-018購買情報マスタ一覧'
@UI: {
  headerInfo: {
    typeName: 'MM-018購買情報マスタ一覧',
    typeNamePlural: 'MM-018購買情報マスタ一覧',
    title: { type: #STANDARD, value: 'purchasinginforecord' }
        } }
define  root custom entity ZR_PURINFOMASTERLIST
{
      @UI                            : { lineItem: [ { position: 10 } ], 
                                         selectionField: [ { position: 10 } ] }
  key purchasinginforecord           : abap.char(10);
      @UI                            : { lineItem: [ { position: 20 } ], 
                                         selectionField: [ { position: 20 } ] }
  key plant                          : abap.char(4);
      @UI                            : { lineItem: [ { position: 30 } ], 
                                         selectionField: [ { position: 30 } ] }
  key purchasingorganization         : abap.char(4);
      @UI                            : { lineItem: [ { position: 40 } ], 
                                         selectionField: [ { position: 40 } ] }
  key material                       : abap.char(40);
      @UI                            : { lineItem: [ { position: 50 } ], 
                                         selectionField: [ { position: 50 } ] }
  key suppliermaterialnumber         : abap.char(35);
      @UI                            : { lineItem: [ { position: 160 } ], 
                                         selectionField: [ { position: 60 } ] }
  key Supplier                       : abap.char(10);
      Ztype1                         : abap.char(1);
      Ztype2                         : abap.char(1);
      ProductName                    : abap.char(40);
      ProductGroup                   : abap.char(9);
      NetPriceAmount                 : abap.curr(13,2);
      condition_validity_start_date  : abap.dats;
      condition_validity_end_date    : abap.dats;
      @Semantics.currencyCode        : true
      Currency_plnt                  : waers;
      @Semantics.amount.currencyCode : 'Currency_plnt'
      ConditionRateValue             : abap.curr(13,2);
      MaterialPriceUnitQty           : abap.dec(5);
      @Semantics.unitOfMeasure       : true
      PurgDocOrderQuantityUnit       : abap.unit(3);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      ConditionScaleQuantity         : abap.quan(15);
      organizationbpname1_ja         : abap.char(40);
      organizationbpname1_en         : abap.char(40);
      @UI                            : { lineItem: [ { position: 190, label: '購買グループ' } ], 
                                         selectionField: [ { position: 70 } ] }
      PurchasingGroup                : abap.char(3);
      PurchasingGroupName            : abap.char(18);
      FirstSalesSpecProductGroup     : abap.char(3);
      @UI                            : { lineItem: [ { position: 220, label: '登録日' } ], 
                                         selectionField: [ { position: 80 } ] }
      CreationDate_1                 : abap.dats;
      CreatedByUser                  : abap.char(12);
      @UI                            : { lineItem: [ { position: 240, label: 'Quotation creation date' } ],
                                         selectionField: [ { position: 90 } ] }
      CreationDate_2                 : abap.dats;
      OwnInventoryManagedProduct     : abap.char(40);
      ProductOID                     : abap.char(40);
      BaseUnit                       : abap.unit(3);
      @UI                            : { lineItem: [ { position: 280, label: 'Manufacturer code' } ],
                                         selectionField: [ { position: 100 } ] }
      ManufacturerNumber             : abap.char(10);
      OrganizationBPName1            : abap.char(40);
      @UI                            : { lineItem: [ { position: 300, label: 'MPN' } ], 
                                         selectionField: [ { position: 110 } ] }
      ProductManufacturerNumber      : abap.char(40);
      standardpurchaseorderquantity  : abap.dec(15,3);
      Taxprice                       : abap.dec(15,3);
      UnitPrice_plnt                 : abap.dec(15,3);
      @Semantics.amount.currencyCode : 'Currency_plnt'
      UnitPrice_standard             : abap.curr(15,2);
      PriceUnitQty                   : abap.dec(5);
      Currency_standard              : waers;
      orderpriceunittoorderunitnmrtr : abap.dec(5,0);
      @UI                            : { lineItem: [ { position: 380, label: 'Latest offer' } ], 
                                         selectionField: [ { position: 120 } ] }
      latestoffer  : abap.char(1);
      @UI                            : { lineItem: [ { position: 390, label: '固定仕入先' } ], 
                                         selectionField: [ { position: 130 } ] }
      SupplierIsFixed                : abap.char(1);
      MaterialPlannedDeliveryDurn    : abap.dec(3);
      ShippingConditionName          : abap.char(20);
      IndustryStandardName           : abap.char(18);
      TaxCode                        : abap.char(2);
      MinimumPurchaseOrderQuantity   : abap.char(13);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      MaximumOrderQuantity           : abap.quan(13);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      PricingDateControl             : abap.quan(13);
      SupplierMaterialGroup          : abap.char(18);
      SupplierCertOriginCountry      : abap.char(3);
      SupplierCertOriginRegion       : abap.char(3);
      @UI                            : { lineItem: [ { position: 500, label: '基軸通貨' } ], 
                                         selectionField: [ { position: 140 } ] }
      IncotermsClassification        : abap.char(3);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      UMCJPPurchasingPrice           : abap.quan(13);
      DeliveryLT                     : abap.char(5);    
      @UI                            : { lineItem: [ { position: 590, label: 'Plus day' } ], 
                                         selectionField: [ { position: 150 } ] }
      PlusDay                        : abap.char(3);
      PurchasingInfoRecordCategory   : abap.char(1);
      SupplierConfirmationControlKey : abap.char(4);
      ValuationClass                 : abap.char(4);
      SupplierSubrange               : abap.char(6);
      SupplierSubrangeName           : abap.char(20);
      loginflag                      : abap.char(1);
      isdeleted                      : abap.char(1);
      ismarkedfordeletion            : abap.char(1);
      productsalesorg                : abap.char(4);
      zvalue2                        : abap.char(120);
      Rate                           : abap.char(11);
}
