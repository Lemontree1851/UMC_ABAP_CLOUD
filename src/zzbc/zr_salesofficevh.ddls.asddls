@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value help for SalesOffice'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
  serviceQuality: #X,
  sizeCategory: #S,
  dataClass: #MIXED
}
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZR_SalesOfficeVH as select from I_SalesOfficeText
{
  @ObjectModel.text.element: [ 'SalesOfficeName' ]
  key SalesOffice,
  @Semantics.text: true
  SalesOfficeName
}
where Language = $session.system_language
