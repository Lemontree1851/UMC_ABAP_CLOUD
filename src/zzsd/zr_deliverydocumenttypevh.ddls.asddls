@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for DeliveryDocumentType'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@ObjectModel.dataCategory: #VALUE_HELP
@Search.searchable: true
@Consumption.ranked: true
define view entity ZR_DeliveryDocumentTypeVH
  as select from I_DeliveryDocumentTypeText
{
  @ObjectModel.text.element: ['DeliveryDocumentTypeName']
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key DeliveryDocumentType,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Semantics.text: true
      DeliveryDocumentTypeName
}
where Language = $session.system_language
