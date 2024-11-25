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
      @UI                           : { lineItem: [ { position: 10 } ],
                                         selectionField: [ { position: 10 } ] }
  key SalesOrganization             : abap.char(4);
      @UI                           : { lineItem: [ { position: 20 } ],
                                         selectionField: [ { position: 20 } ] }
  key Customer                      : abap.char(10);
      @UI                           : { lineItem: [ { position: 30 } ],
                                         selectionField: [ { position: 30 } ] }
  key YearDate                      : abap.char(6);
      @UI                           : { lineItem: [ { position: 40 } ],
                                         selectionField: [ { position: 40 } ] }
  key Product                       : abap.char(40);
//      @UI                           : { lineItem: [ { position: 50 } ],
//                                         selectionField: [ { position: 50 } ] }
  key plantype                      : abap.char(10);
      CustomerName                  : abap.numc(80);
      ProfitCenter                  : abap.char(10);
      PlantName                     : abap.char(30);
      SalesOffice                   : abap.char(4);
      SalesGroup                    : abap.char(3);
      CreatedByUser                 : abap.char(12);
      MatlAccountAssignmentGroup    : abap.char(2);
      ProductGroup                  : abap.char(9);
      ProductName                   : abap.char(40);
      ConditionRateValue            : abap.char(10);
      MaterialCost2000              : abap.char(10);
      Manufacturingcost             : abap.char(10);
      SalesAmount                   : abap.char(20);
      ContributionProfit            : abap.char(20);
      GrossProfit                   : abap.char(20);
      ContributionProfitTotal       : abap.char(20);
      GrossProfitTotal              : abap.char(20);
      salesplanamountindspcrcy      : abap.char(20);

}
