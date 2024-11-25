@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOW '
define root view entity ZC_PRWORKFLOW
  provider contract transactional_query
  as projection on ZR_PRWORKFLOW
{
        @ObjectModel.text.element: ['ApplyDepartText']
  key   ApplyDepart,
  key   PrNo,
  key   UserZseq,
        UUID,
        //PrItem,
        @ObjectModel.text.element: ['PrTypeText']
        PrType,
        //@ObjectModel.text.element: ['OrderTypeText']
        //OrderType,
        //Supplier,
        //CompanyCode,
        PurchaseOrg,
        PurchaseGrp,
        //Plant,
        //Currency,
        //ItemCategory,
        //@ObjectModel.text.element: ['KnttpText']
        //AccountType,
        //MatID,
        //MatDesc,
        //MaterialGroup,
        //Quantity,
        //Unit,
        //Price,
        //UnitPrice,
        //DeliveryDate,
        //Location,
        //ReturnItem,
        //Free,
        //GlAccount,
        //@ObjectModel.text.element: ['CostCenterName']
        //CostCenter,
        //WbsElemnt,
        //AssetNo,
        //Tax,
        //ItemText,
        PrBy,
        //TrackNo,
        //Ean,
        //CustomerRec,
        //AssetOri,
        //MemoText,
        //@ObjectModel.text.element: ['BuyPurposeText']
        //BuyPurpoose,
        //IsLink,
        ///@ObjectModel.text.element: ['ApproveStatusText']
        ApproveStatus,
        //PurchaseOrder,
        //PurchaseOrderItem,
        @ObjectModel.text.element: ['KyotenText']
        Kyoten,
        //IsApprove,
        //DocumentInfoRecordDocType,
        //DocumentInfoRecordDocNumber,
        //DocumentInfoRecordDocVersion,
        //DocumentInfoRecordDocPart,
        ApplyDate,
        ApplyTime,
        //CreatedAt,
        Type,
        //ResultText,
        Message,
        //LocalCreatedBy,
        //LocalCreatedAt,
        //LocalLastChangedBy,
        //LocalLastChangedAt,
        //LatCahangedAt,
        WorkflowId,
        InstanceId,
        ApplicationId,
        EmailAddress,
        @UI.hidden: true
        @EndUserText.label        : 'ステータステキスト'
        _ApprovalStatus.Zvalue2 as ApproveStatusText,
        @UI.hidden: true
        @EndUserText.label        : '購買申請タイプテキスト'
        _PrType.Zvalue2      as PrTypeText,
        @UI.hidden: true
        @EndUserText.label        : '依頼部署テキスト'
        _ApplyDepart.Zvalue2 as ApplyDepartText,
        //@UI.hidden: true
        //_OrderType.Zvalue2   as OrderTypeText,
        //@UI.hidden: true
       // _BuyPurpose.Zvalue2  as BuyPurposeText,
        @UI.hidden: true
        @EndUserText.label        : '拠点テキスト'
        _Kyoten.Zvalue2      as KyotenText
        //@UI.hidden: true
        //_KNTTP.Zvalue2       as KnttpText
        //@UI.hidden: true
        //_CostCenterText.CostCenterName
}
