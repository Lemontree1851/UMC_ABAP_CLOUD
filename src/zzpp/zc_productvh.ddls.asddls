@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'Material',
  supportedCapabilities: [ #SQL_DATA_SOURCE,
                           #CDS_MODELING_DATA_SOURCE,
                           #CDS_MODELING_ASSOCIATION_TARGET,
                           #VALUE_HELP_PROVIDER,
                           #SEARCHABLE_ENTITY
  ],
  usageType:{
    serviceQuality: #A,
    sizeCategory: #L,
    dataClass: #MASTER
  }
}

@AccessControl.authorizationCheck: #NOT_REQUIRED

@Consumption.ranked: true
@Search.searchable: true
@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Product Value Help'
define view entity ZC_ProductVH
  as select from I_ProductPlantBasic
  association [0..1] to I_ProductDescription    as _Description on  $projection.Material  = _Description.Product
                                                                and _Description.Language = $session.system_language
  association [0..*] to I_ProductValuationBasic as _Valuation   on  $projection.Material = _Valuation.Product
                                                                and $projection.Plant    = _Valuation.ValuationArea
{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key Product                         as Material,
      @UI.hidden: true
  key Plant,
      _Description.ProductDescription as MaterialDescription,
      _Product.ProductType,
      @Semantics.amount.currencyCode: 'Currency'
      _Valuation.StandardPrice,
      _Valuation.PriceUnitQty,
      _Valuation.Currency,
      @UI.hidden: true
      _Valuation.ValuationArea,
      @UI.hidden: true
      BaseUnit
}
where
  IsMarkedForDeletion = ''
