@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '先々在庫推移分析'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI005_REPORT
  provider contract transactional_query
  as projection on ZI_BI005_REPORT
{
      @UI                            : {
      selectionField                 : [ { position: 2 } ],
      lineItem                       : [ { position: 50 } ] }
      @EndUserText: { label:  '予測年月', quickInfo: '予測年月' }
  key YearMonth,
      @UI                            : {
      lineItem                       : [ { position: 20 } ] }
      @EndUserText: { label:  'タイプ', quickInfo: 'タイプ' }
  key Type,
      @UI                            : {
      selectionField                 : [ { position: 1 } ],
      lineItem                       : [ { position: 10 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' } }]
      @EndUserText: { label:  '会社コード', quickInfo: '会社コード' }
  key Companycode,
      @UI                            : {
      selectionField                 : [ { position: 5 } ],
      lineItem                       : [ { position: 100 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_PlantStdVH', element: 'Plant' } }]
      @EndUserText: { label:  'プラント', quickInfo: 'プラント' }
  key Plant,
      @UI                            : {
      selectionField                 : [ { position: 3 } ],
      lineItem                       : [ { position: 80 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_ProductStdVH', element: 'Product' } }]
      @EndUserText: { label:  '品番', quickInfo: '品番' }
  key Product,
      @UI                            : {
      selectionField                 : [ { position: 4 } ],
      lineItem                       : [ { position: 120 } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_BusinessPartnerVH', element: 'BusinessPartner' } }]
      @EndUserText: { label:  '得意先', quickInfo: '得意先' }
  key Customer,
      @EndUserText: { label:  '会社コードテキスト', quickInfo: '会社コードテキスト' }
      CompanycodeText,
      @EndUserText: { label:  'プラントテキスト', quickInfo: 'プラントテキスト' }
      PlantText,
      @UI                            : {
      lineItem                       : [ { position: 90 } ] }
      @EndUserText: { label:  '品番テキスト', quickInfo: '品番テキスト' }
      ProductDescription,
      @UI                            : {
      lineItem                       : [ { position: 60 } ] }
      @EndUserText: { label:  '品目タイプ', quickInfo: '品目タイプ' }
      MaterialType,
      @UI                            : {
      lineItem                       : [ { position: 70 } ] }
      @EndUserText: { label:  '品目タイプテキスト', quickInfo: '品目タイプテキスト' }
      MaterialTypeText,
      @UI                            : {
      lineItem                       : [ { position: 130 } ] }
      @EndUserText: { label:  '得意先テキスト', quickInfo: '得意先テキスト' }
      CustomerText,
      @UI                            : {
      lineItem                       : [ { position: 140 } ] }
      @EndUserText: { label:  'Balance（期首）', quickInfo: 'Balance（期首）' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      BalanceOpenning,
      @UI                            : {
      lineItem                       : [ { position: 150 } ] }
      @EndUserText: { label:  'Supply', quickInfo: 'Supply' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Supply,
      @UI                            : {
      lineItem                       : [ { position: 160 } ] }
      @EndUserText: { label:  'Demand', quickInfo: 'Demand' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Demand,
      @UI                            : {
      lineItem                       : [ { position: 179 } ] }
      @EndUserText: { label:  'Balance（期末）', quickInfo: 'Balance（期末）' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      BalanceClosing,
      @UI                            : {
      lineItem                       : [ { position: 180 } ] }
      @EndUserText: { label:  '数量単位', quickInfo: '数量単位' }
      Unit,
      @UI                            : {
      lineItem                       : [ { position: 190 } ] }
      @EndUserText: { label:  '標準原価', quickInfo: '標準原価' }
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      StandardPrice,
      @UI                            : {
      lineItem                       : [ { position: 200 } ] }
      @EndUserText: { label:  '実際原価', quickInfo: '実際原価' }
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ActualPrice,
      @UI                            : {
      lineItem                       : [ { position: 210 } ] }
      @EndUserText: { label:  '期末在庫金額', quickInfo: '期末在庫金額' }
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ClosingInventoryTotal,
      @UI                            : {
      lineItem                       : [ { position: 220 } ] }
      @EndUserText: { label:  '通貨', quickInfo: '通貨' }
      CompanyCodeCurrency
}
