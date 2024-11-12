@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
  representativeKey: 'ManufacturingOrder',
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

@EndUserText.label: 'Manufacturing Order Product Value Help'
define view entity ZC_ManufacturingOrderProductVH
  as select distinct from I_ManufacturingOrder         as _Order
    inner join            I_MfgOrderOperationComponent as _Component on _Component.ManufacturingOrder = _Order.ManufacturingOrder
  association [0..1] to I_MfgOrderWithStatus as _MfgOrderWithStatus on  $projection.ManufacturingOrder = _MfgOrderWithStatus.ManufacturingOrder
  association [0..1] to ZC_ProductVH         as _Product            on  $projection.Product         = _Product.Material
                                                                    and $projection.ProductionPlant = _Product.Plant
  association [0..1] to ZC_ProductVH         as _Material           on  $projection.Material        = _Material.Material
                                                                    and $projection.ProductionPlant = _Material.Plant
  association [0..1] to I_StorageLocation    as _StorageLocation    on  $projection.ProductionPlant = _StorageLocation.Plant
                                                                    and $projection.StorageLocation = _StorageLocation.StorageLocation

{
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @Search.ranking: #HIGH
  key _Order.ManufacturingOrder,
      @UI.hidden: true
  key _Component.ReservationItem   as Item,
  key _Order.ProductionPlant,
      _Order.Product,
      _Product.MaterialDescription as ProductDescription,
      _Component.Material,
      _Material.MaterialDescription,
      _Order.ManufacturingOrderType,

      _Component.StorageLocation,
      _StorageLocation.StorageLocationName,
      _Component.GoodsMovementType,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      _Component.RequiredQuantity,
      @Semantics.quantity.unitOfMeasure: 'BaseUnit'
      _Component.WithdrawnQuantity,

      _Order.MfgOrderPlannedStartDate,
      _Order.MfgOrderPlannedEndDate,
      _Order.MRPController,
      @UI.hidden: true
      @Semantics.amount.currencyCode: 'Currency'
      _Material.StandardPrice,
      @UI.hidden: true
      _Material.PriceUnitQty,
      @UI.hidden: true
      _Material.Currency,
      @UI.hidden: true
      _Material.BaseUnit,
      @UI.hidden: true
      _MfgOrderWithStatus.OrderIsClosed
}
