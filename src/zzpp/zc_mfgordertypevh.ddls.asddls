@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Manufacturing Order Type Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel: {
  dataCategory : #VALUE_HELP,
  usageType: {
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
    } }
@Search.searchable: true
define view entity ZC_MfgOrderTypeVH
  as select from I_MfgOrderTypeText
{
      @Search.defaultSearchElement: true
  key ManufacturingOrderType,
      ManufacturingOrderTypeName
}
where
  Language = $session.system_language;
