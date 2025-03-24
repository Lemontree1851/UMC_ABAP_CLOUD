@ObjectModel.query.implementedBy: 'ABAP:ZCL_PURINFOMASTERLIST'
@EndUserText.label: 'MM-018購買情報マスタレポート'
@UI: {
  headerInfo: {
    typeName: 'MM-018購買情報マスタレポート',
    typeNamePlural: 'MM-018購買情報マスタレポート',
    title: { type: #STANDARD, value: 'purchasinginforecord' }
        } }
define root custom entity ZR_PURINFOMASTERLIST
{
  key uuid                           : sysuuid_x16;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_PurchasingInfoRecordApi01', element: 'PurchasingInfoRecord' } }]
  key purchasinginforecord           : infnr;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_Plant', element: 'Plant' } }]
  key plant                          : werks_d;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_PurchasingOrganization', element: 'PurchasingOrganization' } }]
  key purchasingorganization         : ekorg;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
  key material                       : matnr;
  key suppliermaterialnumber         : abap.char(35);
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_Supplier', element: 'Supplier' } }]
  key Supplier                       : lifnr;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_PurchasingGroup', element: 'PurchasingGroup' } }]
  key PurchasingGroup                : ekgrp;
      @Consumption.valueHelpDefinition:[{ entity: { name: 'I_Supplier', element: 'Supplier' } }]
  key ManufacturerNumber             : mfrnr;
  key ProductManufacturerNumber      : mfrpn;
  key latestoffer                    : abap.char(1);
  key SupplierIsFixed                : abap.char(1);
  key IncotermsClassification        : abap.char(3);
  key condition_validity_start_date  : abap.dats;
  key condition_validity_end_date    : abap.dats;
      Ztype1                         : abap.char(1);
      Ztype2                         : abap.char(1);
      ProductName                    : maktx;
      ProductGroup                   : matkl;
      @Semantics.amount.currencyCode : 'Currency_plnt'
      NetPriceAmount                 : abap.curr(13,2);
      @Semantics.currencyCode        : true
      Currency_plnt                  : waers;
      @Semantics.amount.currencyCode : 'Currency_plnt'
      ConditionRateValue             : abap.curr(13,2);
      MaterialPriceUnitQty           : abap.dec(5);
      @Semantics.unitOfMeasure       : true
      PurgDocOrderQuantityUnit       : abap.unit(3);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      ConditionScaleQuantity         : abap.quan(15,3);
      organizationbpname1_ja         : abap.char(40);
      organizationbpname1_en         : abap.char(40);
      PurchasingGroupName            : abap.char(18);
      FirstSalesSpecProductGroup     : bezei40;
      @Consumption.filter.selectionType: #INTERVAL
      CreationDate_1                 : abap.dats;
      CreatedByUser                  : abap.char(12);
      @Consumption.filter.selectionType: #INTERVAL
      CreationDate_2                 : abap.dats;
      OwnInventoryManagedProduct     : abap.char(40);
      ProductOID                     : matnr;
      BaseUnit                       : abap.unit(3);
      OrganizationBPName1            : abap.char(40);
      standardpurchaseorderquantity  : abap.dec(15,3);
      Taxprice                       : abap.dec(15,3);
      @Semantics.amount.currencyCode : 'Currency_standard'
      UnitPrice_plnt                 : abap.curr(15,2);
      UnitPrice_standard             : abap.dec(15,3);
      PriceUnitQty                   : abap.dec(5);
      Currency_standard              : waers;
      orderpriceunittoorderunitnmrtr : abap.dec(5,0);
      MaterialPlannedDeliveryDurn    : abap.dec(3);
      ShippingConditionName          : abap.char(20);
      IndustryStandardName           : abap.char(18);
      TaxCode                        : abap.char(2);
      MinimumPurchaseOrderQuantity   : abap.char(13);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      MaximumOrderQuantity           : abap.quan(13,3);
      PricingDateControl             : abap.char(1);
      SupplierMaterialGroup          : abap.char(18);
      SupplierCertOriginCountry      : abap.char(3);
      SupplierCertOriginRegion       : abap.char(3);
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      UMCJPPurchasingPrice           : abap.quan(13);
      DeliveryLT                     : abap.char(5);
      @Consumption.filter.selectionType: #SINGLE
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
      Rate                           : abap.char(50);

      @Consumption.filter.hidden     : true
      @UI.hidden                     : true
      UserEmail                      : abap.char(241); // ADD BY XINLEI XU 2025/03/17
}
