@EndUserText.label: 'Query CDS'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_FIXEDASSETPRINT'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}
define root custom entity ZC_FIXEDASSETPRINTs
{
      @UI                           : {
          lineItem                  : [ { position: 1 } ],
          selectionField            : [ { position: 10 } ]
      }
  key Companycode                   : bukrs; //①会社コード：必須項目　Odata:Company Code
      @UI.hidden                    : true
  key MasterFixedAsset              : anln1;
      @UI.hidden                    : true
  key FixedAsset                    : anln2;
      @UI.hidden                    : true
  key ValidityEndDate               : datum;
      @UI                           : {
          lineItem                  : [ { position: 2 } ]
      }
      CompanyCodeName               : butxt;

      @UI                           : {
          selectionField            : [ { position: 60 } ]
      }
       @EndUserText.label            : '資本化日付'
      AssetAdditionalDescription    : abap.char(50); //⑥資本化日付：入力可能項目 txa50_more
      @UI                           : {
          //lineItem: [ { position: 10 } ],
          selectionField            : [ { position: 50 } ]
      }
      @EndUserText.label            : '棚卸ノート'
      InventoryNote                 : abap.char(15); //①棚卸ノート  ⑤棚卸ノート:入力可能項目　検索ボックス付きinvzu_anla
      @UI                           : {
          lineItem                  : [ { position: 20 } ],
          selectionField            : [ { position: 30 } ]
      }
      @EndUserText.label            : '資産テキスト' 
      FixedAssetDescription         : abap.char(50); //②資産テキスト  ③資産テキスト:入力可能項目txa50_anlt
      @UI                           : {
          lineItem                  : [ { position: 30 } ],
          selectionField            : [ { position: 20 } ]
      }
      @EndUserText.label            : '資産番号' 
      FixedAssetExternalID          : anln2; //③資産番号  ②資産番号:入力可能項目　検索ボックス付き
      @UI                           : {
          lineItem                  : [ { position: 40 } ]
      }
      @EndUserText.label            : '棚卸番号' 
      Inventory                     : abap.char(25); //④棚卸番号invnr_anla
      @UI                           : {
          lineItem                  : [ { position: 50 } ],
          selectionField            : [ { position: 40 } ]
      }
      @EndUserText.label            : '原価センタ' 
      CostCenter                    : kostl; //⑤原価センタ  ④原価センタ:入力可能項目　検索ボックス付き
      @UI                           : {
          lineItem                  : [ { position: 60 } ]
      }
      @EndUserText.label            : '原価センタ名称' 
      CostCenterName                : ktext; //⑥原価センタ名称
      @UI                           : {
          lineItem                  : [ { position: 70 } ]
      }
      @EndUserText.label            : '資本化日付' 
      AssetCapitalizationDate       : datum; //⑦資本化日付aktivd
      @UI                           : {
          lineItem                  : [ { position: 90 } ]
      }
      @EndUserText.label            : '勘定設定' 
      AssetAccountDetermination     : abap.char(8); //⑧勘定設定名称ktogr
      @UI                           : {
          lineItem                  : [ { position: 95 } ]
      }
      @EndUserText.label            : '勘定設定名称'
      AssetAccountDeterminationDesc : abap.char(50); //⑧勘定設定名称   ktgrtx
      @UI                           : {
          lineItem                  : [ { position: 80 } ]
      }
      DepreciationStartDate         : datum; //⑨償却開始日afabg
      //   @UI:{
      //       lineItem: [ { position: 100 } ]
      //   }
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
      @EndUserText.label            : '償却方法'
      DepreciationKeyName           : abap.char(50); //⑩償却方法
      //   @UI:{
      //       lineItem: [ { position: 110 } ]
      //   }
      @EndUserText.label            : '⑪追記テキスト'
      LeasedAssetNote               : abap.char(50); //⑪追記テキストletxt
      @UI                           : {
          lineItem                  : [ { position: 120 } ]
      }
      @EndUserText.label            : '耐用年数'
      PlannedUsefulLifeInYears      : abap.numc(3); //⑫耐用年数ndjar
      @UI                           : {
          lineItem                  : [ { position: 130 } ]
      }
      @Semantics.amount.currencyCode: 'OriginalAcquisitionCurrency'
      @EndUserText.label            : '取得価額'
      OriginalAcquisitionAmount     : abap.curr(23,2); //⑬取得価額urwrt
      // @UI:{
      //      lineItem: [ { position: 140 } ]
      //  }
       @EndUserText.label            : '設備投資理由'
      InvestmentReason              : abap.char(2); //⑭設備投資理由izwek
      //   @UI:{
      //      lineItem: [ { position: 150 } ]
      //  }
      @EndUserText.label            : 'イニシャル顧客名'
      AssetTypeName                 : abap.char(15); //⑮イニシャル顧客名typbz_anla
      //  @UI:{
      //     lineItem: [ { position: 160 } ]
      // }
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
      @EndUserText.label            : '特例コード'
      JP_PrptyTxRptSpclDepr         : abap.char(4); //⑯特例コード
      //   @UI:{
      //      lineItem: [ { position: 150 } ]
      //  }
      @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
      @EndUserText.label            : '不動産所有区分'
      YY1_FIXEDASSET1_FAA           : abap.char(2); //⑰不動産所有区分
      @UI.hidden                    : true
      OriginalAcquisitionCurrency   : waers; //faa_md_org_acq_curr
      @UI.hidden                    : true
      DepreciationKey               : abap.char(4); //afasl

}
