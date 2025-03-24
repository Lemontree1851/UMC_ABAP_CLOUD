@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'DeliveryDocument'

@ObjectModel.usageType.dataClass: #TRANSACTIONAL
@ObjectModel.usageType.serviceQuality: #B
@ObjectModel.usageType.sizeCategory: #L

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Value help for Delivery Document PRIVILEGED'

@Search.searchable: true
@Consumption.ranked: true

@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER, #SEARCHABLE_ENTITY ]
define view entity ZC_DeliveryDocumentVH
  as select from I_DeliveryDocument
{

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key DeliveryDocument,

      @Consumption.hidden: true
      ShippingPoint
}
