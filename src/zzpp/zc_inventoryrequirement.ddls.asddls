@EndUserText.label: 'Inventory Requirement Report'
@Metadata.allowExtensions: true
@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_INVENTORYREQUIREMENT'
define root custom entity ZC_InventoryRequirement
{
  key UUID                   : sysuuid_x16;
      Plant                  : werks_d;
      MRPArea                : abap.char(10);
      MRPController          : dispo;
      PurchasingGroup        : ekgrp;
      ProductGroup           : matkl;
      ProductType            : mtart;
      Product                : matnr;
      Supplier               : elifn;
      SupplierMaterialNumber : abap.char(35);
      PeriodEndDate          : abap.dats;
      DisplayUnit            : abap.char(1); // 表示単位: 日単位、週単位、月単位
      DisplayDimension       : abap.char(1); // 結果表示: 横表示、縦表示
      SelectionRule          : abap.char(8); // 範囲選択
      ShowInformation        : abap_boolean; // 購買関連情報表示
      ShowDetailLines        : abap_boolean; // 購買関連明細行表示
      ShowDEMAND             : abap_boolean; // DEMAND明細表示

      // Dynamic Data
      DynamicData            : abap.string;
}
