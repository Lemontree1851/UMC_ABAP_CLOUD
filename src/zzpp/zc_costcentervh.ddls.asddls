@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'CostCenter'
@ObjectModel.modelingPattern: #VALUE_HELP_PROVIDER
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_DATA_SOURCE, #CDS_MODELING_ASSOCIATION_TARGET, #VALUE_HELP_PROVIDER ]
@ObjectModel.usageType.dataClass: #ORGANIZATIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #L

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Cost Center Value Help'
define view entity ZC_CostCenterVH
  as select distinct from I_CostCenter
  association [0..1] to I_CostCenterText as _Text on  $projection.ControllingArea = _Text.ControllingArea
                                                  and $projection.CostCenter      = _Text.CostCenter
                                                  and $projection.ValidityEndDate = _Text.ValidityEndDate
                                                  and _Text.Language              = $session.system_language
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
      @UI.lineItem: [{importance: #HIGH, position: 10}]
  key CostCenter,
      _Text.CostCenterName,
      ControllingArea,
      ValidityEndDate,
      ValidityStartDate,
      CompanyCode
}
