@AbapCatalog.sqlViewName: 'ZFIXEDASSET'
@AbapCatalog.compiler.compareFilter: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fixed Asset Print'
define view ZC_FIXEDASSETPRINT as select from I_FixedAssetAssgmt as A 
{
    @UI:{
        lineItem: [ { position: 1 } ],
        selectionField: [ { position: 10 } ] 
    }
    key A._FixedAsset.CompanyCode,//①会社コード：必須項目　Odata:Company Code 
    @UI.hidden: true
    key A._FixedAsset.MasterFixedAsset,
    @UI.hidden: true
    key A._FixedAsset.FixedAsset,
    @UI.hidden: true
    key A.ValidityEndDate,
    @UI:{
        lineItem: [ { position: 2 } ]
    }    
    A._CompanyCode.CompanyCodeName,

    @UI:{
        selectionField: [ { position: 60 } ]
    }      
    A._FixedAsset.AssetAdditionalDescription,//⑥資本化日付：入力可能項目
    @UI:{
        //lineItem: [ { position: 10 } ],
        selectionField: [ { position: 50 } ]
    }   
    A._FixedAsset.InventoryNote,//①棚卸ノート  ⑤棚卸ノート:入力可能項目　検索ボックス付き
    @UI:{
        lineItem: [ { position: 20 } ],
        selectionField: [ { position: 30 } ]
    }      
    A._FixedAsset.FixedAssetDescription,//②資産テキスト  ③資産テキスト:入力可能項目
    @UI:{
        lineItem: [ { position: 30 } ],
        selectionField: [ { position: 20 } ]
    }        
    A._FixedAsset.FixedAssetExternalID,//③資産番号  ②資産番号:入力可能項目　検索ボックス付き
    @UI:{
        lineItem: [ { position: 40 } ]
    }      
    A._FixedAsset.Inventory,//④棚卸番号
    @UI:{
        lineItem: [ { position: 50 } ],
        selectionField: [ { position: 40 } ]
    }          
    A.CostCenter,//⑤原価センタ  ④原価センタ:入力可能項目　検索ボックス付き
    @UI:{
        lineItem: [ { position: 60 } ]
    }         
    A._CostCenter._Text[1:Language = 'J'].CostCenterName,//⑥原価センタ名称
    @UI:{
        lineItem: [ { position: 70 } ]
    }
    A._FixedAsset._FixedAssetForLedger.AssetCapitalizationDate,//⑦資本化日付
    @UI:{
        lineItem: [ { position: 90 } ]
    }       
    A._FixedAsset.AssetAccountDetermination,//⑧勘定設定名称
    @UI:{
        lineItem: [ { position: 95 } ]
    }       
    A._FixedAsset._AssetAccountDetermination._Text[1:Language = 'J'].AssetAccountDeterminationDesc ,//⑧勘定設定名称    
    @UI:{
        lineItem: [ { position: 80 } ]
    }    
    A._FixedAsset._AssetValuationForLedger[1:Ledger = '0L'and AssetRealDepreciationArea = '01'].DepreciationStartDate,//⑨償却開始日
 //   @UI:{
 //       lineItem: [ { position: 100 } ]
 //   }       
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
    @EndUserText.label: '償却方法'
    cast( '' as abap.sstring(50)  ) as DepreciationKeyName,  //⑩償却方法
 //   @UI:{
 //       lineItem: [ { position: 110 } ]
 //   }      
    A._FixedAsset.LeasedAssetNote,//⑪追記テキスト
    @UI:{
        lineItem: [ { position: 120 } ]
    }        
    A._FixedAsset._AssetValuationForLedger[1:Ledger = '0L' and AssetRealDepreciationArea = '01'].PlannedUsefulLifeInYears,//⑫耐用年数
    @UI:{
        lineItem: [ { position: 130 } ]
    }    
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
    @EndUserText.label: '取得価額'             
    //A._FixedAsset.OriginalAcquisitionAmount,//⑬取得価額
    @Semantics.amount.currencyCode : 'OriginalAcquisitionCurrency'
    cast( 0 as abap.curr(23,2)  ) as OriginalAcquisitionAmount,
   // @UI:{
  //      lineItem: [ { position: 140 } ]
  //  }       
    A._FixedAsset.InvestmentReason,  //⑭設備投資理由
 //   @UI:{
  //      lineItem: [ { position: 150 } ]
  //  }       
    A._FixedAsset.AssetTypeName, //⑮イニシャル顧客名
  //  @UI:{
   //     lineItem: [ { position: 160 } ]
   // }       
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
    @EndUserText.label: '特例コード'
    cast( '' as abap.sstring(4)  ) as JP_PrptyTxRptSpclDepr  ,//⑯特例コード
 //   @UI:{
  //      lineItem: [ { position: 150 } ]
  //  }     
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
    @EndUserText.label: '不動産所有区分'  
    cast( '' as abap.sstring(2)  ) as YY1_FIXEDASSET1_FAA  , //⑰不動産所有区分    
    @UI.hidden: true
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_FIXEDASSET_CAL'
    @EndUserText.label: '货币'   
    A._FixedAsset.OriginalAcquisitionCurrency,
    @UI.hidden: true
    A._FixedAsset._AssetValuationForLedger[1:Ledger = '0L'and AssetRealDepreciationArea = '01'].DepreciationKey
   
}
