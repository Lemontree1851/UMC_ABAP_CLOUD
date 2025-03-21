@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.modelingPattern: #NONE
@ObjectModel.representativeKey: 'PlannedOrder'
@ObjectModel.supportedCapabilities: [#VALUE_HELP_PROVIDER, #SEARCHABLE_ENTITY]
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #L
@ObjectModel.usageType.dataClass: #TRANSACTIONAL

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Search.searchable: true
@Consumption.ranked: true

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Value help for Planned Order PRIVILEGED'
define view entity ZC_PlannedOrderVH
  as select from I_PlannedOrder
{
      @Search.defaultSearchElement: true
      @Search.ranking: #HIGH
      @Search.fuzzinessThreshold: 0.8
  key PlannedOrder,

      @Consumption.hidden: true
      MRPController,
      @Consumption.hidden: true
      MRPPlant
};
