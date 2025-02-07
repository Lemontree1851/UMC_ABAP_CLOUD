@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_BI003_REPORT'
@EndUserText.label: '回収既存データ照会'
define custom entity ZC_BI003_REPORT_UPLOAD
{
  key uuid                         : sysuuid_x16;
      UploadType                   : abap.char(2);
      YearMonth                    : fins_fyearperiod;
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' } }]
      CompanyCode                  : bukrs;
      CompanyCodeText              : bktxt;
      Customer                     : kunnr;
      CustomerName                 : abap.char(80);
      CompanyCurrency              : waers;
      BaseUnit                     : abap.unit(3);
      RecoveryManagementNumber     : ze_recycle_no;   // 回収管理番号
      PurchaseOrder                : ebeln;           // 発注伝票
      PurchaseOrderItem            : ebelp;           // 発注伝票明細
      @Semantics.amount.currencyCode:'CompanyCurrency'
      RecoveryNecessaryAmount      : dmbtr;

      // スポットバイ（SB）
      SpotbuyMaterial              : matnr;           // スポットバイ品目
      SpotbuyMaterialText          : maktx;           // スポットバイ品目テキスト
      @Semantics.amount.currencyCode:'CompanyCurrency'
      SpotbuyMaterialPrice         : dmbtr;           // スポットバイ品目単価
      GeneralMaterial              : matnr;           // 通常品目
      GeneralMaterialText          : maktx;           // 通常品目テキスト
      @Semantics.amount.currencyCode:'CompanyCurrency'
      GeneralMaterialPrice         : dmbtr;           // 通常品目最新発注単価
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      MaterialQuantity             : abap.quan(13,3); // スポットバイ品目入庫数量
      @Semantics.amount.currencyCode:'CompanyCurrency'
      NetPriceDiff                 : dmbtr;           // 単価差額

      // イニシャル（IN）
      InitialMaterial              : matnr;           // イニシャル品目
      InitialMaterialText          : maktx;           // イニシャル品目テキスト
      MateriaGroup                 : matkl;           // 品目グループ
      AccountingDocument           : belnr_d;         // 会計伝票
      AccountingDocumentItem       : abap.char(6);    // 会計伝票明細
      GLAccount                    : hkont;           // 勘定科目
      GLAccountText                : abap.char(20);   // 勘定科目テキスト
      FixedAsset                   : anln1;           // 固定資産番号
      FixedAssetText               : abap.char(50);   // 固定資産テキスト
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      POQuantity                   : abap.quan(13,3); // 発注伝票数量
      @Semantics.amount.currencyCode:'CompanyCurrency'
      NetAmount                    : dmbtr;           // 発注伝票単価

      // 特別輸送費（ST）
      TransportExpenseMaterial     : matnr;           // 特別輸送費品目
      TransportExpenseMaterialText : maktx;           // 特別輸送費品目テキスト

      // 在庫廃棄ロス（SS）
      MaterialDocument             : mblnr;           // 品目入出庫伝票
      MaterialDocumentItem         : mblpo;           // 品目入出庫伝票明細
      SSMaterial                   : matnr;           // 在庫廃棄ロス品目
      SSMaterialText               : maktx;           // 在庫廃棄ロス品目テキスト
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      Quantity                     : abap.quan(13,3); // 品目入出庫伝票数量
}
