@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOW '
define root view entity ZC_PRWORKFLOW 
  provider contract transactional_query
  as projection on ZR_PRWORKFLOW 
{

   key   ApplyDepart,
   key   PrNo,
      UUID,
      PrItem,
      PrType,
      OrderType,
      Supplier,
      CompanyCode,
      PurchaseOrg,
      PurchaseGrp,
      Plant,
      Currency,
      ItemCategory,
      AccountType,
      MatID,
      MatDesc,
      MaterialGroup,
      Quantity,
      Unit,
      Price,
      UnitPrice,
      DeliveryDate,
      Location,
      ReturnItem,
      Free,
      GlAccount,
      CostCenter,
      WbsElemnt,
      AssetNo,
      Tax,
      ItemText,
      PrBy,
      TrackNo,
      Ean,
      CustomerRec,
      AssetOri,
      MemoText,
      BuyPurpoose,
      IsLink,
      ApproveStatus,
      PurchaseOrder,
      PurchaseOrderItem,
      Kyoten,
      IsApprove,
      DocumentInfoRecordDocType,
      DocumentInfoRecordDocNumber,
      DocumentInfoRecordDocVersion,
      DocumentInfoRecordDocPart,
      ApplyDate,
      ApplyTime,
      CreatedAt,
      Type,
      ResultText,
      Message,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LatCahangedAt
}
