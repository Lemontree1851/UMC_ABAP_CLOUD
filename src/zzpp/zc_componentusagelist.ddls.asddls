@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_COMPONENTUSAGELIST'
@EndUserText.label: '部品使用先一覧レポート'
@Metadata.allowExtensions: true
@UI: {
  headerInfo: {
    typeName: '部品使用先一覧レポート',
    typeNamePlural: '部品使用先一覧レポート'
    } }
define root custom entity ZC_COMPONENTUSAGELIST
{
  key Plant                         : werks_d;
  key BillOfMaterialComponent       : abap.char( 40 );
  key Material                      : matnr;
  key BillOfMaterialVariant         : abap.char( 2 );
  key Product                       : matnr;
      ProductDescription            : maktx;
      ComponentDescription          : maktx;
      SupplierMaterialNumber        : abap.char( 35 );
      ProductManufacturerNumber     : mfrpn;
      MaterialByCustomer            : abap.char( 35 );
      MRPResponsible                : co_dispo;
      HighLevelMatValidityStartDate : datuv;
      BillOfMaterialItemNumber      : abap.char( 4 );
      @Semantics.quantity.unitOfMeasure : 'BillOfMaterialItemUnit'
      BillOfMaterialItemQuantity    : menge_d;
      BillOfMaterialItemUnit        : meins;
      AlternativeItemStrategy       : abap.char( 1 );
      AlternativeItemPriority       : abap.numc( 2 );
      BOMSubItemInstallationPoint   : abap.char( 100 );
      NoDisplayNonProduct           : abap_boolean;
      DisplayPurchasingInfo         : abap_boolean;
}
