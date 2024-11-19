@EndUserText.label: 'Sales Acceptance Result'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_SALESACCEPTANCE_RESULT'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}

define root custom entity ZR_SALESACCEPTANCE_RESULT
{

  key SalesOrganization      : ekorg; //販売組織
      @UI                    : { selectionField: [ { position: 1 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_Customer_VH', element: 'Customer' } }]
  key Customer               : kunnr; //得意先BPコード
  key PeriodType             : abap.char(1);  //時期区分
  key AcceptPeriod           : abap.char(2);  //検収期間
  key SalesDocument          : vbeln_va;      //受注伝票番号
  key SalesDocumentItem      : posnr_va;      //受注明細番号
  key BillingDocument        : abap.char(10); //実績伝票番号
      CustomerPO             : abap.char(35); //得意先PO番号
      AcceptPeriodFrom       : abap.dats;     //検収期間From
      AcceptPeriodTo         : abap.dats;     //検収期間To
      SalesDocumentType      : auart; //受注伝票タイプ
      Product                : matnr; //品目コード
      SalesDocumentItemText  : arktx; //品名
      PostingDate            : budat; //実績転記日
      AcceptDate             : abap.dats; //検収日付
      AcceptQty              : abap.quan(15,3); //検収数
      BillingQuantity        : menge_d; //出庫数
      AcceptPrice            : abap.curr(13,2); //検収単価
      ConditionRateValue     : abap.curr(13,2); //請求単価
      @Semantics.currencyCode: true
      ConditionCurrency      : waers; //単価通貨
      ConditionQuantity      : abap.dec(5); //単価数量単位
      AccceptAmount          : abap.curr(13,2); //検収金額
      NetAmount              : abap.curr(13,2); //請求金額
      AccceptTaxAmount       : abap.curr(13,2); //検収税額
      TaxAmount              : abap.curr(13,2); //請求税額
      Currency        : waers; //検収通貨(受注通貨)
      AccountingExchangeRate : abap.char(9); //為替レート(検収通貨と会社通貨)
      ExchangeRateDate       : abap.dats; //為替日付
      OutsideData            : abap.char(1); //SAP外売上区分
      Remarks                : abap.char(100); //備考
      ProcessStatus          : abap.char(2); //処理ステータス
      ProcessStatusTxt       : abap.char(20); //ProcessStatus text
      ReasonCategory         : abap.char(2); //要因区分
      ReasonCategoryTxt      : abap.char(20); //ReasonCategory text
      Reason                 : abap.char(2); //差異要因
      ReasonTxt              : abap.char(20); //Reason text
      @Semantics.unitOfMeasure       : true
      unit                   : meins;

}
