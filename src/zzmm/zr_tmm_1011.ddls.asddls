@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_TMM_1011
  as select from ztmm_1011
{
  key uuid                          as Uuid,
      document_date                 as DocumentDate,
      posting_date                  as PostingDate,
      material_document_header_text as MaterialDocumentHeaderText,
      purchase_order                as PurchaseOrder,
      purchase_order_item           as PurchaseOrderItem,
      order_key as OrderKey,
      inventory_transaction_type    as InventoryTransactionType,
      goods_movement_type           as GoodsMovementType,
      goods_movement_code           as GoodsMovementCode,
      @Semantics.quantity.unitOfMeasure : 'EntryUnit'
      quantity_in_entry_unit        as QuantityInEntryUnit,
      entry_unit                    as EntryUnit,
      material                      as Material,
      plant                         as Plant,
      storage_location              as StorageLocation,
      batch                         as Batch,
      material_document             as MaterialDocument,
      material_document_year        as MaterialDocumentYear,
      material_document_item        as MaterialDocumentItem,
      status                        as Status,
      message                       as Message,
      @Semantics.user.createdBy: true
      created_by                    as CreatedBy,  
      @Semantics.systemDateTime.createdAt: true
      created_at                    as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by               as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at               as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at         as LocalLastChangedAt

}
