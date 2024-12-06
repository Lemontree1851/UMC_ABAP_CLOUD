@EndUserText.label: '有償支給品の純額計算'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_PAIDPAYCALCULATION'
    }
}


define root custom entity ZR_PAIDPAYCALCULATION
{
      @UI                 : { lineItem: [ { position: 10 } ],
                                             selectionField: [ { position: 1 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
  key CompanyCode         : bukrs; //会社コード
      @UI                 : { lineItem: [ { position: 20 } ],
                                             selectionField: [ { position: 2 } ] }
  key FiscalYear          : gjahr; //会計年度
      @UI                 : { lineItem: [ { position: 30 } ],
                                             selectionField: [ { position: 3 } ] }
  key Period              : monat; //会計期間
          @UI                 : { lineItem: [ { position: 40 } ] }
  key Customer            : kunnr; //得意先コード
      @UI                 : { lineItem: [ { position: 50 } ] }
  key Supplier            : lifnr; //仕入先コード
  key Product             : matnr; //有償支給品番
  key ProfitCenter        : prctr; //利益センタ
  key PurchasingGroup     : ekgrp; //購買グループ
  key UpperProduct01      : matnr; //上位品番
  key ValuationClass01    : bklas; //評価クラス
  key UpperProduct02      : matnr;
  key ValuationClass02    : bklas;
  key UpperProduct03      : matnr;
  key ValuationClass03    : bklas;
  key UpperProduct04      : matnr;
  key ValuationClass04    : bklas;
  key UpperProduct05      : matnr;
  key ValuationClass05    : bklas;
  key UpperProduct06      : matnr;
  key ValuationClass06    : bklas;
  key UpperProduct07      : matnr;
  key ValuationClass07    : bklas;
  key UpperProduct08      : matnr;
  key ValuationClass08    : bklas;
  key UpperProduct09      : matnr;
  key ValuationClass09    : bklas;
  key UpperProduct10      : matnr;
  key ValuationClass10    : bklas;
  @UI                 : { lineItem: [ { position: 60 } ],
                                             selectionField: [ { position: 4 } ] }
  key Ledge               : abap.char(2);
      Ztype               : abap.char(1); //A:品番別; B:購買グルー合計
  
      CustomerName        : abap.char(80); //得意先名称
      SupplierName        : abap.char(80); //仕入先名称
      ProfitCenterName    : ktext; //利益センタテキスト
      ProductDescription  : maktx; //有償支給品番テキスト
      @Semantics.amount.currencyCode : 'Currency'
      Cost01              : abap.curr(16,2); //標準原価-材料費
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity01 : abap.quan(23,3);  //库存数量
      @Semantics.amount.currencyCode : 'Currency'
      Cost02              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity02 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost03              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity03 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost04              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity04 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost05              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity05 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost06              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity06 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost07              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity07 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost08              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity08 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost09              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity09 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      Cost10              : abap.curr(16,2);
      @Semantics.quantity.unitOfMeasure : 'Unit'
      ValuationQuantity10 : abap.quan(23,3);
      @Semantics.amount.currencyCode : 'Currency'
      MaterialCost2000    : abap.curr(16,2); //標準原価-材料費合計-2000
      @Semantics.amount.currencyCode : 'Currency'
      MaterialCost3000    : abap.curr(16,2); //標準原価-材料費合計-3000

      //品番別&購買グルー合計 共用
      @Semantics.amount.currencyCode : 'Currency'
      PurGrpAmount1       : abap.curr(16,2); //当期購買グループ別仕入金額期初
      @Semantics.amount.currencyCode : 'Currency'
      PurGrpAmount2       : abap.curr(16,2); //当期購買グループ別仕入金額本年初-上个月末
      @Semantics.amount.currencyCode : 'Currency'
      PurGrpAmount        : abap.curr(16,2); //当期購買グループ別仕入金額当前期间
      @Semantics.amount.currencyCode : 'Currency'
      ChargeableAmount1   : abap.curr(16,2); //当期有償支給品仕入金額-期初
      @Semantics.amount.currencyCode : 'Currency'
      ChargeableAmount2   : abap.curr(16,2); //当期有償支給品仕入金額本年初-上个月末
      @Semantics.amount.currencyCode : 'Currency'
      ChargeableAmount    : abap.curr(16,2); //当期有償支給品仕入金額当前期间
      @Semantics.amount.currencyCode : 'Currency'
      PreviousStockAmount : abap.curr(16,2); //在庫金額（前期末）
      @Semantics.amount.currencyCode : 'Currency'
      CurrentStockAmount  : abap.curr(16,2); //在庫金額（当期末）-有償支給品
      @Semantics.amount.currencyCode : 'Currency'
      CustomerRevenue1    : abap.curr(16,2); //該当得意先の総売上高期初
      @Semantics.amount.currencyCode : 'Currency'
      CustomerRevenue     : abap.curr(16,2); //該当得意先の総売上高
      @Semantics.amount.currencyCode : 'Currency'
      Revenue1            : abap.curr(16,2); //会社レベルの総売上高期初
      @Semantics.amount.currencyCode : 'Currency'
      Revenue             : abap.curr(16,2); //会社レベルの総売上高

      //購買グルー合計
      ChargeableRate      : abap.dec(9,5); //当期仕入率
      @Semantics.amount.currencyCode : 'currency'
      CurrentStockSemi    : abap.curr(16,2); //在庫金額（当期末）-半製品
      @Semantics.amount.currencyCode : 'currency'
      CurrentStockFin     : abap.curr(16,2); //在庫金額（当期末）-製品
      @Semantics.amount.currencyCode : 'currency'
      CurrentStockTotal   : abap.curr(16,2); //在庫金額（当期末）-合計
      @Semantics.amount.currencyCode : 'currency'
      StockChangeAmount   : abap.curr(16,2); //在庫増減金額
      @Semantics.amount.currencyCode : 'currency'
      PaidMaterialCost    : abap.curr(16,2); //払いだし材料費
      RevenueRate         : abap.dec(9,5); //"総売上金額占有率

      Currency            : abap.cuky;
      Unit                : meins;

}
