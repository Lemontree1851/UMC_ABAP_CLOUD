@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Workflow Approval Path'
define root view entity ZR_WF_ApprovalPath
  as select from ztbc_1008 as _ApprovalPath

  association [0..1] to ZC_WF_PrType_VH      as _PrType         on  $projection.PrType = _PrType.Zvalue1
  association [0..1] to ZC_WF_ApplyDepart_VH as _ApplyDepart    on  $projection.ApplyDepart = _ApplyDepart.Zvalue1
  association [0..1] to ZC_WF_OrderType_VH   as _OrderType      on  $projection.OrderType = _OrderType.Zvalue1
  association [0..1] to ZC_WF_BuyPurpose_VH  as _BuyPurpose     on  $projection.BuyPurpose = _BuyPurpose.Zvalue1
  association [0..1] to ZC_WF_Location_VH    as _Location       on  $projection.Location = _Location.Zvalue1
  association [0..1] to ZC_WF_KNTTP_VH       as _KNTTP          on  $projection.Knttp = _KNTTP.Zvalue1
  association [0..1] to I_CostCenterText     as _CostCenterText on  $projection.CostCenter            = _CostCenterText.CostCenter
                                                                and _CostCenterText.ControllingArea   = 'A000'
                                                                and _CostCenterText.Language          = $session.system_language
                                                                and _CostCenterText.ValidityStartDate <= $session.system_date
                                                                and _CostCenterText.ValidityEndDate   >= $session.system_date
  composition [0..*] of ZR_WF_ApprovalNode   as _ApprovalNode
{
  key workflow_id           as WorkflowId,
  key application_id        as ApplicationId,
      pr_type               as PrType,
      apply_depart          as ApplyDepart,
      order_type            as OrderType,
      buy_purpose           as BuyPurpose,
      location              as Location,
      knttp                 as Knttp,
      cost_center           as CostCenter,
      amount_from           as AmountFrom,
      amount_to             as AmountTo,
      @Semantics.user.createdBy: true
      created_by            as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at            as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by       as LastChangedBy,
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at       as LastChangedAt,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      _ApprovalNode,

      _PrType,
      _ApplyDepart,
      _OrderType,
      _BuyPurpose,
      _Location,
      _KNTTP,
      _CostCenterText
}
