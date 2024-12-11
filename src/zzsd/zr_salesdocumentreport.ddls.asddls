@ObjectModel.query.implementedBy: 'ABAP:ZCL_SALESDOCUMENTREPORT'
@EndUserText.label: '販売計画一覧'
@UI: {
  headerInfo: {
    typeName: '販売計画一覧',
    typeNamePlural: '販売計画一覧',
    title: { type: #STANDARD, value: 'SalesOrganization' }
        } }

define root custom entity ZR_SALESDOCUMENTREPORT
{
      @Consumption.valueHelpDefinition:[{entity:{ name: 'I_SalesOrganization', element: 'SalesOrganization'} }]
  key SalesOrganization              : abap.char(4);
      @Consumption.valueHelpDefinition:[{entity:{ name: 'ZC_CustomerSalesAreaVH', element: 'Customer'} }]
  key Customer                       : abap.char(10);
  key ProfitCenter                   : abap.char(10);
  key SalesOffice                    : abap.char(4);
  key SalesGroup                     : abap.char(3);
      @Consumption                   : {valueHelpDefinition: [{ entity:{ element: 'Product', name: 'I_ProductStdVH'}}]  }
  key Product                        : abap.char(40);
  key CreatedByUser                  : abap.char(50);
      @UI                            : {
        selectionField               : [ { position: 60 } ]
      }
  key plantype                       : abap.char(10);
  key YearDate                       : abap.char(6);

      CustomerName                   : abap.char(80);
      PlantName                      : abap.char(30);
      MatlAccountAssignmentGroup     : abap.char(2);
      ProductGroup                   : abap.char(9);
      ProductName                    : abap.char(40);
      ConditionRateValue             : abap.char(10); //没用 等会删
      MaterialCost2000               : abap.char(10); //5
      Manufacturingcost              : abap.char(10); //6
      SalesAmount                    : abap.char(20); //没用 等会删
      ContributionProfit             : abap.char(20); //貢献利益(単価) buyaole shan
      GrossProfit                    : abap.char(20); //売上総利益(単価)buyaole shan
      ContributionProfitTotal        : abap.char(20); //没用 等会删
      GrossProfitTotal               : abap.char(20); //没用 等会删
      salesplanamountindspcrcy       : abap.char(20); //没用 等会删
      CustomerAccountAssignmentGroup : abap.char(14);
      FirstSalesSpecProductGroup     : abap.char(3);
      SecondSalesSpecProductGroup    : abap.char(3);
      ThirdSalesSpecProductGroup     : abap.char(3);
      AccountDetnProductGroup        : abap.char(3);

      SplitRange                     : char13;
       @Consumption.valueHelpDefinition:[{entity:{ name: 'I_CurrencyStdVH', element: 'Currency'} }]
      ConditionCurrency              : abap.cuky;

      ConditionRateValueUnit         : waers;
      SalesPlanUnit                  : meins;
      DisplayCurrency1               : waers;
      DisplayCurrency2               : waers;
      DisplayCurrency3               : waers;
      currency                       : abap.cuky;
      currency1                      : abap.cuky;

      @Semantics.amount.currencyCode : 'currency'
      materialcost2000_n             : abap.curr(15,2); //材料费
      @Semantics.amount.currencyCode : 'currency'
      materialcost2000per_n          : abap.curr(15,2); //材料费单价
      @Semantics.amount.currencyCode : 'currency1'
      Manufacturingcost_n            : abap.curr(20,2); //6
      @Semantics.amount.currencyCode : 'currency1'
      Manufacturingcostper_n         : abap.curr(20,2); //6

      @Semantics.amount.currencyCode : 'ConditionRateValueUnit'
      ConditionRateValue_n           : abap.curr(11,2); //单价
      @Semantics.quantity.unitOfMeasure: 'SalesPlanUnit'
      salesplanamountindspcrcy_n     : abap.quan(15,3); //QTY  SalesPlanQuantity
      @Semantics.amount.currencyCode : 'DisplayCurrency1'
      SalesAmount_n                  : abap.curr(20,2); //销售额
      @Semantics.amount.currencyCode : 'DisplayCurrency2'
      ContributionProfitTotal_n      : abap.curr(20,2); //贡献利润
      @Semantics.amount.currencyCode : 'DisplayCurrency3'
      GrossProfitTotal_n             : abap.curr(20,2); //销售总利润


}
