@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOWITEM '
define root view entity ZC_PRWORKFLOWITEM
  provider contract transactional_query
  as projection on ZR_PRWORKFLOWITEM
{
  key UUID,
      @EndUserText.label        : 'ステータス'
      ApplyDepart,
      PrNo,
      PrItem,
      //PrType,
      //OrderType,
      Supplier,
      //CompanyCode,
      //PurchaseOrg,
      //PurchaseGrp,
      //Plant,
      Currency,
      //ItemCategory,
      //AccountType,
      MatID,
      MatDesc,
      MaterialGroup,
      Quantity,
      Unit,
      Price,
      UnitPrice,
      DeliveryDate,
      Location,
      //ReturnItem,
      //Free,
      GlAccount,
      CostCenter,
      WbsElemnt,
      AssetNo,
      Tax,
      ItemText,
      //PrBy,
      //TrackNo,
      Ean,
      CustomerRec,
      AssetOri,
      MemoText,
 
      BuyPurpoose,
      //IsLink,
      //ApproveStatus,
      //PurchaseOrder,
      //PurchaseOrderItem,
      //Kyoten,
      //IsApprove,
      //DocumentInfoRecordDocType,
      //DocumentInfoRecordDocNumber,
      //DocumentInfoRecordDocVersion,
      //DocumentInfoRecordDocPart,

      //ApplyDate,
      //ApplyTime,
      //CreatedAt,
      //Type,
      //ResultText,
      //Message,
      //LocalCreatedBy,
      //LocalCreatedAt,
      //LocalLastChangedBy,
      //LocalLastChangedAt,
      //LatCahangedAt,
      @EndUserText.label        : '購入目的テキスト'
      @Consumption.filter.hidden: true
      BuyPurposeText,
      amount1
}
