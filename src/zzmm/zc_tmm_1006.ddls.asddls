@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TMM_1006'
define root view entity ZC_TMM_1006
  provider contract transactional_query
  as projection on ZR_TMM_1006
{
  key UUID,
      ApplyDepart,
      PrNo,
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
      @Consumption.filter.hidden: true
      Unit,
      Price,
      @Consumption.filter.hidden: true
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
      @Consumption.filter.hidden: true
      @UI.hidden: true
      DocumentInfoRecordDocType,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      DocumentInfoRecordDocNumber,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      DocumentInfoRecordDocVersion,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      DocumentInfoRecordDocPart,
      ApplyDate,
      ApplyTime,
      CreatedAt,
      @Consumption.filter.hidden: true
      Type,
      @Consumption.filter.hidden: true
      ResultText,
      @Consumption.filter.hidden: true
      Message,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      LocalCreatedBy,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      LocalCreatedAt,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      LocalLastChangedBy,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      LocalLastChangedAt,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      LatCahangedAt
}
