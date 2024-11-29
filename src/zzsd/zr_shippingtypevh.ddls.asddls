@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for ShippingType'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
@Consumption.ranked: true
define view entity ZR_ShippingTypeVH
  as select from I_ShippingTypeText
{
  @ObjectModel.text.element: ['ShippingTypeName']
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key ShippingType,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      ShippingTypeName
}
where Language = $session.system_language
