@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: '日別在庫推移'
define root view entity ZC_DAYSTOCKTRANS
  provider contract transactional_query
  as projection on ZR_DAYSTOCKTRANS
{
      @UI                            : {
      selectionField                 : [ { position: 1 } ],
      lineItem                       : [ { position: 10, label: '日付' } ] }
      @Consumption.filter: { selectionType: #INTERVAL, multipleSelections: false }
      @EndUserText.label: '日付'
  key ExcuDate,
      @UI                            : {
      selectionField                 : [ { position: 2 } ],
      lineItem                       : [ { position: 20, label: '会社コード' } ] }
      @Consumption.valueHelpDefinition: [{ entity: { name: 'I_CompanyCodeVH', element: 'CompanyCode' } }]
      @EndUserText.label: '会社コード'
  key CompanyCode,
      @UI                        : { lineItem: [ { position: 30, label: 'プラント' } ], selectionField: [ { position: 3 } ] }
      @Consumption.filter        : { selectionType: #SINGLE, multipleSelections: false }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'I_PlantStdVH', element: 'Plant' } } ]
      @EndUserText.label         : 'プラント'
  key Plant,
      @UI                        : { lineItem: [ { position: 40, label: '得意先BPコード' } ], selectionField: [ { position: 4 } ] }
      @Consumption.filter        : { selectionType: #SINGLE, multipleSelections: false }
      @Consumption.valueHelpDefinition: [ { entity: { name: 'ZC_BusinessPartnerVH', element: 'BusinessPartner' } } ]
      @EndUserText.label         : '得意先BPコード'
  key BusinessPartner,
      @UI                        : { lineItem: [ { position: 50, label: '得意先名' } ] }
      BusinessPartnerName,
      @UI                        : { lineItem: [ { position: 60, label: '製品' } ] }
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      FinishedGoods,
      @UI                        : { lineItem: [ { position: 70, label: '半製品' } ] }
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      SemiFinishedGoods,
      @UI                        : { lineItem: [ { position: 80, label: '原材料' } ] }
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      Material,
      @UI                        : { lineItem: [ { position: 90, label: '合計' } ] }
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      Total,
      @UI                        : { lineItem: [ { position: 100, label: '売上実績（先月）' } ] }
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      SaleActual,
      @UI                        : { lineItem: [ { position: 110, label: '売上予測（翌月）' } ] }
      @Semantics.amount.currencyCode: 'DisplayCurrency'
      Saleforcast,
      @UI                        : { lineItem: [ { position: 120, label: '通貨' } ] }
      DisplayCurrency
}
