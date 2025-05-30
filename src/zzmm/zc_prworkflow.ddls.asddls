@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_PRWORKFLOW '
define root view entity ZC_PRWORKFLOW
  provider contract transactional_query
  as projection on ZR_PRWORKFLOW
{
      @ObjectModel.text.element: ['ApplyDepartText']
  key ApplyDepart,
  key PrNo,
  key UserZseq,
      UUID,
      @ObjectModel.text.element: ['PrTypeText']
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_WF_PrType_VH', element: 'Zvalue1' } }]
      PrType,
      PurchaseOrg,
      PurchaseGrp,
      PrBy,
      ApproveStatus,
      @ObjectModel.text.element: ['KyotenText']
      Kyoten,
      @Consumption.filter.selectionType: #INTERVAL
      ApplyDate,
      ApplyTime,
      Type,
      Message,
      WorkflowId,
      InstanceId,
      ApplicationId,
      EmailAddress,
      @UI.hidden: true
      @EndUserText.label: 'ステータステキスト'
      _ApprovalStatus.Zvalue2 as ApproveStatusText,
      @UI.hidden: true
      @EndUserText.label: '購買申請タイプテキスト'
      _PrType.Zvalue2         as PrTypeText,
      @UI.hidden: true
      @EndUserText.label: '依頼部署テキスト'
      _ApplyDepart.Zvalue2    as ApplyDepartText,
      @UI.hidden: true
      @EndUserText.label: '拠点テキスト'
      _Kyoten.Zvalue2         as KyotenText,

      @Consumption.filter.hidden: true
      _PurchasingGroup.PurchasingGroupName // ADD BY XINLEI XU 2025/05/07 CR#4359
}
