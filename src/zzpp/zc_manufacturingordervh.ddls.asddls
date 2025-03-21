@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'ManufacturingOrder'

@ObjectModel.usageType.dataClass: #TRANSACTIONAL
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #L

@ObjectModel.supportedCapabilities: [ #SEARCHABLE_ENTITY, #VALUE_HELP_PROVIDER ]

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true

@Metadata.ignorePropagatedAnnotations: true
@EndUserText.label: 'Value help for Manufacturing Order PRIVILEGED'
define view entity ZC_ManufacturingOrderVH
  as select from I_ManufacturingOrder
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
  key ManufacturingOrder,
      ManufacturingOrderText
}
