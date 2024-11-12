@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
@AccessControl.authorizationCheck: #CHECK
define root view entity ZC_TMM_1011
  provider contract transactional_query
  as projection on ZR_TMM_1011
{
  key Uuid,
      DocumentDate,
      PostingDate,
      MaterialDocumentHeaderText,
      PurchaseOrder,
      PurchaseOrderItem,
      OrderKey,
      InventoryTransactionType,
      GoodsMovementType,
      GoodsMovementCode,
      @Semantics.quantity.unitOfMeasure : 'EntryUnit'
      QuantityInEntryUnit,
      EntryUnit,
      Material,
      Plant,
      StorageLocation,
      Batch,
      MaterialDocument,
      MaterialDocumentYear,
      MaterialDocumentItem,
      Status,
      Message,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt

}
