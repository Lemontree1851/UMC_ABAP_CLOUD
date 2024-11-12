@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Material Requisition'
@ObjectModel.semanticKey: [ 'MaterialRequisitionNo', 'ItemNo' ]
define root view entity ZC_MATERIALREQUISITION
  provider contract transactional_query
  as projection on ZR_MATERIALREQUISITION
{
  key MaterialRequisitionNo,
  key ItemNo,
      @ObjectModel.text.element: ['TypeText']
      Type,
      @ObjectModel.text.element: ['MRStatusText']
      MRStatus,
      @ObjectModel.text.element: ['PlantName']
      Plant,
      @ObjectModel.text.element: ['CostCenterName']
      CostCenter,
      @ObjectModel.text.element: ['CustomerName']
      Customer,
      Receiver,
      @ObjectModel.text.element: ['LineWarehouseStatusText']
      LineWarehouseStatus,
      RequisitionDate,
      HeaderDeleteFlag,

      LastApprovedDate,
      LastApprovedTime,
      @ObjectModel.text.element: ['LastApprovedByUserName']
      LastApprovedByUser,
      @UI.hidden: true
      LastApprovedByUserName,

      HeaderCreatedDate,
      HeaderCreatedTime,
      HeaderCreatedByUser,
      HeaderCreatedByUserName,
      HeaderLastChangedDate,
      HeaderLastChangedTime,
      HeaderLastChangedByUser,
      HeaderLastChangedByUserName,

      ManufacturingOrder,
      @ObjectModel.text.element: ['ProductDescription']
      Product,
      @ObjectModel.text.element: ['MaterialDescription']
      Material,
      @ObjectModel.text.element: ['StorageLocationName']
      StorageLocation,
      BaseUnit,
      Quantity,
      Location,
      @ObjectModel.text.element: ['ReasonText']
      Reason,
      Remark,
      @ObjectModel.text.element: ['PostingStatusText']
      PostingStatus,
      GoodsMovementType,
      MaterialDocument,
      PostingDate,
      PostingTime,
      @ObjectModel.text.element: ['PostingByUserName']
      PostingByUser,
      @UI.hidden: true
      PostingByUserName,
      CancelMaterialDocument,
      @ObjectModel.text.element: ['CancelledByUserName']
      CancelledByUser,
      @UI.hidden: true
      CancelledByUserName,
      @ObjectModel.text.element: ['UWMS_PostStatusText']
      UWMS_PostStatus,
      @ObjectModel.text.element: ['DeleteFlagText']
      ItemDeleteFlag,
      @ObjectModel.text.element: ['OrderStatusText']
      OrderIsClosed,
      StandardPrice,
      PriceUnitQty,
      TotalAmount,
      Currency,

      ItemCreatedDate,
      ItemCreatedTime,
      @ObjectModel.text.element: ['ItemCreatedByUserName']
      ItemCreatedByUser,
      @UI.hidden: true
      ItemCreatedByUserName,
      ItemLastChangedDate,
      ItemLastChangedTime,
      @ObjectModel.text.element: ['ItemLastChangedByUserName']
      ItemLastChangedByUser,
      @UI.hidden: true
      ItemLastChangedByUserName,

      @UI.hidden: true
      HeaderLocalLastChangedAt,
      @UI.hidden: true
      ItemLocalLastChangedAt,
      @UI.hidden: true
      _Plant.PlantName,
      @UI.hidden: true
      _CostCenterText.CostCenterName,
      @UI.hidden: true
      _ProductDescription.MaterialDescription as ProductDescription,
      @UI.hidden: true
      _MaterialDescription.MaterialDescription,
      @UI.hidden: true
      _Customer.CustomerName,
      @UI.hidden: true
      _StorageLocation.StorageLocationName,

      @UI.hidden: true
      _TypeText.Zvalue2                       as TypeText,
      @UI.hidden: true
      _MRStatusText.Zvalue2                   as MRStatusText,
      @UI.hidden: true
      _OrderStatusText.Zvalue2                as OrderStatusText,
      @UI.hidden: true
      _PostingStatusText.Zvalue2              as PostingStatusText,
      @UI.hidden: true
      _LineWarehouseStatusText.Zvalue2        as LineWarehouseStatusText,
      @UI.hidden: true
      UWMS_PostStatusText,
      @UI.hidden: true
      _DeleteFlagText.Zvalue2                 as DeleteFlagText,
      @UI.hidden: true
      _ReasonText.Zvalue2                     as ReasonText,

      Criticality
}
