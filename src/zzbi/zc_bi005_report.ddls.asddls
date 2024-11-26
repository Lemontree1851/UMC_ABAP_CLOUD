@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '先々在庫推移分析'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_BI005_REPORT
  provider contract transactional_query
  as projection on ZI_BI005_REPORT
{
      @EndUserText: { label:  '会計年月', quickInfo: '会計年月' }
  key YearMonth,
      @EndUserText: { label:  'タイプ', quickInfo: 'タイプ' }
  key Type,
      @EndUserText: { label:  '会社コード', quickInfo: '会社コード' }
      @ObjectModel.text.element: [ 'CompanycodeText' ]
  key Companycode,
      @EndUserText: { label:  'プラント', quickInfo: 'プラント' }
      @ObjectModel.text.element: [ 'PlantText' ]
  key Plant,
      @EndUserText: { label:  '製品', quickInfo: '製品' }
      @ObjectModel.text.element: [ 'ProductDescription' ]
  key Product,
      @EndUserText: { label:  '得意先', quickInfo: '得意先' }
      @ObjectModel.text.element: [ 'CustomerText' ]
  key Customer,
      @EndUserText: { label:  '会社コードテキスト', quickInfo: '会社コードテキスト' }
      CompanycodeText,
      @EndUserText: { label:  'プラントテキスト', quickInfo: 'プラントテキスト' }
      PlantText,
      @EndUserText: { label:  '製品テキスト', quickInfo: '製品テキスト' }
      ProductDescription,
      @EndUserText: { label:  '品目タイプ', quickInfo: '品目タイプ' }
      @ObjectModel.text.element: [ 'MaterialTypeText' ]
      MaterialType,
      @EndUserText: { label:  '品目タイプテキスト', quickInfo: '品目タイプテキスト' }
      MaterialTypeText,
      @EndUserText: { label:  '得意先テキスト', quickInfo: '得意先テキスト' }
      CustomerText,
      @EndUserText: { label:  'Balance（期首）', quickInfo: 'Balance（期首）' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      BalanceOpenning,
      @EndUserText: { label:  'Supply', quickInfo: 'Supply' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Supply,
      @EndUserText: { label:  'Demand', quickInfo: 'Demand' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Demand,
      @EndUserText: { label:  'Balance（期末）', quickInfo: 'Balance（期末）' }
      @Semantics.quantity.unitOfMeasure: 'Unit'
      BalanceClosing,
      @EndUserText: { label:  '数量単位', quickInfo: '数量単位' }
      Unit,
      @EndUserText: { label:  '標準原価', quickInfo: '標準原価' }
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      StandardPrice,
      @EndUserText: { label:  '実際原価', quickInfo: '実際原価' }
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ActualPrice,
      @EndUserText: { label:  '期末在庫金額', quickInfo: '期末在庫金額' }
      @Semantics.amount.currencyCode: 'CompanyCodeCurrency'
      ClosingInventoryTotal,
      @EndUserText: { label:  '通貨', quickInfo: '通貨' }
      CompanyCodeCurrency
}
