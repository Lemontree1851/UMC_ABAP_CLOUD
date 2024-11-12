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
      @ObjectModel.text.element: ['LocationText']
      Location,
      @ObjectModel.text.element: ['KnttpText']
      Knttp,
      @ObjectModel.text.element: ['CostCenterName']
      CostCenter,
      AmountFrom,
      AmountTo,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,

      _PrType.Zvalue2      as PrTypeText,
      _ApplyDepart.Zvalue2 as ApplyDepartText,
      _OrderType.Zvalue2   as OrderTypeText,
      _BuyPurpose.Zvalue2  as BuyPurposeText,
      _Location.Zvalue2    as LocationText,
      _KNTTP.Zvalue2       as KnttpText,
      _CostCenterText.CostCenterName,

      /* Associations */
      _ApprovalNode : redirected to composition child ZC_WF_ApprovalNode
}
