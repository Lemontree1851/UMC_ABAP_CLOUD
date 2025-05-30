@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOWLINK '
define root view entity ZC_PRWORKFLOWLINK
  provider contract transactional_query
  as projection on ZR_PRWORKFLOWLINK
{
  key UUID,
      ApplyDepart,
      PrNo,
      PrItem,
      @ObjectModel.text.element: ['PrTypeText']
      PrType,
      OrderType,
      Supplier,
      CompanyCode,
      PurchaseOrg,
      @ObjectModel.text.element: ['PurchasingGroupName']
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
      @ObjectModel.text.element: ['KyotenText']
      Kyoten,
      IsApprove,
      DocumentInfoRecordDocType,
      DocumentInfoRecordDocNumber,
      DocumentInfoRecordDocVersion,
      DocumentInfoRecordDocPart,
      ApplyDate,
      ApplyTime,
      CreatedAt,
      LocalCreatedBy,
      LocalCreatedAt,
      LocalLastChangedBy,
      LocalLastChangedAt,
      LatCahangedAt,
      AmountSum,
      WorkflowId,
      InstanceId,
      ApplicationId,
      @UI.hidden: true
      _PrType.Zvalue2 as PrTypeText,
      @UI.hidden: true
      _Kyoten.Zvalue2 as KyotenText,
      @UI.hidden: true
      _PurchasingGroup.PurchasingGroupName, // ADD BY XINLEI XU 2025/05/07 CR#4359

      _Attachment
}
