@EndUserText.label: 'Workflow Approval Path'
@Metadata.allowExtensions: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZC_WF_ApprovalPath
  provider contract transactional_query
  as projection on ZR_WF_ApprovalPath
{
  key WorkflowId,
  key ApplicationId,
      @ObjectModel.text.element: ['PrTypeText']
      PrType,
      @ObjectModel.text.element: ['ApplyDepartText']
      ApplyDepart,
      @ObjectModel.text.element: ['OrderTypeText']
      OrderType,
      @ObjectModel.text.element: ['BuyPurposeText']
      BuyPurpose,
      @ObjectModel.text.element: ['KyotenText']
      Kyoten,
      @ObjectModel.text.element: ['KnttpText']
      Knttp,
      @ObjectModel.text.element: ['CostCenterName']
      CostCenter,
      @ObjectModel.text.element: ['PurchasingGroupName']
      PurchaseGroup,
      AmountFrom,
      AmountTo,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      @UI.hidden: true
      _PrType.Zvalue2      as PrTypeText,
      @UI.hidden: true
      _ApplyDepart.Zvalue2 as ApplyDepartText,
      @UI.hidden: true
      _OrderType.Zvalue2   as OrderTypeText,
      @UI.hidden: true
      _BuyPurpose.Zvalue2  as BuyPurposeText,
      @UI.hidden: true
      _Kyoten.Zvalue2      as KyotenText,
      @UI.hidden: true
      _KNTTP.Zvalue2       as KnttpText,
      @UI.hidden: true
      _CostCenterText.CostCenterName,
      @UI.hidden: true
      _PurchasingGroup.PurchasingGroupName,

      /* Associations */
      _ApprovalNode : redirected to composition child ZC_WF_ApprovalNode
}
