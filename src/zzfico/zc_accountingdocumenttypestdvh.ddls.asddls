@VDM.viewType: #COMPOSITE
@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'AccountingDocumentType'
@ObjectModel.modelingPattern: #VALUE_HELP_PROVIDER
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_DATA_SOURCE, #CDS_MODELING_ASSOCIATION_TARGET, #VALUE_HELP_PROVIDER ]
@ObjectModel.usageType.dataClass: #ORGANIZATIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #L

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'AccountingDocumentTypeStdVH'
define view entity ZC_AccountingDocumentTypeStdVH
  as select distinct from I_AccountingDocumentTypeText                                           
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @UI.lineItem: [{importance: #HIGH, position: 10}]
  key AccountingDocumentType,
  AccountingDocumentTypeName
}where Language = 'J'
