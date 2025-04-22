@ObjectModel.query.implementedBy: 'ABAP:ZCL_QUERY_SALESDOCUMENTREPORT'
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
  key YearDate                       : abap.char(14);  // 格式：年月_会计年月

      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'ZC_SalesPlanVersion0_VH', element: 'SalesPlanVersion'} }]
      SalesPlanVersion0              : sales_plan_version;
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'ZC_SalesPlanVersion1_VH', element: 'SalesPlanVersion'} }]
      SalesPlanVersion1              : sales_plan_version;
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'ZC_SalesPlanVersion2_VH', element: 'SalesPlanVersion'} }]
      SalesPlanVersion2              : sales_plan_version;
      @Consumption.filter            : {selectionType: #SINGLE, multipleSelections: false }
      @Consumption.valueHelpDefinition:[{entity:{ name: 'ZC_SalesPlanVersion3_VH', element: 'SalesPlanVersion'} }]
      SalesPlanVersion3              : sales_plan_version;

      CustomerName                   : abap.char(80);
      Plant                          : werks_d;       // ADD BY XINLEI XU 2025/02/17
      PlantName                      : abap.char(30);
      MatlAccountAssignmentGroup     : abap.char(10); // abap.char(2); MOD BY XINLEI XU 2025/02/19
      ProductGroup                   : abap.char(9);
      ProductName                    : abap.char(40);
      ConditionRateValue             : abap.char(10); //没用 等会删
      MaterialCost2000               : abap.char(10); //5 buyaole shan
      Manufacturingcost              : abap.char(10); //6 buyaole shan
      SalesAmount                    : abap.char(20); //没用 等会删
      ContributionProfit             : abap.char(20); //貢献利益(単価) buyaole shan
      GrossProfit                    : abap.char(20); //売上総利益(単価)buyaole shan
      ContributionProfitTotal        : abap.char(20); //没用 等会删
      GrossProfitTotal               : abap.char(20); //没用 等会删
      salesplanamountindspcrcy       : abap.char(20); //没用 等会删
      CustomerAccountAssignmentGroup : abap.char(14);
      FirstSalesSpecProductGroup     : abap.char(30);
      SecondSalesSpecProductGroup    : abap.char(30);
      ThirdSalesSpecProductGroup     : abap.char(30);
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

      GLAccount1                     : hkont;
      GLAccount2                     : hkont;
      GLAccount3                     : hkont;
      GLAccountName1                 : abap.char(30);
      GLAccountName2                 : abap.char(30);
      GLAccountName3                 : abap.char(30);

      SalesPlanUnit_c                : abap.char(10);
      CompanyCode                    : bukrs;
      
      //MOD BEGIN BY XINLEI XU 2025/04/16 CR#4277
      //@Semantics.amount.currencyCode : 'currency'
      //materialcost2000_n             : abap.curr(15,2); //材料费
      //@Semantics.amount.currencyCode : 'currency'
      //materialcost2000per_n          : abap.curr(15,2); //贡献利润(单价)
      //@Semantics.amount.currencyCode : 'currency1'
      //Manufacturingcost_n            : abap.curr(20,2); //加工费
      //@Semantics.amount.currencyCode : 'currency1'
      //Manufacturingcostper_n         : abap.curr(20,2); //销售总利润(单价)
      materialcost2000_n             : abap.dec(15,2); //材料费
      materialcost2000per_n          : abap.dec(15,2); //贡献利润(单价)
      Manufacturingcost_n            : abap.dec(20,2); //加工费
      Manufacturingcostper_n         : abap.dec(20,2); //销售总利润(单价)
      //MOD END BY XINLEI XU 2025/04/16 CR#4277

      @Semantics.quantity.unitOfMeasure: 'SalesPlanUnit'
      salesplanamountindspcrcy_n     : abap.quan(15,3); //QTY  SalesPlanQuantity
      
      //MOD BEGIN BY XINLEI XU 2025/04/16 CR#4277
      //@Semantics.amount.currencyCode : 'ConditionRateValueUnit'
      //ConditionRateValue_n           : abap.curr(11,2); //单价
      //@Semantics.amount.currencyCode : 'DisplayCurrency1'
      //SalesAmount_n                  : abap.curr(20,2); //销售额
      //@Semantics.amount.currencyCode : 'DisplayCurrency2'
      //ContributionProfitTotal_n      : abap.curr(20,2); //贡献利润
      //@Semantics.amount.currencyCode : 'DisplayCurrency3'
      //GrossProfitTotal_n             : abap.curr(20,2); //销售总利润
      ConditionRateValue_n           : abap.dec(11,2); //单价
      SalesAmount_n                  : abap.dec(20,2); //销售额
      ContributionProfitTotal_n      : abap.dec(20,2); //贡献利润
      GrossProfitTotal_n             : abap.dec(20,2); //销售总利润
      //MOD END BY XINLEI XU 2025/04/16 CR#4277
}
