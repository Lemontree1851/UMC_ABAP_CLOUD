@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for SalesGroup'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@Search.searchable: true
define view entity ZR_SalesGroupVH as select from I_SalesGroupText
{
  @ObjectModel.text.element: [ 'SalesGroupName' ]
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  key SalesGroup,
  @Semantics.text: true
  @Search.defaultSearchElement: true
  @Search.fuzzinessThreshold: 0.8
  SalesGroupName
}
where Language = $session.system_language
