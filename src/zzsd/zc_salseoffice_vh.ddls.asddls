@VDM.viewType: #COMPOSITE
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'SalesOffice'
@ObjectModel.modelingPattern: #VALUE_HELP_PROVIDER
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_DATA_SOURCE, #CDS_MODELING_ASSOCIATION_TARGET, #VALUE_HELP_PROVIDER ]
@ObjectModel.usageType.dataClass: #ORGANIZATIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #L

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'SalesOffice Value Help'
define view entity ZC_SALSEOFFICE_VH
  as select distinct from I_SalesOfficeText                                        
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @UI.lineItem: [{importance: #HIGH, position: 10}]
  key SalesOffice,
  SalesOfficeName
}where Language = $session.system_language
