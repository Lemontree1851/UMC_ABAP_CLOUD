@EndUserText.label: '有償支給純額導入'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_PAIDPAY_REPORT'
    }
}

define root custom entity ZR_PAIDPAY_REPORT
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
  key ProfitCenter        : prctr;
  key BusinessPartner     : abap.char(10);
  key PurchasingGroup     : ekgrp;
      Ztype               : abap.char(1); //A:有償支給品期首在庫金額; B:有償支給品期首仕入金額
      ProfitCenterName    : ktext;
      BusinessPartnerName : abap.char(80);
      PurchasingGroupName : eknam;
      @Semantics.amount.currencyCode : 'currency'
      PreStockAmt         : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      BegPurGrpAmt        : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      BegChgMaterialAmt   : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      BegCustomerRev      : abap.curr(15,2);
      @Semantics.amount.currencyCode : 'currency'
      BegRev              : abap.curr(15,2);
      Currency            : abap.cuky;


}
