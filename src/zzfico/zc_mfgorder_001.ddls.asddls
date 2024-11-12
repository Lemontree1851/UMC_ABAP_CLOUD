@EndUserText.label: 'Query CDS'

@ObjectModel: {
    query: {
        implementedBy: 'ABAP:ZCL_MFGORDER_001'
    }
}

@UI.headerInfo:{
   typeName: 'Items',
   typeNamePlural: 'Items'
}
define root custom entity ZC_MFGORDER_001
{
      @UI                       : {
      lineItem                  : [ { position: 10, label: '年月' } ] }
      @EndUserText.label        : '年月'
  key YearMonth                 : abap.char(7);
      @UI                       : {
        selectionField          : [ { position: 1 } ],
        lineItem                : [ { position: 20, label: '会社コード' } ]
      }
      @Consumption.valueHelpDefinition: [{entity:{ name: 'I_CompanyCodeStdVH', element: 'CompanyCode'} }]
      @EndUserText.label        : '会社コード'
  key Companycode               : abap.char(4);
      @UI                       : {
      selectionField            : [ { position: 2 } ],
      lineItem                  : [ { position: 30, label: 'プラント' } ] }
      //@Consumption.valueHelpDefinition: [{entity:{ name: 'I_PlantStdVH', element: 'Plant'} }]
      @Consumption.valueHelpDefinition: [{ entity:  { name:'I_PlantStdVH', element: 'Plant' }}]
      @EndUserText.label        : 'プラント'
  key Plant                     : abap.char(4);
      @UI                       : {
      lineItem                  : [ { position: 50, label: '製品' } ] }
      @EndUserText.label        : '製品'
  key Product                   : abap.char(40);
      @UI                       : {
      lineItem                  : [ { position: 80, label: '得意先' } ] }
      @EndUserText.label        : '得意先'
  key BusinessPartner           : abap.char(10);
      @UI                       : {
      lineItem                  : [ { position: 100, label: '利益センタ' } ] }
      @EndUserText.label        : '利益センタ'
  key ProfitCenter              : abap.char(10);
      @UI                       : {
      lineItem                  : [ { position: 120, label: '原価センタ' } ] }
      @EndUserText.label        : '原価センタ'
  key CostCenter                : abap.char(10);
      @UI                       : {
      lineItem                  : [ { position: 140, label: '活動タイプ' } ] }
      @EndUserText.label        : '活動タイプ'
  key ActivityType              : abap.char(6);
        @EndUserText.label        : 'OrderID'
 key      orderid: abap.char(10);
      @UI                       : {
        lineItem                : [ { position: 20, label: '会社コードテキスト' } ] }
      @EndUserText.label        : '会社コードテキスト'
      CompanycodeText           : abap.char(25);

      @UI                       : {
      lineItem                  : [ { position: 40, label: 'プラントテキスト' } ] }
      @EndUserText.label        : 'プラントテキスト'
      PlantText                 : abap.char(30);

      @UI                       : {
      lineItem                  : [ { position: 60, label: '製品テキスト' } ] }
      @EndUserText.label        : '製品テキスト'
      ProductDescription        : abap.char(40);
      @UI                       : {
      lineItem                  : [ { position: 70, label: '入庫数量' } ] }
      @EndUserText.label        : '入庫数量'
      @Semantics.quantity.unitOfMeasure: 'ProductionUnit'
      MfgOrderConfirmedYieldQty : abap.quan( 23, 3 );
      ProductionUnit:meins;
      @UI                       : {
      lineItem                  : [ { position: 90, label: '得意先テキスト' } ] }
      @EndUserText.label        : '得意先テキスト'
      BusinessPartnerName       : abap.char(35);

      @UI                       : {
      lineItem                  : [ { position: 110, label: '利益センタテキスト' } ] }
      @EndUserText.label        : '利益センタテキスト'
      ProfitCenterLongName      : abap.char(40);

      @UI                       : {
      lineItem                  : [ { position: 130, label: '原価センタテキスト' } ] }
      @EndUserText.label        : '原価センタテキスト'
      CostCenterDescription     : abap.char(40);

      @UI                       : {
      lineItem                  : [ { position: 150, label: '活動タイプテキスト' } ] }
      @EndUserText.label        : '活動タイプテキスト'
      CostCtrActivityTypeName   : abap.char(20);
      @UI                       : {
      lineItem                  : [ { position: 160, label: '部署（工程）' } ] }
      @EndUserText.label        : '部署（工程）'
      Department                : abap.char(12);
      @UI                       : {
      lineItem                  : [ { position: 165, label: '製造責任者（工程情報）' } ] }
      @EndUserText.label        : '製造責任者（工程情報）'
      ProductionSupervisor      : abap.char(20);
      @UI                       : {
      lineItem                  : [ { position: 170, label: '計画工数' } ] }
      @EndUserText.label        : '計画工数'
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      PlanQtyInCostSourceUnit   : abap.quan( 23, 3 );
      @UI                       : {
      lineItem                  : [ { position: 180, label: '実績工数' } ] }
      @EndUserText.label        : '実績工数'
      @Semantics.quantity.unitOfMeasure: 'UnitOfMeasure'
      ActualQtyInCostSourceUnit : abap.quan( 23, 3 );
      @UI                       : {
      lineItem                  : [ { position: 190, label: '工数単位' } ] }
      @EndUserText.label        : '工数単位'
      UnitOfMeasure             : meinh;
      @UI                       : {
      lineItem                  : [ { position: 200, label: '計画賃率' } ] }
      @EndUserText.label        : '計画賃率'
      @Semantics.amount.currencyCode : 'Currency1'
      PlanCostRate              : abap.curr(16,2);
      @UI                       : {
      lineItem                  : [ { position: 210, label: '実際賃率' } ] }
      @EndUserText.label        : '実際賃率'
       @Semantics.amount.currencyCode : 'Currency2'
      ActualCostRate            : abap.curr(16,2);
      Currency1:waerk;
      Currency2:waerk;
      CostRateScaleFactor1:abap.dec(5);
      CostRateScaleFactor2:abap.dec(5);
      @UI                       : {
      lineItem                  : [ { position: 220, label: '加工費実績合計' } ] }
      @EndUserText.label        : '加工費実績合計'
      @Semantics.amount.currencyCode : 'Currency2'
      TotalActualCost           : abap.curr(20,2);
      @UI                       : {
      lineItem                  : [ { position: 230, label: '加工費実績（1単位）' } ] }
      @EndUserText.label        : '加工費実績（1単位）'
      @Semantics.amount.currencyCode : 'Currency2'
      ActualCost1PC             : abap.curr(20,2);
      @UI                       : {
      selectionField            : [ { position: 3 } ] }
      @Consumption.filter       : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label        : '会計年度'
      calendaryear              : calendaryear;
      @UI                       : {
      selectionField            : [ { position: 4 } ] }
      @Consumption.filter       : {selectionType: #SINGLE, multipleSelections: false, mandatory: true }
      @EndUserText.label        : '会計期間'
      calendarMonth             : calendarmonth;

      @EndUserText.label        : '構成品目'
      producedproduct: abap.char(40);


}
