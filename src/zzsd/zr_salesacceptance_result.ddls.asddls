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
  key AcceptYear             : gjahr;
  key AcceptPeriod           : abap.char(2);  //検収期間
  key SalesDocument          : vbeln_va;      //受注伝票番号
  key SalesDocumentItem      : abap.char(6); //受注明細番号
  key BillingDocument        : abap.char(10); //実績伝票番号
  key CustomerPO             : abap.char(35); //得意先PO番号
  key ProcessStatus          : abap.char(20); //処理ステータス
      AcceptPeriodFrom       : abap.dats;     //検収期間From
      AcceptPeriodTo         : abap.dats;     //検収期間To
      SalesDocumentType      : auart; //受注伝票タイプ
      SalesDocumentTypeText  : bezei; //SalesDocumentTypeName
      Product                : matnr; //品目コード
      SalesDocumentItemText  : arktx; //品名
      PostingDate            : budat; //実績転記日
      AcceptDate             : abap.dats; //検収日付
      AcceptQty              : abap.char(20); //検収数
      BillingQuantity        : abap.char(20); //出庫数
      AcceptPrice            : abap.char(20); //検収単価
      ConditionRateValue     : abap.char(20); //請求単価
      ConditionCurrency      : waers; //単価通貨
      ConditionQuantity      : abap.char(5); //単価数量単位
      AccceptAmount          : abap.char(20); //検収金額
      NetAmount              : abap.char(20); //請求金額
      AccceptTaxAmount       : abap.char(20); //検収税額
      TaxAmount              : abap.char(20); //請求税額
      Currency               : waers; //検収通貨(受注通貨)
      AccountingExchangeRate : abap.char(9); //為替レート(検収通貨と会社通貨)
      ExchangeRateDate       : abap.dats; //為替日付
      OutsideData            : abap.char(1); //SAP外売上区分
      Remarks                : abap.char(100); //備考
      ReasonCategory         : abap.char(20); //要因区分
      Reason                 : abap.char(20); //差異要因
      FinishStatus           : abap.char(20); //Status
      CustomerName           : abap.char(80); //Customer Name
      PeriodTypeText         : abap.char(30);
      AcceptPeriodText       : abap.char(30);
      AcceptPeriodFromText   : abap.char(30);
      AcceptPeriodToText     : abap.char(30);
      @UI                    : { selectionField: [ { position: 2 } ] }
      Layer                  : abap.char(1);
      @Semantics.unitOfMeasure       : true
      unit                   : meins;

      UserEmail              : abap.char(241); // ADD BY XINLEI XU 2025/03/19
}
