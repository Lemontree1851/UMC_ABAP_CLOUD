@VDM.viewType: #COMPOSITE

@ObjectModel: {
  dataCategory : #VALUE_HELP,
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

@Metadata.ignorePropagatedAnnotations: true

@EndUserText.label: 'Material Stock Value Help'
define root view entity ZR_MaterialStockVH
  as select from I_MaterialStock_2
{
  key Material,
  key Plant,
  key StorageLocation,
      _StorageLocation.StorageLocationName,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( MatlWrhsStkQtyInMatlBaseUnit ) as StockQuantity,
      MaterialBaseUnit
}
where
      StorageLocation           is not initial
  and InventoryStockType        = '01'
  and InventorySpecialStockType = ''
group by
  Material,
  Plant,
  StorageLocation,
  _StorageLocation.StorageLocationName,
  MaterialBaseUnit
