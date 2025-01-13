@EndUserText.label: 'Material Stock Value Help'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_MaterialStockVH
  provider contract transactional_query
  as projection on ZR_MaterialStockVH
{
  key     Material,
  key     Plant,
  key     StorageLocation,
          StorageLocationName,
          @Semantics.quantity.unitOfMeasure: 'MaterialBaseUnit'
          StockQuantity,
          MaterialBaseUnit,
          InventorySpecialStockType,

          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_UWMS_MCARD'
          @Semantics.quantity.unitOfMeasure : 'MaterialBaseUnit'
  virtual M_CARD_Quantity : menge_d,
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_GET_UWMS_MCARD'
  virtual M_CARD          : maktx
}
