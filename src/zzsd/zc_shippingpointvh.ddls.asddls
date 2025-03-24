@VDM.viewType: #COMPOSITE

@ObjectModel.dataCategory: #VALUE_HELP
@ObjectModel.representativeKey: 'ShippingPoint'

@ObjectModel.usageType.dataClass: #ORGANIZATIONAL
@ObjectModel.usageType.serviceQuality: #A
@ObjectModel.usageType.sizeCategory: #S

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Metadata.ignorePropagatedAnnotations: true

@ObjectModel.supportedCapabilities: [ #VALUE_HELP_PROVIDER ]

@EndUserText.label: 'Value help for Shipping Point PRIVILEGED'

@Search.searchable: true
@Consumption.ranked: true

define view entity ZC_ShippingPointVH
  as select from I_ShippingPoint
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key ShippingPoint,

      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #LOW
      _Text[1: Language=$session.system_language].ShippingPointName as ShippingPointName
}
where
  ConfigDeprecationCode <> 'E';
