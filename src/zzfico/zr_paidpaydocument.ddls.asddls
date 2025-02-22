@EndUserText.label: 'PaidPay Journal Entry'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_PAIDPAYDOCUMENT'
    }
}
define root custom entity ZR_PAIDPAYDOCUMENT
{
  @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeStdVH', element: 'CompanyCode' } }]
  @UI                 : { lineItem: [ { position: 10 } ],
                                             selectionField: [ { position: 1 } ] }
  key CompanyCode         : bukrs; //会社コード
  @UI                 : { lineItem: [ { position: 20 } ],
                                             selectionField: [ { position: 2 } ] }
  key FiscalYear          : gjahr; //会計年度
  @UI                 : { lineItem: [ { position: 30 } ],
                                             selectionField: [ { position: 3 } ] }
  key Period              : monat; //会計期間
  key Customer            : kunnr; //得意先コード
  key Supplier            : lifnr; //仕入先コード
  key ProfitCenter        : prctr; //利益センタ
  key PurchasingGroup     : ekgrp; //購買グループ
      Ztype               : abap.char(1);  //売上仕入純額処理 ,買掛金/売掛金純額処理
      CustomerName        : abap.char(80); //得意先名称
      SupplierName        : abap.char(80); //仕入先名称
      ProfitCenterName    : ktext; //利益センタテキスト

      @Semantics.amount.currencyCode : 'Currency'
      PurGrpAmount        : abap.curr(16,2); //当期購買グループ別仕入金額
      @Semantics.amount.currencyCode : 'Currency'
      ChargeableAmount    : abap.curr(16,2); //当期有償支給品仕入金額
      ChargeableRate      : abap.dec(9,5); //当期仕入率
      @Semantics.amount.currencyCode : 'Currency'
      PreviousStockAmount : abap.curr(16,2); //在庫金額（前期末）
      @Semantics.amount.currencyCode : 'Currency'
      CurrentStockAmount  : abap.curr(16,2); //在庫金額（当期末）-有償支給品
      @Semantics.amount.currencyCode : 'Currency'
      CurrentStockSemi    : abap.curr(16,2); //在庫金額（当期末）-半製品
      @Semantics.amount.currencyCode : 'currency'
      CurrentStockFin     : abap.curr(16,2); //在庫金額（当期末）-製品
      @Semantics.amount.currencyCode : 'currency'
      CurrentStockTotal   : abap.curr(16,2); //在庫金額（当期末）-合計
      @Semantics.amount.currencyCode : 'currency'
      StockChangeAmount   : abap.curr(16,2); //在庫増減金額
      @Semantics.amount.currencyCode : 'currency'
      PaidMaterialCost    : abap.curr(16,2); //払いだし材料費
      @Semantics.amount.currencyCode : 'Currency'
      CustomerRevenue     : abap.curr(16,2); //該当得意先の総売上高
      @Semantics.amount.currencyCode : 'Currency'
      Revenue             : abap.curr(16,2); //会社レベルの総売上高
      RevenueRate         : abap.dec(9,5); //"総売上金額占有率
      AP                  : abap.char(23);  //買掛金金額
      AR                  : abap.char(23);  //売掛金金額
      Currency            : abap.cuky;

      //売上仕入仕訳生成
      Gjahr1              : abap.char(4);
      Belnr1              : belnr_d;
      Gjahr2              : abap.char(4);
      Belnr2              : belnr_d;
      Gjahr3              : abap.char(4);
      Belnr3              : belnr_d;
      Gjahr4              : abap.char(4);
      Belnr4              : belnr_d;
      //買掛金&売掛金仕訳生成
      Gjahr5              : abap.char(4);
      Belnr5              : belnr_d;
      Gjahr6              : abap.char(4);
      Belnr6              : belnr_d;
      Gjahr7              : abap.char(4);
      Belnr7              : belnr_d;
      Gjahr8              : abap.char(4);
      Belnr8              : belnr_d;
      
      Status              : abap.char(1);
      Message             : zze_zzkey;
}
