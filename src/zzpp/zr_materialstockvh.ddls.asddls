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
  as select from    I_ProductStorageLocationBasic as _Basic
    left outer join I_MaterialStock_2             as _Stock on  _Stock.Material        = _Basic.Product
                                                            and _Stock.Plant           = _Basic.Plant
                                                            and _Stock.StorageLocation = _Basic.StorageLocation
{
  key _Basic.Product                             as Material,
  key _Basic.Plant,
  key _Basic.StorageLocation,
      _Basic._StorageLocation.StorageLocationName,
      @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
      sum( _Stock.MatlWrhsStkQtyInMatlBaseUnit ) as StockQuantity,
      _Basic._Product.BaseUnit                   as MaterialBaseUnit
}
where
       _Basic.StorageLocation           is not initial
  and  _Basic.IsMarkedForDeletion       <> 'X'
  and  _Basic.IsActiveEntity            =  'X'
  and(
       _Stock.InventoryStockType        =  '01'
    or _Stock.InventoryStockType        is null
  )
  and(
       _Stock.InventorySpecialStockType =  ''
    or _Stock.InventorySpecialStockType is null
  )
group by
  _Basic.Product,
  _Basic.Plant,
  _Basic.StorageLocation,
  _Basic._StorageLocation.StorageLocationName,
  _Basic._Product.BaseUnit
