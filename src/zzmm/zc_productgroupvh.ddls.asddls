@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'ProductGroup'
@ObjectModel.modelingPattern: #VALUE_HELP_PROVIDER
@ObjectModel.supportedCapabilities: [ #CDS_MODELING_DATA_SOURCE, #CDS_MODELING_ASSOCIATION_TARGET, #VALUE_HELP_PROVIDER ]
@ObjectModel.usageType.dataClass: #ORGANIZATIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #L

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Material Group Search Help'

define view entity ZC_PRODUCTGROUPVH
  as select from I_ProductGroup_2 as MaterialGroup
  association [0..*] to I_ProductGroupText_2 as _Text on $projection.ProductGroup = _Text.ProductGroup
                                                      and _Text.Language = $session.system_language

{
      @EndUserText.label: '{@i18n>MaterialGroup}'
      @ObjectModel.text.element:  [ 'ProductGroupName' ]
      @Search: { defaultSearchElement: true, ranking: #HIGH }
  key MaterialGroup.ProductGroup,

      @EndUserText.label: '{@i18n>MaterialGroupName}'
      @Search: { defaultSearchElement: true, ranking: #LOW, fuzzinessThreshold: 0.7 }
      _Text.ProductGroupName


}
