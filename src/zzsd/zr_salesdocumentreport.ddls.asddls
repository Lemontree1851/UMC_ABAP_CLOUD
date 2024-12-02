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
      @UI                            : { lineItem: [ { position: 10 } ],
                                          selectionField: [ { position: 10 } ] }
  key SalesOrganization              : abap.char(4);
      @UI                            : { lineItem: [ { position: 20 } ],
                                          selectionField: [ { position: 20 } ] }
  key Customer                       : abap.char(10);
      @UI                            : { lineItem: [ { position: 30 } ],
                                          selectionField: [ { position: 30 } ] }
  key YearDate                       : abap.char(6);
      @UI                            : { lineItem: [ { position: 40 } ],
                                          selectionField: [ { position: 40 } ] }
  key Product                        : abap.char(40);
      @UI                            : { lineItem: [ { position: 50 } ],
                                          selectionField: [ { position: 50 } ] }
  key plantype                       : abap.char(10);
      CustomerName                   : abap.numc(80);
      ProfitCenter                   : abap.char(10);
      PlantName                      : abap.char(30);
      SalesOffice                    : abap.char(4);
      SalesGroup                     : abap.char(3);
      CreatedByUser                  : abap.char(12);
      MatlAccountAssignmentGroup     : abap.char(2);
      ProductGroup                   : abap.char(9);
      ProductName                    : abap.char(40);
      ConditionRateValue             : abap.char(10);
      MaterialCost2000               : abap.char(10);
      Manufacturingcost              : abap.char(10);
      SalesAmount                    : abap.char(20);
      ContributionProfit             : abap.char(20);
      GrossProfit                    : abap.char(20);
      ContributionProfitTotal        : abap.char(20);
      GrossProfitTotal               : abap.char(20);
      salesplanamountindspcrcy       : abap.char(20);
      CustomerAccountAssignmentGroup : abap.char(14);
      FirstSalesSpecProductGroup     : abap.char(3);
      SecondSalesSpecProductGroup    : abap.char(3);
      ThirdSalesSpecProductGroup     : abap.char(3);
      AccountDetnProductGroup        : abap.char(3);
      
      
      ConditionRateValue01           : abap.char(10);
      ConditionRateValue02           : abap.char(10);
      ConditionRateValue03           : abap.char(10);
      ConditionRateValue04           : abap.char(10);
      ConditionRateValue05           : abap.char(10);
      ConditionRateValue06           : abap.char(10);
      ConditionRateValue07           : abap.char(10);
      ConditionRateValue08           : abap.char(10);
      ConditionRateValue09           : abap.char(10);
      ConditionRateValue10           : abap.char(10);
      ConditionRateValue11           : abap.char(10);
      ConditionRateValue12           : abap.char(10);
      
      salesplanamountindspcrcy01     : abap.char(20);
      salesplanamountindspcrcy02     : abap.char(20);
      salesplanamountindspcrcy03     : abap.char(20);
      salesplanamountindspcrcy04     : abap.char(20);
      salesplanamountindspcrcy05     : abap.char(20);
      salesplanamountindspcrcy06     : abap.char(20);
      salesplanamountindspcrcy07     : abap.char(20);
      salesplanamountindspcrcy08     : abap.char(20);
      salesplanamountindspcrcy09     : abap.char(20);
      salesplanamountindspcrcy10     : abap.char(20);
      salesplanamountindspcrcy11     : abap.char(20);
      salesplanamountindspcrcy12     : abap.char(20);
      
      SalesAmount01                  : abap.char(20);
      SalesAmount02                  : abap.char(20);
      SalesAmount03                  : abap.char(20);
      SalesAmount04                  : abap.char(20);
      SalesAmount05                  : abap.char(20);
      SalesAmount06                  : abap.char(20);
      SalesAmount07                  : abap.char(20);
      SalesAmount08                  : abap.char(20);
      SalesAmount09                  : abap.char(20);
      SalesAmount10                  : abap.char(20);
      SalesAmount11                  : abap.char(20);
      SalesAmount12                  : abap.char(20);
      
      ContributionProfitTotal01      : abap.char(20);
      ContributionProfitTotal02      : abap.char(20);
      ContributionProfitTotal03      : abap.char(20);
      ContributionProfitTotal04      : abap.char(20);
      ContributionProfitTotal05      : abap.char(20);
      ContributionProfitTotal06      : abap.char(20);
      ContributionProfitTotal07      : abap.char(20);
      ContributionProfitTotal08      : abap.char(20);
      ContributionProfitTotal09      : abap.char(20);
      ContributionProfitTotal10      : abap.char(20);
      ContributionProfitTotal11      : abap.char(20);
      ContributionProfitTotal12      : abap.char(20);
      
      GrossProfitTotal01             : abap.char(20);
      GrossProfitTotal02             : abap.char(20);
      GrossProfitTotal03             : abap.char(20);
      GrossProfitTotal04             : abap.char(20);
      GrossProfitTotal05             : abap.char(20);
      GrossProfitTotal06             : abap.char(20);
      GrossProfitTotal07             : abap.char(20);
      GrossProfitTotal08             : abap.char(20);
      GrossProfitTotal09             : abap.char(20);
      GrossProfitTotal10             : abap.char(20);
      GrossProfitTotal11             : abap.char(20);
      GrossProfitTotal12             : abap.char(20);

}
