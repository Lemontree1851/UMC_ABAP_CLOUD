@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_TMM_1006'
define root view entity ZC_TMM_1006
  provider contract transactional_query
  as projection on ZR_TMM_1006
{
  key UUID,
      @ObjectModel.text.element: [ 'ApplyDepartText' ]
      @Consumption.filter.hidden: true
      ApplyDepart,
      PrNo,
      @Consumption.filter.hidden: true
      PrItem,
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: [ 'PrTypeText' ]
      PrType,
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: [ 'OrderTypeText' ]
      OrderType,
      Supplier,
      @Consumption.filter.hidden: true
      CompanyCode,
      @Consumption.filter.hidden: true
      PurchaseOrg,
      PurchaseGrp,
      Plant,
      @Consumption.filter.hidden: true
      Currency,
      @Consumption.filter.hidden: true
      ItemCategory,
      @Consumption.filter.hidden: true
      AccountType,
      MatID,
      @Consumption.filter.hidden: true
      MatDesc,
      @Consumption.filter.hidden: true
      MaterialGroup,
      @Consumption.filter.hidden: true
      Quantity,
      @Consumption.filter.hidden: true
      Unit,
      @Consumption.filter.hidden: true
      Price,
      @Consumption.filter.hidden: true
      UnitPrice,
      @Consumption.filter.hidden: true
      DeliveryDate,
      @Consumption.filter.hidden: true
      Location,
      @Consumption.filter.hidden: true
      ReturnItem,
      @Consumption.filter.hidden: true
      Free,
      @Consumption.filter.hidden: true
      GlAccount,
      CostCenter,
      WbsElemnt,
      @EndUserText.label: '指図'
      OrderId,
      AssetNo,
      @Consumption.filter.hidden: true
      Tax,
      @Consumption.filter.hidden: true
      ItemText,
      PrBy,
      @Consumption.filter.hidden: true
      TrackNo,
      @Consumption.filter.hidden: true
      Ean,
      @Consumption.filter.hidden: true
      CustomerRec,
      @Consumption.filter.hidden: true
      AssetOri,
      @Consumption.filter.hidden: true
      MemoText,
      @Consumption.filter.hidden: true
      @ObjectModel.text.element: [ 'BuyPurposeText' ]
      BuyPurpoose,
      @Consumption.filter.hidden: true
      IsLink,
      @ObjectModel.text.element: [ 'ApproveStatusText' ]
      ApproveStatus,
      @Consumption.filter.hidden: true
      PurchaseOrder,
      @Consumption.filter.hidden: true
      PurchaseOrderItem,
      @ObjectModel.text.element: [ 'KyotenText' ]
      Kyoten,
      @Consumption.filter.hidden: true
      IsApprove,
      SupplierMat,
      @Consumption.filter.hidden: true
      PolinkBy,
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
      @Consumption.filter.hidden: true
      ApplyDate,
      @Consumption.filter.hidden: true
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
      LatCahangedAt,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      WorkflowId,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      InstanceId,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      ApplicationId,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      ApplyDepartText,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      PrTypeText,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      OrderTypeText,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      BuyPurposeText,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      KyotenText,
      @Consumption.filter.hidden: true
      @UI.hidden: true
      ApproveStatusText,
      
      _Attachment
}
